import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

Future<void> addMoreMedicines() async {
  print('🔧 Adding more medicines to the database...\n');
  
  try {
    String path = join(await getDatabasesPath(), 'nine27_pharmacy.db');
    Database db = await openDatabase(path);
    
    // Additional medicine products
    List<Map<String, dynamic>> newProducts = [
      // More Medicines
      {
        'name': 'Advil 200mg',
        'description': 'Ibuprofen tablets for pain relief and inflammation',
        'price': 75.00,
        'image': 'assets/img/advil.jpg',
        'category': 'medicines',
        'brand': 'Pfizer',
        'sku': 'ADV-200-20',
        'stock_quantity': 120,
        'is_available': 1,
        'requires_prescription': 0,
        'dosage': '200mg',
        'active_ingredient': 'Ibuprofen',
        'manufacturer': 'Pfizer',
        'rating': 4.4,
        'review_count': 95,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      {
        'name': 'Tylenol 500mg',
        'description': 'Acetaminophen tablets for fever and pain relief',
        'price': 65.00,
        'image': 'assets/img/tylenol.jpg',
        'category': 'medicines',
        'brand': 'Johnson & Johnson',
        'sku': 'TYL-500-24',
        'stock_quantity': 80,
        'is_available': 1,
        'requires_prescription': 0,
        'dosage': '500mg',
        'active_ingredient': 'Acetaminophen',
        'manufacturer': 'Johnson & Johnson',
        'rating': 4.6,
        'review_count': 142,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      {
        'name': 'Aspirin 325mg',
        'description': 'Low-dose aspirin for heart health and pain relief',
        'price': 35.00,
        'image': 'assets/img/aspirin.jpg',
        'category': 'medicines',
        'brand': 'Bayer',
        'sku': 'ASP-325-100',
        'stock_quantity': 200,
        'is_available': 1,
        'requires_prescription': 0,
        'dosage': '325mg',
        'active_ingredient': 'Acetylsalicylic Acid',
        'manufacturer': 'Bayer',
        'rating': 4.3,
        'review_count': 78,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      
      // More Vitamins
      {
        'name': 'Multivitamins Complete',
        'description': 'Complete daily multivitamin with minerals',
        'price': 450.00,
        'image': 'assets/img/multivitamins.jpg',
        'category': 'vitamins',
        'brand': 'Centrum',
        'sku': 'MUL-COM-30',
        'stock_quantity': 60,
        'is_available': 1,
        'requires_prescription': 0,
        'manufacturer': 'Pfizer',
        'rating': 4.5,
        'review_count': 203,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      {
        'name': 'Vitamin D3 1000IU',
        'description': 'High-potency Vitamin D3 for bone health',
        'price': 320.00,
        'image': 'assets/img/vitamin-d3.jpg',
        'category': 'vitamins',
        'brand': 'Nature Made',
        'sku': 'VIT-D3-1000-60',
        'stock_quantity': 90,
        'is_available': 1,
        'requires_prescription': 0,
        'dosage': '1000IU',
        'active_ingredient': 'Cholecalciferol',
        'manufacturer': 'Nature Made',
        'rating': 4.7,
        'review_count': 156,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      {
        'name': 'Omega-3 Fish Oil',
        'description': 'Premium fish oil capsules for heart and brain health',
        'price': 680.00,
        'image': 'assets/img/omega3.jpg',
        'category': 'vitamins',
        'brand': 'Nordic Naturals',
        'sku': 'OME-3-120',
        'stock_quantity': 45,
        'is_available': 1,
        'requires_prescription': 0,
        'manufacturer': 'Nordic Naturals',
        'rating': 4.8,
        'review_count': 234,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      
      // First Aid Items
      {
        'name': 'Alcohol 70% 500ml',
        'description': 'Isopropyl alcohol for disinfection and cleaning',
        'price': 45.00,
        'image': 'assets/img/alcohol.jpg',
        'category': 'first_aid',
        'brand': 'Green Cross',
        'sku': 'ALC-70-500',
        'stock_quantity': 150,
        'is_available': 1,
        'requires_prescription': 0,
        'active_ingredient': 'Isopropyl Alcohol',
        'manufacturer': 'Green Cross',
        'rating': 4.2,
        'review_count': 67,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      {
        'name': 'Band-Aid Adhesive Bandages',
        'description': 'Sterile adhesive bandages for wound protection',
        'price': 125.00,
        'image': 'assets/img/bandaid.jpg',
        'category': 'first_aid',
        'brand': 'Band-Aid',
        'sku': 'BND-AID-50',
        'stock_quantity': 200,
        'is_available': 1,
        'requires_prescription': 0,
        'manufacturer': 'Johnson & Johnson',
        'rating': 4.6,
        'review_count': 189,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      {
        'name': 'Hydrogen Peroxide 3%',
        'description': 'Antiseptic solution for wound cleaning',
        'price': 35.00,
        'image': 'assets/img/hydrogen-peroxide.jpg',
        'category': 'first_aid',
        'brand': 'Generic',
        'sku': 'HYD-PER-250',
        'stock_quantity': 100,
        'is_available': 1,
        'requires_prescription': 0,
        'active_ingredient': 'Hydrogen Peroxide',
        'manufacturer': 'Generic Pharma',
        'rating': 4.1,
        'review_count': 45,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      
      // Prescription Drugs
      {
        'name': 'Losartan 50mg',
        'description': 'ACE inhibitor for high blood pressure',
        'price': 180.00,
        'image': 'assets/img/losartan.jpg',
        'category': 'prescription_drugs',
        'brand': 'Generics',
        'sku': 'LOS-50-30',
        'stock_quantity': 60,
        'is_available': 1,
        'requires_prescription': 1,
        'dosage': '50mg',
        'active_ingredient': 'Losartan Potassium',
        'manufacturer': 'Generics Pharmacy',
        'rating': 4.4,
        'review_count': 89,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      {
        'name': 'Metformin 500mg',
        'description': 'Diabetes medication for blood sugar control',
        'price': 95.00,
        'image': 'assets/img/metformin.jpg',
        'category': 'prescription_drugs',
        'brand': 'Generics',
        'sku': 'MET-500-30',
        'stock_quantity': 80,
        'is_available': 1,
        'requires_prescription': 1,
        'dosage': '500mg',
        'active_ingredient': 'Metformin HCl',
        'manufacturer': 'Generics Pharmacy',
        'rating': 4.3,
        'review_count': 112,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
    ];
    
    // Insert new products
    for (var product in newProducts) {
      await db.insert('products', product);
    }
    
    // Check total products
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM products');
    final count = result.first['count'];
    
    print('✅ Successfully added ${newProducts.length} new medicines!');
    print('📦 Total products in database: $count');
    print('\n🎯 Your home view will now show more variety of medicines.');
    
    await db.close();
  } catch (e) {
    print('❌ Error adding medicines: $e');
  }
}

void main() async {
  await addMoreMedicines();
}