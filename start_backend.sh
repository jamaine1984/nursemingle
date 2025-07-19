#!/bin/bash

echo "🔍 Checking backend directory..."
BACKEND_PATH="/var/www/nurse-mingle-backend"

if [ -d "$BACKEND_PATH" ]; then
    echo "✅ Backend directory found"
    cd "$BACKEND_PATH"
    ls -la
    
    echo "📦 Installing dependencies..."
    npm install
    
    echo "🚀 Starting backend server..."
    if [ -f "package.json" ]; then
        echo "Found package.json, starting with npm start..."
        npm start &
    elif [ -f "server.js" ]; then
        echo "Found server.js, starting with node..."
        node server.js &
    elif [ -f "app.js" ]; then
        echo "Found app.js, starting with node..."
        node app.js &
    else
        echo "❌ No startup file found"
        echo "Available files:"
        ls -la
        exit 1
    fi
    
    echo "⏳ Waiting for server to start..."
    sleep 3
    
    echo "🔍 Checking if backend is running..."
    if pgrep -f "node.*3000" > /dev/null; then
        echo "✅ Backend is running!"
        ps aux | grep -E "node.*3000" | grep -v grep
    else
        echo "❌ Backend failed to start"
        echo "Checking for any node processes:"
        ps aux | grep node | grep -v grep
    fi
else
    echo "❌ Backend directory not found at $BACKEND_PATH"
    echo "📁 Available directories in /var/www:"
    ls -la /var/www/
fi 