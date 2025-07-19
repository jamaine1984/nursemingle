#!/bin/bash

# Nurse Mingle Backend NGINX Setup Script
# Run this on your backend server (178.156.173.172)

echo "🚀 Setting up NGINX for Nurse Mingle Backend..."

# 1. Update system and install NGINX
echo "📦 Installing NGINX..."
sudo apt update && sudo apt install nginx -y

# 2. Configure firewall
echo "🔥 Configuring firewall..."
sudo ufw allow 'Nginx Full'
sudo ufw delete allow 3000/tcp 2>/dev/null || true

# 3. Create NGINX configuration
echo "⚙️ Creating NGINX configuration..."
sudo tee /etc/nginx/sites-available/nursemingle <<EOF
server {
    listen 80;
    server_name 178.156.173.172;

    # Increase client max body size for file uploads
    client_max_body_size 50M;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
        
        # CORS headers
        add_header 'Access-Control-Allow-Origin' '*' always;
        add_header 'Access-Control-Allow-Methods' 'GET, POST, PUT, DELETE, OPTIONS' always;
        add_header 'Access-Control-Allow-Headers' 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range,Authorization' always;
        add_header 'Access-Control-Expose-Headers' 'Content-Length,Content-Range' always;
        
        if (\$request_method = 'OPTIONS') {
            add_header 'Access-Control-Allow-Origin' '*';
            add_header 'Access-Control-Allow-Methods' 'GET, POST, PUT, DELETE, OPTIONS';
            add_header 'Access-Control-Allow-Headers' 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range,Authorization';
            add_header 'Access-Control-Max-Age' 1728000;
            add_header 'Content-Type' 'text/plain; charset=utf-8';
            add_header 'Content-Length' 0;
            return 204;
        }
    }
}
EOF

# 4. Enable the site
echo "🔗 Enabling NGINX site..."
sudo ln -sf /etc/nginx/sites-available/nursemingle /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

# 5. Test and reload NGINX
echo "🧪 Testing NGINX configuration..."
sudo nginx -t

if [ \$? -eq 0 ]; then
    echo "✅ NGINX configuration is valid"
    echo "🔄 Reloading NGINX..."
    sudo systemctl reload nginx
    sudo systemctl enable nginx
    echo "✅ NGINX setup complete!"
    echo ""
    echo "📋 Next steps:"
    echo "1. Make sure your Node.js backend is running on port 3000"
    echo "2. Update your Flutter app to use http://178.156.173.172 (port 80) instead of port 3000"
    echo "3. Test the connection from your app"
else
    echo "❌ NGINX configuration test failed"
    exit 1
fi 