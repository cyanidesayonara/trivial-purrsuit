import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/game_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Set preferred orientations to portrait only
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  // Set full screen
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersive,
    overlays: [],
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trivial Purrsuit',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
        useMaterial3: true,
      ),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  final List<GameObject> _gameObjects = [];
  late final AnimationController _controller;
  final Random _random = Random();
  static const maxObjects = 2;
  DateTime? _lastSpawnTime;

  @override
  void initState() {
    super.initState();
    // Lock to landscape orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // Setup animation controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16), // ~60 FPS
    )..addListener(_updateGameObjects);

    // Start the game
    _controller.repeat();
    _spawnGameObjects();
  }

  void _spawnGameObjects() {
    // Add initial game object
    final types = GameObjectType.values;
    _gameObjects.add(
      GameObject(
        type: types[_random.nextInt(types.length)],
        position: Offset(
          _random.nextDouble() * 300,
          _random.nextDouble() * 300,
        ),
      ),
    );
    _lastSpawnTime = DateTime.now();
  }

  void _updateGameObjects() {
    if (!mounted) return;

    setState(() {
      final size = MediaQuery.of(context).size;
      for (var object in _gameObjects) {
        object.update(size);
      }

      // Remove inactive objects
      _gameObjects.removeWhere((object) => !object.isActive);

      // Check if we need to spawn new objects
      final now = DateTime.now();
      if (_gameObjects.length < maxObjects && 
          (_lastSpawnTime == null || now.difference(_lastSpawnTime!) > const Duration(seconds: 3))) {
        final types = GameObjectType.values;
        _gameObjects.add(
          GameObject(
            type: types[_random.nextInt(types.length)],
            position: Offset(
              _random.nextDouble() * size.width,
              _random.nextDouble() * size.height,
            ),
          ),
        );
        _lastSpawnTime = now;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Container(
          color: Colors.black,
          child: Stack(
            children: [
              for (final object in _gameObjects)
                GameObjectWidget(
                  key: ValueKey(object),
                  gameObject: object,
                  onTap: () => object.onTap(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    SystemChrome.setPreferredOrientations([]);
    super.dispose();
  }
}
