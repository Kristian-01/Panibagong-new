// Test local SQLite database
import 'lib/services/local_database_service.dart';

void main() async {
  print('🚀 Testing Local SQLite Database for Nine27 Pharmacy\n');
  
  try {
    await testLocalDatabase();
    
    print('\n✅ Local database test completed!');
    print('💡 You can use this as a fallback while setting up Laravel');
    
  } catch (e) {
    print('❌ Local database test failed: $e');
    print('💡 Make sure sqflite dependency is added to pubspec.yaml');
  }
}
