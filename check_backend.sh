#!/bin/bash

echo "🔍 Checking backend server status..."

# Check if Node.js backend is running
echo "📊 Checking if backend process is running..."
if pgrep -f "node.*3000" > /dev/null; then
    echo "✅ Backend process is running"
    ps aux | grep -E "node.*3000" | grep -v grep
else
    echo "❌ Backend process is NOT running"
fi

# Check if port 3000 is listening
echo ""
echo "🔌 Checking if port 3000 is listening..."
if netstat -tlnp | grep :3000 > /dev/null; then
    echo "✅ Port 3000 is listening"
    netstat -tlnp | grep :3000
else
    echo "❌ Port 3000 is NOT listening"
fi

# Check if backend directory exists
echo ""
echo "📁 Checking backend directory..."
if [ -d "/var/www/nursemingle-backend" ]; then
    echo "✅ Backend directory exists: /var/www/nursemingle-backend"
    ls -la /var/www/nursemingle-backend/
else
    echo "❌ Backend directory not found"
    echo "Looking for Node.js projects..."
    find /var/www -name "package.json" -type f 2>/dev/null | head -5
fi

# Try to start the backend if it's not running
echo ""
echo "🚀 Attempting to start backend server..."

# Common backend startup commands
if [ -f "/var/www/nursemingle-backend/package.json" ]; then
    echo "Found package.json, starting with npm..."
    cd /var/www/nursemingle-backend
    npm start &
elif [ -f "/var/www/nursemingle-backend/server.js" ]; then
    echo "Found server.js, starting with node..."
    cd /var/www/nursemingle-backend
    node server.js &
elif [ -f "/var/www/nursemingle-backend/app.js" ]; then
    echo "Found app.js, starting with node..."
    cd /var/www/nursemingle-backend
    node app.js &
else
    echo "❌ No backend files found. Please check the backend directory."
fi

# Wait a moment and check again
sleep 3
echo ""
echo "🔍 Re-checking backend status..."
if pgrep -f "node.*3000" > /dev/null; then
    echo "✅ Backend is now running!"
    ps aux | grep -E "node.*3000" | grep -v grep
else
    echo "❌ Backend failed to start"
    echo ""
    echo "📋 Manual steps to start backend:"
    echo "1. Find your backend directory:"
    echo "   find /var/www -name 'package.json' -type f"
    echo ""
    echo "2. Navigate to backend directory:"
    echo "   cd /path/to/your/backend"
    echo ""
    echo "3. Install dependencies:"
    echo "   npm install"
    echo ""
    echo "4. Start the server:"
    echo "   npm start"
    echo "   # or"
    echo "   node server.js"
    echo "   # or"
    echo "   node app.js"
fi

echo ""
echo "🧪 Testing API endpoint..."
curl -X POST http://localhost:3000/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"testpass"}' \
  -w "\nHTTP Status: %{http_code}\n" \
  -s 