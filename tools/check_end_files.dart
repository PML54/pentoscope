#!/usr/bin/env dart

// tools/check_end_files.dart
// Identifie les fichiers sans dépendances internes (feuilles)
// Utilise config.dart pour la configuration centralisée

import 'dart:io';
import 'config.dart';

class EndFilesChecker {
  final List<Map<String, String>> endFiles = [];

  Future<void> run() async {
    printf('$COLOR_BOLD=== Vérification des fichiers sans dépendances internes ===$COLOR_RESET\n\n');

    if (!File(DB_FULL_PATH).existsSync()) {
      printf('$COLOR_RED✗ Base de données non trouvée: $DB_FULL_PATH$COLOR_RESET\n');
      exit(1);
    }

    printf('${COLOR_YELLOW}Interrogation de la base de données...$COLOR_RESET\n');

    final result = await _querySqlite();

    if (result.isEmpty) {
      printf('$COLOR_GREEN✓ Tous les fichiers importent au moins un dart$COLOR_RESET\n');
      exit(0);
    }

    for (final line in result.split('\n')) {
      if (line.trim().isEmpty) continue;
      final parts = line.split('|');
      if (parts.length < 4) continue;

      endFiles.add({
        'dart_id': parts[0].trim(),
        'relative_path': parts[1].trim(),
        'first_dir': parts[2].trim(),
        'filename': parts[3].trim(),
      });
    }

    printf('$COLOR_GREEN✓ ${endFiles.length} fichier(s) sans dépendances$COLOR_RESET\n\n');

    _printByDirectory();
    await _exportCsv();
  }

  Future<String> _querySqlite() async {
    final ignoreList = IGNORE_FILES.map((f) => "'$f'").join(', ');
    final query = '''
SELECT 
  df.dart_id,
  df.relative_path,
  df.first_dir,
  df.filename
FROM dartfiles df
WHERE df.dart_id NOT IN (
  SELECT DISTINCT i.dart_id FROM imports i
)
  AND df.filename NOT IN ($ignoreList)
ORDER BY df.first_dir, df.filename;
''';

    try {
      final process = await Process.run(
        'sqlite3',
        ['-separator', '|', DB_FULL_PATH, query],
      );

      if (process.exitCode != 0) {
        printf('$COLOR_RED✗ Erreur sqlite3: ${process.stderr}$COLOR_RESET\n');
        exit(1);
      }

      return process.stdout as String;
    } catch (e) {
      printf('$COLOR_RED✗ Erreur: $e$COLOR_RESET\n');
      exit(1);
    }
  }

  void _printByDirectory() {
    printf('$COLOR_BOLD=== Fichiers sans dépendances par répertoire ===$COLOR_RESET\n\n');

    final byDir = <String, List<Map<String, String>>>{};
    for (final file in endFiles) {
      final dir = file['first_dir']!;
      byDir.putIfAbsent(dir, () => []).add(file);
    }

    for (final dir in byDir.keys.toList()..sort()) {
      final files = byDir[dir]!;
      printf('$COLOR_YELLOW$dir$COLOR_RESET (${files.length} fichiers)\n');
      for (final file in files) {
        printf('  • [${file['dart_id']}] ${file['relative_path']}\n');
      }
      printf('\n');
    }

    printf('$COLOR_BOLD=== Total ===$COLOR_RESET\n');
    printf('Fichiers sans dépendances: $COLOR_BOLD${endFiles.length}$COLOR_RESET\n\n');
  }

  Future<void> _exportCsv() async {
    Directory(CSV_PATH).createSync(recursive: true);

    final buffer = StringBuffer();
    buffer.writeln('dart_id,relative_path,first_dir,filename');

    for (final file in endFiles) {
      buffer.writeln('${file['dart_id']},"${file['relative_path']}","${file['first_dir']}","${file['filename']}"');
    }

    await File(CSV_ENDFILES).writeAsString(buffer.toString());
    printf('$COLOR_GREEN✓ Export CSV: $COLOR_BOLD$CSV_ENDFILES$COLOR_RESET\n');
  }
}

void printf(String msg) => stdout.write(msg);

Future<void> main(List<String> args) async {
  try {
    await EndFilesChecker().run();
  } catch (e) {
    printf('$COLOR_RED✗ Erreur: $e$COLOR_RESET\n');
    exit(1);
  }
}