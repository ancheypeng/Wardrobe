import 'package:flutter/material.dart';
import 'package:wardrobe/screens/home_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          scaffoldBackgroundColor: Colors.grey[200],
        ),
        initialRoute: '/homeScreen',
        routes: {
          '/homeScreen': (context) => HomeScreen(),
        });
  }
}
