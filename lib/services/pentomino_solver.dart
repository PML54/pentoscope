// Modified: 2025-11-15 06:45:00
// lib/services/pentomino_solver.dart

import 'package:pentapol/common/game_piece.dart';
import 'package:pentapol/common/pentominos.dart';
import 'package:pentapol/common/plateau.dart';
import 'package:pentapol/common/point.dart';

// Retourne la solution si elle existe, null sinon
List<PlacementInfo>? findSolution(Plateau plateau, List<Pento> pieces) {
  final solver = PentominoSolver(plateau: plateau, pieces: pieces);
  return solver.solve();
}

// Fonction helper pour juste vérifier si une solution existe
bool hasSolution(Plateau plateau, List<Pento> pieces) {
  return findSolution(plateau, pieces) != null;
}

class PentominoSolver {
  final Plateau plateau;
  final List<Pento> pieces;
  final int maxSeconds = 30; // Augmenté à 30 secondes

  late Plateau workingPlateau;
  late List<bool> piecesUsed;
  late DateTime startTime;
  late List<PlacementInfo> placementHistory;

  // Ordre des pièces à essayer (null = ordre de la liste)
  List<int>? _pieceOrder;

  int attemptCount = 0;

  // Pour l'interruption du comptage
  bool _shouldStopCounting = false;

  PentominoSolver({required this.plateau, required this.pieces}) {
    workingPlateau = plateau.copy();
    piecesUsed = List.filled(pieces.length, false);
    placementHistory = [];
  }

  /// Constructeur permettant de spécifier l'ordre des pièces par leurs IDs (1-12)
  factory PentominoSolver.fromIds({
    required Plateau plateau,
    required List<Pento> pentominos,
    List<int>? pieceOrder, // IDs de 1 à 12
  }) {
    List<int>? indexOrder;

    if (pieceOrder != null) {
      print('[SOLVER] Ordre demandé (IDs): $pieceOrder');

      // Convertir IDs → indices
      indexOrder = pieceOrder.map((id) {
        final index = pentominos.indexWhere((p) => p.id == id);
        if (index == -1) {
          throw ArgumentError('Pièce avec id=$id introuvable');
        }
        return index;
      }).toList();

      print('[SOLVER] Converti en indices: $indexOrder');
    }

    // Créer le solver avec l'ordre converti
    final solver = PentominoSolver(plateau: plateau, pieces: pentominos);

    solver._pieceOrder = indexOrder;
    return solver;
  }

  bool areIsolatedRegionsValid() {
    final visited = List.generate(
      workingPlateau.height,
      (_) => List.filled(workingPlateau.width, false),
    );

    for (int y = 0; y < workingPlateau.height; y++) {
      for (int x = 0; x < workingPlateau.width; x++) {
        if (workingPlateau.getCell(x, y) == 0 && !visited[y][x]) {
          final region = <Point>[];
          int regionSize = floodFillAndCollect(x, y, visited, region);

          // Règle 1 : Taille < 5 → impossible
          if (regionSize < 5) {
            return false;
          }

          // Règle 2 : Taille = 5 → vérifier qu'une pièce peut remplir
          if (regionSize == 5) {
            if (!canAnyAvailablePieceFitRegion(region)) {
              return false;
            }
          }

          // Règle 3 : Taille non multiple de 5 → impossible
          if (regionSize % 5 != 0) {
            return false;
          }
        }
      }
    }

    return true;
  }

