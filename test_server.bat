@echo off
echo 🔍 Testing Laravel Server Connection...
echo =====================================

echo.
echo 📋 Testing localhost (from this PC)...
curl -s -o nul -w "Status: %%{http_code}\n" http://localhost:8000/api/health
if %errorlevel% neq 0 (
    echo ❌ Server not responding on localhost:8000
) else (
    echo ✅ Server responding on localhost:8000
)

echo.
echo 📋 Testing 10.0.2.2 (Android Emulator access)...
curl -s -o nul -w "Status: %%{http_code}\n" http://10.0.2.2:8000/api/health
if %errorlevel% neq 0 (
    echo ❌ Server not accessible via 10.0.2.2:8000
) else (
    echo ✅ Server accessible via 10.0.2.2:8000
)

echo.
echo 📋 Full response from health endpoint:
curl -s http://localhost:8000/api/health

echo.
echo.
echo 📋 Next Steps:
echo 1. If server is not responding, run: start_server.bat
echo 2. If server is responding, your Flutter app should work
echo 3. Make sure your Flutter app uses the correct URL for your environment

pause