// lib/pentapol/providers/pentomino_game_provider.dart
// Modified: 251209157
// Corrections: (1) Toujours calculer solutions même si plateau vide, (2) Afficher 9356 à l'initialisation

import 'dart:async';

import 'package:flutter/material.dart' show Color, debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pentapol/classical/pentomino_game_state.dart';

import 'package:pentapol/common/pentominos.dart';
import 'package:pentapol/common/placed_piece.dart';
import 'package:pentapol/common/plateau.dart';
import 'package:pentapol/common/point.dart';
import 'package:pentapol/common/shape_recognizer.dart';
import 'package:pentapol/services/plateau_solution_counter.dart' show PlateauSolutionCounter;
import 'package:pentapol/services/solution_matcher.dart' show SolutionInfo;
import 'package:pentapol/providers/settings_provider.dart' show settingsDatabaseProvider;
import 'dart:math';
import 'package:pentapol/services/solution_matcher.dart' show solutionMatcher;
import 'package:collection/collection.dart';

final pentominoGameProvider =
NotifierProvider<PentominoGameNotifier, PentominoGameState>(
      () => PentominoGameNotifier(),
);

class PentominoGameNotifier extends Notifier<PentominoGameState> {
  static const int _snapRadius = 2;

  Timer? _gameTimer;  // ✨ NOUVEAU
  DateTime? _startTime;  // ✨ NOUVEAU






  /// Applique une rotation 90° horaire
  void applyIsometryRotationCW() {
    debugPrint(
      "ISO: RotCW (view=${state.viewOrientation}) idx=${state.selectedPositionIndex} piece=${state.selectedPiece?.id} placed=${state.selectedPlacedPiece?.piece.id}",
    );

    // Pour les pièces placées, appliquer une rotation spécifique
    if (state.selectedPlacedPiece != null) {
      _applyRotationToPlacedPiece(isClockwise: true);
      return;
    }

    // Pour les pièces du slider, rotation normale
    _applyIsoUsingLookup((p, idx) => p.rotationCW(idx));
  }

  /// Applique une rotation 90° anti-horaire
  void applyIsometryRotationTW() {
    debugPrint(
      "ISO: RotTW (view=${state.viewOrientation}) idx=${state.selectedPositionIndex} piece=${state.selectedPiece?.id} placed=${state.selectedPlacedPiece?.piece.id}",
    );

    // Pour les pièces placées, appliquer une rotation spécifique
    if (state.selectedPlacedPiece != null) {
      _applyRotationToPlacedPiece(isClockwise: false);
      return;
    }

    // Pour les pièces du slider, rotation normale
    _applyIsoUsingLookup((p, idx) => p.rotationTW(idx));
  }

  /// Applique une symétrie (H/V swap en paysage)
  void applyIsometrySymmetryH() {
    debugPrint(
      "ISO: SymH (view=${state.viewOrientation}) idx=${state.selectedPositionIndex} piece=${state.selectedPiece?.id} placed=${state.selectedPlacedPiece?.piece.id}",
    );

    // Pour les pièces placées, appliquer la symétrie relative à la mastercase si définie
    if (state.selectedPlacedPiece != null) {
      if (state.selectedCellInPiece != null) {
        _applySymmetryWithMastercase(isHorizontal: true);
      } else {
        // Comportement classique si pas de mastercase
        _applySymmetryToPlacedPiece(isHorizontal: true);
      }
      return;
    }

    // Pour les pièces du slider, comportement classique
    if (state.viewOrientation == ViewOrientation.landscape) {
      _applyIsoUsingLookup((p, idx) => p.symmetryV(idx));
    } else {
      _applyIsoUsingLookup((p, idx) => p.symmetryH(idx));
    }
  }

  /// Applique une symétrie verticale (V/H swap en paysage)
  void applyIsometrySymmetryV() {
    debugPrint(
      "ISO: SymV (view=${state.viewOrientation}) idx=${state.selectedPositionIndex} piece=${state.selectedPiece?.id} placed=${state.selectedPlacedPiece?.piece.id}",
    );

    // Pour les pièces placées, appliquer la symétrie relative à la mastercase si définie
    if (state.selectedPlacedPiece != null) {
      if (state.selectedCellInPiece != null) {
        _applySymmetryWithMastercase(isHorizontal: false);
      } else {
        // Comportement classique si pas de mastercase
        _applySymmetryToPlacedPiece(isHorizontal: false);
      }
      return;
    }

    // Pour les pièces du slider, comportement classique
    if (state.viewOrientation == ViewOrientation.landscape) {
      _applyIsoUsingLookup((p, idx) => p.symmetryH(idx));
    } else {
      _applyIsoUsingLookup((p, idx) => p.symmetryV(idx));
    }
  }
  // ========================================================================
  // 🆕 GESTION ORIENTATION + ISOMÉTRIES LOOKUP (Pentoscope approach)
  // ========================================================================

  @override
  PentominoGameState build() {
    final initialState = PentominoGameState.initial();
    // Calculer le total de solutions au démarrage (plateau vide = 9356)
    final totalSolutions = Plateau.allVisible(6, 10).countPossibleSolutions();
    return initialState.copyWith(solutionsCount: totalSolutions);
  }

  int calculateScore(int elapsedSeconds) {
    // Score basé sur rapidité : 100 - (secondes / 2)
    // Max 100 (< 10 sec), Min 0 (> 200 sec)
    int score = 100 - (elapsedSeconds ~/ 2);
    return score.clamp(0, 100);
  }

  /// Annule la sélection en cours
  void cancelSelection() {
    if (state.selectedPiece == null) return;

    // Si c'est une pièce placée, la replacer sur le plateau
    if (state.selectedPlacedPiece != null) {
      final placedPiece = state.selectedPlacedPiece!;

      // Reconstruire le plateau avec toutes les pièces placées + celle qui était sélectionnée
      final newPlateau = Plateau.allVisible(6, 10);

      // Replacer toutes les pièces déjà placées
      for (final placed in state.placedPieces) {
        final position = placed.piece.positions[placed.positionIndex];

        for (final cellNum in position) {
          final localX = (cellNum - 1) % 5;
          final localY = (cellNum - 1) ~/ 5;
          final x = placed.gridX + localX;
          final y = placed.gridY + localY;
          newPlateau.setCell(x, y, placed.piece.id);
        }
      }

      // Replacer la pièce qui était sélectionnée à sa position d'origine
      final position = placedPiece.piece.positions[state.selectedPositionIndex];
      for (final cellNum in position) {
        final localX = (cellNum - 1) % 5;
        final localY = (cellNum - 1) ~/ 5;
        final x = placedPiece.gridX + localX;
        final y = placedPiece.gridY + localY;
        if (x >= 0 && x < 6 && y >= 0 && y < 10) {
          newPlateau.setCell(x, y, placedPiece.piece.id);
        }
      }

      // Remettre la pièce dans les placées avec sa nouvelle position si elle a été modifiée
      final updatedPlacedPiece = placedPiece.copyWith(
        positionIndex: state.selectedPositionIndex,
      );
      final newPlaced = List<PlacedPiece>.from(state.placedPieces)
        ..add(updatedPlacedPiece);

      state = state.copyWith(
        plateau: newPlateau,
        placedPieces: newPlaced,
        clearSelectedPiece: true,
        clearSelectedPlacedPiece: true,
        clearSelectedCellInPiece: true,
      );
      _recomputeBoardValidity();

    } else {
      // C'est une pièce du slider, juste annuler la sélection
      state = state.copyWith(
        clearSelectedPiece: true,
        clearSelectedPlacedPiece: true,
        clearSelectedCellInPiece: true,
      );

    }
  }
// lib/pentapol/providers/pentomino_game_provider.dart
// Modified: 250101HHMMM
// Apply hint from compatible solutions
// CHANGEMENTS: (1) applyHint() method


// ========================================================================
// 💡 HINT SYSTEM - Appliquer un indice basé sur une solution aléatoire
// ========================================================================

