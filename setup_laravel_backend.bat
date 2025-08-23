@echo off
echo 🚀 Nine27 Pharmacy Laravel Backend Setup
echo ==========================================

echo.
echo 📋 Checking Prerequisites...

:: Check PHP
php --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ PHP is not installed or not in PATH
    echo 💡 Please install PHP 8.1+ from https://windows.php.net/download/
    pause
    exit /b 1
) else (
    echo ✅ PHP is installed
)

:: Check Composer
composer --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Composer is not installed or not in PATH
    echo 💡 Please install Composer from https://getcomposer.org/download/
    pause
    exit /b 1
) else (
    echo ✅ Composer is installed
)

echo.
echo 🏗️ Setting up Laravel Backend...

:: Create Laravel project
if not exist "nine27-pharmacy-backend" (
    echo 📦 Creating Laravel project...
    composer create-project laravel/laravel nine27-pharmacy-backend
    if %errorlevel% neq 0 (
        echo ❌ Failed to create Laravel project
        pause
        exit /b 1
    )
) else (
    echo ✅ Laravel project already exists
)

cd nine27-pharmacy-backend

:: Install Sanctum
echo 📦 Installing Laravel Sanctum...
composer require laravel/sanctum
php artisan vendor:publish --provider="Laravel\Sanctum\SanctumServiceProvider"

:: Copy our backend files
echo 📁 Copying backend files...
if exist "..\laravel_backend" (
    xcopy "..\laravel_backend\*" "." /E /Y /I
    echo ✅ Backend files copied
) else (
    echo ⚠️ Backend files not found in parent directory
    echo 💡 You'll need to manually copy the files from laravel_backend folder
)

:: Setup environment
echo ⚙️ Setting up environment...
if not exist ".env" (
    copy ".env.example" ".env"
)

:: Generate app key
php artisan key:generate

echo.
echo 🎯 Next Steps:
echo 1. Configure your database in .env file
echo 2. Run: php artisan migrate
echo 3. Run: php artisan db:seed --class=OrderSeeder
echo 4. Run: php artisan serve
echo.
echo 📖 See LARAVEL_SETUP_GUIDE.md for detailed instructions
echo.
pause
