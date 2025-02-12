import 'package:flutter/material.dart';
import 'image_generator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ImageGenerator.generatePlaceholderImages();
  print('Images generated successfully!');
}
