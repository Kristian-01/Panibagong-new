import 'lib/services/local_database_service.dart';

void main() async {
  print('🔍 Debugging Home View Data...\n');
  
  try {
    final dbService = LocalDatabaseService();
    
    // Test database connection
    final isConnected = await dbService.testConnection();
    print('Database connected: $isConnected\n');
    
    if (isConnected) {
      // Get all products
      final products = await dbService.getProducts();
      print('📦 Total products found: ${products.length}');
      
      if (products.isEmpty) {
        print('❌ No products in database! This is why home view is empty.');
        print('💡 Run: dart populate_database.dart to add sample data');
      } else {
        print('✅ Products found in database:');
        
        // Group by category
        final medicines = products.where((p) => p.category == 'medicines').toList();
        final vitamins = products.where((p) => p.category == 'vitamins').toList();
        final firstAid = products.where((p) => p.category == 'first_aid').toList();
        final prescription = products.where((p) => p.category == 'prescription_drugs').toList();
        
        print('💊 Medicines: ${medicines.length}');
        for (var product in medicines.take(3)) {
          print('   - ${product.name} (${product.formattedPrice})');
        }
        
        print('🧴 Vitamins: ${vitamins.length}');
        for (var product in vitamins.take(3)) {
          print('   - ${product.name} (${product.formattedPrice})');
        }
        
        print('🩹 First Aid: ${firstAid.length}');
        for (var product in firstAid.take(3)) {
          print('   - ${product.name} (${product.formattedPrice})');
        }
        
        print('📋 Prescription: ${prescription.length}');
        for (var product in prescription.take(3)) {
          print('   - ${product.name} (${product.formattedPrice})');
        }
        
        print('\n🎯 Home view should show:');
        print('   - Featured Medicines: ${medicines.take(5).length} items');
        print('   - Popular Vitamins: ${vitamins.take(4).length} items');
        print('   - Recent Items: ${products.take(3).length} items');
      }
    }
  } catch (e) {
    print('❌ Error: $e');
  }
}