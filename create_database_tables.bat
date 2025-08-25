@echo off
echo 🔧 Creating Nine27 Pharmacy Database Tables...
echo ==========================================

echo.
echo 📋 Step 1: Navigate to Laravel backend
cd nine27-pharmacy-backend

echo.
echo 📋 Step 2: Run database migrations
php artisan migrate

echo.
echo 📋 Step 3: Seed database with products
php artisan db:seed --class=ProductSeeder

echo.
echo 📋 Step 4: Check if tables were created
php artisan tinker --execute="echo 'Products count: ' . App\Models\Product::count();"

echo.
echo ✅ Database setup complete!
echo 🚀 Now start your Laravel server: php artisan serve --host=0.0.0.0 --port=8000
echo.
pause