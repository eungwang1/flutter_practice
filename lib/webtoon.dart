import 'package:flutter/material.dart';
import 'package:toonflix/screens/home_screen.webtoon.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: WebtoonHomeScreen(),
    );
  }
}
