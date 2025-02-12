import 'package:flutter/material.dart';
import 'image_generator.dart';

void main() {
  runApp(const ImageGeneratorApp());
}

class ImageGeneratorApp extends StatelessWidget {
  const ImageGeneratorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: FutureBuilder(
          future: ImageGenerator.generatePlaceholderImages(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return const Center(
                child: Text('Images generated successfully!'),
              );
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }
}