  bool backtrack() {
    // Vérifier timeout
    if (DateTime.now().difference(startTime).inSeconds > maxSeconds) {
      return false;
    }

    // Toutes les pièces placées ?
    if (piecesUsed.every((used) => used)) {
      return true;
    }

    // Trouver la plus petite case libre
    final targetCell = findSmallestFreeCell();
    if (targetCell == -1) {
      // Plus de case libre mais toutes les pièces ne sont pas placées
      return piecesUsed.every((used) => used);
    }

    // Essayer chaque pièce non utilisée selon l'ordre défini
    final indicesToTry = _pieceOrder ?? List.generate(pieces.length, (i) => i);
    final availableIndices = indicesToTry.where((i) => !piecesUsed[i]);

    for (final pieceIndex in availableIndices) {
      final piece = pieces[pieceIndex];

      // Essayer chaque orientation
      for (
        int orientation = 0;
        orientation < piece.numPositions;
        orientation++
      ) {
        attemptCount++;

        final shape = piece.positions[orientation];

        // Calculer la translation nécessaire
        final minShapeCell = shape.reduce((a, b) => a < b ? a : b);
        final shapeCellX = (minShapeCell - 1) % 5;
        final shapeCellY = (minShapeCell - 1) ~/ 5;

        final targetX = (targetCell - 1) % 6;
        final targetY = (targetCell - 1) ~/ 6;

        final offsetX = targetX - shapeCellX;
        final offsetY = targetY - shapeCellY;

        // Vérifier si placement possible
        final occupiedCells = <int>[];
        if (canPlaceWithOffset(shape, offsetX, offsetY, occupiedCells)) {
          // Placer la pièce
          placeWithOffset(shape, offsetX, offsetY);
          piecesUsed[pieceIndex] = true;

          // Enregistrer dans l'historique
          placementHistory.add(
            PlacementInfo(
              pieceIndex: pieceIndex,
              orientation: orientation,
              targetCell: targetCell,
              offsetX: offsetX,
              offsetY: offsetY,
              occupiedCells: occupiedCells,
            ),
          );

          // Vérifier zones isolées après placement
          if (areIsolatedRegionsValid()) {
            // Continuer récursivement
            if (backtrack()) {
              return true;
            }
          }

          // Backtrack : annuler le placement
          removeWithOffset(shape, offsetX, offsetY);
          piecesUsed[pieceIndex] = false;
          placementHistory.removeLast();
        }
      }
    }

    return false;
  }

  // Version modifiée de backtrack qui saute un placement spécifique
  bool backtrackFromPosition(
    int skipPieceIndex,
    int skipOrientation,
    int skipTargetCell,
  ) {
    // Cette fonction n'est plus utilisée, on peut la supprimer
    // mais je la laisse pour compatibilité
    return backtrack();
  }

  bool canAnyAvailablePieceFitRegion(List<Point> region) {
    if (region.length != 5) return true;

    // Pièces disponibles
    final availablePieces = <Pento>[];
    for (int i = 0; i < pieces.length; i++) {
      if (!piecesUsed[i]) {
        availablePieces.add(pieces[i]);
      }
    }

    if (availablePieces.isEmpty) {
      return false;
    }

    // Normaliser la région
    final minX = region.map((p) => p.x).reduce((a, b) => a < b ? a : b);
    final minY = region.map((p) => p.y).reduce((a, b) => a < b ? a : b);
    final normalizedRegion = region
        .map((p) => Point(p.x - minX, p.y - minY))
        .toSet();

    // Tester chaque pièce disponible
    for (final piece in availablePieces) {
      for (
        int orientation = 0;
        orientation < piece.numPositions;
        orientation++
      ) {
        final shape = piece.positions[orientation];
        final shapeCoords = GamePiece.shapeToCoordinates(shape);

        // Normaliser la forme
        final shapeMinX = shapeCoords
            .map((p) => p.x)
            .reduce((a, b) => a < b ? a : b);
        final shapeMinY = shapeCoords
            .map((p) => p.y)
            .reduce((a, b) => a < b ? a : b);
        final normalizedShape = shapeCoords
            .map((p) => Point(p.x - shapeMinX, p.y - shapeMinY))
            .toSet();

        // Comparer
        if (normalizedShape.length == normalizedRegion.length) {
          bool match = true;
          for (final point in normalizedShape) {
            if (!normalizedRegion.contains(point)) {
              match = false;
              break;
            }
          }

          if (match) {
            return true;
          }
        }
      }
    }

    return false;
  }

  bool canPlaceWithOffset(
    List<int> shape,
    int offsetX,
    int offsetY,
    List<int> occupiedCells,
  ) {
    occupiedCells.clear();

    for (int shapeCell in shape) {
      // Coordonnées dans la grille 5×5
      final sx = (shapeCell - 1) % 5;
      final sy = (shapeCell - 1) ~/ 5;

      // Coordonnées sur le plateau après translation
      final px = sx + offsetX;
      final py = sy + offsetY;

      // Vérifier limites
      if (!workingPlateau.isInBounds(px, py)) {
        return false;
      }

      // Vérifier disponibilité
      if (workingPlateau.getCell(px, py) != 0) {
        return false;
      }

      // Enregistrer la case du plateau (numérotation 1-60)
      occupiedCells.add(py * 6 + px + 1);
    }

    return true;
  }

