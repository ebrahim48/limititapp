#!/usr/bin/env dart
import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:typed_data';

/// Simple script to create a placeholder PNG logo
/// This creates a 1024x1024 green circle as a placeholder
/// For production, use an online SVG to PNG converter
void main() async {
  // Create a 1024x1024 image
  final image = img.Image(width: 1024, height: 1024);
  
  // Fill with transparent background
  img.fill(image, color: img.ColorRgba8(0, 0, 0, 0));
  
  // Draw a green circle (matching LimitIt brand color #214432)
  final centerX = 512;
  final centerY = 512;
  final radius = 480;
  
  for (var y = 0; y < image.height; y++) {
    for (var x = 0; x < image.width; x++) {
      final dx = x - centerX;
      final dy = y - centerY;
      final distance = (dx * dx + dy * dy).sqrt();
      
      if (distance <= radius) {
        // Inside circle - use brand color #214432
        image.setPixelRgba8(x, y, 33, 68, 50, 255);
      }
    }
  }
  
  // Encode as PNG
  final pngBytes = img.encodePng(image);
  
  // Write to file
  final pngFile = File('assets/icons/logo.png');
  await pngFile.writeAsBytes(pngBytes);
  
  print('✓ Created placeholder logo: assets/icons/logo.png');
  print('  Size: ${pngBytes.length} bytes');
  print('  Dimensions: 1024x1024');
  print('');
  print('Note: This is a simple green circle placeholder.');
  print('For your actual logo, convert assets/icons/logo.svg to PNG using:');
  print('  - https://cloudconvert.com/svg-to-png');
  print('  - Or use Inkscape, Adobe Illustrator, etc.');
  
  exit(0);
}
