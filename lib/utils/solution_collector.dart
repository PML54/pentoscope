// Modified: 2025-11-15 06:45:00
// lib/utils/solution_collector.dart
// Adaptateur pour collecter les solutions du solver et les exporter

import 'package:pentapol/utils/solution_exporter.dart';
import 'package:pentapol/services/pentomino_solver.dart'; // Ajuste le chemin selon ton projet

/// Collecteur qui capture les solutions du solver et les exporte
class SolutionCollector {
  final SolutionExporter exporter;
  int solutionCount = 0;

  SolutionCollector({required String outputPath})
      : exporter = SolutionExporter(outputPath: outputPath);

  /// Callback à passer au solver pour chaque solution trouvée
  void onSolutionFound(List<PlacementInfo> placements) {
    solutionCount++;

    // Convertir les placements en grille
    final grid = _placementsToGrid(placements);
    exporter.addSolution(PentominoSolution(grid));

    // Afficher progression tous les 100 solutions
    if (solutionCount % 100 == 0) {
      print('[COLLECTOR] 📊 $solutionCount solutions collectées');
    }
  }

  /// Convertit une List<PlacementInfo> en grille 10x6
  List<List<int>> _placementsToGrid(List<PlacementInfo> placements) {
    // Grille 10 lignes x 6 colonnes (attention: y avant x!)
    final grid = List.generate(10, (_) => List<int>.filled(6, 0));

    for (int i = 0; i < placements.length; i++) {
      final placement = placements[i];
      final pieceNumber = i + 1; // Numéros de 1 à 12

      for (final cellIndex in placement.occupiedCells) {
        // cellIndex est de 1 à 60, mais ton plateau fait 6 de large
        // D'après ton code: boardCell = actualY * 6 + actualX + 1
        // Donc: actualX = (cellIndex - 1) % 6
        //       actualY = (cellIndex - 1) ~/ 6
        final x = (cellIndex - 1) % 6;
        final y = (cellIndex - 1) ~/ 6;
        grid[y][x] = pieceNumber;
      }
    }

    return grid;
  }

  /// Sauvegarde finale et statistiques
  Future<void> finalize() async {
    print('[COLLECTOR] 🏁 Finalisation: $solutionCount solutions');

    await exporter.saveToFile();
    await exporter.saveCompact();
    await exporter.saveDartCode();

    print('[COLLECTOR] ✅ Export terminé');
  }
}

// ============================================================================
// FONCTION STANDALONE POUR TESTER SANS MODIFIER TON CODE PRINCIPAL
// ============================================================================

/// Lance le comptage et la collecte des solutions de manière isolée
Future<void> collectAllSolutions({
  required String outputPath,
  String plateauType = '6x10',
}) async {
  print('=' * 70);
  print('COLLECTE DES SOLUTIONS DE PENTOMINOS');
  print('Plateau: $plateauType avec 12 pièces');
  print('Fichier de sortie: $outputPath');
  print('=' * 70);
  print('');

  // Note: Cette fonction nécessite d'importer tes classes Plateau et pentominos
  // Pour la rendre complètement standalone, tu devras:
  // 1. Créer le plateau
  // 2. Sélectionner les 12 pièces
  // 3. Créer le solver
  // 4. Lancer countAllSolutions avec le collector

  print('⚠️  Cette fonction doit être appelée depuis ton code existant');
  print('    Voir exemple d\'intégration ci-dessous');
}

