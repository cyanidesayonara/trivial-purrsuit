import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class GameObjectPainter extends CustomPainter {
  final void Function(Canvas, Size) drawFunction;

  GameObjectPainter(this.drawFunction);

  @override
  void paint(Canvas canvas, Size size) {
    drawFunction(canvas, size);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ImageGenerator {
  static Future<void> generatePlaceholderImages() async {
    await _generateImage(_drawMouse, 'mouse.png');
    await _generateImage(_drawLaserDot, 'laser_dot.png');
    await _generateImage(_drawBug, 'bug.png');
    await _generateImage(_drawFeather, 'feather.png');
    await _generateImage(_drawYarnBall, 'yarn_ball.png');
  }

  static Future<void> _generateImage(
    void Function(Canvas, Size) drawFunction,
    String fileName,
  ) async {
    const size = Size(100, 100);
    
    final repaintBoundary = RepaintBoundary(
      child: CustomPaint(
        size: size,
        painter: GameObjectPainter(drawFunction),
      ),
    );

    final pipelineOwner = PipelineOwner();
    final buildOwner = BuildOwner(focusManager: FocusManager());
    
    final rootElement = RenderObjectToWidgetAdapter<RenderBox>(
      container: RenderView(
        configuration: ViewConfiguration(
          size: size,
          devicePixelRatio: 1.0,
        ),
        window: WidgetsBinding.instance.window,
      ),
      child: repaintBoundary,
    ).attachToRenderTree(buildOwner);
    
    buildOwner.buildScope(rootElement);
    buildOwner.finalizeTree();
    
    pipelineOwner.flushLayout();
    pipelineOwner.flushCompositingBits();
    pipelineOwner.flushPaint();
    
    final renderObject = rootElement.renderObject as RenderRepaintBoundary;
    final image = await renderObject.toImage();
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final buffer = byteData!.buffer.asUint8List();

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(buffer);
  }

  static void _drawMouse(Canvas canvas, Size size) {
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

  static void _drawLaserDot(Canvas canvas, Size size) {
    // Red dot with glow effect
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

  static void _drawBug(Canvas canvas, Size size) {
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

  static void _drawFeather(Canvas canvas, Size size) {
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

  static void _drawYarnBall(Canvas canvas, Size size) {
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
}
