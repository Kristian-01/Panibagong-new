# Nine27 Pharmacy - MySQL Setup Instructions

## 🎯 Complete MySQL Integration Setup

Your Flutter app is now configured to use your **MySQL database** via the Laravel API instead of SQLite.

## Step 1: Setup Laravel Backend

### 1.1 Navigate to Laravel Directory
```bash
cd nine27-pharmacy-backend
```

### 1.2 Install Dependencies (if not done)
```bash
composer install
```

### 1.3 Run Database Migration
```bash
php artisan migrate
```

### 1.4 Seed Database with Medicine Data
```bash
php artisan db:seed --class=ProductSeeder
```

### 1.5 Start Laravel Server
```bash
php artisan serve --host=0.0.0.0 --port=8000
```

**Keep this terminal open** - your server needs to stay running.

## Step 2: Verify Database Setup

### 2.1 Check API Health
Open browser and go to: `http://localhost:8000/api/health`

You should see:
```json
{
  "status": "ok",
  "timestamp": "2024-01-01T12:00:00.000000Z",
  "service": "Nine27 Pharmacy API"
}
```

### 2.2 Check Products API
Go to: `http://localhost:8000/api/products`

You should see a JSON response with medicine data.

### 2.3 Check Categories API
Go to: `http://localhost:8000/api/categories`

You should see medicine categories.

## Step 3: Configure Flutter App

### 3.1 Update Base URL (if needed)
Edit `lib/common/globs.dart`:

```dart
// For Android Emulator
static const mainUrl = "http://10.0.2.2:8000";

// For iOS Simulator  
static const mainUrl = "http://127.0.0.1:8000";

// For Physical Device
static const mainUrl = "http://192.168.1.6:8000"; // Your PC's IP
```

### 3.2 Rebuild Flutter App
```bash
flutter clean
flutter pub get
flutter run
```

## Step 4: Test the Integration

### 4.1 Test Login/Registration
- Use the registration form to create a new account
- Login with your credentials
- Both should work via MySQL database

### 4.2 Test Home View
- Navigate to Home tab
- You should see:
  - **Featured Medicines** (5 items from MySQL)
  - **Popular Vitamins** (4 items from MySQL)  
  - **Recently Viewed** (3 items from MySQL)
  - **Search functionality** working with MySQL data

### 4.3 Test Search
- Search for "biogesic", "vitamin", "pain relief"
- Results should come from MySQL database

## 📊 What's in Your MySQL Database

After seeding, you'll have **17 products**:

### 💊 Medicines (5 items)
- Biogesic 500mg - ₱50.00
- Advil 200mg - ₱75.00  
- Tylenol 500mg - ₱65.00
- Aspirin 325mg - ₱35.00
- Mefenamic Acid 500mg - ₱45.00

### 🧴 Vitamins (5 items)
- Vitamin C 500mg - ₱15.00
- Multivitamins Complete - ₱450.00
- Vitamin D3 1000IU - ₱320.00
- Omega-3 Fish Oil - ₱680.00
- Calcium + Vitamin D - ₱280.00

### 🩹 First Aid (4 items)
- Betadine Solution 60ml - ₱85.00
- Alcohol 70% 500ml - ₱45.00
- Band-Aid Adhesive Bandages - ₱125.00
- Hydrogen Peroxide 3% - ₱35.00

### 📋 Prescription Drugs (3 items)
- Amoxicillin 500mg - ₱25.00 (Requires Prescription)
- Losartan 50mg - ₱180.00 (Requires Prescription)
- Metformin 500mg - ₱95.00 (Requires Prescription)

## 🔧 API Endpoints Available

Your Laravel backend now provides these endpoints:

### Public Endpoints (No Authentication)
- `GET /api/health` - Health check
- `GET /api/products` - Get all products
- `GET /api/products/featured` - Get featured products
- `GET /api/products/category/{category}` - Get products by category
- `GET /api/products/{id}` - Get product details
- `GET /api/categories` - Get all categories
- `GET /api/products/suggestions?query=term` - Search suggestions

### Authentication Endpoints
- `POST /api/register` - User registration
- `POST /api/login` - User login
- `POST /api/logout` - User logout (requires auth)

## 🚨 Troubleshooting

### If Home View is Empty:
1. **Check Laravel server is running**: `http://localhost:8000/api/health`
2. **Check products exist**: `http://localhost:8000/api/products`
3. **Check Flutter console** for API error messages
4. **Verify base URL** matches your environment

### If Login/Registration Fails:
1. **Check Laravel server logs**: `tail -f storage/logs/laravel.log`
2. **Verify MySQL connection** in Laravel `.env` file
3. **Check users table exists**: `php artisan migrate`

### If API Returns Errors:
1. **Check MySQL is running**
2. **Verify database credentials** in `.env`
3. **Run migrations**: `php artisan migrate`
4. **Seed data**: `php artisan db:seed --class=ProductSeeder`

## ✅ Success Indicators

When everything is working correctly:

1. **Laravel server shows**: `Laravel development server started: http://0.0.0.0:8000`
2. **API health check returns**: `{"status":"ok",...}`
3. **Flutter home view shows**: Medicine categories and products
4. **Search works**: Returns results from MySQL
5. **Login/Registration works**: Via MySQL database

## 🎉 You're All Set!

Your Nine27 Pharmacy app now uses:
- **MySQL database** for all data storage
- **Laravel API** for all backend operations  
- **Real-time data** from your server
- **Professional pharmacy features** with actual medicine data

The app will show rich content with medicines, vitamins, first aid supplies, and prescription drugs - all stored in your MySQL database and served via your Laravel API!