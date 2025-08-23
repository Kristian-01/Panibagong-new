# Laravel API Requirements for Nine27 Pharmacy App

## Overview
The Flutter app has been configured to connect to a Laravel backend with MySQL database. Here are the API endpoints and expected request/response formats.

## Base Configuration
- **Base URL**: `http://10.0.2.2:8000/api/` (Laravel development server)
- **Content Type**: `application/json`
- **Accept**: `application/json`

## Required API Endpoints

### 1. User Registration
**Endpoint**: `POST /api/register`

**Request Body**:
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "mobile": "09123456789",
  "address": "123 Main St, City",
  "password": "password123",
  "password_confirmation": "password123"
}
```

**Success Response** (200):
```json
{
  "success": true,
  "message": "Registration successful",
  "user": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com",
    "mobile": "09123456789",
    "address": "123 Main St, City",
    "created_at": "2024-01-01T00:00:00.000000Z",
    "updated_at": "2024-01-01T00:00:00.000000Z"
  },
  "token": "your-jwt-token-here"
}
```

**Error Response** (422):
```json
{
  "success": false,
  "message": "Validation failed",
  "errors": {
    "email": ["The email has already been taken."],
    "password": ["The password must be at least 6 characters."]
  }
}
```

### 2. User Login
**Endpoint**: `POST /api/login`

**Request Body**:
```json
{
  "email": "john@example.com",
  "password": "password123"
}
```

**Success Response** (200):
```json
{
  "success": true,
  "message": "Login successful",
  "user": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com",
    "mobile": "09123456789",
    "address": "123 Main St, City"
  },
  "token": "your-jwt-token-here"
}
```

**Error Response** (401):
```json
{
  "success": false,
  "message": "Invalid credentials"
}
```

### 3. Forgot Password
**Endpoint**: `POST /api/forgot-password`

**Request Body**:
```json
{
  "email": "john@example.com"
}
```

**Success Response** (200):
```json
{
  "success": true,
  "message": "Password reset link sent to your email"
}
```

### 4. User Profile (Protected)
**Endpoint**: `GET /api/profile`
**Headers**: `Authorization: Bearer {token}`

**Success Response** (200):
```json
{
  "success": true,
  "user": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com",
    "mobile": "09123456789",
    "address": "123 Main St, City"
  }
}
```

### 5. Update Profile (Protected)
**Endpoint**: `PUT /api/profile/update`
**Headers**: `Authorization: Bearer {token}`

**Request Body**:
```json
{
  "name": "John Updated",
  "mobile": "09987654321",
  "address": "456 New St, City"
}
```

### 6. Logout (Protected)
**Endpoint**: `POST /api/logout`
**Headers**: `Authorization: Bearer {token}`

**Success Response** (200):
```json
{
  "success": true,
  "message": "Successfully logged out"
}
```

## Database Schema Requirements

### Users Table
```sql
CREATE TABLE users (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    mobile VARCHAR(20) NOT NULL,
    address TEXT NOT NULL,
    email_verified_at TIMESTAMP NULL,
    password VARCHAR(255) NOT NULL,
    remember_token VARCHAR(100) NULL,
    created_at TIMESTAMP NULL,
    updated_at TIMESTAMP NULL
);
```

## Laravel Implementation Notes

1. **Install Laravel Sanctum** for API authentication:
   ```bash
   composer require laravel/sanctum
   php artisan vendor:publish --provider="Laravel\Sanctum\SanctumServiceProvider"
   php artisan migrate
   ```

2. **Add Sanctum middleware** to `api` routes in `app/Http/Kernel.php`:
   ```php
   'api' => [
       \Laravel\Sanctum\Http\Middleware\EnsureFrontendRequestsAreStateful::class,
       'throttle:api',
       \Illuminate\Routing\Middleware\SubstituteBindings::class,
   ],
   ```

3. **User Model** should use `HasApiTokens` trait:
   ```php
   use Laravel\Sanctum\HasApiTokens;
   
   class User extends Authenticatable
   {
       use HasApiTokens, HasFactory, Notifiable;
   }
   ```

4. **API Routes** in `routes/api.php`:
   ```php
   Route::post('/register', [AuthController::class, 'register']);
   Route::post('/login', [AuthController::class, 'login']);
   Route::post('/forgot-password', [AuthController::class, 'forgotPassword']);
   
   Route::middleware('auth:sanctum')->group(function () {
       Route::get('/profile', [AuthController::class, 'profile']);
       Route::put('/profile/update', [AuthController::class, 'updateProfile']);
       Route::post('/logout', [AuthController::class, 'logout']);
   });
   ```

## Testing the Connection

1. Start your Laravel development server:
   ```bash
   php artisan serve
   ```

2. The Flutter app will connect to `http://10.0.2.2:8000/api/`

