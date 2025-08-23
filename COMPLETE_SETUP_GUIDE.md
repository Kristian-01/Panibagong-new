# 🚀 Complete Laravel + MySQL Setup for Nine27 Pharmacy

## ✅ Current Status
- ✅ **PHP 8.3.16** - Already installed!
- ❌ **Composer** - Need to install
- ❌ **MySQL** - Need to install

## 📋 Step-by-Step Installation

### Step 1: Install Composer

**Option A: Download Installer (Recommended)**
1. Go to: https://getcomposer.org/download/
2. Download `Composer-Setup.exe`
3. Run the installer
4. Follow the setup wizard
5. Test: Open new Command Prompt and run `composer --version`

**Option B: Manual Installation**
1. Download: https://getcomposer.org/composer.phar
2. Save to `C:\composer\composer.phar`
3. Create `C:\composer\composer.bat` with content:
   ```batch
   @echo off
   php "C:\composer\composer.phar" %*
   ```
4. Add `C:\composer` to your PATH environment variable

### Step 2: Install MySQL

**Option A: MySQL Server (Recommended)**
1. Go to: https://dev.mysql.com/downloads/mysql/
2. Download MySQL Community Server
3. Run installer and choose "Developer Default"
4. Set root password (remember this!)
5. Complete installation

**Option B: XAMPP (Easier)**
1. Go to: https://www.apachefriends.org/download.html
2. Download XAMPP for Windows
3. Install XAMPP
4. Start Apache and MySQL from XAMPP Control Panel

### Step 3: Create Laravel Project

Open Command Prompt in your project directory and run:

```bash
# Create Laravel project
composer create-project laravel/laravel nine27-pharmacy-backend

# Navigate to project
cd nine27-pharmacy-backend

# Install Sanctum for API authentication
composer require laravel/sanctum

# Publish Sanctum configuration
php artisan vendor:publish --provider="Laravel\Sanctum\SanctumServiceProvider"
```

### Step 4: Setup Database

1. **Create MySQL Database:**
   ```sql
   -- Open MySQL Command Line or phpMyAdmin
   CREATE DATABASE nine27_pharmacy;
   CREATE USER 'nine27_user'@'localhost' IDENTIFIED BY 'nine27_password';
   GRANT ALL PRIVILEGES ON nine27_pharmacy.* TO 'nine27_user'@'localhost';
   FLUSH PRIVILEGES;
   ```

2. **Configure Laravel Environment:**
   - Copy `.env.example` to `.env`
   - Edit `.env` file:
   ```env
   DB_CONNECTION=mysql
   DB_HOST=127.0.0.1
   DB_PORT=3306
   DB_DATABASE=nine27_pharmacy
   DB_USERNAME=nine27_user
   DB_PASSWORD=nine27_password
   ```

3. **Generate Application Key:**
   ```bash
   php artisan key:generate
   ```

### Step 5: Copy Backend Files

Copy all files from the `laravel_backend` folder to your Laravel project:

1. **Migrations:** Copy to `database/migrations/`
2. **Models:** Copy to `app/Models/`
3. **Controllers:** Copy to `app/Http/Controllers/Api/`
4. **Routes:** Replace `routes/api.php`
5. **Seeders:** Copy to `database/seeders/`

### Step 6: Configure Sanctum

1. **Update `config/sanctum.php`:**
   ```php
   'stateful' => explode(',', env('SANCTUM_STATEFUL_DOMAINS', sprintf(
       '%s%s',
       'localhost,localhost:3000,127.0.0.1,127.0.0.1:8000,::1',
       Sanctum::currentApplicationUrlWithPort()
   ))),
   ```

2. **Update `app/Http/Kernel.php`:**
   ```php
   'api' => [
       \Laravel\Sanctum\Http\Middleware\EnsureFrontendRequestsAreStateful::class,
       'throttle:api',
       \Illuminate\Routing\Middleware\SubstituteBindings::class,
   ],
   ```

3. **Update User Model (`app/Models/User.php`):**
   ```php
   use Laravel\Sanctum\HasApiTokens;
   
   class User extends Authenticatable
   {
       use HasApiTokens, HasFactory, Notifiable;
       
       protected $fillable = [
           'name', 'email', 'mobile', 'address', 'password',
       ];
   }
   ```

### Step 7: Run Migrations and Seeders

```bash
# Run migrations to create tables
php artisan migrate

# Run seeders to add sample data
php artisan db:seed --class=OrderSeeder
```

### Step 8: Start Laravel Server

```bash
# Start the development server
php artisan serve

# Server will run on http://localhost:8000
```

### Step 9: Test API Connection

1. **Test Health Endpoint:**
   ```bash
   curl http://localhost:8000/api/health
   ```

2. **Test Registration:**
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

### Step 10: Update Flutter App

The Flutter app is already configured to connect to `http://10.0.2.2:8000` (Android emulator) or `http://localhost:8000` (iOS simulator).

## 🔧 Troubleshooting

### Common Issues:

1. **"composer: command not found"**
   - Restart Command Prompt after installing Composer
   - Check if Composer is in your PATH

2. **"Access denied for user"**
   - Check MySQL username/password in `.env`
   - Ensure MySQL service is running

3. **"Connection refused"**
   - Start MySQL service
   - Check if port 3306 is available

4. **Laravel errors**
   - Run `php artisan config:clear`
   - Run `php artisan cache:clear`
   - Check file permissions

### Verification Commands:

```bash
# Check if everything is working
php --version          # Should show PHP 8.3.16
composer --version     # Should show Composer version
mysql --version        # Should show MySQL version
php artisan serve      # Should start Laravel server
```

## 🎯 Next Steps

Once everything is set up:

1. ✅ Laravel server running on http://localhost:8000
2. ✅ MySQL database with sample data
3. ✅ Flutter app can connect to backend
4. ✅ Test all API endpoints
5. ✅ Start developing your pharmacy app!

## 📞 Need Help?

If you encounter any issues:
1. Check the error messages carefully
2. Ensure all prerequisites are installed
3. Verify database connection
4. Check Laravel logs in `storage/logs/laravel.log`

## 🎉 Success Indicators

You'll know everything is working when:
- ✅ `php artisan serve` starts without errors
- ✅ You can access http://localhost:8000 in browser
- ✅ API endpoints return JSON responses
- ✅ Flutter app can register/login users
- ✅ Orders and products are saved to database
