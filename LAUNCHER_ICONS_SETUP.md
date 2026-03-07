# Flutter Launcher Icons Setup Guide

## How to Generate Launcher Icons from SVG

### Option 1: Using Online Converter (Recommended)

1. **Convert SVG to PNG**
   - Go to: https://cloudconvert.com/svg-to-png
   - Upload: `assets/icons/logo.svg`
   - Set dimensions: **1024x1024** pixels
   - Download the PNG file
   - Save as: `assets/icons/logo.png`

2. **Generate Icons**
   ```bash
   fvm flutter pub get
   fvm flutter pub run flutter_launcher_icons
   ```

### Option 2: Using ImageMagick (Command Line)

1. **Install ImageMagick** (if not already installed)
   - Windows: https://imagemagick.org/script/download.php#windows
   - Or use Chocolatey: `choco install imagemagick`

2. **Convert SVG to PNG**
   ```bash
   cd assets/icons
   convert logo.svg -resize 1024x1024 -background none logo.png
   ```

3. **Generate Icons**
   ```bash
   fvm flutter pub get
   fvm flutter pub run flutter_launcher_icons
   ```

### Option 3: Using Inkscape (Desktop App)

1. **Open SVG in Inkscape**
   - Download: https://inkscape.org/release/
   - Open `assets/icons/logo.svg`

2. **Export as PNG**
   - File → Export
   - Set dimensions: 1024x1024
   - Save as: `assets/icons/logo.png`

3. **Generate Icons**
   ```bash
   fvm flutter pub get
   fvm flutter pub run flutter_launcher_icons
   ```

## Configuration

The launcher icon configuration is in `pubspec.yaml`:

```yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icons/logo.png"
  # Optional: For Android adaptive icons (8.0+)
  # adaptive_icon_background: "#214432"
  # adaptive_icon_foreground: "assets/icons/logo_foreground.png"
```

## File Requirements

- **Format**: PNG
- **Size**: 1024x1024 pixels (recommended)
- **Background**: Transparent or solid color
- **File path**: `assets/icons/logo.png`

## Verify Icons

After generating, check:
- Android: `android/app/src/main/res/mipmap-*/ic_launcher.png`
- iOS: `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

## Troubleshooting

### Icons not updating?
```bash
# Clean and regenerate
fvm flutter clean
fvm flutter pub get
fvm flutter pub run flutter_launcher_icons
```

### Wrong size?
Make sure your PNG is 1024x1024 pixels before running the generator.

### Adaptive Icons (Android 8.0+)
For better Android icons, create a foreground-only version:
1. Create `assets/icons/logo_foreground.png` (logo without background)
2. Uncomment adaptive icon lines in pubspec.yaml
3. Set `adaptive_icon_background: "#214432"` (your brand color)

## Next Steps

After generating icons:
1. Build your app: `fvm flutter build apk --debug`
2. Install on device
3. Verify the app icon appears correctly

## Resources

- Flutter Launcher Icons: https://pub.dev/packages/flutter_launcher_icons
- Android Icon Guidelines: https://developer.android.com/guide/practices/ui_guidelines/icon_design_launcher
- iOS Icon Guidelines: https://developer.apple.com/design/human-interface-guidelines/app-icons
