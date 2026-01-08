#!/usr/bin/env dart

// tools/check_external_dependencies.dart
// Identifie quels répertoires/fichiers (autres que les 5 modules)
// sont importés par au moins l'un des 5 modules.
//
// Exemple: si isopento/ importe package:pentapol/providers/auth.dart
// alors providers/ apparaît dans le rapport

import 'dart:io';

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

class ExternalDependenciesChecker {
  // Map: externalDir -> Set of (importingModule, importPath)
  final Map<String, Set<String>> externalDeps = {};

  Future<void> run() async {
    print('$bold=== Dépendances externes des modules Pentapol ===$reset');
    print('Modules analysés: ${modules.join(", ")}\n');
    print('Recherche des imports vers répertoires autres que common et les 5 modules...\n');

    for (final module in modules) {
      await checkModule(module);
    }

    printSummary();
  }

  Future<void> checkModule(String module) async {
    final modulePath = Directory('$libPath/$module');

    if (!modulePath.existsSync()) {
      return;
    }

    final dartFiles = modulePath
        .listSync(recursive: true, followLinks: false)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'));

    for (final dartFile in dartFiles) {
      await checkDartFile(dartFile, module);
    }
  }

  Future<void> checkDartFile(File file, String currentModule) async {
    final content = await file.readAsString();
    final lines = content.split('\n');

    for (final line in lines) {
      // Sauter commentaires et lignes vides
      if (line.trim().startsWith('//') || line.trim().isEmpty) {
        continue;
      }

      // Extraire imports
      final importMatch = RegExp(
          "^\\s*import\\s+['\"]([^'\"]+)['\"]"
      ).firstMatch(line);

      if (importMatch == null) continue;

      final importPath = importMatch.group(1)!;

      // Analyser uniquement les imports package:pentapol/
      if (!importPath.startsWith('package:pentapol/')) {
        continue;
      }

      // Extraire le module/répertoire importé
      final parts = importPath.split('/');
      if (parts.length < 2) continue;

      final externalDir = parts[1];

      // Ignorer les imports des 5 modules et common
      if (modules.contains(externalDir) || externalDir == commonModule) {
        continue;
      }

      // Enregistrer cette dépendance
      final key = externalDir;
      externalDeps.putIfAbsent(key, () => {});

      // Stocker le module qui importe et le chemin complet
      externalDeps[key]!.add('$currentModule → $importPath');
    }
  }

  void printSummary() {
    if (externalDeps.isEmpty) {
      print('$green✓ Aucune dépendance externe trouvée$reset');
      return;
    }

    print('$bold=== Répertoires externes utilisés ===$reset\n');

    final sortedDirs = externalDeps.keys.toList()..sort();

    for (final dir in sortedDirs) {
      final imports = externalDeps[dir]!;
      final modulesUsing = <String>{};

      for (final imp in imports) {
        final module = imp.split(' → ')[0];
        modulesUsing.add(module);
      }

      print('$bold$dir$reset (utilisé par ${modulesUsing.length} module(s): ${modulesUsing.join(", ")})');
      for (final imp in imports.toList()..sort()) {
        print('  • $imp');
      }
      print('');
    }

    print('$bold=== Résumé ===$reset');
    print('Répertoires externes: $bold${externalDeps.length}$reset');
    print('Total imports externes: $bold${externalDeps.values.fold(0, (sum, set) => sum + set.length)}$reset');
  }
}

Future<void> main(List<String> args) async {
  try {
    final checker = ExternalDependenciesChecker();
    await checker.run();
  } catch (e) {
    print('$red✗ Erreur: $e$reset');
    exit(1);
  }
}