  /// Applique un indice en choisissant une solution compatible aléatoire
  /// et en plaçant une pièce du slider qui n'est pas encore posée
  void applyHint() {
    // 1️⃣ Récupérer les indices des solutions compatibles
    final compatibleIndices = state.plateau.getCompatibleSolutionIndices();

    if (compatibleIndices.isEmpty) {
      debugPrint('❌ HINT: Aucune solution compatible');
      return;
    }

    // 2️⃣ Choisir une solution au hasard
    final random = Random();
    final randomSolutionIndex = compatibleIndices[random.nextInt(compatibleIndices.length)];

    debugPrint(
      '💡 HINT: Solution sélectionnée #$randomSolutionIndex sur ${compatibleIndices.length} compatibles',
    );

    // 3️⃣ Décoder la solution BigInt en PlacedPiece
    final allSolutionPieces = solutionMatcher.getPlacedPiecesByIndex(randomSolutionIndex);

    if (allSolutionPieces == null || allSolutionPieces.isEmpty) {
      debugPrint('❌ HINT: Impossible de décoder la solution');
      return;
    }

    // 4️⃣ Trouver une pièce NON encore placée (du slider)
    final placedPieceIds = state.placedPieces.map((p) => p.piece.id).toSet();
    final PlacedPiece? hintPiece = allSolutionPieces.firstWhereOrNull(
          (p) => !placedPieceIds.contains(p.piece.id),
    );

    if (hintPiece == null) {
      debugPrint('❌ HINT: Aucune pièce nouvelle trouvée dans cette solution');
      return;
    }

    // 5️⃣ Ajouter cette pièce au plateau
    final newPlaced = List<PlacedPiece>.from(state.placedPieces)..add(hintPiece);

    // 6️⃣ Reconstruire le plateau avec la nouvelle pièce
    final newPlateau = Plateau.allVisible(6, 10);
    for (final placed in newPlaced) {
      final position = placed.piece.positions[placed.positionIndex];
      for (final cellNum in position) {
        final localX = (cellNum - 1) % 5;
        final localY = (cellNum - 1) ~/ 5;
        final x = placed.gridX + localX;
        final y = placed.gridY + localY;
        if (x >= 0 && x < 6 && y >= 0 && y < 10) {
          newPlateau.setCell(x, y, placed.piece.id);
        }
      }
    }

    // 7️⃣ Retirer la pièce du slider
    final newAvailable = state.availablePieces
        .where((p) => p.id != hintPiece.piece.id)
        .toList();

    // 8️⃣ Recalculer le nombre de solutions compatibles
    final solutionsCount = newPlateau.countPossibleSolutions();

    // 9️⃣ Mettre à jour l'état
    state = state.copyWith(
      plateau: newPlateau,
      placedPieces: newPlaced,
      availablePieces: newAvailable,
      solutionsCount: solutionsCount,
      clearSelectedPiece: true,
      clearSelectedPlacedPiece: true,
      clearSelectedCellInPiece: true,
      clearPreview: true,
    );

    _recomputeBoardValidity();

    debugPrint(
      '✅ HINT: Pièce ${hintPiece.piece.id} placée à (${hintPiece.gridX}, ${hintPiece.gridY}) position ${hintPiece.positionIndex}',
    );
    debugPrint('🎯 Solutions restantes: $solutionsCount');
  }
  /// Annule le tutoriel (toujours restaurer)
  void cancelTutorial() {
    exitTutorialMode(restore: true);
  }

  // ✨ AJOUT: Appelé quand le puzzle est complété (12 pièces placées)
  Future<void> onPuzzleCompleted() async {
    _gameTimer?.cancel();  // Arrêter le timer

    final elapsedSeconds = state.elapsedSeconds;
    final isometriesCount = state.isometriesCount;
    final solutionsViewCount = state.solutionsViewCount;

    debugPrint('✅ PUZZLE COMPLÉTÉ!');
    debugPrint('   Pièces placées: ${state.placedPieces.length}');
    debugPrint('   Temps écoulé: ${elapsedSeconds}s');
    debugPrint('   Isométries utilisées: $isometriesCount');
    debugPrint('   Solutions consultées: $solutionsViewCount');

    // Utiliser le numéro de solution identifié (+1 pour affichage human-friendly 1-9356)
    final solutionNumber = state.solvedSolutionIndex != null 
        ? state.solvedSolutionIndex! + 1 
        : -1;

    // Score à 0 pour l'instant (à définir plus tard)
    const score = 0;

    // Sauvegarder la session via le provider de base de données
    try {
      final database = ref.read(settingsDatabaseProvider);
      await database.saveGameSession(
        solutionNumber: solutionNumber,
        elapsedSeconds: elapsedSeconds,
        score: score,
        piecesPlaced: 12,
        numUndos: 0,  // À calculer si tu tracks les annulations
        isometriesCount: isometriesCount,
        solutionsViewCount: solutionsViewCount,
      );

      debugPrint('✅ Session sauvegardée');
      debugPrint('   Solution #$solutionNumber');

    } catch (e) {
      debugPrint('❌ Erreur sauvegarde: $e');
    }
  }

  /// Efface la surbrillance du plateau
  void clearBoardHighlight() {
    state = state.copyWith(clearHighlightedBoardPiece: true);

  }

  /// Efface toutes les surbrillances de cases
  void clearCellHighlights() {
    state = state.copyWith(clearCellHighlights: true);

  }

  /// 🆕 Efface la surbrillance des icônes d'isométrie
  void clearIsometryIconHighlight() {
    state = state.copyWith(clearHighlightedIsometryIcon: true);
  }

  /// 🆕 Incrémente le compteur de consultation des solutions
  void incrementSolutionsViewCount() {
    state = state.copyWith(solutionsViewCount: state.solutionsViewCount + 1);
    debugPrint('[GAME] 👁️ Solutions consultées: ${state.solutionsViewCount} fois');
  }



  /// Efface la surbrillance de la mastercase
  void clearMastercaseHighlight() {
    state = state.copyWith(clearHighlightedMastercase: true);

  }

  /// Efface la prévisualisation
  void clearPreview() {
    if (state.previewX != null || state.previewY != null) {
      state = state.copyWith(clearPreview: true);
    }
  }

  /// Efface la surbrillance du slider
  void clearSliderHighlight() {
    state = state.copyWith(clearHighlightedSliderPiece: true);

  }

  /// Cycle vers l'orientation suivante de la pièce sélectionnée
  /// Passe simplement à l'index suivant dans piece.positions (boucle)
  void cycleToNextOrientation() {
    // Pour une pièce sélectionnée (pas encore placée)
    if (state.selectedPiece != null) {
      final piece = state.selectedPiece!;
      final currentIndex = state.selectedPositionIndex;
      final nextIndex = (currentIndex + 1) % piece.numPositions;


      // Sauvegarder le nouvel index dans le Map
      final newIndices = Map<int, int>.from(state.piecePositionIndices);
      newIndices[piece.id] = nextIndex;

      // Mettre à jour l'état
      state = state.copyWith(
        selectedPositionIndex: nextIndex,
        piecePositionIndices: newIndices,
      );
      _recomputeBoardValidity();
      return;
    }

    // Pour une pièce placée
    if (state.selectedPlacedPiece != null) {
      final selectedPiece = state.selectedPlacedPiece!;
      final currentIndex = selectedPiece.positionIndex;
      final nextIndex = (currentIndex + 1) % selectedPiece.piece.numPositions;


      // Créer la pièce avec la nouvelle orientation
      final transformedPiece = selectedPiece.copyWith(positionIndex: nextIndex);

      // Recalculer les solutions possibles
      final solutionsCount = _computeSolutionsWithTransformedPiece(
        transformedPiece,
      );
      print('[GAME] 🎯 Solutions possibles après cycle : $solutionsCount');

      // Mettre à jour l'état
      state = state.copyWith(
        selectedPlacedPiece: transformedPiece,
        selectedPositionIndex: nextIndex,
        solutionsCount: solutionsCount,
      );
      _recomputeBoardValidity();
      return;
    }

  }

