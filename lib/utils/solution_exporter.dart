// Modified: 2025-11-15 06:45:00
// lib/utils/solution_exporter.dart
// Module isolé pour exporter les solutions de pentominos dans un fichier
// Indépendant du reste de l'application

import 'dart:io';

/// Représente une solution de pentomino comme une grille 6x10
/// Chaque cellule contient le numéro de la pièce (1-12) qui l'occupe
class PentominoSolution {
  final List<List<int>> grid; // grid[y][x] = numéro de pièce (1-12)

  PentominoSolution(this.grid);

  /// Crée une grille vide 6x10
  static PentominoSolution empty() {
    return PentominoSolution(
        List.generate(10, (_) => List<int>.filled(6, 0))
    );
  }

  /// Convertit en string pour affichage
  @override
  String toString() {
    final buffer = StringBuffer();
    for (final row in grid) {
      buffer.writeln(row.map((n) => n.toString().padLeft(2)).join(' '));
    }
    return buffer.toString();
  }
}

/// Classe pour exporter les solutions vers un fichier
class SolutionExporter {
  final List<PentominoSolution> solutions = [];
  final String outputPath;

  SolutionExporter({required this.outputPath});

  /// Ajoute une solution à la collection
  void addSolution(PentominoSolution solution) {
    solutions.add(solution);
  }

  /// Sauvegarde toutes les solutions dans le fichier
  Future<void> saveToFile() async {
    final file = File(outputPath);
    final buffer = StringBuffer();

    // En-tête du fichier
    buffer.writeln('// Solutions de pentominos - Plateau 6x10 avec 12 pièces');
    buffer.writeln('// Format: grille 10 lignes x 6 colonnes');
    buffer.writeln('// Chaque nombre (1-12) représente une pièce');
    buffer.writeln('// Généré le ${DateTime.now()}');
    buffer.writeln('// Nombre total de solutions: ${solutions.length}');
    buffer.writeln();

    // Écrire chaque solution
    for (int i = 0; i < solutions.length; i++) {
      buffer.writeln('// Solution ${i + 1}');
      buffer.write(solutions[i].toString());
      buffer.writeln();
    }

    await file.writeAsString(buffer.toString());

    print('[EXPORT] ✅ ${solutions.length} solutions sauvegardées');
    print('[EXPORT] 📁 Fichier: $outputPath');
    print('[EXPORT] 📊 Taille: ${(await file.length()) / 1024} Ko');
  }

  /// Sauvegarde avec format compact (une solution par ligne)
  Future<void> saveCompact() async {
    final file = File('${outputPath}.compact');
    final buffer = StringBuffer();

    // En-tête
    buffer.writeln('# ${solutions.length} solutions');

    // Une ligne par solution (60 nombres séparés par des virgules)
    for (int i = 0; i < solutions.length; i++) {
      final flatGrid = solutions[i].grid.expand((row) => row).toList();
      buffer.writeln(flatGrid.join(','));
    }

    await file.writeAsString(buffer.toString());

    print('[EXPORT] ✅ Format compact sauvegardé: ${file.path}');
  }

  /// Sauvegarde au format Dart (tableau constant)
  Future<void> saveDartCode() async {
    final file = File('${outputPath}.dart');
    final buffer = StringBuffer();

    buffer.writeln('// Généré automatiquement - ${solutions.length} solutions');
    buffer.writeln('// ignore_for_file: lines_longer_than_80_chars');
    buffer.writeln();
    buffer.writeln('/// Solutions complètes pour un plateau 6x10 avec 12 pièces');
    buffer.writeln('const List<List<int>> allSolutions = [');

    for (int i = 0; i < solutions.length; i++) {
      final flatGrid = solutions[i].grid.expand((row) => row).toList();
      buffer.write('  [');
      buffer.write(flatGrid.join(','));
      buffer.writeln('],');

      // Ajouter des commentaires tous les 100 solutions
      if ((i + 1) % 100 == 0) {
        buffer.writeln('  // ${i + 1} solutions');
      }
    }

    buffer.writeln('];');

    await file.writeAsString(buffer.toString());

    print('[EXPORT] ✅ Code Dart généré: ${file.path}');
  }
}

/// Fonction utilitaire pour convertir une List<PlacementInfo> en grille
/// Cette fonction doit être adaptée selon ta structure PlacementInfo
PentominoSolution placementsToGrid(List<dynamic> placements, int width, int height) {
  final grid = List.generate(height, (_) => List<int>.filled(width, 0));

  for (int i = 0; i < placements.length; i++) {
    final placement = placements[i];
    final pieceNumber = i + 1; // Numéros de 1 à 12

    // Supposons que placement a une propriété occupiedCells: List<int>
    // où chaque cellule est numérotée de 1 à 60
    final occupiedCells = placement.occupiedCells as List<int>;

    for (final cellIndex in occupiedCells) {
      // Conversion cellIndex (1-60) en coordonnées (x,y)
      final x = (cellIndex - 1) % width;
      final y = (cellIndex - 1) ~/ width;
      grid[y][x] = pieceNumber;
    }
  }

  return PentominoSolution(grid);
}

// ============================================================================
// EXEMPLE D'UTILISATION STANDALONE
// ============================================================================

void main() async {
  print('Test du module SolutionExporter');

  // Créer quelques solutions de test
  final exporter = SolutionExporter(outputPath: 'pentomino_solutions_test.txt');

  // Solution de test 1
  final solution1 = PentominoSolution([
    [1, 1, 1, 2, 2, 3],
    [1, 1, 2, 2, 2, 3],
    [4, 4, 4, 5, 5, 3],
    [4, 4, 5, 5, 5, 3],
    [6, 7, 7, 8, 8, 3],
    [6, 6, 7, 7, 8, 9],
    [6, 6, 10, 10, 8, 9],
    [11, 10, 10, 10, 8, 9],
    [11, 11, 12, 12, 9, 9],
    [11, 11, 12, 12, 12, 9],
  ]);

  exporter.addSolution(solution1);
  exporter.addSolution(solution1); // Dupliquer pour le test

  // Sauvegarder dans tous les formats
  await exporter.saveToFile();
  await exporter.saveCompact();
  await exporter.saveDartCode();

  print('\n✅ Test terminé avec succès!');
}