#!/bin/bash

# Update NGINX configuration to proxy API requests to backend
echo "🔧 Updating NGINX configuration..."

# Backup the current config
sudo cp /etc/nginx/sites-available/default /etc/nginx/sites-available/default.backup

# Create the new NGINX configuration
sudo tee /etc/nginx/sites-available/default <<EOF
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name _;

    # API proxy configuration
    location /auth/ {
        proxy_pass http://localhost:3000/auth/;
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

    # Proxy other API endpoints
    location /api/ {
        proxy_pass http://localhost:3000/;
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
    }

    # WebSocket support
    location /ws/ {
        proxy_pass http://localhost:3000/ws/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }

    # Default location for static files or other content
    location / {
        try_files \$uri \$uri/ =404;
    }

    # Health check endpoint
    location /health {
        access_log off;
        return 200 "healthy\n";
        add_header Content-Type text/plain;
    }
}
EOF

echo "✅ NGINX configuration updated"

# Test the configuration
echo "🧪 Testing NGINX configuration..."
sudo nginx -t

if [ \$? -eq 0 ]; then
    echo "✅ NGINX configuration is valid"
    echo "🔄 Reloading NGINX..."
    sudo systemctl reload nginx
    echo "✅ NGINX reloaded successfully"
    
    echo ""
    echo "📋 Configuration Summary:"
    echo "- /auth/* requests → localhost:3000/auth/*"
    echo "- /api/* requests → localhost:3000/*"
    echo "- /ws/* requests → localhost:3000/ws/*"
    echo ""
    echo "🔗 Test the API endpoint:"
    echo "curl -X POST http://178.156.173.172/auth/register -H 'Content-Type: application/json' -d '{\"email\":\"test@example.com\",\"password\":\"testpass\"}'"
else
    echo "❌ NGINX configuration test failed"
    echo "Restoring backup..."
    sudo cp /etc/nginx/sites-available/default.backup /etc/nginx/sites-available/default
    exit 1
fi 