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
          title: const Text('Game Object Previews'),
        ),
        body: GridView.count(
          crossAxisCount: 2,
          padding: const EdgeInsets.all(16),
          children: GameObjectType.values.map((type) {
            final gameObject = GameObject(
              type: type,
              x: 0,
              y: 0,
            );
            return Card(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    gameObject.imagePath,
                    width: 100,
                    height: 100,
                  ),
                  const SizedBox(height: 8),
                  Text(type.toString().split('.').last),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