  Future<int> countAllSolutions({
    required void Function(int count, int elapsedSeconds) onProgress,
  }) async {
    print(
      '[SOLVER] Démarrage comptage exhaustif - ${pieces.length} pièces, ${plateau.numVisibleCells} cases',
    );

    startTime = DateTime.now();
    _shouldStopCounting = false;
    int solutionCount = 0;
    int lastYieldTime = DateTime.now().millisecondsSinceEpoch;

    // Fonction récursive qui compte toutes les solutions
    Future<void> countRecursive() async {
      // Vérifier si on doit arrêter
      if (_shouldStopCounting) {
        print('[SOLVER] ⏸️ Comptage interrompu par l\'utilisateur');
        return;
      }

      // Vérifier si toutes les pièces sont placées
      if (placementHistory.length == pieces.length) {
        solutionCount++;
        final elapsed = DateTime.now().difference(startTime).inSeconds;

        // Callback pour mise à jour UI - SEULEMENT tous les 10 pour accélérer
        if (solutionCount % 10 == 0) {
          onProgress(solutionCount, elapsed);
        }

        // Log périodique (toutes les 100 solutions)
        if (solutionCount % 100 == 0) {
          print('[SOLVER] 🔢 $solutionCount solutions trouvées en ${elapsed}s');
        }

        return; // Ne pas continuer après une solution complète
      }

      // Trouver la prochaine pièce non utilisée
      int? nextPieceIndex;
      for (int i = 0; i < pieces.length; i++) {
        if (!piecesUsed[i]) {
          nextPieceIndex = i;
          break;
        }
      }

      if (nextPieceIndex == null) return;

      final piece = pieces[nextPieceIndex];

      // Essayer toutes les positions et orientations
      for (int targetCell = 1; targetCell <= 60; targetCell++) {
        if (_shouldStopCounting) return;

        final x = (targetCell - 1) % 6;
        final y = (targetCell - 1) ~/ 6;

        if (!workingPlateau.isInBounds(x, y)) continue;
        if (workingPlateau.getCell(x, y) == -1) continue;

        for (
          int orientation = 0;
          orientation < piece.numPositions;
          orientation++
        ) {
          if (_shouldStopCounting) return;

          attemptCount++;
          final shape = piece.positions[orientation];

          // Yield périodiquement pour permettre la mise à jour UI (toutes les 50ms)
          final now = DateTime.now().millisecondsSinceEpoch;
          if (now - lastYieldTime > 50) {
            await Future.delayed(Duration.zero); // Yield au scheduler
            lastYieldTime = now;
          }

          // Calculer offset
          final minShapeCell = shape.reduce((a, b) => a < b ? a : b);
          final shapeCellX = (minShapeCell - 1) % 5;
          final shapeCellY = (minShapeCell - 1) ~/ 5;
          final targetX = (targetCell - 1) % 6;
          final targetY = (targetCell - 1) ~/ 6;
          final offsetX = targetX - shapeCellX;
          final offsetY = targetY - shapeCellY;

          // Vérifier placement
          final occupiedCells = <int>[];
          if (canPlaceWithOffset(shape, offsetX, offsetY, occupiedCells)) {
            // Placer la pièce
            placeWithOffset(shape, offsetX, offsetY);
            piecesUsed[nextPieceIndex] = true;
            placementHistory.add(
              PlacementInfo(
                pieceIndex: nextPieceIndex,
                orientation: orientation,
                targetCell: targetCell,
                offsetX: offsetX,
                offsetY: offsetY,
                occupiedCells: occupiedCells,
              ),
            );

            // Vérifier heuristique zones isolées
            if (areIsolatedRegionsValid()) {
              // Continuer récursivement
              await countRecursive();
            }

            // Retirer la pièce (backtrack)
            removeWithOffset(shape, offsetX, offsetY);
            piecesUsed[nextPieceIndex] = false;
            placementHistory.removeLast();
          }
        }
      }
    }

    // Lancer le comptage
    await countRecursive();

    final duration = DateTime.now().difference(startTime);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;

    // Appeler onProgress une dernière fois avec le compte final
    // (au cas où ce n'est pas un multiple de 10)
    final elapsed = DateTime.now().difference(startTime).inSeconds;
    onProgress(solutionCount, elapsed);

    if (_shouldStopCounting) {
      print(
        '[SOLVER] ⏸️ Comptage interrompu: $solutionCount solutions en ${minutes}m ${seconds}s',
      );
    } else {
      print(
        '[SOLVER] ✅ Comptage terminé: $solutionCount solutions en ${minutes}m ${seconds}s ($attemptCount tentatives)',
      );
    }

    return solutionCount;
  }

