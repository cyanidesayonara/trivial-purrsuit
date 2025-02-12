import 'dart:math';
import 'package:flutter/material.dart';

enum GameObjectType {
  mouse,
  bug,
  laserDot,
  feather,
  yarnBall,
}

class GameObject {
  final GameObjectType type;
  Offset position;
  Offset velocity;
  bool isActive;
  final double size;

  GameObject({
    required this.type,
    required this.position,
    Offset? velocity,
    this.size = 50.0,
  })  : velocity = velocity ?? _getRandomVelocity(),
        isActive = true;

  static Offset _getRandomVelocity() {
    final random = Random();
    return Offset(
      (random.nextDouble() - 0.5) * 5,
      (random.nextDouble() - 0.5) * 5,
    );
  }

  void update(Size screenSize) {
    if (!isActive) return;

    position += velocity;

    // Bounce off screen edges
    if (position.dx <= 0 || position.dx >= screenSize.width - size) {
      velocity = Offset(-velocity.dx, velocity.dy);
    }
    if (position.dy <= 0 || position.dy >= screenSize.height - size) {
      velocity = Offset(velocity.dx, -velocity.dy);
    }

    // Keep within bounds
    position = Offset(
      position.dx.clamp(0, screenSize.width - size),
      position.dy.clamp(0, screenSize.height - size),
    );
  }

  void onTap() {
    switch (type) {
      case GameObjectType.mouse:
        // Scurry away - increase speed and change direction
        final random = Random();
        velocity *= 2;
        velocity = Offset(
          velocity.dx + (random.nextDouble() - 0.5) * 10,
          velocity.dy + (random.nextDouble() - 0.5) * 10,
        );
        break;
      case GameObjectType.bug:
        // Get squished
        isActive = false;
        break;
      case GameObjectType.laserDot:
        // Teleport to a random location
        final random = Random();
        position = Offset(
          random.nextDouble() * 300,
          random.nextDouble() * 300,
        );
        break;
      case GameObjectType.feather:
        velocity = _getRandomVelocity();
        break;
      case GameObjectType.yarnBall:
        // Roll - increase angular momentum (will be implemented in the widget)
        break;
    }
  }
}
