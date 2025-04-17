import 'package:flutter/material.dart';
import 'package:ecommerce/home_page.dart';
import 'package:ecommerce/show_products.dart';
import 'package:ecommerce/add_product.dart';
import 'package:ecommerce/show_users.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chick Shop',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: Colors.orange[50],
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(255, 255, 191, 94),
          foregroundColor: Colors.black,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange[700],
            foregroundColor: Colors.black,
          ),
        ),
      ),
      home: const HomePage(),
    );
  }
}