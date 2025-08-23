# Laravel Backend Setup Guide for Nine27 Pharmacy

## Prerequisites
- PHP 8.1 or higher
- Composer
- MySQL 8.0 or higher
- Laravel 10.x

## Step 1: Create Laravel Project

```bash
# Create new Laravel project
composer create-project laravel/laravel nine27-pharmacy-backend

# Navigate to project directory
cd nine27-pharmacy-backend

# Install Laravel Sanctum for API authentication
composer require laravel/sanctum

# Publish Sanctum configuration
php artisan vendor:publish --provider="Laravel\Sanctum\SanctumServiceProvider"
```

## Step 2: Database Configuration

1. **Create MySQL Database**:
```sql
CREATE DATABASE nine27_pharmacy;
```

2. **Update `.env` file**:
```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=nine27_pharmacy
DB_USERNAME=your_username
DB_PASSWORD=your_password

APP_URL=http://localhost:8000
```

## Step 3: Copy Backend Files

Copy all the files from the `laravel_backend/` folder to your Laravel project:

1. **Migrations**: Copy to `database/migrations/`
2. **Models**: Copy to `app/Models/`
3. **Controllers**: Copy to `app/Http/Controllers/Api/`
4. **Routes**: Replace `routes/api.php`
5. **Seeders**: Copy to `database/seeders/`

## Step 4: Update User Migration

Add mobile and address fields to the existing users migration:

```php
// In database/migrations/xxxx_xx_xx_xxxxxx_create_users_table.php
Schema::create('users', function (Blueprint $table) {
    $table->id();
    $table->string('name');
    $table->string('email')->unique();
    $table->string('mobile', 20); // Add this line
    $table->text('address');      // Add this line
    $table->timestamp('email_verified_at')->nullable();
    $table->string('password');
    $table->rememberToken();
    $table->timestamps();
});
```

## Step 5: Configure Sanctum

1. **Update `config/sanctum.php`**:
```php
'stateful' => explode(',', env('SANCTUM_STATEFUL_DOMAINS', sprintf(
    '%s%s',
    'localhost,localhost:3000,127.0.0.1,127.0.0.1:8000,::1',
    Sanctum::currentApplicationUrlWithPort()
))),
```

2. **Update `app/Http/Kernel.php`**:
```php
'api' => [
    \Laravel\Sanctum\Http\Middleware\EnsureFrontendRequestsAreStateful::class,
    'throttle:api',
    \Illuminate\Routing\Middleware\SubstituteBindings::class,
],
```

## Step 6: Run Migrations and Seeders

```bash
# Run migrations
php artisan migrate

# Run the order seeder to create test data
php artisan db:seed --class=OrderSeeder
```

## Step 7: Start Laravel Server

```bash
# Start the development server
php artisan serve

# Server will run on http://localhost:8000
```

## Step 8: Test API Endpoints

### Test with cURL or Postman:

1. **Register User**:
```bash
curl -X POST http://localhost:8000/api/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "email": "john@example.com",
    "mobile": "09123456789",
    "address": "123 Main St, City",
    "password": "password123",
    "password_confirmation": "password123"
  }'
```

2. **Login**:
```bash
curl -X POST http://localhost:8000/api/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "password": "password123"
  }'
```

3. **Get Orders** (use token from login):
```bash
curl -X GET http://localhost:8000/api/orders \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Accept: application/json"
```

## Step 9: Update Flutter App Configuration

Update the Flutter app's API URL in `lib/common/globs.dart`:

```dart
class SVKey {
  static const mainUrl = "http://10.0.2.2:8000"; // For Android emulator
  // static const mainUrl = "http://localhost:8000"; // For iOS simulator
  // static const mainUrl = "http://YOUR_IP:8000"; // For physical device
  static const baseUrl = '$mainUrl/api/';
  // ... rest of the endpoints
}
```

## Step 10: Test Integration

1. **Start Laravel server**: `php artisan serve`
2. **Run Flutter app**: `flutter run`
3. **Test the flow**:
   - Register a new user
   - Login with credentials
   - View orders (should show test data from seeder)
   - Test order details, filtering, etc.

## Troubleshooting

### CORS Issues
If you encounter CORS issues, install Laravel CORS:

```bash
composer require fruitcake/laravel-cors
```

Add to `config/cors.php`:
```php
'paths' => ['api/*'],
'allowed_methods' => ['*'],
'allowed_origins' => ['*'],
'allowed_headers' => ['*'],
```

### Database Connection Issues
- Verify MySQL is running
- Check database credentials in `.env`
- Ensure database exists

### Token Issues
- Make sure Sanctum is properly configured
- Check that API routes are protected with `auth:sanctum` middleware
- Verify token is being sent in Authorization header

## Production Considerations

1. **Environment Variables**: Set proper values in production `.env`
2. **Database**: Use production MySQL database
3. **HTTPS**: Enable SSL certificates
4. **Caching**: Configure Redis for better performance
5. **Queue**: Set up queue workers for background jobs
6. **Logging**: Configure proper logging levels

## API Documentation

All endpoints are documented in `LARAVEL_API_REQUIREMENTS.md` with:
- Request/response formats
- Authentication requirements
- Error handling
- Status codes

## Next Steps

Once the backend is running:
1. Test all order management features
2. Implement push notifications (optional)
3. Proceed to Product Catalog & Cart System implementation
