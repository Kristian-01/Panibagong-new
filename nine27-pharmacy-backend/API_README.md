# Nine27 Pharmacy API

This is the backend API for the Nine27 Pharmacy application built with Laravel 11 and Laravel Sanctum for authentication.

## Setup Instructions

### Prerequisites
- PHP 8.2 or higher
- Composer
- SQLite (or MySQL/PostgreSQL)

### Quick Setup
1. Run the setup script:
   ```bash
   setup.bat
   ```
   
   Or manually:
   ```bash
   composer install
   php setup_database.php
   php artisan serve
   ```

### Database Setup
The setup script will:
- Run all database migrations
- Create a test user for testing
- Verify database connectivity

## API Endpoints

### Public Endpoints (No Authentication Required)

#### Health Check
```
GET /api/health
```
Returns API status and timestamp.

#### Test
```
GET /api/test
```
Simple test endpoint to verify API is working.

#### Authentication
```
POST /api/register
POST /api/login
POST /api/forgot-password
POST /api/verify-otp
POST /api/reset-password
```

#### Products
```
GET /api/products
GET /api/products/featured
GET /api/products/category/{category}
GET /api/products/suggestions
GET /api/products/{id}
GET /api/categories
```

### Protected Endpoints (Authentication Required)

All protected endpoints require a Bearer token in the Authorization header.

#### User Management
```
GET /api/user
GET /api/profile
PUT /api/profile/update
POST /api/logout
```

#### Orders
```
GET /api/orders
POST /api/orders
GET /api/orders/{order}
POST /api/orders/{order}/cancel
POST /api/orders/{order}/reorder
GET /api/orders/track/{orderNumber}
```

## Authentication

### Registration
```json
POST /api/register
{
    "name": "John Doe",
    "email": "john@example.com",
    "mobile": "1234567890",
    "address": "123 Main St",
    "password": "password123",
    "password_confirmation": "password123"
}
```

### Login
```json
POST /api/login
{
    "email": "john@example.com",
    "password": "password123"
}
```

Response includes a token:
```json
{
    "success": true,
    "message": "Login successful",
    "user": {...},
    "token": "1|abc123..."
}
```

### Using the Token
Include the token in the Authorization header for protected endpoints:
```
Authorization: Bearer 1|abc123...
```

## Test User
A test user is automatically created during setup:
- Email: `test@example.com`
- Password: `password123`

## Error Handling

The API returns consistent error responses:

### Authentication Error (401)
```json
{
    "success": false,
    "message": "Unauthenticated. Please login to access this resource.",
    "error": "Authentication required"
}
```

### Validation Error (422)
```json
{
    "success": false,
    "message": "Validation failed",
    "errors": {
        "email": ["The email field is required."]
    }
}
```

### Not Found Error (404)
```json
{
    "success": false,
    "message": "Resource not found",
    "error": "Not found"
}
```

## Testing the API

### Using the Test Script
```bash
php test_api.php
```

### Using cURL
```bash
# Health check
curl http://127.0.0.1:8000/api/health

# Login
curl -X POST http://127.0.0.1:8000/api/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123"}'

# Protected endpoint
curl http://127.0.0.1:8000/api/orders \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

### Using Postman
1. Import the endpoints
2. Set the base URL to `http://127.0.0.1:8000`
3. For protected endpoints, add the Authorization header with your Bearer token

## Troubleshooting

### Common Issues

1. **"Route [login] not defined"**
   - This has been fixed by adding web routes for authentication
   - The API now properly handles authentication errors

2. **Database connection issues**
   - Run `php setup_database.php` to initialize the database
   - Check that SQLite file exists and is writable

3. **Authentication token issues**
   - Ensure you're using the correct token format: `Bearer TOKEN`
   - Check that the token hasn't expired

4. **CORS issues**
   - The API is configured to accept requests from localhost
   - Check the Sanctum configuration if you need to add other domains

### Server Status
- Check if the server is running: `http://127.0.0.1:8000/api/health`
- Verify database connection: Check the setup script output
- Check Laravel logs: `storage/logs/laravel.log`

## Development

### Adding New Endpoints
1. Add the route to `routes/api.php`
2. Create the controller method
3. Add any necessary validation
4. Test with the test script

### Database Changes
1. Create a new migration: `php artisan make:migration create_table_name`
2. Update the model if needed
3. Run migrations: `php artisan migrate`

## Security Notes

- Passwords are hashed using Laravel's built-in hashing
- API tokens are managed by Laravel Sanctum
- CORS is configured for local development
- Input validation is implemented for all endpoints
- Authentication middleware protects sensitive endpoints





