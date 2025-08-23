@echo off
echo 🚀 Nine27 Pharmacy Laravel Setup with Laragon
echo =============================================

echo.
echo 📋 Checking Laragon environment...

:: Check if we're in Laragon environment
if not defined LARAGON_ROOT (
    echo ❌ Laragon environment not detected
    echo 💡 Please run this from Laragon Terminal or set LARAGON_ROOT
    echo 💡 Or start Laragon and use "Terminal" button
    pause
    exit /b 1
)

echo ✅ Laragon environment detected: %LARAGON_ROOT%

:: Check PHP
echo 🐘 Checking PHP...
php --version | findstr /C:"PHP" && echo ✅ PHP is available || echo ❌ PHP not found

:: Check Composer
echo 🎼 Checking Composer...
composer --version | findstr /C:"Composer" && echo ✅ Composer is available || echo ❌ Composer not found

:: Check MySQL
echo 🐬 Checking MySQL...
mysql --version | findstr /C:"mysql" && echo ✅ MySQL is available || echo ❌ MySQL not found

echo.
echo 🏗️ Creating Laravel project...

:: Create Laravel project in Laragon www directory
if not exist "nine27-pharmacy-backend" (
    echo 📦 Creating new Laravel project...
    composer create-project laravel/laravel nine27-pharmacy-backend
    
    if %errorlevel% neq 0 (
        echo ❌ Failed to create Laravel project
        pause
        exit /b 1
    )
    echo ✅ Laravel project created
) else (
    echo ✅ Laravel project already exists
)

cd nine27-pharmacy-backend

:: Install Sanctum
echo 📦 Installing Laravel Sanctum...
composer require laravel/sanctum
php artisan vendor:publish --provider="Laravel\Sanctum\SanctumServiceProvider"

:: Setup environment
echo ⚙️ Setting up environment...
if not exist ".env" (
    copy ".env.example" ".env"
)

:: Generate app key
php artisan key:generate

echo.
echo 🗄️ Setting up database...

:: Create database
echo 📊 Creating MySQL database...
mysql -u root -e "CREATE DATABASE IF NOT EXISTS nine27_pharmacy;"
mysql -u root -e "CREATE USER IF NOT EXISTS 'nine27_user'@'localhost' IDENTIFIED BY 'nine27_password';"
mysql -u root -e "GRANT ALL PRIVILEGES ON nine27_pharmacy.* TO 'nine27_user'@'localhost';"
mysql -u root -e "FLUSH PRIVILEGES;"

if %errorlevel% equ 0 (
    echo ✅ Database created successfully
) else (
    echo ⚠️ Database creation may have failed, but continuing...
)

:: Update .env file for database
echo 🔧 Updating .env file...
powershell -Command "(Get-Content .env) -replace 'DB_DATABASE=.*', 'DB_DATABASE=nine27_pharmacy' | Set-Content .env"
powershell -Command "(Get-Content .env) -replace 'DB_USERNAME=.*', 'DB_USERNAME=nine27_user' | Set-Content .env"
powershell -Command "(Get-Content .env) -replace 'DB_PASSWORD=.*', 'DB_PASSWORD=nine27_password' | Set-Content .env"

echo.
echo 📁 Copying backend files...

:: Copy backend files if they exist
if exist "..\laravel_backend" (
    echo 📋 Copying migrations...
    if exist "..\laravel_backend\database\migrations" (
        xcopy "..\laravel_backend\database\migrations\*" "database\migrations\" /Y /I
    )
    
    echo 📦 Copying models...
    if exist "..\laravel_backend\app\Models" (
        xcopy "..\laravel_backend\app\Models\*" "app\Models\" /Y /I
    )
    
    echo 🎮 Copying controllers...
    if exist "..\laravel_backend\app\Http\Controllers" (
        xcopy "..\laravel_backend\app\Http\Controllers\*" "app\Http\Controllers\" /Y /I /E
    )
    
    echo 🛤️ Copying routes...
    if exist "..\laravel_backend\routes\api.php" (
        copy "..\laravel_backend\routes\api.php" "routes\api.php" /Y
    )
    
    echo 🌱 Copying seeders...
    if exist "..\laravel_backend\database\seeders" (
        xcopy "..\laravel_backend\database\seeders\*" "database\seeders\" /Y /I
    )
    
    echo ✅ Backend files copied
) else (
    echo ⚠️ Backend files not found in ..\laravel_backend
    echo 💡 You may need to copy them manually
)

echo.
echo 🔧 Configuring Sanctum...

:: Update Kernel.php for Sanctum
powershell -Command "if (!(Select-String -Path 'app\Http\Kernel.php' -Pattern 'EnsureFrontendRequestsAreStateful')) { (Get-Content 'app\Http\Kernel.php') -replace \"'api' => \[\", \"'api' => [`n            \Laravel\Sanctum\Http\Middleware\EnsureFrontendRequestsAreStateful::class,\" | Set-Content 'app\Http\Kernel.php' }"

echo.
echo 🗃️ Running migrations...
php artisan migrate --force

if %errorlevel% equ 0 (
    echo ✅ Migrations completed
    
    echo 🌱 Running seeders...
    php artisan db:seed --class=OrderSeeder --force
    
    if %errorlevel% equ 0 (
        echo ✅ Sample data created
    ) else (
        echo ⚠️ Seeder may have failed, but continuing...
    )
) else (
    echo ❌ Migrations failed
    echo 💡 Check database connection and try again
)

echo.
echo 🧹 Clearing caches...
php artisan config:clear
php artisan cache:clear
php artisan route:clear

echo.
echo 🎉 Setup complete!
echo.
echo 🌐 Your Laravel app is ready at:
echo    http://nine27-pharmacy-backend.test (Laragon auto-host)
echo    http://localhost/nine27-pharmacy-backend/public
echo.
echo 🧪 Test the API:
echo    http://nine27-pharmacy-backend.test/api/health
echo.
echo 🚀 To start development server:
echo    php artisan serve
echo.
echo 📱 Your Flutter app should connect to:
echo    http://10.0.2.2:8000 (Android emulator)
echo    http://localhost:8000 (iOS simulator)
echo.

pause
