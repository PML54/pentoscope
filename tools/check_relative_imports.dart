#!/usr/bin/env dart

// tools/check_relative_imports.dart
// Lister tous les imports qui ne sont PAS en adressage absolu
// Utilise config.dart pour la configuration

import 'dart:io';
import 'config.dart';

class RelativeImportsChecker {
  final Map<String, List<Map<String, String>>> relativeImports = {};
  int totalRelative = 0;

  Future<void> run() async {
    printf('$COLOR_BOLD=== Vérification des imports relatifs ===$COLOR_RESET\n\n');

    final libDir = Directory(LIB_PATH);
    if (!libDir.existsSync()) {
      printf('$COLOR_RED✗ Répertoire $LIB_PATH/ non trouvé$COLOR_RESET\n');
      exit(1);
    }

    printf('${COLOR_YELLOW}Scanning des imports relatifs...$COLOR_RESET\n\n');

    final allFiles = libDir
        .listSync(recursive: true, followLinks: false)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'));

    for (final file in allFiles) {
      await checkFileImports(file);
    }

    if (relativeImports.isEmpty) {
      printf('$COLOR_GREEN✓ Aucun import relatif détecté - Parfait !$COLOR_RESET\n');
      return;
    }

    printf('$COLOR_RED✗ $totalRelative import(s) relatif(s) trouvé(s)$COLOR_RESET\n\n');

    _printByFile();
    await _exportCsv();
  }

  Future<void> checkFileImports(File file) async {
    final content = await file.readAsString();
    final lines = content.split('\n');
    final relativePath = file.path.replaceFirst('$LIB_PATH/', '');

    final relativeImportsList = <Map<String, String>>[];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();

      // Chercher les imports
      if (line.startsWith('import ') || line.startsWith("import '")) {
        // Import avec chemin
        final importPattern = RegExp(r"""import\s+['"]([^'"]+)['"]""");
        final match = importPattern.firstMatch(line);

        if (match != null) {
          final importPath = match.group(1)!;

          // Vérifier si c'est un import relatif
          if (!importPath.startsWith('package:')) {
            relativeImportsList.add({
              'relative_path': relativePath,
              'line_number': (i + 1).toString(),
              'import_path': importPath,
            });
          }
        }
      }
    }

    if (relativeImportsList.isNotEmpty) {
      relativeImports[relativePath] = relativeImportsList;
      totalRelative += relativeImportsList.length;
    }
  }

  void _printByFile() {
    printf('$COLOR_BOLD=== Imports relatifs par fichier ===$COLOR_RESET\n\n');

    for (final entry in relativeImports.entries.toList()..sort((a, b) => a.key.compareTo(b.key))) {
      final filePath = entry.key;
      final imports = entry.value;

      printf('$COLOR_RED$filePath$COLOR_RESET (${imports.length} relatif(s))\n');
      for (final imp in imports) {
        final line = imp['line_number'];
        final path = imp['import_path'];
        printf('  $COLOR_YELLOW⚠$COLOR_RESET Ligne $line: $path\n');
      }
      printf('\n');
    }

    printf('$COLOR_BOLD=== Total ===$COLOR_RESET\n');
    printf('Fichiers affectés: $COLOR_BOLD${relativeImports.length}$COLOR_RESET\n');
    printf('Imports relatifs: $COLOR_BOLD$totalRelative$COLOR_RESET\n\n');

    printf('$COLOR_YELLOW💡 Conseil: Remplacer les imports relatifs par des imports absolus package:$PACKAGE_NAME/$COLOR_RESET\n');
    printf("$COLOR_YELLOW   Exemple: import 'package:$PACKAGE_NAME/pentoscope/game.dart';$COLOR_RESET\n\n");
  }

  Future<void> _exportCsv() async {
    Directory(CSV_PATH).createSync(recursive: true);

    final buffer = StringBuffer();
    buffer.writeln('relative_path,line_number,import_path');

    for (final entry in relativeImports.entries) {
      for (final imp in entry.value) {
        final filePath = imp['relative_path'];
        final line = imp['line_number'];
        final importPath = imp['import_path'];

        buffer.writeln('"$filePath",$line,"$importPath"');
      }
    }

    final csvFile = File('$CSV_PATH/pentapol_relative_imports.csv');
    await csvFile.writeAsString(buffer.toString());
    printf('$COLOR_GREEN✓ Export CSV: $COLOR_BOLD$CSV_PATH/pentapol_relative_imports.csv$COLOR_RESET\n');
  }
}

void printf(String msg) => stdout.write(msg);

Future<void> main(List<String> args) async {
  try {
    await RelativeImportsChecker().run();
  } catch (e) {
    printf('$COLOR_RED✗ Erreur: $e$COLOR_RESET\n');
    exit(1);
  }
}