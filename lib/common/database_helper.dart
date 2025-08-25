import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'nine27_pharmacy.db');
    
    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDatabase,
      onUpgrade: _upgradeDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        mobile TEXT NOT NULL,
        address TEXT NOT NULL,
        password_hash TEXT NOT NULL,
        profile_picture TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Orders table for future use
    await db.execute('''
      CREATE TABLE orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        order_number TEXT UNIQUE NOT NULL,
        status TEXT NOT NULL,
        total_amount REAL NOT NULL,
        items_count INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Order items table for future use
    await db.execute('''
      CREATE TABLE order_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_id INTEGER NOT NULL,
        product_name TEXT NOT NULL,
        product_price REAL NOT NULL,
        quantity INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (order_id) REFERENCES orders (id)
      )
    ''');
  }

  Future<void> _upgradeDatabase(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add profile_picture column to users table
      await db.execute('ALTER TABLE users ADD COLUMN profile_picture TEXT');
    }
  }

  // Password hashing
  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  // User registration
  Future<Map<String, dynamic>> registerUser({
    required String name,
    required String email,
    required String mobile,
    required String address,
    required String password,
  }) async {
    try {
      final db = await database;
      
      // Check if user already exists
      final existingUser = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email.toLowerCase()],
      );

      if (existingUser.isNotEmpty) {
        return {
          'success': false,
          'message': 'User with this email already exists',
        };
      }

      // Hash password
      String hashedPassword = _hashPassword(password);
      String currentTime = DateTime.now().toIso8601String();

      // Insert user
      int userId = await db.insert('users', {
        'name': name,
        'email': email.toLowerCase(),
        'mobile': mobile,
        'address': address,
        'password_hash': hashedPassword,
        'created_at': currentTime,
        'updated_at': currentTime,
      });

      // Get the created user
      final user = await db.query(
        'users',
        where: 'id = ?',
        whereArgs: [userId],
      );

      return {
        'success': true,
        'message': 'User registered successfully',
        'user': {
          'id': user.first['id'],
          'name': user.first['name'],
          'email': user.first['email'],
          'mobile': user.first['mobile'],
          'address': user.first['address'],
          'profile_picture': user.first['profile_picture'],
        },
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Registration failed: ${e.toString()}',
      };
    }
  }

  // User login
  Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final db = await database;
      
      // Hash the provided password
      String hashedPassword = _hashPassword(password);

      // Find user with matching email and password
      final users = await db.query(
        'users',
        where: 'email = ? AND password_hash = ?',
        whereArgs: [email.toLowerCase(), hashedPassword],
      );

      if (users.isEmpty) {
        return {
          'success': false,
          'message': 'Invalid email or password',
        };
      }

      final user = users.first;
      return {
        'success': true,
        'message': 'Login successful',
        'user': {
          'id': user['id'],
          'name': user['name'],
          'email': user['email'],
          'mobile': user['mobile'],
          'address': user['address'],
          'profile_picture': user['profile_picture'],
        },
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Login failed: ${e.toString()}',
      };
    }
  }

  // Get user by ID
  Future<Map<String, dynamic>?> getUserById(int userId) async {
    try {
      final db = await database;
      final users = await db.query(
        'users',
        where: 'id = ?',
        whereArgs: [userId],
      );

      if (users.isEmpty) return null;

      final user = users.first;
      return {
        'id': user['id'],
        'name': user['name'],
        'email': user['email'],
        'mobile': user['mobile'],
        'address': user['address'],
        'profile_picture': user['profile_picture'],
      };
    } catch (e) {
      return null;
    }
  }

  // Update user profile
  Future<Map<String, dynamic>> updateUser({
    required int id,
    String? name,
    String? email,
    String? mobile,
    String? address,
    String? profilePicture,
  }) async {
    try {
      final db = await database;
      
      // Check if email is being changed and if it already exists
      if (email != null) {
        final existingUser = await db.query(
          'users',
          where: 'email = ? AND id != ?',
          whereArgs: [email.toLowerCase(), id],
        );

        if (existingUser.isNotEmpty) {
          return {
            'success': false,
            'message': 'Email already exists',
          };
        }
      }
      
      Map<String, dynamic> updateData = {
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (name != null) updateData['name'] = name;
      if (email != null) updateData['email'] = email.toLowerCase();
      if (mobile != null) updateData['mobile'] = mobile;
      if (address != null) updateData['address'] = address;
      if (profilePicture != null) updateData['profile_picture'] = profilePicture;

      await db.update(
        'users',
        updateData,
        where: 'id = ?',
        whereArgs: [id],
      );

      return {
        'success': true,
        'message': 'Profile updated successfully',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Update failed: ${e.toString()}',
      };
    }
  }

  // Update profile picture
  Future<Map<String, dynamic>> updateProfilePicture({
    required int userId,
    required String profilePicturePath,
  }) async {
    try {
      final db = await database;
      
      await db.update(
        'users',
        {
          'profile_picture': profilePicturePath,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [userId],
      );

      return {
        'success': true,
        'message': 'Profile picture updated successfully',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to update profile picture: ${e.toString()}',
      };
    }
  }

  // Change password
  Future<Map<String, dynamic>> changePassword({
    required int userId,
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final db = await database;
      
      // Verify current password
      String currentHashedPassword = _hashPassword(currentPassword);
      final users = await db.query(
        'users',
        where: 'id = ? AND password_hash = ?',
        whereArgs: [userId, currentHashedPassword],
      );

      if (users.isEmpty) {
        return {
          'success': false,
          'message': 'Current password is incorrect',
        };
      }

      // Update password
      String newHashedPassword = _hashPassword(newPassword);
      await db.update(
        'users',
        {
          'password_hash': newHashedPassword,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [userId],
      );

      return {
        'success': true,
        'message': 'Password changed successfully',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Password change failed: ${e.toString()}',
      };
    }
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}