  /// Trouve toutes les solutions et les retourne
  /// Utile pour la normalisation
  Future<List<List<PlacementInfo>>> findAllSolutions({
    void Function(int count, int elapsedSeconds)? onProgress,
    int? maxSolutions,
  }) async {
    print('[SOLVER] Recherche de toutes les solutions...');

    startTime = DateTime.now();
    _shouldStopCounting = false;
    attemptCount = 0;

    final allSolutions = <List<PlacementInfo>>[];
    int lastYieldTime = DateTime.now().millisecondsSinceEpoch;
    int lastProgressTime = 0;

    // Réinitialiser l'état
    workingPlateau = plateau.copy();
    piecesUsed = List.filled(pieces.length, false);
    placementHistory = [];

    Future<void> searchRecursive() async {
      if (_shouldStopCounting) return;
      if (maxSolutions != null && allSolutions.length >= maxSolutions) return;

      // Timeout check
      final elapsed = DateTime.now().difference(startTime).inSeconds;
      if (elapsed > maxSeconds) {
        print('[SOLVER] ⏱️  Timeout après ${maxSeconds}s');
        return;
      }

      // Solution complète trouvée ?
      if (piecesUsed.every((used) => used)) {
        // Sauvegarder une copie de la solution
        allSolutions.add(List.from(placementHistory));

        // Callback de progression
        if (onProgress != null) {
          final now = elapsed;
          if (now - lastProgressTime >= 10 || allSolutions.length % 1000 == 0) {
            onProgress(allSolutions.length, now);
            lastProgressTime = now;
          }
        }

        return;
      }

      // Trouver la prochaine case libre
      final targetCell = findSmallestFreeCell();
      if (targetCell == -1) return;

      // Essayer chaque pièce non utilisée selon l'ordre défini
      final indicesToTry =
          _pieceOrder ?? List.generate(pieces.length, (i) => i);
      final availableIndices = indicesToTry.where((i) => !piecesUsed[i]);

      for (final pieceIndex in availableIndices) {
        if (_shouldStopCounting) return;

        final piece = pieces[pieceIndex];

        for (
          int orientation = 0;
          orientation < piece.numPositions;
          orientation++
        ) {
          attemptCount++;

          // Yield périodiquement pour garder l'UI responsive
          final now = DateTime.now().millisecondsSinceEpoch;
          if (now - lastYieldTime > 50) {
            await Future.delayed(Duration.zero);
            lastYieldTime = now;
          }

          final shape = piece.positions[orientation];
          final minShapeCell = shape.reduce((a, b) => a < b ? a : b);
          final shapeCellX = (minShapeCell - 1) % 5;
          final shapeCellY = (minShapeCell - 1) ~/ 5;

          final targetX = (targetCell - 1) % plateau.width;
          final targetY = (targetCell - 1) ~/ plateau.width;

          final offsetX = targetX - shapeCellX;
          final offsetY = targetY - shapeCellY;

          final occupiedCells = <int>[];
          if (canPlaceWithOffset(shape, offsetX, offsetY, occupiedCells)) {
            placeWithOffset(shape, offsetX, offsetY);
            piecesUsed[pieceIndex] = true;
            placementHistory.add(
              PlacementInfo(
                pieceIndex: pieceIndex,
                orientation: orientation,
                targetCell: targetCell,
                offsetX: offsetX,
                offsetY: offsetY,
                occupiedCells: occupiedCells,
              ),
            );

            if (areIsolatedRegionsValid()) {
              await searchRecursive();
            }

            removeWithOffset(shape, offsetX, offsetY);
            piecesUsed[pieceIndex] = false;
            placementHistory.removeLast();
          }
        }
      }
    }

    await searchRecursive();

    final duration = DateTime.now().difference(startTime);
    print(
      '[SOLVER] ✅ Terminé: ${allSolutions.length} solutions en ${duration.inSeconds}s',
    );

    return allSolutions;
  }

