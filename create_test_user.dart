import 'lib/common/database_helper.dart';

void main() async {
  print('🔧 Creating test user for Nine27 Pharmacy...\n');
  
  try {
    final dbHelper = DatabaseHelper();
    
    // Create a test user
    final result = await dbHelper.registerUser(
      name: 'Test User',
      email: 'test@nine27pharmacy.com',
      mobile: '09123456789',
      address: '123 Test Street, Test City',
      password: 'password123',
    );
    
    if (result['success']) {
      print('✅ Test user created successfully!');
      print('📧 Email: test@nine27pharmacy.com');
      print('🔑 Password: password123');
      print('\n🎯 You can now use these credentials to login in your app.');
    } else {
      print('❌ Failed to create test user: ${result['message']}');
    }
  } catch (e) {
    print('❌ Error: $e');
  }
}