  /// Entre en mode isométries (sauvegarde l'état actuel)
  void enterIsometriesMode() {
    if (state.isIsometriesMode) return; // Déjà en mode isométries


    // Sauvegarder l'état actuel (sans le savedGameState pour éviter la récursion)
    final savedState = PentominoGameState(
      plateau: state.plateau,
      availablePieces: List.from(state.availablePieces),
      placedPieces: List.from(state.placedPieces),
      selectedPiece: state.selectedPiece,
      selectedPositionIndex: state.selectedPositionIndex,
      selectedPlacedPiece: state.selectedPlacedPiece,
      piecePositionIndices: Map.from(state.piecePositionIndices),
      selectedCellInPiece: state.selectedCellInPiece,
      previewX: state.previewX,
      previewY: state.previewY,
      isPreviewValid: state.isPreviewValid,
      solutionsCount: state.solutionsCount,
    );

    // Passer en mode isométries
    state = state.copyWith(isIsometriesMode: true, savedGameState: savedState);
  }

  /// Entre en mode tutoriel : sauvegarde l'état actuel et reset le jeu
  void enterTutorialMode() {
    if (state.isInTutorial) {
      throw StateError('Déjà en mode tutoriel');
    }

    if (state.isIsometriesMode) {
      throw StateError(
        'Impossible d\'entrer en tutoriel depuis le mode isométries',
      );
    }

    // Sauvegarder l'état complet actuel
    final savedState = state.copyWith();

    // Reset le jeu pour un plateau vierge
    reset();

    // Marquer comme mode tutoriel avec sauvegarde
    state = state.copyWith(savedGameState: savedState, isInTutorial: true);

  }

  /// Sort du mode isométries (restaure l'état sauvegardé)
  void exitIsometriesMode() {
    if (!state.isIsometriesMode) return; // Pas en mode isométries
    if (state.savedGameState == null) {

      return;
    }



    // Restaurer l'état sauvegardé
    state = state.savedGameState!;
  }

  /// Sort du mode tutoriel et restaure l'état sauvegardé
  void exitTutorialMode({bool restore = true}) {
    if (!state.isInTutorial) {
      throw StateError('Pas en mode tutoriel');
    }

    if (state.savedGameState == null) {
      throw StateError('Pas de sauvegarde disponible');
    }

    if (restore) {
      // Restaurer l'état complet
      state = state.savedGameState!.copyWith(
        savedGameState: null,
        isInTutorial: false,
        clearHighlightedSliderPiece: true,
        clearHighlightedBoardPiece: true,
        clearHighlightedMastercase: true,
        clearCellHighlights: true,
        sliderOffset: 0,
      );

    } else {
      // Garder le plateau actuel, juste enlever le flag tutoriel
      state = state.copyWith(
        savedGameState: null,
        isInTutorial: false,
        clearHighlightedSliderPiece: true,
        clearHighlightedBoardPiece: true,
        clearHighlightedMastercase: true,
        clearCellHighlights: true,
        sliderOffset: 0,
      );

    }
  }

  /// Trouve une pièce placée à une position donnée
  PlacedPiece? findPlacedPieceAt(int x, int y) {
    for (final placedPiece in state.placedPieces) {
      final cells = placedPiece.absoluteCells;
      if (cells.any((cell) => cell.x == x && cell.y == y)) {
        return placedPiece;
      }
    }
    return null;
  }

  /// Trouve une pièce placée par son ID
  PlacedPiece? findPlacedPieceById(int pieceNumber) {
    try {
      return state.placedPieces.firstWhere((p) => p.piece.id == pieceNumber);
    } catch (e) {
      return null;
    }
  }

  int getElapsedSeconds() {
    if (_startTime == null) return 0;
    return DateTime.now().difference(_startTime!).inSeconds;
  }

  /// Trouve la pièce placée à une position donnée
  PlacedPiece? getPlacedPieceAt(int gridX, int gridY) {
    for (final placed in state.placedPieces) {
      final position = placed.piece.positions[placed.positionIndex];

      for (final cellNum in position) {
        final localX = (cellNum - 1) % 5;
        final localY = (cellNum - 1) ~/ 5;
        final x = placed.gridX + localX;
        final y = placed.gridY + localY;

        if (x == gridX && y == gridY) {
          return placed;
        }
      }
    }
    return null;
  }

  /// Surligne une case individuelle avec une couleur
  void highlightCell(int x, int y, Color color) {
    if (x < 0 || x >= 6 || y < 0 || y >= 10) {
      throw ArgumentError('Position hors limites: ($x, $y)');
    }

    final newHighlights = Map<Point, Color>.from(state.cellHighlights);
    newHighlights[Point(x, y)] = color;

    state = state.copyWith(cellHighlights: newHighlights);
    print('[TUTORIAL] Case ($x, $y) surlignée');
  }

  /// Surligne plusieurs cases avec la même couleur
  void highlightCells(List<Point> cells, Color color) {
    final newHighlights = Map<Point, Color>.from(state.cellHighlights);

    for (final cell in cells) {
      if (cell.x >= 0 && cell.x < 6 && cell.y >= 0 && cell.y < 10) {
        newHighlights[cell] = color;
      }
    }

    state = state.copyWith(cellHighlights: newHighlights);
    print('[TUTORIAL] ${cells.length} cases surlignées');
  }

  /// 🆕 Surligne une icône d'isométrie (pour tutoriel)
  /// iconName: 'rotation', 'rotation_cw', 'symmetry_h', 'symmetry_v'
  void highlightIsometryIcon(String iconName) {
    final validIcons = ['rotation', 'rotation_cw', 'symmetry_h', 'symmetry_v'];
    if (!validIcons.contains(iconName)) {
      print('[TUTORIAL] ⚠️ Icône invalide: $iconName (attendu: ${validIcons.join(", ")})');
      return;
    }
    state = state.copyWith(highlightedIsometryIcon: iconName);
    print('[TUTORIAL] 🔆 Icône d\'isométrie surlignée: $iconName');
  }

  /// Surligne la mastercase d'une pièce
  void highlightMastercase(Point position) {
    state = state.copyWith(highlightedMastercase: position);
    print('[TUTORIAL] Mastercase surlignée en (${position.x}, ${position.y})');
  }

  /// Surligne une pièce dans le slider (sans la sélectionner)
  void highlightPieceInSlider(int pieceNumber) {
    if (pieceNumber < 1 || pieceNumber > 12) {
      throw ArgumentError('pieceNumber doit être entre 1 et 12');
    }

    state = state.copyWith(highlightedSliderPiece: pieceNumber);
    print('[TUTORIAL] Pièce $pieceNumber surlignée dans le slider');
  }

  /// Surligne une pièce posée sur le plateau (sans la sélectionner)
  void highlightPieceOnBoard(int pieceNumber) {
    if (pieceNumber < 1 || pieceNumber > 12) {
      throw ArgumentError('pieceNumber doit être entre 1 et 12');
    }

    // Vérifier que la pièce existe sur le plateau
    final exists = state.placedPieces.any((p) => p.piece.id == pieceNumber);
    if (!exists) {
      throw StateError('La pièce $pieceNumber n\'est pas sur le plateau');
    }

    state = state.copyWith(highlightedBoardPiece: pieceNumber);
    print('[TUTORIAL] Pièce $pieceNumber surlignée sur le plateau');
  }

  /// Surligne toutes les positions valides pour la pièce sélectionnée
  void highlightValidPositions(Pento piece, int positionIndex, Color color) {
    final validCells = <Point>[];

    // Tester toutes les positions du plateau
    for (int y = 0; y < 10; y++) {
      for (int x = 0; x < 6; x++) {
        if (state.canPlacePiece(piece, positionIndex, x, y)) {
          // Ajouter toutes les cases que la pièce occuperait
          final position = piece.positions[positionIndex];
          for (final cellNum in position) {
            final localX = (cellNum - 1) % 5;
            final localY = (cellNum - 1) ~/ 5;
            final absX = x + localX;
            final absY = y + localY;

            if (absX >= 0 && absX < 6 && absY >= 0 && absY < 10) {
              validCells.add(Point(absX, absY));
            }
          }
        }
      }
    }

    highlightCells(validCells, color);
    print('[TUTORIAL] ${validCells.length} positions valides surlignées');
  }

