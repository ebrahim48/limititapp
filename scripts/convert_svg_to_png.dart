import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:ui';

/// Script to convert SVG logo to PNG for launcher icon
/// Run this with: fvm dart run scripts/convert_svg_to_png.dart
void main() async {
  // Read SVG file
  final svgFile = File('assets/icons/logo.svg');
  final svgString = await svgFile.readAsString();
  
  // Parse SVG
  final pictureInfo = await vg.loadPicture(
    SvgStringLoader(svgString),
    null,
  );
  
  // Create PNG with 1024x1024 size (recommended for launcher icons)
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  
  // Scale to fit 1024x1024
  final size = 1024.0;
  final svgSize = pictureInfo.size;
  final scale = size / svgSize.width;
  
  canvas.translate(size / 2, size / 2);
  canvas.scale(scale);
  canvas.translate(-svgSize.width / 2, -svgSize.height / 2);
  
  canvas.drawPicture(pictureInfo.picture);
  
  final picture = recorder.endRecording();
  final image = await picture.toImage(size.toInt(), size.toInt());
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  final pngBytes = byteData!.buffer.asUint8List();
  
  // Write PNG file
  final pngFile = File('assets/icons/logo.png');
  await pngFile.writeAsBytes(pngBytes);
  
  print('✓ Logo converted to PNG: assets/icons/logo.png');
  print('  Size: ${pngBytes.length} bytes');
  print('  Dimensions: ${size.toInt()}x${size.toInt()}');
  
  exit(0);
}
