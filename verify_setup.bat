@echo off
echo 🔍 Verifying Nine27 Pharmacy Laravel Setup
echo ==========================================

echo.
echo 📋 Checking installation...

:: Check PHP
echo 🐘 PHP:
php --version | findstr /C:"PHP" || echo ❌ PHP not found

:: Check Composer
echo 🎼 Composer:
composer --version | findstr /C:"Composer" || echo ❌ Composer not found

:: Check MySQL
echo 🐬 MySQL:
mysql --version | findstr /C:"mysql" || echo ❌ MySQL not found

echo.
echo 🌐 Testing Laravel server...

:: Check if Laravel project exists
if exist "nine27-pharmacy-backend" (
    echo ✅ Laravel project found
    cd nine27-pharmacy-backend
    
    :: Check if .env exists
    if exist ".env" (
        echo ✅ Environment file found
    ) else (
        echo ❌ .env file missing
    )
    
    :: Test Laravel
    echo 🧪 Testing Laravel...
    php artisan --version || echo ❌ Laravel not working
    
    echo.
    echo 🚀 Starting Laravel server...
    echo 💡 Server will start on http://localhost:8000
    echo 💡 Press Ctrl+C to stop the server
    echo.
    
    php artisan serve
    
) else (
    echo ❌ Laravel project not found
    echo 💡 Please follow COMPLETE_SETUP_GUIDE.md first
)

echo.
pause
