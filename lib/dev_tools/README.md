# Development Tools

This directory contains utility files used during development but not required for the main game functionality.

## Files

- `preview_images.dart`: A utility for previewing game object images during development
- `generate_images.dart`: A tool for generating and testing game object images
- `preview_objects.dart`: A preview app for testing game objects and their behaviors
- `image_generator.dart`: Core functionality for generating game object images, used by `generate_images.dart`

## Usage

These tools are useful for:
- Testing new game object designs
- Debugging visual elements
- Previewing animations and movements
- Generating test assets

### Running the Preview Tools

To run the preview tools:

1. For object preview:
```bash
flutter run lib/dev_tools/preview_objects.dart
```

2. For image generation:
```bash
flutter run lib/dev_tools/generate_images.dart
```

Note: These files are not required for the main game to run and are kept here for development purposes only.
