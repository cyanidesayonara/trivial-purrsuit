import 'package:flutter/material.dart';
import '../models/game_object.dart';

class GameObjectWidget extends StatelessWidget {
  final GameObject gameObject;
  final Function onTap;

  const GameObjectWidget({
    Key? key,
    required this.gameObject,
    required this.onTap,
  }) : super(key: key);

  Size _getObjectSize() {
    switch (gameObject.type) {
      case GameObjectType.mouse:
      case GameObjectType.bug:
      case GameObjectType.feather:
        return const Size(100, 100); // Twice as big
      case GameObjectType.laserDot:
        return const Size(25, 25); // Half size
      case GameObjectType.yarnBall:
        return const Size(50, 50); // Original size
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!gameObject.isActive) return const SizedBox.shrink();

    final size = _getObjectSize();
    return Positioned(
      left: gameObject.x,
      top: gameObject.y,
      child: GestureDetector(
        onTapDown: (_) => onTap(),
        child: CustomPaint(
          painter: gameObject.painter,
          size: size,
        ),
      ),
    );
  }
}