  /// Place la pièce sélectionnée à la position indiquée (pour tutoriel)
  /// Place la pièce sélectionnée à la position indiquée (pour tutoriel)
  /// gridX/gridY = position de la MASTERCASE (pas du coin haut-gauche)
  void placeSelectedPieceForTutorial(int gridX, int gridY) {
    if (state.selectedPiece == null) {
      print('[TUTORIAL] ⚠️ Aucune pièce sélectionnée');
      return;
    }

    final piece = state.selectedPiece!;
    final positionIndex = 0; // Position par défaut

    // IMPORTANT : Calculer l'offset de la mastercase
    // La première cellule de position[0] est la mastercase
    final position = piece.positions[positionIndex];
    final mastercellNum = position.first;
    final masterLocalX = (mastercellNum - 1) % 5;
    final masterLocalY = (mastercellNum - 1) ~/ 5;

    // Convertir : position mastercase → position coin haut-gauche
    final anchorX = gridX - masterLocalX;
    final anchorY = gridY - masterLocalY;


    // Vérifier que la position est valide
    if (!state.canPlacePiece(piece, positionIndex, anchorX, anchorY)) {
      print('[TUTORIAL] ⚠️ Position invalide pour placer la pièce');
      return;
    }

    // Créer le plateau avec toutes les pièces existantes
    final newPlateau = Plateau.allVisible(6, 10);
    for (final placed in state.placedPieces) {
      final pos = placed.piece.positions[placed.positionIndex];
      for (final cellNum in pos) {
        final localX = (cellNum - 1) % 5;
        final localY = (cellNum - 1) ~/ 5;
        final x = placed.gridX + localX;
        final y = placed.gridY + localY;
        newPlateau.setCell(x, y, 1);
      }
    }

    // Ajouter la nouvelle pièce au plateau
    for (final cellNum in position) {
      final localX = (cellNum - 1) % 5;
      final localY = (cellNum - 1) ~/ 5;
      newPlateau.setCell(anchorX + localX, anchorY + localY, 1);
    }

    // Créer l'objet PlacedPiece (avec l'ancre, pas la mastercase)
    final placedPiece = PlacedPiece(
      piece: piece,
      positionIndex: positionIndex,
      gridX: anchorX,  // ← Ancre, pas mastercase
      gridY: anchorY,  // ← Ancre, pas mastercase
    );

    // Retirer la pièce des disponibles
    final newAvailable = List<Pento>.from(state.availablePieces)
      ..removeWhere((p) => p.id == piece.id);

    // Ajouter aux pièces placées
    final newPlaced = List<PlacedPiece>.from(state.placedPieces)
      ..add(placedPiece);

    // Calculer le nombre de solutions possibles
    final solutionsCount = newPlateau.countPossibleSolutions();

    // Mettre à jour l'état
    state = state.copyWith(
      plateau: newPlateau,
      placedPieces: newPlaced,
      availablePieces: newAvailable,
      selectedPiece: null,
      solutionsCount: solutionsCount,
    );

    print('[TUTORIAL] 🔍 PlacedPiece absoluteCells: ${placedPiece.absoluteCells.toList()}');
    print('[TUTORIAL] ✅ Pièce ${piece.id} placée avec mastercase en ($gridX, $gridY)');
  }

  /// Retire une pièce placée du plateau
  void removePlacedPiece(PlacedPiece placedPiece) {
    // Reconstruire le plateau sans cette pièce
    final newPlateau = Plateau.allVisible(6, 10);

    // Replacer toutes les pièces sauf celle à retirer
    for (final placed in state.placedPieces) {
      if (placed != placedPiece) {
        final position = placed.piece.positions[placed.positionIndex];

        for (final cellNum in position) {
          final localX = (cellNum - 1) % 5;
          final localY = (cellNum - 1) ~/ 5;
          final x = placed.gridX + localX;
          final y = placed.gridY + localY;
          newPlateau.setCell(x, y, placed.piece.id);
        }
      }
    }

    // Remettre la pièce dans les disponibles
    final newAvailable = List<Pento>.from(state.availablePieces)
      ..add(placedPiece.piece);

    // Retrier par ID pour garder l'ordre
    newAvailable.sort((a, b) => a.id.compareTo(b.id));

    // Retirer de la liste des placées
    final newPlaced = state.placedPieces
        .where((p) => p != placedPiece)
        .toList();

    // Calculer le nombre de solutions possibles
    final solutionsCount = newPlateau.countPossibleSolutions();

    state = state.copyWith(
      plateau: newPlateau,
      availablePieces: newAvailable,
      placedPieces: newPlaced,
      clearSelectedPiece: true,
      clearSelectedPlacedPiece: true,
      clearSelectedCellInPiece: true,
      solutionsCount: solutionsCount,
    );
    _recomputeBoardValidity();

    print('[GAME] 🗑️ Pièce ${placedPiece.piece.id} retirée du plateau');
    if (solutionsCount != null) {
      print('[GAME] 🎯 Solutions possibles: $solutionsCount');
    }
  }

  /// Réinitialise le jeu
  void reset() {
    stopTimer();  // ✨ Arrêter le timer
    _startTime = null;  // ✨ Réinitialiser
    _gameTimer = null;  // ✨ Réinitialiser
    final initialState = PentominoGameState.initial();
    final totalSolutions = Plateau.allVisible(6, 10).countPossibleSolutions();
    state = initialState.copyWith(solutionsCount: totalSolutions);
  }

  /// Remet le slider à sa position initiale
  void resetSliderPosition() {
    state = state.copyWith(sliderOffset: 0);
    print('[TUTORIAL] Slider remis à la position initiale');
  }

  // ============================================================
  // 🆕 MÉTHODES TUTORIEL - Ajoutées pour le système Scratch-Pentapol
  // ============================================================

  /// 🆕 Restaure un état sauvegardé (utilisé par TutorialProvider au quit)
  void restoreState(PentominoGameState savedState) {
    print(
      '[GAME] ♻️ Restauration de l\'état : ${savedState.placedPieces.length} pièces placées',
    );
    state = savedState;
  }

  /// Fait défiler le slider de N positions
  /// positions > 0 : vers la droite
  /// positions < 0 : vers la gauche
  void scrollSlider(int positions) {
    final newOffset = (state.sliderOffset + positions) % 12;
    state = state.copyWith(sliderOffset: newOffset);
    print(
      '[TUTORIAL] Slider décalé de $positions positions (offset: $newOffset)',
    );
  }

  /// Fait défiler le slider pour centrer sur une pièce
  void scrollSliderToPiece(int pieceNumber) {
    if (pieceNumber < 1 || pieceNumber > 12) {
      throw ArgumentError('pieceNumber doit être entre 1 et 12');
    }

    // Calculer l'offset pour centrer cette pièce
    // (dépend de l'implémentation exacte du slider)
    final targetOffset = (pieceNumber - 1) % 12;
    state = state.copyWith(sliderOffset: targetOffset);
    print('[TUTORIAL] Slider centré sur pièce $pieceNumber');
  }

  // ============================================================
  // HIGHLIGHTS SLIDER
  // ============================================================

