import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/game_object.dart';
import '../widgets/game_object_widget.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final List<GameObject> gameObjects = [];
  late Timer gameTimer;
  int score = 0;
  final random = Random();

  @override
  void initState() {
    super.initState();
    startGame();
  }

  @override
  void dispose() {
    gameTimer.cancel();
    super.dispose();
  }

  void startGame() {
    // Add initial game objects
    addRandomGameObject();

    // Start game loop
    gameTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      updateGameObjects();
    });

    // Add new objects periodically
    Timer.periodic(const Duration(seconds: 3), (timer) {
      if (gameObjects.length < 5) {
        addRandomGameObject();
      }
    });
  }

  void addRandomGameObject() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final type = GameObjectType.values[random.nextInt(GameObjectType.values.length)];
    final x = random.nextDouble() * (screenWidth - 50);
    final y = random.nextDouble() * (screenHeight - 50);
    final speedX = (random.nextDouble() - 0.5) * 5;
    final speedY = (random.nextDouble() - 0.5) * 5;

    setState(() {
      gameObjects.add(
        GameObject(
          type: type,
          x: x,
          y: y,
          speedX: speedX,
          speedY: speedY,
        ),
      );
    });
  }

  void updateGameObjects() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    setState(() {
      for (final object in gameObjects) {
        object.move(screenWidth - 50, screenHeight - 50);
      }
      gameObjects.removeWhere((object) => !object.isActive);
    });
  }

  void onObjectTap(GameObject object) {
    object.onTouch();
    setState(() {
      score += 10;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Score display
          Positioned(
            top: 40,
            right: 20,
            child: Text(
              'Score: $score',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Game objects
          ...gameObjects.map((object) => GameObjectWidget(
                gameObject: object,
                onTap: () => onObjectTap(object),
              )),
        ],
      ),
    );
  }
}
