import 'package:flutter/material.dart';
import 'package:flutter_3d_tetris/game/game.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: GamePage(),
    );
  }
}