  /// Sélectionne une pièce du slider (commence le drag)
  void selectPiece(Pento piece) {
    // Récupérer l'index de position sauvegardé pour cette pièce
    final savedIndex = state.getPiecePositionIndex(piece.id);
    // Si une pièce du plateau est déjà sélectionnée, la replacer d'abord
    print('[DEBUG PAYSAGE] 🔍 selectPiece(${piece.id})');
    print(
      '[DEBUG PAYSAGE] 📋 piecePositionIndices: ${state.piecePositionIndices}',
    );
    print('[DEBUG PAYSAGE] 📌 savedIndex pour pièce ${piece.id}: $savedIndex');
    if (state.selectedPlacedPiece != null) {
      final placedPiece = state.selectedPlacedPiece!;

      // Reconstruire le plateau avec la pièce replacée
      final newPlateau = Plateau.allVisible(6, 10);

      // Replacer toutes les pièces déjà placées
      for (final placed in state.placedPieces) {
        final position = placed.piece.positions[placed.positionIndex];

        for (final cellNum in position) {
          final localX = (cellNum - 1) % 5;
          final localY = (cellNum - 1) ~/ 5;
          final x = placed.gridX + localX;
          final y = placed.gridY + localY;
          newPlateau.setCell(x, y, placed.piece.id);
        }
      }

      // Replacer la pièce qui était sélectionnée
      final position = placedPiece.piece.positions[placedPiece.positionIndex];
      for (final cellNum in position) {
        final localX = (cellNum - 1) % 5;
        final localY = (cellNum - 1) ~/ 5;
        final x = placedPiece.gridX + localX;
        final y = placedPiece.gridY + localY;
        if (x >= 0 && x < 6 && y >= 0 && y < 10) {
          newPlateau.setCell(x, y, placedPiece.piece.id);
        }
      }

      // Remettre la pièce dans les placées
      final newPlaced = List<PlacedPiece>.from(state.placedPieces)
        ..add(placedPiece.copyWith(positionIndex: placedPiece.positionIndex));

      state = state.copyWith(plateau: newPlateau, placedPieces: newPlaced);
      _recomputeBoardValidity();
    }

    // Définir une case de référence par défaut (première case de la pièce)
    final position = piece.positions[savedIndex];
    Point? defaultCell;
    if (position.isNotEmpty) {
      final firstCellNum = position[0];
      defaultCell = Point((firstCellNum - 1) % 5, (firstCellNum - 1) ~/ 5);
    }

    state = state.copyWith(
      selectedPiece: piece,
      selectedPositionIndex: savedIndex, // Utilise l'index sauvegardé
      clearSelectedPlacedPiece: true,
      selectedCellInPiece: defaultCell,
    );
    _recomputeBoardValidity();
  }

  /// Sélectionne une pièce du slider avec mastercase explicite
  /// (pour compatibilité Scratch SELECT_PIECE_FROM_SLIDER)
  void selectPieceFromSliderForTutorial(int pieceNumber) {
    if (pieceNumber < 1 || pieceNumber > 12) {
      throw ArgumentError('pieceNumber doit être entre 1 et 12');
    }

    final piece = pentominos.firstWhere((p) => p.id == pieceNumber);
    selectPiece(piece);

    print('[TUTORIAL] Pièce $pieceNumber sélectionnée depuis le slider');
  }

  // ============================================================
  // HIGHLIGHTS PLATEAU
  // ============================================================

  /// Sélectionne une pièce déjà placée pour la déplacer
  /// [cellX] et [cellY] sont les coordonnées de la case touchée sur le plateau

  /// Sélectionne une pièce déjà placée pour la déplacer
  /// [cellX] et [cellY] sont les coordonnées de la case touchée sur le plateau
  void selectPlacedPiece(PlacedPiece placedPiece, int cellX, int cellY) {
    // Si une autre pièce du plateau est déjà sélectionnée, la replacer d'abord
    if (state.selectedPlacedPiece != null &&
        state.selectedPlacedPiece != placedPiece) {
      final oldPiece = state.selectedPlacedPiece!;

      // Reconstruire le plateau avec l'ancienne pièce replacée
      final tempPlateau = Plateau.allVisible(6, 10);

      // Replacer toutes les pièces déjà placées
      for (final placed in state.placedPieces) {
        final pos = placed.piece.positions[placed.positionIndex];
        for (final cellNum in pos) {
          final localX = (cellNum - 1) % 5;
          final localY = (cellNum - 1) ~/ 5;
          final x = placed.gridX + localX;
          final y = placed.gridY + localY;
          tempPlateau.setCell(x, y, placed.piece.id);
        }
      }

      // Replacer l'ancienne pièce sélectionnée
      final oldPosition = oldPiece.piece.positions[state.selectedPositionIndex];
      for (final cellNum in oldPosition) {
        final localX = (cellNum - 1) % 5;
        final localY = (cellNum - 1) ~/ 5;
        final x = oldPiece.gridX + localX;
        final y = oldPiece.gridY + localY;
        if (x >= 0 && x < 6 && y >= 0 && y < 10) {
          tempPlateau.setCell(x, y, oldPiece.piece.id);
        }
      }

      // Remettre l'ancienne pièce dans la liste des placées
      final tempPlaced = List<PlacedPiece>.from(state.placedPieces)
        ..add(oldPiece.copyWith(positionIndex: state.selectedPositionIndex));

      // Mettre à jour l'état avec le plateau et la liste mis à jour
      state = state.copyWith(
        plateau: tempPlateau,
        placedPieces: tempPlaced,
        clearSelectedPiece: true,
        clearSelectedPlacedPiece: true,
        clearSelectedCellInPiece: true,
      );
    }

    // Trouver quelle case de la pièce correspond à (cellX, cellY)
    final position = placedPiece.piece.positions[placedPiece.positionIndex];
    Point? selectedCell;

    for (final cellNum in position) {
      final localX = (cellNum - 1) % 5;
      final localY = (cellNum - 1) ~/ 5;
      final x = placedPiece.gridX + localX;
      final y = placedPiece.gridY + localY;

      if (x == cellX && y == cellY) {
        // C'est cette case qui a été touchée
        selectedCell = Point(localX, localY);
        break;
      }
    }

    // Si aucune case trouvée, utiliser la première case de la pièce
    if (selectedCell == null && position.isNotEmpty) {
      final firstCellNum = position[0];
      selectedCell = Point((firstCellNum - 1) % 5, (firstCellNum - 1) ~/ 5);
    }

    // Retirer la pièce du plateau
    final newPlateau = Plateau.allVisible(6, 10);

    // Replacer toutes les pièces SAUF celle sélectionnée
    for (final placed in state.placedPieces) {
      if (placed != placedPiece) {
        final pos = placed.piece.positions[placed.positionIndex];

        for (final cellNum in pos) {
          final localX = (cellNum - 1) % 5;
          final localY = (cellNum - 1) ~/ 5;
          final x = placed.gridX + localX;
          final y = placed.gridY + localY;
          newPlateau.setCell(x, y, placed.piece.id);
        }
      }
    }

    // Retirer la pièce de la liste des placées
    final newPlaced = state.placedPieces
        .where((p) => p != placedPiece)
        .toList();

    // ✅ AJOUT : Calculer les solutions en incluant la pièce sélectionnée
    final solutionsCount = _computeSolutionsWithTransformedPiece(placedPiece);

    // Sélectionner la pièce avec sa position actuelle et la case de référence
    state = state.copyWith(
      plateau: newPlateau,
      placedPieces: newPlaced,
      selectedPiece: placedPiece.piece,
      selectedPositionIndex: placedPiece.positionIndex,
      selectedPlacedPiece: placedPiece,
      selectedCellInPiece: selectedCell,
      solutionsCount: solutionsCount, // ✅ AJOUT
    );

    print(
      '[GAME] 🔄 Pièce ${placedPiece.piece.id} sélectionnée pour déplacement (case ref: $selectedCell)',
    );
  }

  /// Sélectionne une pièce sur le plateau à une position donnée
  /// (pour compatibilité Scratch SELECT_PIECE_ON_BOARD_AT)
  void selectPlacedPieceAtForTutorial(int x, int y) {
    final placedPiece = findPlacedPieceAt(x, y);

    if (placedPiece == null) {
      throw StateError('Aucune pièce à la position ($x, $y)');
    }

    // La case cliquée devient la mastercase
    selectPlacedPiece(placedPiece, x, y);

    print('[TUTORIAL] Pièce ${placedPiece.piece.id} sélectionnée en ($x, $y)');
  }

