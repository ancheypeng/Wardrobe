import 'package:flutter/material.dart';
import 'package:wardrobe/screens/home_screen.dart';
import 'package:wardrobe/screens/items_screen.dart';
import 'package:wardrobe/screens/outfit_screen.dart';
import 'package:wardrobe/screens/outfit_add_items_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/homeScreen',
      routes: {
        '/homeScreen': (context) => HomeScreen(),
      }
    );
  }
}
