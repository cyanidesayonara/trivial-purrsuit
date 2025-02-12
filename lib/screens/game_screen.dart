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
    final x = random.nextDouble() * (screenSize!.width - 50);
    final y = random.nextDouble() * (screenSize!.height - 50);
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
    if (screenSize == null) return;

    setState(() {
      for (final object in gameObjects) {
        object.move(screenSize!.width - 50, screenSize!.height - 50);
      }
      gameObjects.removeWhere((object) => !object.isActive);
    });
  }

  void onObjectTap(GameObject object) {
    object.onTouch();
    setState(() {
      score += 10;
      // Spawn a new object immediately if we're under the limit
      if (gameObjects.length < maxObjects) {
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
