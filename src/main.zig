const std = @import("std");
const httpz = @import("httpz");
const Logger = @import("middleware/Logger.zig");

const websocket = httpz.websocket;

const PORT = 5882;

pub const std_options = .{ .log_scope_levels = &[_]std.log.ScopeLevel{
    .{ .scope = .websocket, .level = .err },
} };

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    var default_handler = Handler{
        .log = true,
    };

    var nolog_handler = Handler{
        .log = false,
    };

    var server = try httpz.Server(*Handler).init(allocator, .{
        .port = PORT,
        .request = .{
            .max_form_count = 20,
        },
    }, &default_handler);

    defer {
        server.deinit();
        server.stop();
    }

    const logger = try server.middleware(Logger, .{ .query = true });

    var router = server.router(.{});

    router.middlewares = &.{logger};

    const restricted_route = &RouteData{ .restricted = true };

    router.get("/", index, .{});
    router.get("/user/:name", getUser, .{});
    router.get("/hello", hello, .{});
    router.get("/form_data/", formShow, .{});
    router.post("/form_data/", formPost, .{});
    router.get("/image_form_data/", imageFormShow, .{});
    router.post("/image_form_data/", imageFormPost, .{});
    router.post("/arena/", arenaExample, .{});
    router.get("/hits", hits, .{});
    router.get("/error", @"error", .{});
    router.get("/admin", admin, .{ .data = restricted_route });
    router.get("/other", other, .{ .middlewares = &.{} });
    router.get("/page1", page1, .{ .dispatcher = Handler.infoDispatch });
    router.get("/page2", page2, .{ .handler = &nolog_handler });
    router.get("/ws", ws, .{});

    std.debug.print("listening http://127.0.0.1:{d}/\n", .{PORT});

    // blocking
    try server.listen();
}

const index_page =
    \\<!DOCTYPE html>
    \\ <ul>
    \\ <li><a href="/hello?name=Teg">Querystring + text output</a>
    \\ <li><a href="/writer/hello/Ghanima">Path parameter + serialize json object</a>
    \\ <li><a href="/json/hello/Duncan">Path parameter + json writer</a>
    \\ <li><a href="/metrics">Internal metrics</a>
    \\ <li><a href="/form_data">Form Data</a>
    \\ <li><a href="/image_form_data">Image Form Data</a>
    \\ <li><a href="/explicit_write">Explicit Write</a>
    \\ <li><a href="/hits">Shared global hit counter</a>
    \\ <li><a href="/not_found">Custom not found handler</a>
    \\ <li><a href="/error">Custom error handler</a>
    \\ <li><a href="/page1">page with custom dispatch</a>
    \\ <li><a href="/page2">page with custom handler</a>
    \\ </ul>
    \\ <p>Copy and paste the following in your browser console to have the server echo back:</p>
    \\ <pre>ws.send("hello from the client!");</pre>
    \\ <script>
    \\ const ws = new WebSocket("ws://localhost:5882/ws");
    \\ ws.addEventListener("message", (event) => { console.log("from server: ", event.data) });
    \\ </script>
;

fn index(_: *Env, _: *httpz.Request, res: *httpz.Response) !void {
    res.content_type = .HTML;
    res.body = index_page;
}

fn ws(_: *Env, req: *httpz.Request, res: *httpz.Response) !void {
    const ctx = Client.Context{ .user_id = 9001 };

    if (try httpz.upgradeWebsocket(Client, req, res, &ctx) == false) {
        res.status = 500;
        res.body = "invalid websocket";
    }
}

fn getUser(_: *Env, req: *httpz.Request, res: *httpz.Response) !void {
    res.status = 200;
    try res.json(.{ .id = req.param("id").?, .name = "Teg" }, .{});
}

fn hello(_: *Env, req: *httpz.Request, res: *httpz.Response) !void {
    const query = try req.query();
    const name = query.get("name") orelse "stranger";

    res.status = 200;
    res.body = try std.fmt.allocPrint(res.arena, "Hello {s}", .{name});
}

fn formShow(_: *Env, _: *httpz.Request, res: *httpz.Response) !void {
    res.body =
        \\ <html>
        \\ <form method=post enctype="multipart/form-data">
        \\    <p><input name=name value=goku></p>
        \\    <p><input name=password value=9001></p>
        \\    <p>Image: <input name=image type=file accept="image/*"></p>
        \\    <p>Video: <input name=video type=file accept="video/*"></p>
        \\    <p>Audio: <input name=audio type=file accept="audio/*"></p>
        \\    <p>Files: <input type="file" id="files" name="files" multiple /></p>
        \\    <p><input type=submit value=submit></p>
        \\ </form>
    ;
}

fn imageFormShow(_: *Env, _: *httpz.Request, res: *httpz.Response) !void {
    res.body =
        \\ <html>
        \\ <form method=post>
        \\    <p>Image: <input name=image type=file accept="image/*"></p>
        \\    <p><input type=submit value=submit></p>
        \\ </form>
    ;
}

fn formPost(_: *Env, req: *httpz.Request, res: *httpz.Response) !void {
    const w = res.writer();

    std.debug.print("Received file:\n", .{});

    const form_data = try req.multiFormData();
    var it = form_data.iterator();

    while (it.next()) |kv| {
        std.debug.print("it.next() \n", .{});

        const key = kv.key;
        const value = kv.value.value;
        const filename = kv.value.filename orelse "(no file)";

        try std.fmt.format(w, "file - name - value: {s} - {s} - {s} \n", .{ filename, key, value });
        if (std.mem.eql(u8, filename, "(no file)")) {
            const file = try std.fs.cwd().createFile(filename, .{});
            defer file.close();
            try file.writeAll(value);
        }
    }

    res.status = 200;
    try res.json(.{ .message = "File uploaded successfully!" }, .{});
}

