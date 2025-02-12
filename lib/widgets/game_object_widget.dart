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

  @override
  Widget build(BuildContext context) {
    if (!gameObject.isActive) return const SizedBox.shrink();

    return Positioned(
      left: gameObject.position.dx,
      top: gameObject.position.dy,
      child: GestureDetector(
        onTapDown: (_) => onTap(),
        child: CustomPaint(
          painter: gameObject.painter,
          size: Size(gameObject.size, gameObject.size),
        ),
      ),
    );
  }
}