  /// Sélectionne une pièce avec une mastercase explicite
  /// (pour compatibilité Scratch SELECT_PIECE_ON_BOARD_WITH_MASTERCASE)
  void selectPlacedPieceWithMastercaseForTutorial(
      int pieceNumber,
      int mastercaseX,
      int mastercaseY,
      ) {
    final placedPiece = findPlacedPieceById(pieceNumber);

    if (placedPiece == null) {
      throw StateError('La pièce $pieceNumber n\'est pas sur le plateau');
    }

    // Vérifier que la mastercase est bien dans la pièce
    final isInPiece = placedPiece.absoluteCells.any(
          (cell) => cell.x == mastercaseX && cell.y == mastercaseY,
    );

    if (!isInPiece) {
      throw ArgumentError(
        'La position ($mastercaseX, $mastercaseY) n\'est pas dans la pièce $pieceNumber',
      );
    }

    selectPlacedPiece(placedPiece, mastercaseX, mastercaseY);

    print(
      '[TUTORIAL] Pièce $pieceNumber sélectionnée avec mastercase ($mastercaseX, $mastercaseY)',
    );
  }

  /// Enregistre l'orientation de la vue (portrait/landscape)
  void setViewOrientation(bool isLandscape) {
    final orientation =
    isLandscape ? ViewOrientation.landscape : ViewOrientation.portrait;
    state = state.copyWith(viewOrientation: orientation);
  }

  // ============================================================
  // HIGHLIGHTS DE CASES
  // ============================================================

  void startTimer() {
    if (_startTime != null) return;
    print('🚀 TIMER STARTED!');  // ← AJOUTER
    _startTime = DateTime.now();
    _gameTimer = Timer.periodic(Duration(milliseconds: 100), (_) {
      // ✨ Mettre à jour elapsedSeconds
      state = state.copyWith(
        elapsedSeconds: getElapsedSeconds(),
      );
    });
  }

  void stopTimer() {
    _gameTimer?.cancel();
    _gameTimer = null;
  }

  /// Tente de placer la pièce sélectionnée sur le plateau
  /// [gridX] et [gridY] sont les coordonnées où on lâche la pièce (position du doigt)
  /// Tente de placer la pièce sélectionnée sur le plateau
  /// [gridX] et [gridY] sont les coordonnées où on lâche la pièce (position du doigt)
  bool tryPlacePiece(int gridX, int gridY) {
    if (state.selectedPiece == null) return false;

    final piece = state.selectedPiece!;
    final positionIndex = state.selectedPositionIndex;
    print(
      '[DEBUG PLACEMENT] 🎯 tryPlacePiece: piece=${piece.id}, positionIndex=$positionIndex',
    );
    print(
      '[DEBUG PLACEMENT] 📋 piecePositionIndices=${state.piecePositionIndices}',
    );
    final wasPlacedPiece =
        state.selectedPlacedPiece !=
            null; // ✅ Mémoriser si c'était une pièce placée
    final savedCellInPiece =
        state.selectedCellInPiece; // ✅ Garder la master cell

    // Calculer la position d'ancrage en utilisant la case de référence
    int anchorX = gridX;
    int anchorY = gridY;

    if (state.selectedCellInPiece != null) {
      // Translation : la case de référence doit être placée à (gridX, gridY)
      // Donc la position d'ancrage = position de lâcher - position locale de la case de référence
      anchorX = gridX - state.selectedCellInPiece!.x;
      anchorY = gridY - state.selectedCellInPiece!.y;

      print(
        '[GAME] Translation: lâcher à ($gridX, $gridY), case ref locale (${state.selectedCellInPiece!.x}, ${state.selectedCellInPiece!.y}), anchor ($anchorX, $anchorY)',
      );
    }
// Vérifier position exacte
    bool canPlace = state.canPlacePiece(piece, positionIndex, anchorX, anchorY);

    // Si pas valide, essayer le snap
    if (!canPlace) {
      final snapped = _findNearestValidPosition(piece, positionIndex, anchorX, anchorY);
      if (snapped != null) {
        anchorX = snapped.x;
        anchorY = snapped.y;
        canPlace = true;
        print('[GAME] 🧲 Snap appliqué: nouvelle position ($anchorX, $anchorY)');
      }
    }

    if (!canPlace) {
      print('[GAME] ❌ Placement impossible à ($anchorX, $anchorY)');
      return false;
    }

    // Vérifier si la pièce peut être placée
    if (!state.canPlacePiece(piece, positionIndex, anchorX, anchorY)) {
      print('[GAME] ❌ Placement impossible à ($anchorX, $anchorY)');
      return false;
    }

    // Créer une copie du plateau et placer la pièce
    final newGrid = List.generate(
      state.plateau.height,
          (y) => List.generate(
        state.plateau.width,
            (x) => state.plateau.getCell(x, y),
      ),
    );

    final newPlateau = Plateau(
      width: state.plateau.width,
      height: state.plateau.height,
      grid: newGrid,
    );

    // Placer la nouvelle pièce
    final position = piece.positions[positionIndex];

    for (final cellNum in position) {
      // Convertir cellNum (1-25 sur grille 5×5) en coordonnées (x, y)
      final localX = (cellNum - 1) % 5;
      final localY = (cellNum - 1) ~/ 5;

      // Position absolue sur le plateau (utiliser anchorX/anchorY)
      final x = anchorX + localX;
      final y = anchorY + localY;

      newPlateau.setCell(x, y, piece.id);
    }

    // Créer l'objet PlacedPiece
    final placedPiece = PlacedPiece(
      piece: piece,
      positionIndex: positionIndex,
      gridX: anchorX,
      gridY: anchorY,
    );

    // Retirer la pièce des disponibles (si elle y était)
    final newAvailable = List<Pento>.from(state.availablePieces)
      ..removeWhere((p) => p.id == piece.id);

    // Ajouter aux pièces placées
    final newPlaced = List<PlacedPiece>.from(state.placedPieces)
      ..add(placedPiece);

    // Calculer le nombre de solutions possibles
    final solutionsCount = newPlateau.countPossibleSolutions();

    // ✅ Si c'était une pièce placée, on la garde sélectionnée (comme pour rotation/symétrie)
    if (wasPlacedPiece) {
      // Retirer la pièce du plateau pour qu'elle reste "flottante" (sélectionnée)
      final plateauSansPiece = Plateau.allVisible(6, 10);
      for (final placed in state.placedPieces) {
        final pos = placed.piece.positions[placed.positionIndex];
        for (final cellNum in pos) {
          final localX = (cellNum - 1) % 5;
          final localY = (cellNum - 1) ~/ 5;
          final x = placed.gridX + localX;
          final y = placed.gridY + localY;
          if (x >= 0 && x < 6 && y >= 0 && y < 10) {
            plateauSansPiece.setCell(x, y, placed.piece.id);
          }
        }
      }

      state = state.copyWith(
        plateau: plateauSansPiece,
        availablePieces: newAvailable,
        placedPieces:
        state.placedPieces, // ✅ Ne pas ajouter la pièce aux placées
        selectedPiece: piece,
        selectedPositionIndex: positionIndex,
        selectedPlacedPiece:
        placedPiece, // ✅ Garder la référence à la nouvelle position
        selectedCellInPiece: savedCellInPiece, // ✅ Garder la master cell
        solutionsCount: solutionsCount,
        clearPreview: true,
      );
      _recomputeBoardValidity();

      print(
        '[GAME] ✅ Pièce ${piece.id} déplacée à ($anchorX, $anchorY) - reste sélectionnée',
      );
      print('[GAME] 🎯 Solutions possibles: $solutionsCount');
    } else {
      // C'était une pièce du slider → comportement normal (désélectionner)
      state = state.copyWith(
        plateau: newPlateau,
        availablePieces: newAvailable,
        placedPieces: newPlaced,
        clearSelectedPiece: true,
        clearSelectedPlacedPiece: true,
        clearSelectedCellInPiece: true,
        solutionsCount: solutionsCount,
        clearPreview: true,
      );
      _recomputeBoardValidity();

      print('[GAME] ✅ Pièce ${piece.id} placée à ($anchorX, $anchorY)');
      print('[GAME] Pièces restantes: ${newAvailable.length}');
      print('[GAME] 🎯 Solutions possibles: $solutionsCount');

      // ✨ Si puzzle complet, identifier la solution et arrêter le timer
      if (newAvailable.isEmpty) {
        stopTimer();
        final solutionIndex = newPlateau.findExactSolutionIndex();
        if (solutionIndex >= 0) {
          final info = SolutionInfo(solutionIndex);
          state = state.copyWith(solvedSolutionIndex: solutionIndex);
          print('[GAME] 🎉 Puzzle complété! Solution #${info.index}');
          print('[GAME]    (canonique ${info.canonicalIndex}, ${info.variantName})');
          print('[GAME]    Temps: ${getElapsedSeconds()} secondes');
        } else {
          print('[GAME] 🎉 Puzzle complété! Temps: ${getElapsedSeconds()} secondes');
          print('[GAME] ⚠️  Solution non identifiée dans la base');
        }
      }
    }

    return true;
  }

