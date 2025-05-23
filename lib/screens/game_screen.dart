import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/game_object.dart';
import '../widgets/game_object_widget.dart';
import '../services/feedback_service.dart';
import '../models/game_types.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with WidgetsBindingObserver {
  final List<GameObject> gameObjects = [];
  Timer? gameTimer;
  Timer? spawnTimer;
  int score = 0;
  final random = Random();
  Size? screenSize;
  static const maxObjects = 2; // Limit to 2 objects at a time
  final FeedbackService _feedback = FeedbackService();
  bool _isInitialized = false;
  GameObjectType? _lastSpawnedType;  // Track the last spawned object type
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Wait for the first frame to be rendered before initializing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeGame();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    gameTimer?.cancel();
    spawnTimer?.cancel();
    _feedback.dispose();
    // Reset orientation settings
    SystemChrome.setPreferredOrientations([]);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _pauseGame();
    } else if (state == AppLifecycleState.resumed) {
      _resumeGame();
    }
  }

  Future<void> _initializeGame() async {
    if (_isInitialized) return;

    try {
      // Get screen size first
      screenSize = MediaQuery.of(context).size;
      if (screenSize == null) {
        print('Screen size not available yet');
        return;
      }

      // Initialize feedback service
      await _feedback.initialize();

      // Force landscape mode
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        startGame();
      }
    } catch (e) {
      print('Failed to initialize game: $e');
    }
  }

  void startGame() {
    if (!_isInitialized) {
      print('Game not initialized yet');
      return;
    }

    // Clear any existing objects and timers
    gameObjects.clear();
    gameTimer?.cancel();
    spawnTimer?.cancel();
    _lastSpawnedType = null;  // Reset the last spawned type

    // Add initial game object
    addRandomGameObject();

    // Start game loop
    const fps = 60;
    gameTimer = Timer.periodic(
      const Duration(milliseconds: 1000 ~/ fps),
      (_) => updateGameObjects(),
    );

    // Start spawning objects
    spawnTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) {
        if (gameObjects.length < maxObjects) {
          addRandomGameObject();
        }
      },
    );
  }

  void _pauseGame() {
    _isPaused = true;
    gameTimer?.cancel();
    spawnTimer?.cancel();
  }

  void _resumeGame() {
    _isPaused = false;
    startGame();
  }

  void addRandomGameObject() {
    if (_isPaused) return;

    if (screenSize == null) return;

    // Get a random type that's not currently in play
    GameObjectType type;
    final existingTypes = gameObjects.map((obj) => obj.type).toSet();
    final availableTypes = GameObjectType.values.toSet().difference(existingTypes);

    if (availableTypes.isEmpty) {
      print('No available unique types to spawn');
      return;
    }

    // Convert to list for random selection
    final typesList = availableTypes.toList();
    type = typesList[random.nextInt(typesList.length)];
    _lastSpawnedType = type;  // Update the last spawned type
    
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
    if (_isPaused) return;

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
      // Play appropriate feedback for the object type
      switch (object.type) {
        case GameObjectType.mouse:
          _feedback.playFeedback(GameObjectSound.mouse);
          break;
        case GameObjectType.bug:
          _feedback.playFeedback(GameObjectSound.bug);
          break;
        case GameObjectType.laserDot:
          _feedback.playFeedback(GameObjectSound.laser);
          break;
        case GameObjectType.feather:
          _feedback.playFeedback(GameObjectSound.feather);
          break;
        case GameObjectType.yarnBall:
          _feedback.playFeedback(GameObjectSound.yarnBall);
          break;
      }
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
        body: Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.2,
              colors: [
                const Color(0xFF1B4B6A), // Lighter blue in center
                const Color(0xFF0A2436), // Darker blue at edges
              ],
              stops: const [0.0, 1.0],
            ),
          ),
          child: Stack(
            children: [
              // Outer gold trim
              Positioned.fill(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFFD4AF37), // Classic gold color
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              
              // Inner gold trim
              Positioned.fill(
                child: Container(
                  margin: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFFD4AF37), // Classic gold color
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              
              // Title
              Center(
                child: Text(
                  'Trivial Purrsuit',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.greatVibes(
                    fontSize: 80,
                    color: const Color(0xFFD4AF37), // Classic gold color
                    shadows: [
                      const Shadow(
                        color: Colors.black26,
                        offset: Offset(2, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),

              // Game objects
              ...gameObjects.map((obj) => GameObjectWidget(
                gameObject: obj,
                onTap: () => onObjectTap(obj),
              )),
            ],
          ),
        ),
      ),
    );
  }
}
