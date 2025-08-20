import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nine27_pharmacy_app/providers/cart_provider.dart';
import 'package:nine27_pharmacy_app/screens/home_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}
