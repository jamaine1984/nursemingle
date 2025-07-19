#!/bin/bash

# Nurse Mingle Web Deployment Script
echo "🚀 Deploying Nurse Mingle Web Frontend..."

# Create web directory if it doesn't exist
sudo mkdir -p /var/www/nurse-mingle-web

# Copy built web files to server directory
echo "📁 Copying web files to /var/www/nurse-mingle-web..."
sudo cp -r build/web/* /var/www/nurse-mingle-web/

# Set proper permissions
sudo chown -R www-data:www-data /var/www/nurse-mingle-web
sudo chmod -R 755 /var/www/nurse-mingle-web

# Create NGINX configuration
echo "⚙️  Creating NGINX configuration..."
sudo tee /etc/nginx/sites-available/nurse-mingle.com << 'EOF'
server {
    listen 80;
    server_name nurse-mingle.com www.nurse-mingle.com;
    return 301 https://$server_name$request_uri;
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
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        proxy_read_timeout 86400;
    }
    
    # Flutter web app - serve index.html for all routes
    location / {
        try_files $uri $uri/ /index.html;
        
        # Cache static assets
        location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
            expires 1y;
            add_header Cache-Control "public, immutable";
        }
    }
    
    # Specific handling for Flutter service worker
    location /flutter_service_worker.js {
        add_header Cache-Control "no-cache";
        try_files $uri =404;
    }
    
    # Handle manifest.json
    location /manifest.json {
        add_header Content-Type application/manifest+json;
        try_files $uri =404;
    }
}
EOF

# Enable the site
sudo ln -sf /etc/nginx/sites-available/nurse-mingle.com /etc/nginx/sites-enabled/

# Test NGINX configuration
echo "🧪 Testing NGINX configuration..."
sudo nginx -t

if [ $? -eq 0 ]; then
    echo "✅ NGINX configuration is valid"
    
    # Reload NGINX
    echo "🔄 Reloading NGINX..."
    sudo systemctl reload nginx
    
    if [ $? -eq 0 ]; then
        echo "✅ NGINX reloaded successfully"
        echo ""
        echo "🎉 Deployment Complete!"
        echo "🌐 Web app is now live at: https://nurse-mingle.com"
        echo "📱 API endpoint: https://nurse-mingle.com/api"
        echo ""
        echo "🧪 Test the deployment:"
        echo "curl -I https://nurse-mingle.com"
        echo "curl -I https://nurse-mingle.com/api/health"
    else
        echo "❌ Failed to reload NGINX"
        exit 1
    fi
else
    echo "❌ NGINX configuration test failed"
    exit 1
fi 