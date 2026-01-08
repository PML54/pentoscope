#!/usr/bin/env dart

// tools/check_module_isolation.dart
// Vérifie l'isolation architecturale des 5 modules de Pentapol:
//   - lib/classical/
//   - lib/pentoscope/
//   - lib/isopento/
//   - lib/duel/
//   - lib/tutorial/
//
// Chaque module ne peut importer QUE:
//   1) lib/common/ (composants partagés)
//   2) Lui-même (son propre module)
//   3) dart: et package: externes (Flutter, dépendances)
//
// INTERDIT:
//   - classical/ importe duel/, isopento/, etc.
//   - Imports relatifs (../, ./) - utiliser package:pentapol/...

import 'dart:io';
import 'dart:async';

const List<String> modules = [
  'classical',
  'pentoscope',
  'isopento',
  'duel',
  'tutorial',
];

const String libPath = 'lib';
const String commonModule = 'common';

// ANSI colors
const String red = '\x1B[31m';
const String green = '\x1B[32m';
const String yellow = '\x1B[33m';
const String bold = '\x1B[1m';
const String reset = '\x1B[0m';

class ModuleChecker {
  int errors = 0;
  final Map<String, List<String>> violations = {};

  Future<void> run() async {
    print('$bold=== Vérification isolation des modules Pentapol ===$reset');
    print('Modules vérifiés: ${modules.join(", ")}\n');
    print('Règles:');
    print('  • Chaque module ne peut importer que lui-même + lib/common/');
    print('  • Pas d\'import croisé (ex: isopento → duel interdit)');
    print('  • Tous les imports relatifs au projet en package:pentapol/ (adressage absolu)\n');

    for (final module in modules) {
      await checkModule(module);
    }

    printSummary();
    exit(errors > 0 ? 1 : 0);
  }

  Future<void> checkModule(String module) async {
    final modulePath = Directory('$libPath/$module');

    if (!modulePath.existsSync()) {
      print('$yellow⚠ Module $module non trouvé$reset');
      return;
    }

    print('$yellow▸ Analyse $module$reset');
    violations[module] = [];

    final dartFiles = modulePath
        .listSync(recursive: true, followLinks: false)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'));

    for (final dartFile in dartFiles) {
      await checkDartFile(dartFile, module);
    }

    if (violations[module]!.isEmpty) {
      print('$green  ✓ Aucune violation$reset\n');
    } else {
      print('');
    }
  }

  Future<void> checkDartFile(File file, String currentModule) async {
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

      // Vérifier les imports package:pentapol/* (adressage absolu)
      if (importPath.startsWith('package:pentapol/')) {
        final moduleName = _extractModuleName(importPath);

        // Vérifier que c'est un import autorisé (pas import croisé)
        if (!_isAllowedImport(moduleName, currentModule)) {
          violations[currentModule]!.add(
            '${file.path}:$lineNum\n'
                '    Importe $moduleName (isolation violée): $line',
          );
          errors++;
        }
      }

      // Ignorer tous les autres imports (dart:, package: externes, etc.)
      // Vérification adressage absolu faite par check_absolute_imports.dart
    }
  }

  String _extractModuleName(String importPath) {
    // package:pentapol/[MODULE]/...
    final parts = importPath.split('/');
    if (parts.length > 1) {
      return parts[1];
    }
    return '';
  }

  bool _isAllowedImport(String importedModule, String currentModule) {
    // Autorisé: import depuis common OU depuis son propre module
    if (importedModule == commonModule || importedModule == currentModule) {
      return true;
    }

    // Autorisé: import vers un répertoire qui n'est PAS l'un des 5 modules
    // (providers, utils, models, etc.)
    if (!modules.contains(importedModule)) {
      return true;
    }

    // Interdit: import croisé entre les 5 modules
    return false;
  }

  void printSummary() {
    print('$bold=== Résumé ===$reset');

    bool hasViolations = false;
    for (final module in modules) {
      final moduleViolations = violations[module] ?? [];
      if (moduleViolations.isNotEmpty) {
        hasViolations = true;
        print('\n$red✗ $module ($bold${moduleViolations.length}$reset$red violations)$reset');
        for (final violation in moduleViolations) {
          print('  $violation');
        }
      }
    }

    if (!hasViolations) {
      print('$green✓ Tous les modules sont correctement isolés$reset');
    } else {
      print('\n$red✗ $bold$errors violations$reset$red détectées$reset');
    }
  }
}

Future<void> main(List<String> args) async {
  try {
    final checker = ModuleChecker();
    await checker.run();
  } catch (e) {
    print('$red✗ Erreur: $e$reset');
    exit(1);
  }
}