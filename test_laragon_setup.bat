@echo off
echo 🔍 Testing Nine27 Pharmacy Setup with Laragon
echo ===============================================

echo.
echo 📋 Checking Laragon environment...

:: Check if Laragon is running
tasklist /FI "IMAGENAME eq laragon.exe" 2>NUL | find /I /N "laragon.exe">NUL
if "%ERRORLEVEL%"=="0" (
    echo ✅ Laragon is running
) else (
    echo ❌ Laragon is not running
    echo 💡 Please start Laragon first
)

:: Check PHP
echo 🐘 Testing PHP...
php --version >nul 2>&1
if %errorlevel% equ 0 (
    php --version | findstr /C:"PHP"
    echo ✅ PHP is working
) else (
    echo ❌ PHP not found - use Laragon Terminal
)

:: Check Composer
echo 🎼 Testing Composer...
composer --version >nul 2>&1
if %errorlevel% equ 0 (
    composer --version | findstr /C:"Composer"
    echo ✅ Composer is working
) else (
    echo ❌ Composer not found - use Laragon Terminal
)

:: Check MySQL
echo 🐬 Testing MySQL...
mysql --version >nul 2>&1
if %errorlevel% equ 0 (
    mysql --version | findstr /C:"mysql"
    echo ✅ MySQL is working
) else (
    echo ❌ MySQL not found - check Laragon MySQL
)

echo.
echo 🌐 Testing Laravel project...

if exist "nine27-pharmacy-backend" (
    echo ✅ Laravel project found
    cd nine27-pharmacy-backend
    
    :: Test Laravel
    php artisan --version >nul 2>&1
    if %errorlevel% equ 0 (
        echo ✅ Laravel is working
        php artisan --version | findstr /C:"Laravel"
    ) else (
        echo ❌ Laravel not working
    )
    
    :: Check database connection
    echo 🗄️ Testing database connection...
    php -r "
    try {
        $pdo = new PDO('mysql:host=127.0.0.1;dbname=nine27_pharmacy', 'nine27_user', 'nine27_password');
        echo '✅ Database connection successful\n';
        
        $stmt = $pdo->query('SELECT COUNT(*) as count FROM orders');
        $result = $stmt->fetch();
        echo '📋 Orders in database: ' . $result['count'] . '\n';
        
        $stmt = $pdo->query('SELECT COUNT(*) as count FROM users');
        $result = $stmt->fetch();
        echo '👥 Users in database: ' . $result['count'] . '\n';
        
    } catch (Exception $e) {
        echo '❌ Database connection failed: ' . $e->getMessage() . '\n';
        echo '💡 Run setup_with_laragon.bat to create database\n';
    }
    "
    
    echo.
    echo 🧪 Testing API endpoints...
    
    :: Start server in background for testing
    start /B php artisan serve --port=8000
    
    :: Wait a moment for server to start
    timeout /t 3 /nobreak >nul
    
    :: Test health endpoint
    curl -s http://localhost:8000/api/health >nul 2>&1
    if %errorlevel% equ 0 (
        echo ✅ API health endpoint working
        curl -s http://localhost:8000/api/health
    ) else (
        echo ❌ API health endpoint not responding
        echo 💡 Check if server started properly
    )
    
    :: Kill the background server
    taskkill /F /IM php.exe >nul 2>&1
    
) else (
    echo ❌ Laravel project not found
    echo 💡 Run setup_with_laragon.bat to create project
)

echo.
echo 📱 Flutter app configuration...
echo ✅ Flutter app is configured to connect to:
echo    - Android Emulator: http://10.0.2.2:8000
echo    - iOS Simulator: http://localhost:8000

echo.
echo 🎯 Next steps:
if exist "nine27-pharmacy-backend" (
    echo 1. Start Laravel server: php artisan serve
    echo 2. Run Flutter app: flutter run
    echo 3. Test registration/login in the app
) else (
    echo 1. Run: setup_with_laragon.bat
    echo 2. Follow LARAGON_SETUP_GUIDE.md
)

echo.
echo 🌐 Useful Laragon URLs:
echo - Laravel App: http://localhost:8000
echo - Auto-host: http://nine27-pharmacy-backend.test
echo - phpMyAdmin: http://localhost/phpmyadmin

echo.
pause