  /// Retire la dernière pièce placée (undo)
  void undoLastPlacement() {
    if (state.placedPieces.isEmpty) return;

    final lastPlaced = state.placedPieces.last;

    // Recréer le plateau sans cette pièce
    final newPlateau = Plateau.allVisible(6, 10);

    // Replacer toutes les pièces sauf la dernière
    for (int i = 0; i < state.placedPieces.length - 1; i++) {
      final placed = state.placedPieces[i];
      final position = placed.piece.positions[placed.positionIndex];

      for (final cellNum in position) {
        // Convertir cellNum (1-25 sur grille 5×5) en coordonnées (x, y)
        final localX = (cellNum - 1) % 5;
        final localY = (cellNum - 1) ~/ 5;

        // Position absolue sur le plateau
        final x = placed.gridX + localX;
        final y = placed.gridY + localY;

        newPlateau.setCell(x, y, placed.piece.id);
      }
    }

    // Remettre la pièce dans les disponibles
    final newAvailable = List<Pento>.from(state.availablePieces)
      ..add(lastPlaced.piece);

    // Retrier par ID pour garder l'ordre
    newAvailable.sort((a, b) => a.id.compareTo(b.id));

    // Retirer de la liste des placées
    final newPlaced = List<PlacedPiece>.from(state.placedPieces)..removeLast();

    // Calculer le nombre de solutions possibles
    final solutionsCount = newPlateau.countPossibleSolutions();

    state = state.copyWith(
      plateau: newPlateau,
      availablePieces: newAvailable,
      placedPieces: newPlaced,
      solutionsCount: solutionsCount,
      clearSolvedSolutionIndex: true, // 🆕 Réinitialiser si on retire une pièce
    );

    print('[GAME] ↩️ Undo: Pièce ${lastPlaced.piece.id} retirée');
    if (solutionsCount != null) {
      print('[GAME] 🎯 Solutions possibles: $solutionsCount');
    }
  }

  // ============================================================
  // CONTRÔLE DU SLIDER
  // ============================================================

  /// Met à jour la prévisualisation du placement pendant le drag
  /// AVEC SNAP INTELLIGENT
  void updatePreview(int gridX, int gridY) {
    if (state.selectedPiece == null) {
      // Effacer la preview si aucune pièce sélectionnée
      if (state.previewX != null || state.previewY != null) {
        state = state.copyWith(clearPreview: true);
      }
      return;
    }

    final piece = state.selectedPiece!;
    final positionIndex = state.selectedPositionIndex;

    // Calculer la position d'ancrage avec la case de référence
    int anchorX = gridX;
    int anchorY = gridY;

    if (state.selectedCellInPiece != null) {
      anchorX = gridX - state.selectedCellInPiece!.x;
      anchorY = gridY - state.selectedCellInPiece!.y;
    }

    // 1. Vérifier la position exacte d'abord
    if (state.canPlacePiece(piece, positionIndex, anchorX, anchorY)) {
      _updatePreviewState(anchorX, anchorY, isValid: true, isSnapped: false);
      return;
    }

    // 2. Chercher la position valide la plus proche (snap)
    final snapped = _findNearestValidPosition(piece, positionIndex, anchorX, anchorY);

    if (snapped != null) {
      _updatePreviewState(snapped.x, snapped.y, isValid: true, isSnapped: true);
    } else {
      // Aucune position valide proche → preview rouge à la position du curseur
      _updatePreviewState(anchorX, anchorY, isValid: false, isSnapped: false);
    }
  }

  /// Applique une transformation isométrique via lookup
  void _applyIsoUsingLookup(int Function(Pento p, int idx) f) {
    final piece = state.selectedPiece;
    if (piece == null) return;
    final oldIdx = state.selectedPositionIndex;
    final newIdx = f(piece, oldIdx);

    // 🆕 Incrémenter le compteur d'isométries
    state = state.copyWith(
      selectedPositionIndex: newIdx,
      selectedCellInPiece: _remapSelectedCell(
        piece: piece,
        oldIndex: oldIdx,
        newIndex: newIdx,
        oldCell: state.selectedCellInPiece,
      ),
      clearPreview: true,
      isometriesCount: state.isometriesCount + 1,
    );

    final sp = state.selectedPlacedPiece;
    if (sp != null) {
      state = state.copyWith(
        selectedPlacedPiece: sp.copyWith(positionIndex: newIdx),
      );
    }
  }

  /// Calcule la nouvelle position locale de la master case après une transformation
  /// [centerX], [centerY] : coordonnées absolues de la master case (fixe)
  /// [newGridX], [newGridY] : nouvelle ancre de la pièce transformée
  Point _calculateNewMasterCell(
      int centerX,
      int centerY,
      int newGridX,
      int newGridY,
      ) {
    final newLocalX = centerX - newGridX;
    final newLocalY = centerY - newGridY;
    return Point(newLocalX, newLocalY);
  }

  // ============================================================
  // UTILITAIRES TUTORIEL
  // ============================================================


  /// Vérifie si une pièce peut être placée à une position donnée
  /// Utilisé après une transformation géométrique
  bool _canPlacePieceAt(ShapeMatch match, PlacedPiece? excludePiece) {
    final position = match.piece.positions[match.positionIndex];

    for (final cellNum in position) {
      final localX = (cellNum - 1) % 5;
      final localY = (cellNum - 1) ~/ 5;
      final absX = match.gridX + localX;
      final absY = match.gridY + localY;

      // Vérifier les limites
      if (!state.plateau.isInBounds(absX, absY)) {
        return false;
      }

      // Vérifier si la cellule est libre (ou occupée par la pièce qu'on transforme)
      final cell = state.plateau.getCell(absX, absY);
      if (cell != 0 &&
          (excludePiece == null || cell != excludePiece.piece.id)) {
        return false;
      }
    }

    return true;
  }
  /// Calcule le nombre de solutions possibles avec une pièce transformée
  /// Crée temporairement un plateau avec toutes les pièces incluant la transformée
  int? _computeSolutionsWithTransformedPiece(PlacedPiece transformedPiece) {
    // Créer un plateau temporaire
    final tempPlateau = Plateau.allVisible(6, 10);

    // Placer toutes les pièces déjà placées (sauf celle en transformation)
    for (final placed in state.placedPieces) {
      final position = placed.piece.positions[placed.positionIndex];
      for (final cellNum in position) {
        final localX = (cellNum - 1) % 5;
        final localY = (cellNum - 1) ~/ 5;
        final x = placed.gridX + localX;
        final y = placed.gridY + localY;
        if (x >= 0 && x < 6 && y >= 0 && y < 10) {
          tempPlateau.setCell(x, y, placed.piece.id);
        }
      }
    }

    // Placer la pièce transformée
    final position =
    transformedPiece.piece.positions[transformedPiece.positionIndex];
    for (final cellNum in position) {
      final localX = (cellNum - 1) % 5;
      final localY = (cellNum - 1) ~/ 5;
      final x = transformedPiece.gridX + localX;
      final y = transformedPiece.gridY + localY;
      if (x >= 0 && x < 6 && y >= 0 && y < 10) {
        tempPlateau.setCell(x, y, transformedPiece.piece.id);
      }
    }

    // Calculer les solutions possibles
    return tempPlateau.countPossibleSolutions();
  }

