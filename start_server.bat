@echo off
echo 🚀 Starting Nine27 Pharmacy Laravel Server...
echo ==========================================

cd nine27-pharmacy-backend

echo 📋 Checking if server is already running...
netstat -an | findstr :8000 >nul
if %errorlevel% equ 0 (
    echo ⚠️  Port 8000 is already in use!
    echo 💡 If Laravel server is running, you're good to go.
    echo 💡 If another app is using port 8000, stop it first.
    pause
    exit /b 1
)

echo 🔧 Starting Laravel development server...
echo 📍 Server will be accessible at:
echo    - From this PC: http://localhost:8000
echo    - From Android Emulator: http://10.0.2.2:8000
echo    - From Physical Device: http://192.168.1.6:8000
echo.
echo 🛑 Press Ctrl+C to stop the server
echo.

php artisan serve --host=0.0.0.0 --port=8000