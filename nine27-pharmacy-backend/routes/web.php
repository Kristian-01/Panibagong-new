<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;

Route::get('/', function () {
    return view('welcome');
});

// Authentication routes
Route::get('/login', function () {
    return response()->json(['message' => 'Please use the API endpoints for authentication']);
})->name('login');

Route::get('/register', function () {
    return response()->json(['message' => 'Please use the API endpoints for authentication']);
})->name('register');