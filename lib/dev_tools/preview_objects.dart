import 'package:flutter/material.dart';
import '../models/game_object.dart';

void main() {
  runApp(const PreviewApp());
}

class PreviewApp extends StatelessWidget {
  const PreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Game Objects Preview'),
          backgroundColor: Colors.purple,
          foregroundColor: Colors.white,
        ),
        body: GridView.count(
          crossAxisCount: 2,
          padding: const EdgeInsets.all(16),
          children: GameObjectType.values.map((type) {
            return Card(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomPaint(
                    painter: GameObject(
                      type: type,
                      x: 0,
                      y: 0,
                    ).painter,
                    size: const Size(100, 100),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    type.toString().split('.').last,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
