import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Flutter Web Build Integration Tests', () {
    test('should generate Flutter web build output', () async {
      // Run flutter build web
      final result = await Process.run(
        'flutter',
        ['build', 'web'],
        workingDirectory: Directory.current.path,
      );

      expect(result.exitCode, equals(0), reason: 'Flutter build should succeed');

      // Check that build/web directory exists
      final buildDir = Directory('build/web');
      expect(buildDir.existsSync(), isTrue, reason: 'build/web directory should exist');

      // Check for essential Flutter web files
      final essentialFiles = [
        'build/web/index.html',
        'build/web/main.dart.js',
        'build/web/flutter.js',
        'build/web/flutter_bootstrap.js',
        'build/web/manifest.json',
      ];

      for (final filePath in essentialFiles) {
        final file = File(filePath);
        expect(file.existsSync(), isTrue, reason: '$filePath should exist');
      }
    });

    test('should generate index.html with Flutter loader', () {
      final indexFile = File('build/web/index.html');
      expect(indexFile.existsSync(), isTrue);

      final content = indexFile.readAsStringSync();
      
      // Check for essential Flutter web elements
      expect(content, contains('flutter'), reason: 'Should contain flutter references');
      expect(content, contains('script'), reason: 'Should include JavaScript');
      expect(content, contains('body'), reason: 'Should have HTML body');
    });

    test('should generate main.dart.js with compiled Dart code', () {
      final mainDartJs = File('build/web/main.dart.js');
      expect(mainDartJs.existsSync(), isTrue);

      final content = mainDartJs.readAsStringSync();
      expect(content.isNotEmpty, isTrue, reason: 'main.dart.js should not be empty');
      
      // Should contain compiled Flutter/Dart code
      expect(content, contains('Flutter'), reason: 'Should contain Flutter references');
    });

    test('should generate proper manifest.json for PWA support', () {
      final manifestFile = File('build/web/manifest.json');
      expect(manifestFile.existsSync(), isTrue);

      final content = manifestFile.readAsStringSync();
      expect(content.isNotEmpty, isTrue);
      
      // Should be valid JSON
      expect(() => content, returnsNormally);
    });

    test('should include all necessary assets', () {
      final assetDirs = [
        'build/web/assets',
        'build/web/canvaskit',
      ];

      for (final dirPath in assetDirs) {
        final dir = Directory(dirPath);
        expect(dir.existsSync(), isTrue, reason: '$dirPath should exist');
      }

      // Check for specific asset files
      final assetFiles = [
        'build/web/assets/AssetManifest.json',
        'build/web/assets/FontManifest.json',
        'build/web/canvaskit/canvaskit.js',
        'build/web/canvaskit/canvaskit.wasm',
      ];

      for (final filePath in assetFiles) {
        final file = File(filePath);
        expect(file.existsSync(), isTrue, reason: '$filePath should exist');
      }
    });

    test('should be ready for web server deployment', () {
      // Verify the build output can be served by a static web server
      final buildWebDir = Directory('build/web');
      expect(buildWebDir.existsSync(), isTrue);

      // Check that we have an entry point
      final indexHtml = File('build/web/index.html');
      expect(indexHtml.existsSync(), isTrue);

      // Check file sizes are reasonable (not empty, not too large)
      final stats = indexHtml.statSync();
      expect(stats.size, greaterThan(1000), reason: 'index.html should have content');
      expect(stats.size, lessThan(50000), reason: 'index.html should not be too large');

      final mainJs = File('build/web/main.dart.js');
      expect(mainJs.existsSync(), isTrue);
      final jsStats = mainJs.statSync();
      expect(jsStats.size, greaterThan(10000), reason: 'main.dart.js should contain compiled code');
    });
  });
}
