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
  double x;
  double y;
  double speedX;
  double speedY;
  bool isActive;

  // Get the image path based on the object type
  String get imagePath {
    switch (type) {
      case GameObjectType.mouse:
        return 'assets/images/mouse.png';
      case GameObjectType.bug:
        return 'assets/images/bug.png';
      case GameObjectType.laserDot:
        return 'assets/images/laser_dot.png';
      case GameObjectType.feather:
        return 'assets/images/feather.png';
      case GameObjectType.yarnBall:
        return 'assets/images/yarn_ball.png';
    }
  }

  GameObject({
    required this.type,
    required this.x,
    required this.y,
    this.speedX = 0,
    this.speedY = 0,
    this.isActive = true,
  });

  void move(double screenWidth, double screenHeight) {
    x += speedX;
    y += speedY;

    // Bounce off screen edges
    if (x <= 0 || x >= screenWidth) {
      speedX = -speedX;
      x = x <= 0 ? 0 : screenWidth;
    }
    if (y <= 0 || y >= screenHeight) {
      speedY = -speedY;
      y = y <= 0 ? 0 : screenHeight;
    }
  }

  void onTouch() {
    switch (type) {
      case GameObjectType.mouse:
        // Mouse scurries away in a random direction
        final random = Random();
        speedX = (random.nextDouble() - 0.5) * 20;
        speedY = (random.nextDouble() - 0.5) * 20;
        break;
      case GameObjectType.bug:
        // Bug gets squished and disappears
        isActive = false;
        break;
      case GameObjectType.laserDot:
        // Laser dot teleports to a random location
        final random = Random();
        x = random.nextDouble() * 300;
        y = random.nextDouble() * 300;
        break;
      case GameObjectType.feather:
        // Feather floats away gently
        speedY = -5;
        speedX = Random().nextDouble() * 4 - 2;
        break;
      case GameObjectType.yarnBall:
        // Yarn ball rolls faster
        speedX *= 1.5;
        speedY *= 1.5;
        break;
    }
  }
}
