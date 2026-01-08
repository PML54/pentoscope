#!/usr/bin/env dart

// tools/check_orphan_files.dart
// Identifie les fichiers .dart qui ne sont importés par aucun autre fichier
// Utilise config.dart pour la configuration centralisée

import 'dart:io';
import 'config.dart';

class OrphanFilesChecker {
  final List<Map<String, String>> orphanFiles = [];

  Future<void> run() async {
    printf('$COLOR_BOLD=== Vérification des fichiers orphelins ===$COLOR_RESET\n\n');

    // Vérifier que la DB existe
    if (!File(DB_FULL_PATH).existsSync()) {
      printf('$COLOR_RED✗ Base de données non trouvée: $DB_FULL_PATH$COLOR_RESET\n');
      exit(1);
    }

    printf('${COLOR_YELLOW}Interrogation de la base de données...$COLOR_RESET\n');

    // Lancer la requête SQL
    final result = await _querySqlite();

    if (result.isEmpty) {
      printf('$COLOR_GREEN✓ Aucun fichier orphelin détecté$COLOR_RESET\n');
      exit(0);
    }

    // Parser les résultats
    for (final line in result.split('\n')) {
      if (line.trim().isEmpty) continue;

      final parts = line.split('|');
      if (parts.length < 4) continue;

      orphanFiles.add({
        'dart_id': parts[0].trim(),
        'relative_path': parts[1].trim(),
        'first_dir': parts[2].trim(),
        'filename': parts[3].trim(),
      });
    }

    printf('$COLOR_GREEN✓ ${orphanFiles.length} fichier(s) orphelin(s) trouvé(s)$COLOR_RESET\n\n');

    // Afficher par répertoire
    _printByDirectory();

    // Exporter CSV
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
WHERE 'package:$PACKAGE_NAME/' || df.relative_path NOT IN (
  SELECT import_path FROM imports
)
  AND df.filename NOT IN ($ignoreList)
ORDER BY df.first_dir, df.filename;
''';

    try {
      final process = await Process.run(
        'sqlite3',
        [
          '-separator', '|',
          DB_FULL_PATH,
          query,
        ],
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
    printf('$COLOR_BOLD=== Fichiers orphelins par répertoire ===$COLOR_RESET\n\n');

    final byDir = <String, List<Map<String, String>>>{};
    for (final file in orphanFiles) {
      final dir = file['first_dir']!;
      byDir.putIfAbsent(dir, () => []).add(file);
    }

    for (final dir in byDir.keys.toList()..sort()) {
      final files = byDir[dir]!;

      printf('$COLOR_YELLOW$dir$COLOR_RESET (${files.length} fichiers)\n');
      for (final file in files) {
        final path = file['relative_path'];
        final dartId = file['dart_id'];
        printf('  • [$dartId] $path\n');
      }
      printf('\n');
    }

    printf('$COLOR_BOLD=== Total ===$COLOR_RESET\n');
    printf('Fichiers orphelins: $COLOR_BOLD${orphanFiles.length}$COLOR_RESET\n\n');
  }

  Future<void> _exportCsv() async {
    final csvDir = Directory(CSV_PATH);
    if (!csvDir.existsSync()) {
      csvDir.createSync(recursive: true);
    }

    final csvFile = File(CSV_ORPHANFILES);
    final buffer = StringBuffer();

    // Header
    buffer.writeln('dart_id,relative_path,first_dir,filename');

    // Données
    for (final file in orphanFiles) {
      final dartId = file['dart_id']!;
      final relativePath = file['relative_path']!;
      final firstDir = file['first_dir']!;
      final filename = file['filename']!;

      buffer.writeln('$dartId,"$relativePath","$firstDir","$filename"');
    }

    await csvFile.writeAsString(buffer.toString());
    printf('$COLOR_GREEN✓ Export CSV: $COLOR_BOLD$CSV_ORPHANFILES$COLOR_RESET\n');
  }
}

void printf(String msg) {
  stdout.write(msg);
}

Future<void> main(List<String> args) async {
  try {
    final checker = OrphanFilesChecker();
    await checker.run();
  } catch (e) {
    printf('$COLOR_RED✗ Erreur: $e$COLOR_RESET\n');
    exit(1);
  }
}