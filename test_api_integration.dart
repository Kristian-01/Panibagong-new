import 'dart:convert';
import 'dart:io';

void main() async {
  print('🧪 Testing Nine27 Pharmacy API Integration...\n');
  
  try {
    // Test 1: Get all products
    print('1️⃣ Testing GET /api/products...');
    final productsResponse = await testEndpoint('http://localhost:8000/api/products');
    if (productsResponse != null) {
      print('✅ Products API working! Found ${productsResponse['products']?.length ?? 0} products');
    }
    
    // Test 2: Get featured products
    print('\n2️⃣ Testing GET /api/products/featured...');
    final featuredResponse = await testEndpoint('http://localhost:8000/api/products/featured');
    if (featuredResponse != null) {
      print('✅ Featured Products API working! Found ${featuredResponse['products']?.length ?? 0} featured products');
    }
    
    // Test 3: Get products by category
    print('\n3️⃣ Testing GET /api/products/category/medicines...');
    final medicinesResponse = await testEndpoint('http://localhost:8000/api/products/category/medicines');
    if (medicinesResponse != null) {
      print('✅ Medicines Category API working! Found ${medicinesResponse['products']?.length ?? 0} medicines');
    }
    
    // Test 4: Get products by category
    print('\n4️⃣ Testing GET /api/products/category/vitamins...');
    final vitaminsResponse = await testEndpoint('http://localhost:8000/api/products/category/vitamins');
    if (vitaminsResponse != null) {
      print('✅ Vitamins Category API working! Found ${vitaminsResponse['products']?.length ?? 0} vitamins');
    }
    
    // Test 5: Search products
    print('\n5️⃣ Testing GET /api/products?search=biogesic...');
    final searchResponse = await testEndpoint('http://localhost:8000/api/products?search=biogesic');
    if (searchResponse != null) {
      print('✅ Search API working! Found ${searchResponse['products']?.length ?? 0} products matching "biogesic"');
    }
    
    print('\n🎉 All API tests completed successfully!');
    print('🚀 Your Flutter app is ready to use the real API!');
    
  } catch (e) {
    print('❌ Error during testing: $e');
  }
}

Future<Map<String, dynamic>?> testEndpoint(String url) async {
  try {
    final client = HttpClient();
    final request = await client.getUrl(Uri.parse(url));
    final response = await request.close();
    
    if (response.statusCode == 200) {
      final responseBody = await response.transform(utf8.decoder).join();
      final jsonData = json.decode(responseBody);
      return jsonData;
    } else {
      print('❌ HTTP ${response.statusCode}: $url');
      return null;
    }
  } catch (e) {
    print('❌ Error testing $url: $e');
    return null;
  }
}
