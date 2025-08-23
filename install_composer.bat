@echo off
echo 🎼 Installing Composer for Nine27 Pharmacy
echo ==========================================

echo.
echo 📥 Downloading Composer installer...

:: Download Composer installer
powershell -Command "Invoke-WebRequest -Uri 'https://getcomposer.org/installer' -OutFile 'composer-setup.php'"

if not exist "composer-setup.php" (
    echo ❌ Failed to download Composer installer
    echo 💡 Please download manually from: https://getcomposer.org/download/
    pause
    exit /b 1
)

echo ✅ Composer installer downloaded

echo.
echo 🔧 Installing Composer...

:: Install Composer
php composer-setup.php --install-dir=. --filename=composer

if not exist "composer.phar" (
    echo ❌ Failed to install Composer
    pause
    exit /b 1
)

echo ✅ Composer installed locally

echo.
echo 🌍 Making Composer globally available...

:: Create composer.bat for global access
echo @echo off > composer.bat
echo php "%~dp0composer.phar" %%* >> composer.bat

echo ✅ Composer is now available!

echo.
echo 🧹 Cleaning up...
del composer-setup.php

echo.
echo 🎉 Composer installation complete!
echo 💡 You can now use: composer --version
echo.

:: Test Composer
echo 🧪 Testing Composer...
composer --version

echo.
pause
