@echo off
echo Starting Nine27 Pharmacy Backend Server...
echo =========================================

echo.
echo Server will be accessible at:
echo - Localhost: http://127.0.0.1:8000
echo - Network: http://192.168.1.6:8000
echo.
echo Make sure your mobile device is on the same WiFi network!
echo.
echo Press Ctrl+C to stop the server
echo.

php artisan serve --host=0.0.0.0 --port=8000

pause





