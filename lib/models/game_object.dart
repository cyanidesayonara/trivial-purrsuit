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

  CustomPainter get painter {
    switch (type) {
      case GameObjectType.mouse:
        return MousePainter();
      case GameObjectType.bug:
        return BugPainter();
      case GameObjectType.laserDot:
        return LaserDotPainter();
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
        width: size.width * 0.7,
        height: size.height * 0.5,
      ),
      paint,
    );

    // Head
    canvas.drawCircle(
      Offset(size.width * 0.3, size.height * 0.4),
      size.width * 0.2,
      paint,
    );

    // Ears
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.2, size.height * 0.25),
        width: size.width * 0.2,
        height: size.height * 0.3,
      ),
      paint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.4, size.height * 0.25),
        width: size.width * 0.2,
        height: size.height * 0.3,
      ),
      paint,
    );

    // Tail
    final tailPath = Path()
      ..moveTo(size.width * 0.8, size.height * 0.6)
      ..quadraticBezierTo(
        size.width * 0.9,
        size.height * 0.4,
        size.width * 0.95,
        size.height * 0.7,
      );
    canvas.drawPath(
      tailPath,
      paint..strokeWidth = 5..style = PaintingStyle.stroke,
    );
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
      size.width * 0.2,
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
        Offset(size.width * 0.2, size.height * (0.4 + i * 0.2)),
        paint,
      );
      canvas.drawLine(
        Offset(size.width * 0.4, size.height * 0.5),
        Offset(size.width * 0.6, size.height * (0.4 + i * 0.2)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class LaserDotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    for (var i = 3; i > 0; i--) {
      canvas.drawCircle(
        Offset(size.width / 2, size.height / 2),
        size.width * 0.3 * i / 3,
        paint..color = Colors.red.withOpacity(0.3 / i),
      );
    }

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width * 0.2,
      paint..color = Colors.red,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class FeatherPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path();
    path.moveTo(size.width * 0.5, size.height * 0.2);

    // Draw feather spine
    path.lineTo(size.width * 0.5, size.height * 0.8);

    // Draw barbs
    for (var i = 0.2; i < 0.8; i += 0.1) {
      path.moveTo(size.width * 0.5, size.height * i);
      path.lineTo(size.width * 0.3, size.height * (i + 0.1));
      path.moveTo(size.width * 0.5, size.height * i);
      path.lineTo(size.width * 0.7, size.height * (i + 0.1));
    }

    canvas.drawPath(path, paint);
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

    // Draw circular yarn patterns
    for (var i = 1; i <= 5; i++) {
      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(size.width / 2, size.height / 2),
          width: size.width * 0.8 * i / 5,
          height: size.height * 0.8 * i / 5,
        ),
        0,
        3.14 * 2,
        false,
        paint,
      );
    }

    // Add some random yarn strands
    final path = Path();
    for (var i = 0; i < 5; i++) {
      path.moveTo(size.width * 0.3, size.height * (0.3 + i * 0.1));
      path.quadraticBezierTo(
        size.width * 0.5,
        size.height * (0.2 + i * 0.1),
        size.width * 0.7,
        size.height * (0.3 + i * 0.1),
      );
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
