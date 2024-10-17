Invoke-WebRequest -Uri 'http://127.0.0.1:5882/form_data/' -Method POST -Body @{ username='bob'; password='4321' }
Invoke-WebRequest -Uri 'http://127.0.0.1:5882/form_data/' -Method POST -Body @{ name='bob'; username='bob'; password='4321'; email='bob@example.com' }
Invoke-WebRequest -Uri 'http://localhost:5882/form_data/' -Method POST -Body @{ name='bob'; username='bob'; password='4321'; email='bob@example.com' }
Invoke-WebRequest -Uri 'http://127.0.0.1:5882/form_data' -Method POST -Body @{ username='bob'; password='4321' }

Invoke-WebRequest -Uri 'http://127.0.0.1:5882/arena/?name=bob' -Method POST
