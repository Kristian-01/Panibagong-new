@echo off
echo 🔍 Checking Prerequisites for Nine27 Pharmacy Laravel Backend
echo ============================================================

echo.
echo 📋 Checking required software...

:: Check PHP
echo 🐘 Checking PHP...
php --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ PHP is NOT installed
    echo 💡 Download PHP 8.1+ from: https://windows.php.net/download/
    echo    Choose "Thread Safe" version and extract to C:\php
    echo    Add C:\php to your PATH environment variable
    set PHP_MISSING=1
) else (
    php --version | findstr /C:"PHP"
    echo ✅ PHP is installed
)

echo.
echo 🎼 Checking Composer...
composer --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Composer is NOT installed
    echo 💡 Download from: https://getcomposer.org/download/
    echo    Run the Windows installer
    set COMPOSER_MISSING=1
) else (
    composer --version
    echo ✅ Composer is installed
)

echo.
echo 🐬 Checking MySQL...
mysql --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ MySQL is NOT installed or not in PATH
    echo 💡 Download MySQL from: https://dev.mysql.com/downloads/mysql/
    echo    OR install XAMPP: https://www.apachefriends.org/download.html
    echo    OR install WAMP: https://www.wampserver.com/
    set MYSQL_MISSING=1
) else (
    mysql --version
    echo ✅ MySQL is installed
)

echo.
echo 🌐 Checking Node.js (optional)...
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ⚠️ Node.js is not installed (optional for Laravel Mix)
    echo 💡 Download from: https://nodejs.org/
) else (
    node --version
    echo ✅ Node.js is installed
)

echo.
echo 📊 Summary:
if defined PHP_MISSING (
    echo ❌ PHP is missing - REQUIRED
)
if defined COMPOSER_MISSING (
    echo ❌ Composer is missing - REQUIRED
)
if defined MYSQL_MISSING (
    echo ❌ MySQL is missing - REQUIRED
)

if not defined PHP_MISSING if not defined COMPOSER_MISSING if not defined MYSQL_MISSING (
    echo ✅ All prerequisites are installed!
    echo 🚀 Ready to set up Laravel backend
    echo.
    echo Next step: Run setup_laravel_backend.bat
) else (
    echo.
    echo ⚠️ Please install missing software before proceeding
    echo 📖 See installation links above
)

echo.
pause
