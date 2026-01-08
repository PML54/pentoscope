#!/usr/bin/env dart

// tools/extract_imports.dart
// Extrait les imports package:X de chaque fichier .dart
// Utilise config.dart pour la configuration centralisée

import 'dart:io';
import 'config.dart';

class ImportsExtractor {
  final Map<String, List<String>> importsByFile = {};
  int totalImports = 0;

  Future<void> run() async {
    printf('$COLOR_BOLD=== Extraction des imports ===$COLOR_RESET\n\n');

    final libDir = Directory(LIB_PATH);
    if (!libDir.existsSync()) {
      printf('$COLOR_RED✗ Répertoire $LIB_PATH/ non trouvé$COLOR_RESET\n');
      exit(1);
    }

    printf('${COLOR_YELLOW}Scanning des imports...$COLOR_RESET\n');

    final allFiles = libDir
        .listSync(recursive: true, followLinks: false)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'));

    for (final file in allFiles) {
      await extractImportsFromFile(file);
    }

    printf('$COLOR_GREEN✓ ${importsByFile.length} fichiers avec imports$COLOR_RESET\n');
    printf('$COLOR_GREEN✓ $totalImports imports trouvés$COLOR_RESET\n\n');

    _printSummary();
    await _exportCsv();
  }

  Future<void> extractImportsFromFile(File file) async {
    final content = await file.readAsString();
    final lines = content.split('\n');

    final imports = <String>{};
    final relativePath = file.path.replaceFirst('$LIB_PATH/', '');

    for (final line in lines) {
      final trimmed = line.trim();

      // Chercher les imports package:X/Y/Z
      if (trimmed.startsWith('import ') || trimmed.startsWith("import '")) {
        final importPattern = RegExp(r"""import\s+['"]package:([^'"]+)['"]""");
        final match = importPattern.firstMatch(trimmed);

        if (match != null) {
          final importPath = 'package:${match.group(1)}';
          // Garder uniquement les imports du package courant
          if (importPath.startsWith('package:$PACKAGE_NAME/')) {
            imports.add(importPath);
          }
        }
      }
    }

    if (imports.isNotEmpty) {
      importsByFile[relativePath] = imports.toList()..sort();
      totalImports += imports.length;
    }
  }

  void _printSummary() {
    printf('$COLOR_BOLD=== Top 10 des fichiers les plus importants ===$COLOR_RESET\n\n');

    final sorted = importsByFile.entries.toList()
      ..sort((a, b) => b.value.length.compareTo(a.value.length));

    int count = 0;
    for (final entry in sorted) {
      if (count >= 10) break;
      printf('$COLOR_YELLOW${entry.key}$COLOR_RESET (${entry.value.length} imports)\n');
      for (final imp in entry.value.take(3)) {
        printf('  → $imp\n');
      }
      if (entry.value.length > 3) {
        printf('  → ... +${entry.value.length - 3} autres\n');
      }
      printf('\n');
      count++;
    }

    printf('$COLOR_BOLD=== Total ===$COLOR_RESET\n');
    printf('Fichiers: $COLOR_BOLD${importsByFile.length}$COLOR_RESET\n');
    printf('Imports: $COLOR_BOLD$totalImports$COLOR_RESET\n');
    printf('Moyenne: $COLOR_BOLD${(totalImports / importsByFile.length).toStringAsFixed(1)}$COLOR_RESET\n\n');
  }

  Future<void> _exportCsv() async {
    Directory(CSV_PATH).createSync(recursive: true);

    final buffer = StringBuffer();
    buffer.writeln('relative_path,import_path');

    for (final entry in importsByFile.entries) {
      for (final importPath in entry.value) {
        buffer.writeln('"${entry.key}","$importPath"');
      }
    }

    await File(CSV_IMPORTS).writeAsString(buffer.toString());
    printf('$COLOR_GREEN✓ Export CSV: $COLOR_BOLD$CSV_IMPORTS$COLOR_RESET\n');
  }
}

void printf(String msg) => stdout.write(msg);

Future<void> main(List<String> args) async {
  try {
    await ImportsExtractor().run();
  } catch (e) {
    printf('$COLOR_RED✗ Erreur: $e$COLOR_RESET\n');
    exit(1);
  }
}