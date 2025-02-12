import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/game_object.dart';
import '../widgets/game_object_widget.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final List<GameObject> gameObjects = [];
  Timer? gameTimer;
  Timer? spawnTimer;
  int score = 0;
  final random = Random();
  Size? screenSize;
  static const maxObjects = 2; // Limit to 2 objects at a time

  @override
  void initState() {
    super.initState();
    // Force landscape mode
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    // We'll start the game when we have the screen size
    WidgetsBinding.instance.addPostFrameCallback((_) {
      startGame();
    });
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    spawnTimer?.cancel();
    // Reset orientation settings
    SystemChrome.setPreferredOrientations([]);
    super.dispose();
  }

  void startGame() {
    screenSize = MediaQuery.of(context).size;
    // Add initial game object
    addRandomGameObject();

    // Start game loop
    gameTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      updateGameObjects();
    });

    // Add new objects periodically
    spawnTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (gameObjects.length < maxObjects) {
        addRandomGameObject();
      }
    });
  }

  void addRandomGameObject() {
    if (screenSize == null) return;

    final type = GameObjectType.values[random.nextInt(GameObjectType.values.length)];
    
    // Get the object size to properly calculate boundaries
    double objectSize;
    switch (type) {
      case GameObjectType.mouse:
      case GameObjectType.bug:
      case GameObjectType.feather:
        objectSize = 100;
        break;
      case GameObjectType.laserDot:
        objectSize = 25;
        break;
      case GameObjectType.yarnBall:
        objectSize = 50;
        break;
    }

    // For yarn ball, start at top of screen
    double x, y;
    if (type == GameObjectType.yarnBall) {
      x = random.nextDouble() * (screenSize!.width - objectSize);
      y = 0; // Start from top
    } else {
      x = random.nextDouble() * (screenSize!.width - objectSize);
      y = random.nextDouble() * (screenSize!.height - objectSize);
    }

    final speedX = (random.nextDouble() - 0.5) * 5;
    final speedY = type == GameObjectType.yarnBall ? 0.0 : (random.nextDouble() - 0.5) * 5; // Explicitly using 0.0 for double

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
    if (screenSize == null) return;

    setState(() {
      for (final object in gameObjects) {
        // Get the object size for boundary checking
        double objectSize;
        switch (object.type) {
          case GameObjectType.mouse:
          case GameObjectType.bug:
          case GameObjectType.feather:
            objectSize = 100;
            break;
          case GameObjectType.laserDot:
            objectSize = 25;
            break;
          case GameObjectType.yarnBall:
            objectSize = 50;
            break;
        }
        object.move(screenSize!.width - objectSize, screenSize!.height - objectSize);
      }
      gameObjects.removeWhere((object) => !object.isActive);
    });
  }

  void onObjectTap(GameObject object) {
    object.onTouch();
    setState(() {
      score += 10;
      // Spawn a new object immediately if we're under the limit and the tapped object was a bug (since it disappears)
      if (object.type == GameObjectType.bug && gameObjects.length < maxObjects) {
        addRandomGameObject();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Reset orientation before exiting
        await SystemChrome.setPreferredOrientations([]);
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // Score display
            Positioned(
              top: 20,
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
      ),
    );
  }
}
