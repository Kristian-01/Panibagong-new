# Nine27 Pharmacy Laragon Setup Checker
Write-Host "🔍 Checking Laragon Setup for Nine27 Pharmacy" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan

Write-Host ""
Write-Host "📋 Checking Laragon environment..." -ForegroundColor Yellow

# Check if Laragon is running
$laragonProcess = Get-Process -Name "laragon" -ErrorAction SilentlyContinue
if ($laragonProcess) {
    Write-Host "✅ Laragon is running" -ForegroundColor Green
} else {
    Write-Host "❌ Laragon is not running" -ForegroundColor Red
    Write-Host "💡 Please start Laragon first" -ForegroundColor Yellow
}

# Check PHP
Write-Host ""
Write-Host "🐘 Checking PHP..." -ForegroundColor Yellow
try {
    $phpVersion = & php --version 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ PHP is available" -ForegroundColor Green
        Write-Host ($phpVersion -split "`n")[0] -ForegroundColor Gray
    } else {
        throw "PHP not found"
    }
} catch {
    Write-Host "❌ PHP not found" -ForegroundColor Red
    Write-Host "💡 Make sure Laragon is running and use Laragon Terminal" -ForegroundColor Yellow
}

# Check Composer
Write-Host ""
Write-Host "🎼 Checking Composer..." -ForegroundColor Yellow
try {
    $composerVersion = & composer --version 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Composer is available" -ForegroundColor Green
        Write-Host $composerVersion -ForegroundColor Gray
    } else {
        throw "Composer not found"
    }
} catch {
    Write-Host "❌ Composer not found" -ForegroundColor Red
    Write-Host "💡 Use Laragon Terminal for Composer access" -ForegroundColor Yellow
}

# Check MySQL
Write-Host ""
Write-Host "🐬 Checking MySQL..." -ForegroundColor Yellow
try {
    $mysqlVersion = & mysql --version 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ MySQL is available" -ForegroundColor Green
        Write-Host $mysqlVersion -ForegroundColor Gray
    } else {
        throw "MySQL not found"
    }
} catch {
    Write-Host "❌ MySQL not found" -ForegroundColor Red
    Write-Host "💡 Check if MySQL is started in Laragon" -ForegroundColor Yellow
}

# Check if Laravel project exists
Write-Host ""
Write-Host "🌐 Checking Laravel project..." -ForegroundColor Yellow
if (Test-Path "nine27-pharmacy-backend") {
    Write-Host "✅ Laravel project found" -ForegroundColor Green
    
    # Check if it's a valid Laravel project
    if (Test-Path "nine27-pharmacy-backend/artisan") {
        Write-Host "✅ Valid Laravel project" -ForegroundColor Green
    } else {
        Write-Host "❌ Invalid Laravel project" -ForegroundColor Red
    }
} else {
    Write-Host "❌ Laravel project not found" -ForegroundColor Red
    Write-Host "💡 Need to create Laravel project" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "🎯 Summary:" -ForegroundColor Cyan

if ($laragonProcess) {
    Write-Host "✅ Laragon is ready for Laravel development" -ForegroundColor Green
    Write-Host ""
    Write-Host "🚀 Next steps:" -ForegroundColor Yellow
    Write-Host "1. Open Laragon Terminal" -ForegroundColor White
    Write-Host "2. Navigate to your project: cd C:\Users\kristian\tolongges" -ForegroundColor White
    Write-Host "3. Run: setup_with_laragon.bat" -ForegroundColor White
    Write-Host "4. Or follow LARAGON_SETUP_GUIDE.md" -ForegroundColor White
} else {
    Write-Host "❌ Please start Laragon first" -ForegroundColor Red
    Write-Host ""
    Write-Host "🔧 To fix:" -ForegroundColor Yellow
    Write-Host "1. Open Laragon application" -ForegroundColor White
    Write-Host "2. Click 'Start All' button" -ForegroundColor White
    Write-Host "3. Wait for Apache and MySQL to start (green icons)" -ForegroundColor White
    Write-Host "4. Click 'Terminal' button to open Laragon terminal" -ForegroundColor White
}

Write-Host ""
Write-Host "📖 For detailed setup instructions, see:" -ForegroundColor Cyan
Write-Host "   LARAGON_SETUP_GUIDE.md" -ForegroundColor White

Write-Host ""
Read-Host "Press Enter to continue"