  // Trouve la prochaine solution en continuant depuis l'état actuel
  List<PlacementInfo>? findNext() {
    print('[SOLVER] Recherche solution suivante...');

    if (placementHistory.isEmpty) {
      return null;
    }

    // CRITIQUE: Réinitialiser le timer pour cette nouvelle recherche
    startTime = DateTime.now();
    final startAttempts = attemptCount;

    // Algorithme: remonter dans l'historique en incrémentant les orientations
    // Exemple: si on a (1,3) (2,5) (3,2) ... (11,2) (12,7)
    // 1. Retirer pièce 12
    // 2. Retirer pièce 11 (position 2)
    // 3. Essayer pièce 11 position 3, 4, 5... jusqu'à épuisement
    // 4. Si épuisé, retirer pièce 10 et incrémenter sa position
    // 5. Replacer pièce 11 en position de départ (0)
    // Et ainsi de suite...

    while (placementHistory.isNotEmpty) {
      // Timeout check
      if (DateTime.now().difference(startTime).inSeconds > maxSeconds) {
        print(
          '[SOLVER] ✗ Timeout atteint après ${attemptCount - startAttempts} tentatives',
        );
        return null;
      }

      // Retirer le dernier placement
      final lastPlacement = placementHistory.removeLast();
      final lastPieceIndex = lastPlacement.pieceIndex;
      final lastOrientation = lastPlacement.orientation;
      final lastTargetCell = lastPlacement.targetCell;

      final piece = pieces[lastPieceIndex];
      final shape = piece.positions[lastOrientation];
      removeWithOffset(shape, lastPlacement.offsetX, lastPlacement.offsetY);
      piecesUsed[lastPieceIndex] = false;

      // Chercher prochaine alternative en explorant:
      // 1. Orientations suivantes à même targetCell
      // 2. TargetCells suivantes avec toutes orientations
      bool foundAlternative = tryNextPlacements(
        lastPieceIndex,
        lastTargetCell, // Commencer à cette targetCell
        lastOrientation + 1, // Commencer à orientation suivante
      );

      if (foundAlternative) {
        // On a trouvé une alternative pour cette pièce, continuer normalement
        if (backtrack()) {
          final duration = DateTime.now().difference(startTime);
          print(
            '[SOLVER] ✓ SOLUTION SUIVANTE TROUVÉE en ${duration.inMilliseconds / 1000}s (${attemptCount - startAttempts} tentatives)',
          );
          return List.from(placementHistory);
        }
        // Si backtrack échoue, on continue la boucle pour remonter encore
      }

      // Pas d'alternative trouvée pour cette pièce, continuer à remonter
    }

    print('[SOLVER] ✗ Aucune autre solution (remonté jusqu\'au début)');
    return null;
  }

  // ============================================================================
  // GESTION DU PLATEAU
  // ============================================================================

  int findSmallestFreeCell() {
    for (int caseNum = 1; caseNum <= 60; caseNum++) {
      final x = (caseNum - 1) % 6;
      final y = (caseNum - 1) ~/ 6;
      if (workingPlateau.getCell(x, y) == 0) {
        return caseNum;
      }
    }
    return -1;
  }

  int floodFillAndCollect(
    int x,
    int y,
    List<List<bool>> visited,
    List<Point> region,
  ) {
    if (!workingPlateau.isInBounds(x, y) ||
        visited[y][x] ||
        workingPlateau.getCell(x, y) != 0) {
      return 0;
    }

    visited[y][x] = true;
    region.add(Point(x, y));
    int size = 1;

    size += floodFillAndCollect(x - 1, y, visited, region);
    size += floodFillAndCollect(x + 1, y, visited, region);
    size += floodFillAndCollect(x, y - 1, visited, region);
    size += floodFillAndCollect(x, y + 1, visited, region);

    return size;
  }

  void placeWithOffset(List<int> shape, int offsetX, int offsetY) {
    for (int shapeCell in shape) {
      final sx = (shapeCell - 1) % 5;
      final sy = (shapeCell - 1) ~/ 5;
      final px = sx + offsetX;
      final py = sy + offsetY;

      workingPlateau.setCell(px, py, 1);
    }
  }

  void removeWithOffset(List<int> shape, int offsetX, int offsetY) {
    for (int shapeCell in shape) {
      final sx = (shapeCell - 1) % 5;
      final sy = (shapeCell - 1) ~/ 5;
      final px = sx + offsetX;
      final py = sy + offsetY;

      workingPlateau.setCell(px, py, 0);
    }
  }

