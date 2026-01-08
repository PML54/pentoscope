#!/usr/bin/env dart

// tools/check_absolute_imports.dart
// Vérifie que TOUS les imports dans lib/ sont en adressage absolu
// - Interdit: import '../something/file.dart'
// - Interdit: import './file.dart'
// - Obligatoire: import 'package:pentapol/something/file.dart'

import 'dart:io';

const String libPath = 'lib';

// ANSI colors
const String red = '\x1B[31m';
const String green = '\x1B[32m';
const String yellow = '\x1B[33m';
const String bold = '\x1B[1m';
const String reset = '\x1B[0m';

class AbsoluteImportsChecker {
  int errors = 0;
  final List<String> violations = [];

  Future<void> run() async {
    print('$bold=== Vérification adressage absolu des imports ===$reset');
    print('Chemin: lib/\n');
    print('Règles:');
    print('  • Imports relatifs (../, ./) → INTERDITS');
    print('  • Tous les imports lib/ → package:pentapol/... (adressage absolu)\n');

    final libDir = Directory(libPath);
    if (!libDir.existsSync()) {
      print('$red✗ Répertoire lib/ non trouvé$reset');
      exit(1);
    }

    // Scanner tous les fichiers .dart dans lib/
    final dartFiles = libDir
        .listSync(recursive: true, followLinks: false)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'));

    for (final dartFile in dartFiles) {
      await checkDartFile(dartFile);
    }

    printSummary();
    exit(errors > 0 ? 1 : 0);
  }

  Future<void> checkDartFile(File file) async {
    final content = await file.readAsString();
    final lines = content.split('\n');

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final lineNum = i + 1;

      // Sauter commentaires et lignes vides
      if (line.trim().startsWith('//') || line.trim().isEmpty) {
        continue;
      }

      // Patterns pour imports Dart
      final importMatch = RegExp(
          "^\\s*import\\s+['\"]([^'\"]+)['\"]"
      ).firstMatch(line);

      if (importMatch == null) continue;

      final importPath = importMatch.group(1)!;

      // Vérifier les imports relatifs (INTERDIT)
      if (importPath.startsWith('./') || importPath.startsWith('../')) {
        violations.add(
          '${file.path}:$lineNum\n'
              '    $red✗ Import relatif (INTERDIT):$reset $line\n'
              '    → Utiliser adressage absolu: package:pentapol/...',
        );
        errors++;
      }
    }
  }

  void printSummary() {
    print('$bold=== Résumé ===$reset\n');

    if (errors == 0) {
      print('$green✓ Tous les imports sont en adressage absolu$reset');
    } else {
      print('$red✗ $bold$errors violations$reset$red détectées:$reset\n');
      for (final violation in violations) {
        print('$violation\n');
      }
    }
  }
}

Future<void> main(List<String> args) async {
  try {
    final checker = AbsoluteImportsChecker();
    await checker.run();
  } catch (e) {
    print('$red✗ Erreur: $e$reset');
    exit(1);
  }
}