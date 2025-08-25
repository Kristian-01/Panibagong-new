import 'dart:io';

void main() async {
  print('🔧 Fixing invalid icons in home_view.dart...');
  
  final file = File('lib/view/home/home_view.dart');
  String content = await file.readAsString();
  
  // Replace invalid Icons.vitamins with Icons.medication
  content = content.replaceAll('Icons.vitamins', 'Icons.medication');
  
  await file.writeAsString(content);
  
  print('✅ Fixed invalid icons!');
  print('📝 Replaced Icons.vitamins with Icons.medication');
}