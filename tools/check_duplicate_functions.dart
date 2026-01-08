#!/usr/bin/env dart

// tools/check_duplicate_functions.dart
// Détecte les fonctions avec le même nom qui apparaissent dans plusieurs fichiers
// Utilise config.dart pour la configuration centralisée

import 'dart:io';
import 'dart:convert';
import 'config.dart';

class DuplicateFunctionsChecker {
  final Map<String, List<Map<String, String>>> functionsByName = {};
  int totalDuplicates = 0;

  Future<void> run() async {
    printf('$COLOR_BOLD=== Détection des fonctions dupliquées ===$COLOR_RESET\n\n');

    if (!File(DB_FULL_PATH).existsSync()) {
      printf('$COLOR_RED✗ Base de données non trouvée: $DB_FULL_PATH$COLOR_RESET\n');
      exit(1);
    }

    printf('${COLOR_YELLOW}Interrogation de la base de données...$COLOR_RESET\n');

    final result = await _querySqlite();

    if (result.isEmpty) {
      printf('$COLOR_GREEN✓ Aucune fonction dupliquée détectée$COLOR_RESET\n');
      exit(0);
    }

    // Parser les résultats
    for (final line in result.split('\n')) {
      if (line.trim().isEmpty) continue;

      final parts = line.split('|');
      if (parts.length < 5) continue;

      final funcName = parts[0].trim();
      final dartId = parts[1].trim();
      final relativePath = parts[2].trim();
      final firstDir = parts[3].trim();
      final count = parts[4].trim();

      functionsByName.putIfAbsent(funcName, () => []).add({
        'dart_id': dartId,
        'relative_path': relativePath,
        'first_dir': firstDir,
        'occurrence_count': count,
      });

      totalDuplicates++;
    }

    printf('$COLOR_GREEN✓ ${functionsByName.length} fonction(s) dupliquée(s) trouvée(s)$COLOR_RESET\n');
    printf('$COLOR_GREEN✓ $totalDuplicates occurrence(s) totales$COLOR_RESET\n\n');

    _printSummary();
    await _insertIntoDb();
  }

  Future<String> _querySqlite() async {
    const query = '''
SELECT 
  f.function_name,
  f.dart_id,
  df.relative_path,
  df.first_dir,
  COUNT(*) as occurrence_count
FROM functions f
JOIN dartfiles df ON f.dart_id = df.dart_id
GROUP BY f.function_name
HAVING COUNT(*) > 1
ORDER BY f.function_name, df.relative_path;
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

  void _printSummary() {
    printf('$COLOR_BOLD=== Fonctions dupliquées ===$COLOR_RESET\n\n');

    for (final funcName in functionsByName.keys.toList()..sort()) {
      final occurrences = functionsByName[funcName]!;
      printf('$COLOR_YELLOW$funcName$COLOR_RESET (${occurrences.length} fichiers)\n');

      for (final occ in occurrences) {
        printf('  • [${occ['dart_id']}] ${occ['relative_path']}\n');
      }
      printf('\n');
    }

    printf('$COLOR_BOLD=== Total ===$COLOR_RESET\n');
    printf('Fonctions avec doublons: $COLOR_BOLD${functionsByName.length}$COLOR_RESET\n');
    printf('Occurrences totales: $COLOR_BOLD$totalDuplicates$COLOR_RESET\n\n');
  }

  Future<void> _insertIntoDb() async {
    printf('${COLOR_YELLOW}Insertion dans la table duplicate_functions...$COLOR_RESET\n');

    // Construire les INSERT
    final buffer = StringBuffer();
    buffer.writeln('BEGIN TRANSACTION;');

    for (final funcName in functionsByName.keys) {
      final occurrences = functionsByName[funcName]!;

      for (final occ in occurrences) {
        final dartId = occ['dart_id'];
        final relativePath = occ['relative_path'];
        final firstDir = occ['first_dir'];
        final count = occ['occurrence_count'];

        buffer.writeln('''INSERT INTO duplicate_functions (function_name, dart_id, relative_path, first_dir, occurrence_count)
VALUES ('$funcName', $dartId, '$relativePath', '$firstDir', $count);''');
      }
    }

    buffer.writeln('COMMIT;');

    try {
      final process = await Process.start(
        'sqlite3',
        [DB_FULL_PATH],
      );

      process.stdin.write(buffer.toString());
      await process.stdin.close();

      final exitCode = await process.exitCode;
      if (exitCode != 0) {
        final error = await process.stderr.transform(const Utf8Decoder()).join();
        printf('$COLOR_RED✗ Erreur insertion: $error$COLOR_RESET\n');
        exit(1);
      }

      printf('$COLOR_GREEN✓ Table duplicate_functions remplie$COLOR_RESET\n');
    } catch (e) {
      printf('$COLOR_RED✗ Erreur: $e$COLOR_RESET\n');
      exit(1);
    }
  }
}

void printf(String msg) => stdout.write(msg);

Future<void> main(List<String> args) async {
  try {
    await DuplicateFunctionsChecker().run();
  } catch (e) {
    printf('$COLOR_RED✗ Erreur: $e$COLOR_RESET\n');
    exit(1);
  }
}