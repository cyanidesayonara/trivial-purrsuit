import 'dart:math';
import 'package:flutter/material.dart';

enum GameObjectType {
  mouse,
  laserDot,
  bug,
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
  DateTime createdAt;
  DateTime lastInteractionAt;
  static const maxLifetimeSeconds = 15; // Random between 10-20 seconds

  GameObject({
    required this.type,
    required this.x,
    required this.y,
    this.speedX = 0,
    this.speedY = 0,
  }) : isActive = true,
       createdAt = DateTime.now(),
       lastInteractionAt = DateTime.now();

  void move(double maxX, double maxY) {
    // Check if object has expired
    final now = DateTime.now();
    final lifetime = now.difference(lastInteractionAt).inSeconds;
    if (lifetime > maxLifetimeSeconds + Random().nextInt(10)) { // Adds 0-10 seconds randomly
      isActive = false;
      return;
    }

    x += speedX;
    y += speedY;

    // Bounce off edges
    if (x <= 0 || x >= maxX) {
      speedX = -speedX;
      x = x <= 0 ? 0 : maxX;
    }
    if (y <= 0 || y >= maxY) {
      speedY = -speedY;
      y = y <= 0 ? 0 : maxY;
    }
  }

  void onTouch() {
    lastInteractionAt = DateTime.now();
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

  CustomPainter get painter {
    switch (type) {
      case GameObjectType.mouse:
        return MousePainter();
      case GameObjectType.laserDot:
        return LaserDotPainter();
      case GameObjectType.bug:
        return BugPainter();
      case GameObjectType.feather:
        return FeatherPainter();
      case GameObjectType.yarnBall:
        return YarnBallPainter();
    }
  }
}

class MousePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.fill;

    // Body
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.6),
        width: size.width * 0.6,
        height: size.height * 0.4,
      ),
      paint,
    );

    // Head
    canvas.drawCircle(
      Offset(size.width * 0.3, size.height * 0.5),
      size.width * 0.15,
      paint,
    );

    // Ears
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.25, size.height * 0.35),
        width: size.width * 0.15,
        height: size.height * 0.2,
      ),
      paint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.35, size.height * 0.35),
        width: size.width * 0.15,
        height: size.height * 0.2,
      ),
      paint,
    );

    // Tail
    final tailPath = Path()
      ..moveTo(size.width * 0.7, size.height * 0.6)
      ..quadraticBezierTo(
        size.width * 0.9,
        size.height * 0.7,
        size.width * 0.8,
        size.height * 0.4,
      );

    canvas.drawPath(
      tailPath,
      paint..strokeWidth = 3..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class LaserDotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    // Glowing dot
    for (var i = 3; i > 0; i--) {
      paint.color = Colors.red.withOpacity(0.3 * i);
      canvas.drawCircle(
        Offset(size.width / 2, size.height / 2),
        size.width * 0.2 * i,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BugPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.brown
      ..style = PaintingStyle.fill;

    // Body segments
    canvas.drawCircle(
      Offset(size.width * 0.4, size.height * 0.5),
      size.width * 0.15,
      paint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.6, size.height * 0.5),
      size.width * 0.15,
      paint,
    );

    // Legs
    paint.strokeWidth = 2;
    paint.style = PaintingStyle.stroke;
    for (var i = 0; i < 3; i++) {
      canvas.drawLine(
        Offset(size.width * 0.4, size.height * 0.5),
        Offset(size.width * 0.2, size.height * (0.4 + i * 0.1)),
        paint,
      );
      canvas.drawLine(
        Offset(size.width * 0.6, size.height * 0.5),
        Offset(size.width * 0.8, size.height * (0.4 + i * 0.1)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class FeatherPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.fill;

    // Create the main feather shape
    final path = Path();
    
    // Start from the top
    path.moveTo(size.width * 0.2, size.height * 0.2);
    
    // Right side of feather
    path.quadraticBezierTo(
      size.width * 0.6,
      size.height * 0.4,
      size.width * 0.8,
      size.height * 0.8,
    );
    
    // Bottom curve
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.85,
      size.width * 0.7,
      size.height * 0.8,
    );
    
    // Left side of feather
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.4,
      size.width * 0.2,
      size.height * 0.2,
    );
    
    canvas.drawPath(path, paint);

    // Draw the spine
    paint
      ..color = Colors.orange.shade800
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    path.reset();
    path.moveTo(size.width * 0.2, size.height * 0.2);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.5,
      size.width * 0.75,
      size.height * 0.8,
    );
    canvas.drawPath(path, paint);

    // Draw barbs
    paint
      ..strokeWidth = 1
      ..color = Colors.orange.shade700;

    for (var i = 0; i < 12; i++) {
      final t = i / 12;
      final spineX = size.width * (0.2 + t * 0.55);
      final spineY = size.height * (0.2 + t * 0.6);
      
      // Left barbs
      canvas.drawLine(
        Offset(spineX, spineY),
        Offset(spineX - size.width * 0.15, spineY + size.height * 0.05),
        paint,
      );
      
      // Right barbs
      canvas.drawLine(
        Offset(spineX, spineY),
        Offset(spineX + size.width * 0.15, spineY + size.height * 0.05),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class YarnBallPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw circular patterns
    for (var i = 0; i < 5; i++) {
      canvas.drawCircle(
        Offset(size.width * 0.5, size.height * 0.5),
        size.width * (0.1 + i * 0.1),
        paint,
      );
    }

    // Draw loose strands
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.2),
      Offset(size.width * 0.7, size.height * 0.1),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.8),
      Offset(size.width * 0.3, size.height * 0.9),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
