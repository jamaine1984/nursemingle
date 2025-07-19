# PowerShell script to start the Nurse Mingle backend
$server = "178.156.173.172"
$user = "root"
$password = "njnniRPHFiJT"
$backendPath = "/var/www/nurse-mingle-backend"

Write-Host "🔗 Connecting to server $server..." -ForegroundColor Green

# Create SSH command to check and start backend
$sshCommands = @"
echo '🔍 Checking backend directory...'
if [ -d '$backendPath' ]; then
    echo '✅ Backend directory found'
    cd $backendPath
    ls -la
    
    echo '📦 Installing dependencies...'
    npm install
    
    echo '🚀 Starting backend server...'
    if [ -f 'package.json' ]; then
        npm start &
    elif [ -f 'server.js' ]; then
        node server.js &
    elif [ -f 'app.js' ]; then
        node app.js &
    else
        echo '❌ No startup file found'
        exit 1
    fi
    
    echo '⏳ Waiting for server to start...'
    sleep 3
    
    echo '🔍 Checking if backend is running...'
    if pgrep -f "node.*3000" > /dev/null; then
        echo '✅ Backend is running!'
        ps aux | grep -E "node.*3000" | grep -v grep
    else
        echo '❌ Backend failed to start'
    fi
else
    echo '❌ Backend directory not found at $backendPath'
    echo '📁 Available directories in /var/www:'
    ls -la /var/www/
fi
"@

# Execute the commands
Write-Host "Executing backend startup commands..." -ForegroundColor Yellow
$sshCommands | ssh -o StrictHostKeyChecking=no root@$server "bash -s" 