  /// Extrait les coordonnées absolues d'une pièce placée
  List<List<int>> _extractAbsoluteCoords(PlacedPiece piece) {
    final position = piece.piece.positions[piece.positionIndex];
    return position.map((cellNum) {
      final localX = (cellNum - 1) % 5;
      final localY = (cellNum - 1) ~/ 5;
      return [piece.gridX + localX, piece.gridY + localY];
    }).toList();
  }

  /// Cherche la position valide la plus proche dans un rayon donné
  /// Utilise la distance euclidienne pour trouver vraiment la plus proche
  Point? _findNearestValidPosition(Pento piece, int positionIndex, int anchorX, int anchorY) {
    Point? best;
    double bestDistanceSquared = double.infinity;

    for (int dx = -_snapRadius; dx <= _snapRadius; dx++) {
      for (int dy = -_snapRadius; dy <= _snapRadius; dy++) {
        if (dx == 0 && dy == 0) continue; // Position exacte déjà testée

        final testX = anchorX + dx;
        final testY = anchorY + dy;

        if (state.canPlacePiece(piece, positionIndex, testX, testY)) {
          // Distance euclidienne au carré (évite sqrt pour la perf)
          final distanceSquared = (dx * dx + dy * dy).toDouble();

          if (distanceSquared < bestDistanceSquared) {
            bestDistanceSquared = distanceSquared;
            best = Point(testX, testY);
          }
        }
      }
    }

    return best;
  }

  /// Recalcule la validité du plateau et les cellules problématiques
  void _recomputeBoardValidity() {
    final overlapping = <Point>{};
    final offBoard = <Point>{};
    final cellCounts = <Point, int>{};

    for (final placed in state.placedPieces) {
      // 🔁 On utilise directement les cases absolues de la pièce
      for (final p in placed.absoluteCells) {
        final x = p.x;
        final y = p.y;

        // Hors plateau ?
        if (x < 0 ||
            x >= state.plateau.width ||
            y < 0 ||
            y >= state.plateau.height) {
          offBoard.add(p);
          continue;
        }

        final count = (cellCounts[p] ?? 0) + 1;
        cellCounts[p] = count;
        if (count > 1) {
          overlapping.add(p);
        }
      }
    }

    final isValid = overlapping.isEmpty && offBoard.isEmpty;

    state = state.copyWith(
      boardIsValid: isValid,
      overlappingCells: overlapping,
      offBoardCells: offBoard,
    );
  }

  /// Remapping de la cellule de référence lors d'une isométrie
  Point? _remapSelectedCell({
    required Pento piece,
    required int oldIndex,
    required int newIndex,
    required Point? oldCell,
  }) {
    if (oldCell == null) return null;

    final oldPos = piece.positions[oldIndex];
    final newPos = piece.positions[newIndex];

    // Trouver la cellule correspondante dans la nouvelle position
    if (oldPos.isNotEmpty && newPos.isNotEmpty) {
      final cellNum = oldPos[0]; // Référence : première cellule
      if (newPos.contains(cellNum)) {
        final localX = (cellNum - 1) % 5;
        final localY = (cellNum - 1) ~/ 5;
        return Point(localX, localY);
      }
    }
    return null;
  }


  /// Applique une symétrie relative à la mastercase pour une pièce placée
  void _applySymmetryWithMastercase({required bool isHorizontal}) {
    final placedPiece = state.selectedPlacedPiece;
    if (placedPiece == null || state.selectedCellInPiece == null) return;

    final piece = placedPiece.piece;
    final currentIndex = placedPiece.positionIndex;
    final mastercase = state.selectedCellInPiece!;

    // Appliquer la symétrie relative à la mastercase
    final newIndex = isHorizontal
        ? piece.symmetryHRelativeToMastercase(currentIndex, mastercase)
        : piece.symmetryVRelativeToMastercase(currentIndex, mastercase);

    if (newIndex == currentIndex) return; // Pas de changement

    // Créer la pièce avec la nouvelle orientation
    final transformedPiece = placedPiece.copyWith(positionIndex: newIndex);

    // Recalculer les solutions possibles
    final solutionsCount = _computeSolutionsWithTransformedPiece(transformedPiece);
    print('[GAME] 🎯 Solutions possibles après symétrie ${isHorizontal ? 'horizontale' : 'verticale'} (mastercase) : $solutionsCount');

    // Mettre à jour l'état
    state = state.copyWith(
      selectedPlacedPiece: transformedPiece,
      selectedPositionIndex: newIndex,
      solutionsCount: solutionsCount,
    );
    _recomputeBoardValidity();
  }

  /// Applique une symétrie classique à une pièce placée (sans mastercase)
  void _applySymmetryToPlacedPiece({required bool isHorizontal}) {
    final placedPiece = state.selectedPlacedPiece;
    if (placedPiece == null) return;

    final piece = placedPiece.piece;
    final currentIndex = placedPiece.positionIndex;

    // Appliquer la symétrie classique
    final newIndex = isHorizontal ? piece.symmetryH(currentIndex) : piece.symmetryV(currentIndex);

    if (newIndex == currentIndex) return; // Pas de changement

    // Créer la pièce avec la nouvelle orientation
    final transformedPiece = placedPiece.copyWith(positionIndex: newIndex);

    // Recalculer les solutions possibles
    final solutionsCount = _computeSolutionsWithTransformedPiece(transformedPiece);
    print('[GAME] 🎯 Solutions possibles après symétrie ${isHorizontal ? 'horizontale' : 'verticale'} : $solutionsCount');

    // Mettre à jour l'état
    state = state.copyWith(
      selectedPlacedPiece: transformedPiece,
      selectedPositionIndex: newIndex,
      solutionsCount: solutionsCount,
    );
    _recomputeBoardValidity();
  }

  /// Applique une rotation spécifique à une pièce placée en maintenant la mastercase fixe
  void _applyRotationToPlacedPiece({required bool isClockwise}) {
    final placedPiece = state.selectedPlacedPiece;
    if (placedPiece == null) return;

    final piece = placedPiece.piece;
    final currentIndex = placedPiece.positionIndex;

    // Appliquer la rotation spécifique
    final newIndex = isClockwise ? piece.rotationCW(currentIndex) : piece.rotationTW(currentIndex);

    if (newIndex == currentIndex) return; // Pas de changement

    // Créer la pièce avec la nouvelle orientation
    final transformedPiece = placedPiece.copyWith(positionIndex: newIndex);

    // Recalculer les solutions possibles
    final solutionsCount = _computeSolutionsWithTransformedPiece(transformedPiece);
    print('[GAME] 🎯 Solutions possibles après rotation ${isClockwise ? 'horaire' : 'anti-horaire'} : $solutionsCount');

    // Mettre à jour l'état
    state = state.copyWith(
      selectedPlacedPiece: transformedPiece,
      selectedPositionIndex: newIndex,
      solutionsCount: solutionsCount,
    );
    _recomputeBoardValidity();
  }

  /// Met à jour l'état de la preview (évite les rebuilds inutiles)
  void _updatePreviewState(int x, int y, {required bool isValid, required bool isSnapped}) {
    if (state.previewX != x ||
        state.previewY != y ||
        state.isPreviewValid != isValid ||
        state.isSnapped != isSnapped) {
      state = state.copyWith(
        previewX: x,
        previewY: y,
        isPreviewValid: isValid,
        isSnapped: isSnapped,
      );
    }
  }

}