pub fn imageFormPost(_: *Env, req: *httpz.Request, res: *httpz.Response) !void {
    var it = (try req.formData()).iterator();

    const w = res.writer();
    while (it.next()) |kv| {
        if (std.mem.eql(u8, kv.key, "image")) {
            const imageData = kv.value;

            try w.print("Received file data: {s}\n", .{imageData});
        } else {
            try w.print("{s} = {s}\n", .{ kv.key, kv.value });
        }
    }

    res.status = 200;
    try res.json(.{ .message = "File uploaded successfully!" }, .{});
}

fn arenaExample(_: *Env, req: *httpz.Request, res: *httpz.Response) !void {
    const query = try req.query();
    const name = query.get("name") orelse "stranger";
    res.body = try std.fmt.allocPrint(res.arena, "Hello {s}", .{name});
}

const Handler = struct {
    _hits: usize = 0,
    log: bool,

    pub const WebsocketHandler = Client;

    pub fn notFound(_: *Handler, _: *httpz.Request, res: *httpz.Response) !void {
        res.status = 404;
        res.body = "Not Found";
    }

    pub fn uncaughtError(_: *Handler, req: *httpz.Request, res: *httpz.Response, err: anyerror) void {
        std.debug.print("uncaught http error at {s}: {}\n", .{ req.url.path, err });

        res.headers.add("content-type", "text/html; charset=utf-8");

        res.status = 505;
        res.body = "<!DOCTYPE html>(╯°□°)╯︵ ┻━┻";
    }

    pub fn infoDispatch(h: *Handler, action: httpz.Action(*Env), req: *httpz.Request, res: *httpz.Response) !void {
        const user = (try req.query()).get("auth");

        var env = Env{
            .user = user,
            .handler = h,
        };

        return action(&env, req, res);
    }

    pub fn dispatch(self: *Handler, action: httpz.Action(*Env), req: *httpz.Request, res: *httpz.Response) !void {
        const user = (try req.query()).get("auth");

        if (req.route_data) |rd| {
            const route_data: *const RouteData = @ptrCast(@alignCast(rd));
            if (route_data.restricted and (user == null or user.?.len == 0)) {
                res.status = 401;
                res.body = "permission denied";
                return;
            }
        }

        var env = Env{
            .user = user, // todo: this is not very good security!
            .handler = self,
        };

        var start = try std.time.Timer.start();

        try action(&env, req, res);

        if (self.log) {
            std.debug.print("ts={d} path={s} status={d}\n", .{ std.time.timestamp(), req.url.path, res.status });
        }

        std.debug.print("ts={d} us={d} path={s}\n", .{ std.time.timestamp(), start.lap() / 1000, req.url.path });
    }
};

const Client = struct {
    user_id: u32,
    conn: *websocket.Conn,

    const Context = struct {
        user_id: u32,
    };

    pub fn init(conn: *websocket.Conn, ctx: *const Context) !Client {
        return .{
            .conn = conn,
            .user_id = ctx.user_id,
        };
    }

    pub fn afterInit(self: *Client) !void {
        return self.conn.write("welcome!");
    }

    pub fn clientMessage(self: *Client, data: []const u8) !void {
        return self.conn.write(data);
    }
};

pub fn page1(_: *Env, _: *httpz.Request, res: *httpz.Response) !void {
    res.body =
        \\ Accessing this endpoint will NOT generate a log line in the console,
        \\ because a custom dispatch method is used
    ;
}

pub fn page2(_: *Env, _: *httpz.Request, res: *httpz.Response) !void {
    res.body =
        \\ Accessing this endpoint will NOT generate a log line in the console,
        \\ because a custom handler method is used
    ;
}

pub fn hits(h: *Env, _: *httpz.Request, res: *httpz.Response) !void {
    const count = @atomicRmw(usize, &h.handler._hits, .Add, 1, .monotonic);

    return res.json(.{ .hits = count + 1 }, .{});
}

fn @"error"(_: *Env, _: *httpz.Request, _: *httpz.Response) !void {
    return error.ActionError;
}

fn errorHandler(_: *Env, req: *httpz.Request, res: *httpz.Response, err: anyerror) void {
    res.status = 500;
    res.body = "Internal Server Error";
    std.log.warn("httpz: unhandled exception for request: {s}\nErr: {}", .{ req.url.raw, err });
}

const RouteData = struct {
    restricted: bool,
};

const Env = struct {
    handler: *Handler,
    user: ?[]const u8,
};

fn admin(env: *Env, _: *httpz.Request, res: *httpz.Response) !void {
    res.body = try std.fmt.allocPrint(res.arena, "Welcome to the admin portal, {s}", .{env.user.?});
}

fn other(_: *Env, _: *httpz.Request, res: *httpz.Response) !void {
    res.body =
        \\ Accessing this endpoint will NOT generate a log line in the console,
        \\ because the Logger middleware is disabled.
    ;
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // Try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}

test "fuzz example" {
    const global = struct {
        fn testOne(input: []const u8) anyerror!void {
            // Try passing `--fuzz` to `zig build test` and see if it manages to fail this test case!
            try std.testing.expect(!std.mem.eql(u8, "canyoufindme", input));
        }
    };
    try std.testing.fuzz(global.testOne, .{});
}