3. Test registration and login from the Flutter app

## Error Handling

The Flutter app handles:
- **422 Validation Errors**: Shows validation messages
- **401 Unauthorized**: Shows "Invalid credentials"
- **Network Errors**: Shows "Network error" message
- **Other HTTP Errors**: Shows API error message

## Order Management API Endpoints

### 7. Get User Orders (Protected)
**Endpoint**: `GET /api/orders`
**Headers**: `Authorization: Bearer {token}`

**Query Parameters**:
```
?status=delivered&order_type=prescription&category=medicines&page=1&limit=20
```

**Success Response** (200):
```json
{
  "success": true,
  "orders": [
    {
      "id": 1,
      "order_number": "ORD-2024-001",
      "status": "delivered",
      "total_amount": 1250.00,
      "items_count": 3,
      "order_type": "prescription",
      "category": "medicines",
      "delivery_address": "123 Main St, City",
      "payment_method": "Cash on Delivery",
      "notes": "Please call before delivery",
      "created_at": "2024-01-01T00:00:00.000000Z",
      "updated_at": "2024-01-01T00:00:00.000000Z",
      "items": [
        {
          "id": 1,
          "order_id": 1,
          "product_name": "Biogesic",
          "product_price": 50.00,
          "quantity": 2,
          "product_image": "https://example.com/biogesic.jpg",
          "product_description": "500mg Tablet",
          "product_category": "medicines"
        }
      ]
    }
  ],
  "total": 25,
  "current_page": 1,
  "total_pages": 3
}
```

### 8. Get Order Details (Protected)
**Endpoint**: `GET /api/orders/{id}`
**Headers**: `Authorization: Bearer {token}`

### 9. Create Order (Protected)
**Endpoint**: `POST /api/orders`
**Headers**: `Authorization: Bearer {token}`

**Request Body**:
```json
{
  "items": [
    {
      "product_name": "Biogesic",
      "product_price": 50.00,
      "quantity": 2,
      "product_image": "https://example.com/biogesic.jpg",
      "product_description": "500mg Tablet"
    }
  ],
  "total_amount": 1250.00,
  "delivery_address": "123 Main St, City",
  "payment_method": "Cash on Delivery",
  "order_type": "regular",
  "notes": "Please call before delivery"
}
```

### 10. Cancel Order (Protected)
**Endpoint**: `POST /api/orders/{id}/cancel`
**Headers**: `Authorization: Bearer {token}`

**Request Body**:
```json
{
  "reason": "User requested cancellation"
}
```

### 11. Reorder (Protected)
**Endpoint**: `POST /api/orders/{id}/reorder`
**Headers**: `Authorization: Bearer {token}`

### 12. Track Order (Protected)
**Endpoint**: `GET /api/orders/track/{order_number}`
**Headers**: `Authorization: Bearer {token}`

## Database Schema for Orders

### Orders Table
```sql
CREATE TABLE orders (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    order_number VARCHAR(50) UNIQUE NOT NULL,
    status ENUM('pending', 'processing', 'shipped', 'delivered', 'cancelled') DEFAULT 'pending',
    total_amount DECIMAL(10,2) NOT NULL,
    items_count INT NOT NULL,
    order_type ENUM('regular', 'prescription') DEFAULT 'regular',
    category VARCHAR(100) NOT NULL,
    delivery_address TEXT NOT NULL,
    payment_method VARCHAR(100) NOT NULL,
    notes TEXT NULL,
    created_at TIMESTAMP NULL,
    updated_at TIMESTAMP NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
```

### Order Items Table
```sql
CREATE TABLE order_items (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    order_id BIGINT UNSIGNED NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    product_price DECIMAL(8,2) NOT NULL,
    quantity INT NOT NULL,
    product_image VARCHAR(500) NULL,
    product_description TEXT NULL,
    product_category VARCHAR(100) NULL,
    created_at TIMESTAMP NULL,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE
);
```

## Security Notes

- Passwords are hashed using Laravel's default bcrypt
- API uses Bearer token authentication
- All requests use HTTPS in production
- Input validation on both client and server side
- Orders are user-specific (filtered by authenticated user)
