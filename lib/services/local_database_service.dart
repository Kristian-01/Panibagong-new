import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/order_model.dart';
import '../models/product_model.dart';

class LocalDatabaseService {
  static Database? _database;
  static final LocalDatabaseService _instance = LocalDatabaseService._internal();
  
  factory LocalDatabaseService() => _instance;
  LocalDatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'nine27_pharmacy.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
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
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Products table
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        price REAL NOT NULL,
        image TEXT,
        category TEXT NOT NULL,
        brand TEXT,
        sku TEXT,
        stock_quantity INTEGER NOT NULL,
        is_available INTEGER NOT NULL DEFAULT 1,
        requires_prescription INTEGER NOT NULL DEFAULT 0,
        dosage TEXT,
        active_ingredient TEXT,
        manufacturer TEXT,
        rating REAL,
        review_count INTEGER,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Orders table
    await db.execute('''
      CREATE TABLE orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        order_number TEXT UNIQUE NOT NULL,
        status TEXT NOT NULL,
        total_amount REAL NOT NULL,
        items_count INTEGER NOT NULL,
        order_type TEXT NOT NULL,
        category TEXT NOT NULL,
        delivery_address TEXT NOT NULL,
        payment_method TEXT NOT NULL,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Order items table
    await db.execute('''
      CREATE TABLE order_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_id INTEGER NOT NULL,
        product_name TEXT NOT NULL,
        product_price REAL NOT NULL,
        quantity INTEGER NOT NULL,
        product_image TEXT,
        product_description TEXT,
        product_category TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (order_id) REFERENCES orders (id)
      )
    ''');

    // Insert sample data
    await _insertSampleData(db);
  }

  Future<void> _insertSampleData(Database db) async {
    // Insert sample user
    await db.insert('users', {
      'name': 'Test User',
      'email': 'test@nine27pharmacy.com',
      'mobile': '09123456789',
      'address': '123 Test Street, Test City',
      'password_hash': 'hashed_password_123',
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });

    // Insert sample products
    List<Map<String, dynamic>> products = [
      {
        'name': 'Biogesic 500mg',
        'description': 'Paracetamol 500mg tablet for fever and pain relief',
        'price': 50.00,
        'image': 'assets/img/biogesic.jpg',
        'category': 'medicines',
        'brand': 'Unilab',
        'sku': 'BIO-500-20',
        'stock_quantity': 150,
        'is_available': 1,
        'requires_prescription': 0,
        'dosage': '500mg',
        'active_ingredient': 'Paracetamol',
        'manufacturer': 'Unilab',
        'rating': 4.5,
        'review_count': 128,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      {
        'name': 'Vitamin C 500mg',
        'description': 'High-potency Vitamin C supplement for immune system support',
        'price': 15.00,
        'image': 'assets/img/vitamin-c.jpg',
        'category': 'vitamins',
        'brand': 'Centrum',
        'sku': 'VIT-C-500-30',
        'stock_quantity': 200,
        'is_available': 1,
        'requires_prescription': 0,
        'dosage': '500mg',
        'active_ingredient': 'Ascorbic Acid',
        'manufacturer': 'Pfizer',
        'rating': 4.3,
        'review_count': 89,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      {
        'name': 'Betadine Solution 60ml',
        'description': 'Antiseptic solution for wound cleaning and disinfection',
        'price': 85.00,
        'image': 'assets/img/betadine.jpg',
        'category': 'first_aid',
        'brand': 'Betadine',
        'sku': 'BET-SOL-60',
        'stock_quantity': 75,
        'is_available': 1,
        'requires_prescription': 0,
        'active_ingredient': 'Povidone Iodine',
        'manufacturer': 'Mundipharma',
        'rating': 4.7,
        'review_count': 156,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      {
        'name': 'Amoxicillin 500mg',
        'description': 'Antibiotic capsule for bacterial infections',
        'price': 25.00,
        'image': 'assets/img/amoxicillin.jpg',
        'category': 'prescription_drugs',
        'brand': 'Generics',
        'sku': 'AMX-500-21',
        'stock_quantity': 100,
        'is_available': 1,
        'requires_prescription': 1,
        'dosage': '500mg',
        'active_ingredient': 'Amoxicillin',
        'manufacturer': 'Generics Pharmacy',
        'rating': 4.2,
        'review_count': 67,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
    ];

    for (var product in products) {
      await db.insert('products', product);
    }

    // Insert sample orders
    await db.insert('orders', {
      'user_id': 1,
      'order_number': 'ORD-2024-001',
      'status': 'delivered',
      'total_amount': 150.00,
      'items_count': 3,
      'order_type': 'regular',
      'category': 'medicines',
      'delivery_address': '123 Test Street, Test City',
      'payment_method': 'Cash on Delivery',
      'notes': 'Please call before delivery',
      'created_at': DateTime.now().subtract(Duration(days: 5)).toIso8601String(),
      'updated_at': DateTime.now().subtract(Duration(days: 5)).toIso8601String(),
    });

    await db.insert('order_items', {
      'order_id': 1,
      'product_name': 'Biogesic 500mg',
      'product_price': 50.00,
      'quantity': 2,
      'product_image': 'assets/img/biogesic.jpg',
      'product_description': 'Paracetamol 500mg tablet',
      'product_category': 'medicines',
      'created_at': DateTime.now().toIso8601String(),
    });

    await db.insert('order_items', {
      'order_id': 1,
      'product_name': 'Vitamin C 500mg',
      'product_price': 15.00,
      'quantity': 1,
      'product_image': 'assets/img/vitamin-c.jpg',
      'product_description': 'Vitamin C supplement',
      'product_category': 'vitamins',
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // Test connection
  Future<bool> testConnection() async {
    try {
      final db = await database;
      final result = await db.rawQuery('SELECT COUNT(*) as count FROM products');
      print('✅ Local database connected! Products: ${result.first['count']}');
      return true;
    } catch (e) {
      print('❌ Database connection failed: $e');
      return false;
    }
  }

  // Get products
  Future<List<ProductModel>> getProducts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('products');
    
    return List.generate(maps.length, (i) {
      return ProductModel.fromJson(maps[i]);
    });
  }

  // Get orders
  Future<List<OrderModel>> getOrders() async {
    final db = await database;
    final List<Map<String, dynamic>> orderMaps = await db.query('orders');
    
    List<OrderModel> orders = [];
    for (var orderMap in orderMaps) {
      // Get order items
      final List<Map<String, dynamic>> itemMaps = await db.query(
        'order_items',
        where: 'order_id = ?',
        whereArgs: [orderMap['id']],
      );
      
      List<OrderItem> items = itemMaps.map((itemMap) => OrderItem.fromJson(itemMap)).toList();
      
      // Create order with items
      OrderModel order = OrderModel.fromJson(orderMap);
      orders.add(order);
    }
    
    return orders;
  }
}

// Test function
Future<void> testLocalDatabase() async {
  print('🔍 Testing Local SQLite Database...');
  
  final dbService = LocalDatabaseService();
  final isConnected = await dbService.testConnection();
  
  if (isConnected) {
    final products = await dbService.getProducts();
    final orders = await dbService.getOrders();
    
    print('📦 Products in database: ${products.length}');
    print('📋 Orders in database: ${orders.length}');
    
    if (products.isNotEmpty) {
      print('🔸 Sample product: ${products.first.name} - ${products.first.formattedPrice}');
    }
    
    if (orders.isNotEmpty) {
      print('🔸 Sample order: ${orders.first.orderNumber} - ${orders.first.status}');
    }
  }
}
