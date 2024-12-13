import 'package:brick_breaker/presentation/home/home_screen.dart';
import 'package:flutter/material.dart';



void main() {
  runApp(const MinigameApp());
}
class MinigameApp extends StatelessWidget {
  const MinigameApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Minigame App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}
