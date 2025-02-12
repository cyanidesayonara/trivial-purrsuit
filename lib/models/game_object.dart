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
  static const maxLifetimeSeconds = 15.0;
  
  // Movement pattern variables
  double _angle = 0.0;
  double _targetX = 0.0;
  double _targetY = 0.0;
  final random = Random();

  GameObject({
    required this.type,
    required this.x,
    required this.y,
    this.speedX = 0.0,
    this.speedY = 0.0,
  }) : isActive = true,
       createdAt = DateTime.now(),
       lastInteractionAt = DateTime.now() {
    // Initialize movement patterns
    switch (type) {
      case GameObjectType.mouse:
        // Mouse moves in quick bursts with pauses
        speedX = (random.nextDouble() - 0.5) * 15.0;
        speedY = (random.nextDouble() - 0.5) * 15.0;
        break;
      case GameObjectType.laserDot:
        // Laser dot moves erratically
        speedX = (random.nextDouble() - 0.5) * 20.0;
        speedY = (random.nextDouble() - 0.5) * 20.0;
        break;
      case GameObjectType.bug:
        // Bug moves in a zigzag pattern
        speedX = 8.0;
        speedY = 4.0;
        break;
      case GameObjectType.feather:
        // Feather starts with gentle sideways movement
        speedX = (random.nextDouble() - 0.5) * 3.0;
        speedY = 1.0; // Start moving down slowly
        break;
      case GameObjectType.yarnBall:
        // Yarn ball starts with only horizontal movement
        speedX = (random.nextDouble() - 0.5) * 15.0;
        speedY = 0.0; // Will be affected by gravity
        break;
    }
  }

  void move(double maxX, double maxY) {
    // Check if object has expired
    final now = DateTime.now();
    final lifetime = now.difference(lastInteractionAt).inSeconds;
    if (lifetime > maxLifetimeSeconds + random.nextInt(10)) {
      isActive = false;
      return;
    }

    _angle += 0.1;

    switch (type) {
      case GameObjectType.mouse:
        // Mouse moves in quick bursts with pauses
        if (random.nextDouble() < 0.05) {
          speedX = (random.nextDouble() - 0.5) * 15.0;
          speedY = (random.nextDouble() - 0.5) * 15.0;
        }
        break;
      case GameObjectType.laserDot:
        // Laser dot moves erratically with sudden direction changes
        if (random.nextDouble() < 0.1) {
          speedX = (random.nextDouble() - 0.5) * 20.0;
          speedY = (random.nextDouble() - 0.5) * 20.0;
        }
        break;
      case GameObjectType.bug:
        // Bug moves in a zigzag pattern
        speedY = sin(_angle) * 8.0;
        break;
      case GameObjectType.feather:
        // Feather floats down with gentle swaying
        speedX = sin(_angle) * 2.0; // Gentle side-to-side movement
        speedY = 1.0 + cos(_angle) * 0.5; // Always moving down, but speed varies slightly
        
        // Move
        x += speedX;
        y += speedY;
        
        // Bounce softly off walls
        if (x < 0.0 || x > maxX) {
          speedX = -speedX * 0.5;
          x = x < 0.0 ? 0.0 : maxX;
        }
        
        // Loop back to top when reaching bottom
        if (y > maxY) {
          y = 0.0;
        }
        return;
      case GameObjectType.yarnBall:
        // Apply gravity
        speedY += 1.5;
        
        // Move
        x += speedX;
        y += speedY;

        // Bounce off bottom with almost no energy loss
        if (y > maxY) {
          y = maxY;
          speedY = -speedY * 0.95; // 5% energy loss on bounce
          // Add a bit more horizontal movement on each bounce
          speedX += (random.nextDouble() - 0.5) * 3.0;
        }

        // Bounce off walls with slight speed increase
        if (x < 0.0 || x > maxX) {
          speedX = -speedX * 1.1; // Slightly increase speed on wall hits
          x = x < 0.0 ? 0.0 : maxX;
        }
        return; // Skip the default movement code for yarn ball
    }

    // Default movement for other objects
    x += speedX;
    y += speedY;

    // Bounce off edges with type-specific behavior
    if (x <= 0.0 || x >= maxX) {
      switch (type) {
        case GameObjectType.yarnBall:
          speedX = -speedX * 0.8; // Yarn ball loses energy
          break;
        case GameObjectType.feather:
          speedX = -speedX * 0.5; // Feather bounces softly
          break;
        default:
          speedX = -speedX;
          break;
      }
      x = x <= 0.0 ? 0.0 : maxX;
    }

    if (y <= 0.0 || y >= maxY) {
      switch (type) {
        case GameObjectType.yarnBall:
          speedY = -speedY * 0.8; // Yarn ball loses energy
          break;
        case GameObjectType.feather:
          speedY = -speedY * 0.5; // Feather bounces softly
          break;
        default:
          speedY = -speedY;
          break;
      }
      y = y <= 0.0 ? 0.0 : maxY;
    }
  }

  void onTouch() {
    lastInteractionAt = DateTime.now();
    switch (type) {
      case GameObjectType.mouse:
        // Mouse scurries away in a random direction
        final random = Random();
        speedX = (random.nextDouble() - 0.5) * 20.0;
        speedY = (random.nextDouble() - 0.5) * 20.0;
        break;
      case GameObjectType.bug:
        // Bug gets squished and disappears
        isActive = false;
        break;
      case GameObjectType.laserDot:
        // Laser dot teleports to a random location
        final random = Random();
        x = random.nextDouble() * 300.0;
        y = random.nextDouble() * 300.0;
        break;
      case GameObjectType.feather:
        // Feather gets a bigger upward boost when tapped
        speedY = -8.0;  // Much bigger upward boost
        speedX = (random.nextDouble() - 0.5) * 6.0;  // More sideways movement too
        break;
      case GameObjectType.yarnBall:
        // Yarn ball bounces back up with spin
        speedY = -25.0; // Less extreme bounce height when tapped
        speedX += (random.nextDouble() - 0.5) * 15.0; // More sideways momentum
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
      paint..strokeWidth = 3.0..style = PaintingStyle.stroke,
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
    paint.strokeWidth = 2.0;
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
      ..strokeWidth = 2.0;

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
      ..strokeWidth = 1.0
      ..color = Colors.orange.shade700;

    for (var i = 0; i < 12; i++) {
      final t = i / 12.0;
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
      ..strokeWidth = 2.0;

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