  List<PlacementInfo>? solve() {
    startTime = DateTime.now();
    print(
      '[SOLVER] Démarrage - ${pieces.length} pièces, ${plateau.numVisibleCells} cases',
    );

    final result = backtrack();

    final duration = DateTime.now().difference(startTime);
    if (result) {
      print(
        '[SOLVER] ✓ SOLUTION TROUVÉE en ${duration.inMilliseconds / 1000}s ($attemptCount tentatives)',
      );
      print('[SOLVER] Solution: ${placementHistory.length} pièces placées');
      return List.from(placementHistory); // Copie de l'historique
    } else {
      print(
        '[SOLVER] ✗ AUCUNE SOLUTION après ${duration.inMilliseconds / 1000}s ($attemptCount tentatives)',
      );
      return null;
    }
  }

  /// Demande l'arrêt du comptage en cours
  void stopCounting() {
    _shouldStopCounting = true;
  }

  // AJOUTEZ CETTE MÉTHODE dans votre PentominoSolver (pentomino_solver.dart)
  // Après la méthode countAllSolutions

  // Essaie de placer une pièce spécifique en explorant toutes positions et orientations
  // à partir de (startTargetCell, startOrientation)
  bool tryNextPlacements(
    int pieceIndex,
    int startTargetCell,
    int startOrientation,
  ) {
    final piece = pieces[pieceIndex];

    // Explorer toutes les targetCells à partir de startTargetCell
    for (int targetCell = startTargetCell; targetCell <= 60; targetCell++) {
      // Vérifier si la case existe et est visible sur le plateau
      final x = (targetCell - 1) % 6;
      final y = (targetCell - 1) ~/ 6;

      // Sortir si hors du plateau
      if (!workingPlateau.isInBounds(x, y)) continue;

      // Ignorer les cases cachées
      if (workingPlateau.getCell(x, y) == -1) continue;

      // Déterminer à partir de quelle orientation commencer
      // Si même targetCell que départ, continuer après startOrientation
      // Sinon, recommencer à 0
      int orientationStart = (targetCell == startTargetCell)
          ? startOrientation
          : 0;

      // Explorer toutes les orientations pour cette targetCell
      for (
        int orientation = orientationStart;
        orientation < piece.numPositions;
        orientation++
      ) {
        attemptCount++;

        final shape = piece.positions[orientation];

        // Calculer la translation nécessaire
        final minShapeCell = shape.reduce((a, b) => a < b ? a : b);
        final shapeCellX = (minShapeCell - 1) % 5;
        final shapeCellY = (minShapeCell - 1) ~/ 5;

        final targetX = (targetCell - 1) % 6;
        final targetY = (targetCell - 1) ~/ 6;

        final offsetX = targetX - shapeCellX;
        final offsetY = targetY - shapeCellY;

        // Vérifier si placement possible
        final occupiedCells = <int>[];
        if (canPlaceWithOffset(shape, offsetX, offsetY, occupiedCells)) {
          // Placer la pièce
          placeWithOffset(shape, offsetX, offsetY);
          piecesUsed[pieceIndex] = true;

          // Enregistrer dans l'historique
          placementHistory.add(
            PlacementInfo(
              pieceIndex: pieceIndex,
              orientation: orientation,
              targetCell: targetCell,
              offsetX: offsetX,
              offsetY: offsetY,
              occupiedCells: occupiedCells,
            ),
          );

          // Vérifier zones isolées
          if (areIsolatedRegionsValid()) {
            print(
              '[SOLVER] Trouvé alternative: pièce $pieceIndex, case $targetCell, orientation $orientation',
            );
            return true;
          }

          // Annuler si zones invalides
          removeWithOffset(shape, offsetX, offsetY);
          piecesUsed[pieceIndex] = false;
          placementHistory.removeLast();
        }
      }
    }

    return false; // Aucun placement valide trouvé
  }
}

class PlacementInfo {
  final int pieceIndex;
  final int orientation;
  final int targetCell;
  final int offsetX;
  final int offsetY;
  final List<int> occupiedCells;

  PlacementInfo({
    required this.pieceIndex,
    required this.orientation,
    required this.targetCell,
    required this.offsetX,
    required this.offsetY,
    required this.occupiedCells,
  });

  @override
  String toString() {
    return 'Pièce ${pieceIndex + 1}, orientation ${orientation + 1} → case $targetCell (offset: $offsetX,$offsetY)';
  }
}
