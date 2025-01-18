import 'package:flutter/material.dart';
import '../models/game_object.dart';

class GameObjectWidget extends StatelessWidget {
  final GameObject gameObject;
  final VoidCallback onTap;

  const GameObjectWidget({
    super.key,
    required this.gameObject,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (!gameObject.isActive) return const SizedBox.shrink();

    return Positioned(
      left: gameObject.position.dx,
      top: gameObject.position.dy,
      child: GestureDetector(
        onTapDown: (_) => onTap(),
        child: Container(
          width: gameObject.size,
          height: gameObject.size,
          decoration: BoxDecoration(
            color: _getColor(),
            shape: _getShape(),
          ),
        ),
      ),
    );
  }

  Color _getColor() {
    switch (gameObject.type) {
      case GameObjectType.mouse:
        return Colors.grey;
      case GameObjectType.bug:
        return Colors.brown;
      case GameObjectType.laserDot:
        return Colors.red;
      case GameObjectType.feather:
        return Colors.orange;
      case GameObjectType.yarnBall:
        return Colors.blue;
    }
  }

  BoxShape _getShape() {
    switch (gameObject.type) {
      case GameObjectType.laserDot:
        return BoxShape.circle;
      default:
        return BoxShape.rectangle;
    }
  }
}
