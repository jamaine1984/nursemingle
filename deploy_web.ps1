# Nurse Mingle Web Deployment Script (Windows)
Write-Host "🚀 Preparing Nurse Mingle Web Frontend for deployment..." -ForegroundColor Green

# Check if web build exists
if (!(Test-Path "build/web")) {
    Write-Host "❌ Web build not found. Run 'flutter build web --release' first." -ForegroundColor Red
    exit 1
}

# Create deployment package
Write-Host "📦 Creating deployment package..." -ForegroundColor Yellow
$deployDir = "deployment"
if (Test-Path $deployDir) {
    Remove-Item -Recurse -Force $deployDir
}
New-Item -ItemType Directory -Path $deployDir

# Copy web files
Copy-Item -Recurse "build/web/*" "$deployDir/web/"

# Create NGINX configuration file
Write-Host "⚙️  Creating NGINX configuration..." -ForegroundColor Yellow
$nginxConfig = @"
server {
    listen 80;
    server_name nurse-mingle.com www.nurse-mingle.com;
    return 301 https://`$server_name`$request_uri;
}

server {
    listen 443 ssl http2;
    server_name nurse-mingle.com www.nurse-mingle.com;
    
    # Web frontend root
    root /var/www/nurse-mingle-web;
    index index.html;
    
    # SSL configuration
    ssl_certificate /etc/letsencrypt/live/nurse-mingle.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/nurse-mingle.com/privkey.pem;
    
    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;
    
    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_proxied expired no-cache no-store private must-revalidate auth;
    gzip_types text/plain text/css text/xml text/javascript application/x-javascript application/xml+rss application/javascript application/json;
    
    # API proxy to backend
    location /api/ {
        proxy_pass http://localhost:3000/api/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade `$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host `$host;
        proxy_set_header X-Real-IP `$remote_addr;
        proxy_set_header X-Forwarded-For `$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto `$scheme;
        proxy_cache_bypass `$http_upgrade;
        proxy_read_timeout 86400;
    }
    
    # Flutter web app - serve index.html for all routes
    location / {
        try_files `$uri `$uri/ /index.html;
        
        # Cache static assets
        location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)`$ {
            expires 1y;
            add_header Cache-Control "public, immutable";
        }
    }
    
    # Specific handling for Flutter service worker
    location /flutter_service_worker.js {
        add_header Cache-Control "no-cache";
        try_files `$uri =404;
    }
    
    # Handle manifest.json
    location /manifest.json {
        add_header Content-Type application/manifest+json;
        try_files `$uri =404;
    }
}
"@

$nginxConfig | Out-File -FilePath "$deployDir/nurse-mingle.com.nginx" -Encoding UTF8

# Create server deployment script
$serverScript = @"
#!/bin/bash

# Server deployment script for Nurse Mingle
echo "🚀 Deploying Nurse Mingle Web Frontend on server..."

# Create web directory
sudo mkdir -p /var/www/nurse-mingle-web

# Copy web files
sudo cp -r web/* /var/www/nurse-mingle-web/

# Set permissions
sudo chown -R www-data:www-data /var/www/nurse-mingle-web
sudo chmod -R 755 /var/www/nurse-mingle-web

# Install NGINX config
sudo cp nurse-mingle.com.nginx /etc/nginx/sites-available/nurse-mingle.com
sudo ln -sf /etc/nginx/sites-available/nurse-mingle.com /etc/nginx/sites-enabled/

# Test and reload NGINX
sudo nginx -t && sudo systemctl reload nginx

echo "✅ Deployment complete!"
echo "🌐 Visit: https://nurse-mingle.com"
"@

$serverScript | Out-File -FilePath "$deployDir/deploy_on_server.sh" -Encoding UTF8

# Create deployment instructions
$instructions = @"
# Nurse Mingle Web Deployment Instructions

## Files in this package:
- web/ - Flutter web build files
- nurse-mingle.com.nginx - NGINX configuration
- deploy_on_server.sh - Server deployment script

## To deploy on your server:

1. Upload this entire 'deployment' folder to your server
2. SSH into your server and navigate to the deployment folder
3. Make the script executable: chmod +x deploy_on_server.sh
4. Run the deployment: ./deploy_on_server.sh

## Manual deployment steps:

1. Copy web files:
   sudo mkdir -p /var/www/nurse-mingle-web
   sudo cp -r web/* /var/www/nurse-mingle-web/
   sudo chown -R www-data:www-data /var/www/nurse-mingle-web

2. Install NGINX config:
   sudo cp nurse-mingle.com.nginx /etc/nginx/sites-available/nurse-mingle.com
   sudo ln -sf /etc/nginx/sites-available/nurse-mingle.com /etc/nginx/sites-enabled/

3. Test and reload NGINX:
   sudo nginx -t
   sudo systemctl reload nginx

## Testing:
- Visit: https://nurse-mingle.com
- API: https://nurse-mingle.com/api
- Check logs: sudo tail -f /var/log/nginx/error.log
"@

$instructions | Out-File -FilePath "$deployDir/README.md" -Encoding UTF8

Write-Host "✅ Deployment package created in '$deployDir' folder" -ForegroundColor Green
Write-Host ""
Write-Host "📁 Package contents:" -ForegroundColor Yellow
Get-ChildItem -Recurse $deployDir | ForEach-Object { Write-Host "  $($_.FullName)" }
Write-Host ""
Write-Host "📋 Next steps:" -ForegroundColor Cyan
Write-Host "1. Upload the '$deployDir' folder to your server" -ForegroundColor White
Write-Host "2. SSH into your server and run: ./deploy_on_server.sh" -ForegroundColor White
Write-Host "3. Visit https://nurse-mingle.com to test" -ForegroundColor White 