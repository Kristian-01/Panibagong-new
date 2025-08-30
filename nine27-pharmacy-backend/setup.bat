@echo off
echo Setting up Nine27 Pharmacy Backend...
echo ====================================

echo.
echo 1. Installing Composer dependencies...
composer install

echo.
echo 2. Setting up database...
php setup_database.php

echo.
echo 3. Starting Laravel server...
echo Server will start at http://127.0.0.1:8000
echo Press Ctrl+C to stop the server
echo.
php artisan serve

pause
