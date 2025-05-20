import 'package:flutter/material.dart';
import 'package:web_portfolio/pages/home.dart';

void main() {
  runApp(Portfolio());
}

class Portfolio extends StatelessWidget {
  Portfolio({key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Jasir pk',
      home: HomeScreen(),
    );
  }
}
