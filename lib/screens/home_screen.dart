import 'package:flutter/material.dart';
import 'order_screen.dart';
import 'prescription_screen.dart';
import 'profile_screen.dart';
import 'product_screen.dart'; // 👈 Import this

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nine27 Pharmacy")),
      body: Center(child: Text("Welcome to Nine27 Pharmacy")),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.teal),
              child: Text("Menu", style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              title: Text("Shop"),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => ProductScreen()));
              },
            ),
            ListTile(
              title: Text("Orders"),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => OrderScreen()));
              },
            ),
            ListTile(
              title: Text("Prescription"),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => PrescriptionScreen()));
              },
            ),
            ListTile(
              title: Text("Profile"),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen()));
              },
            ),
          ],
        ),
      ),
    );
  }
}
