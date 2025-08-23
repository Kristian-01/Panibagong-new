# 🚀 Nine27 Pharmacy Laravel Setup with Laragon

## ✅ Why Laragon is Perfect

Laragon already includes:
- ✅ **PHP** (multiple versions)
- ✅ **MySQL** 
- ✅ **Composer**
- ✅ **Apache/Nginx**
- ✅ **Auto-host creation** (your-app.test)
- ✅ **Terminal with all tools**

## 🎯 Quick Setup (5 minutes!)

### Step 1: Start Laragon
1. Open **Laragon**
2. Click **"Start All"** (Apache + MySQL)
3. Click **"Terminal"** button to open Laragon terminal

### Step 2: Navigate to Your Project
```bash
# In Laragon terminal, go to your Flutter project
cd C:\Users\kristian\tolongges
```

### Step 3: Run Auto Setup
```bash
# Run our automated setup script
setup_with_laragon.bat
```

**OR Manual Setup:**

### Step 4: Create Laravel Project (Manual)
```bash
# Create Laravel project
composer create-project laravel/laravel nine27-pharmacy-backend

# Navigate to project
cd nine27-pharmacy-backend

# Install Sanctum
composer require laravel/sanctum
php artisan vendor:publish --provider="Laravel\Sanctum\SanctumServiceProvider"
```

### Step 5: Setup Database
```bash
# Create database (Laragon MySQL has no password by default)
mysql -u root -e "CREATE DATABASE nine27_pharmacy;"
mysql -u root -e "CREATE USER 'nine27_user'@'localhost' IDENTIFIED BY 'nine27_password';"
mysql -u root -e "GRANT ALL PRIVILEGES ON nine27_pharmacy.* TO 'nine27_user'@'localhost';"
mysql -u root -e "FLUSH PRIVILEGES;"
```

### Step 6: Configure Environment
Edit `.env` file:
```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=nine27_pharmacy
DB_USERNAME=nine27_user
DB_PASSWORD=nine27_password
```

### Step 7: Copy Backend Files
Copy all files from `laravel_backend` folder to your Laravel project:
- `database/migrations/` → Laravel migrations
- `app/Models/` → Laravel models  
- `app/Http/Controllers/Api/` → Laravel controllers
- `routes/api.php` → Laravel API routes
- `database/seeders/` → Laravel seeders

### Step 8: Run Migrations
```bash
# Generate app key
php artisan key:generate

# Run migrations
php artisan migrate

# Add sample data
php artisan db:seed --class=OrderSeeder
```

### Step 9: Start Server
```bash
# Start Laravel development server
php artisan serve
```

## 🌐 Access Your App

### Laravel Backend:
- **Development Server**: http://localhost:8000
- **Laragon Auto-Host**: http://nine27-pharmacy-backend.test
- **API Health Check**: http://localhost:8000/api/health

### Database Access:
- **phpMyAdmin**: http://localhost/phpmyadmin (if enabled in Laragon)
- **HeidiSQL**: Use Laragon's built-in HeidiSQL
- **MySQL Command**: `mysql -u root nine27_pharmacy`

## 🧪 Test Everything

### 1. Test API Health
```bash
curl http://localhost:8000/api/health
```

### 2. Test User Registration
```bash
curl -X POST http://localhost:8000/api/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "email": "test@example.com", 
    "mobile": "09123456789",
    "address": "123 Test St",
    "password": "password123",
    "password_confirmation": "password123"
  }'
```

### 3. Check Database
```bash
# Open MySQL
mysql -u root nine27_pharmacy

# Check tables
SHOW TABLES;

# Check sample data
SELECT * FROM orders;
SELECT * FROM users;
```

## 📱 Flutter App Connection

Your Flutter app is already configured to connect to:
- **Android Emulator**: `http://10.0.2.2:8000`
- **iOS Simulator**: `http://localhost:8000`

No changes needed in Flutter code!

## 🔧 Laragon Advantages

1. **Auto-Host**: Your app automatically gets `nine27-pharmacy-backend.test`
2. **Multiple PHP Versions**: Switch PHP versions easily
3. **Built-in Tools**: phpMyAdmin, HeidiSQL, Terminal
4. **SSL Support**: Enable HTTPS with one click
5. **Pretty URLs**: No need for `/public` in URLs

## 🎯 Verification Checklist

- ✅ Laragon is running (green icons)
- ✅ Laravel project created
- ✅ Database `nine27_pharmacy` exists
- ✅ Tables created (users, orders, order_items)
- ✅ Sample data inserted
- ✅ API responds at http://localhost:8000/api/health
- ✅ Flutter app can register/login users

## 🚨 Troubleshooting

### "Composer not found"
- Make sure you're using Laragon Terminal
- Restart Laragon if needed

### "MySQL connection failed"
- Check if MySQL is running in Laragon
- Try without password: `mysql -u root`
- Check Laragon MySQL settings

### "Laravel errors"
```bash
php artisan config:clear
php artisan cache:clear
php artisan route:clear
```

### "Port 8000 in use"
```bash
# Use different port
php artisan serve --port=8001
```

## 🎉 Success!

Once everything is working:
1. ✅ Laravel backend running
2. ✅ MySQL database with data
3. ✅ API endpoints working
4. ✅ Flutter app connected
5. ✅ Ready for development!

Your Nine27 Pharmacy app now has a full Laravel + MySQL backend! 🚀
