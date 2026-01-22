// lib/pentoscope/pentoscope_provider.dart
// Provider Pentoscope - calqué sur pentomino_game_provider
// CORRIGÉ: Bug de disparition des pièces (sync plateau/placedPieces)
import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pentapol/common/pentominos.dart';
import 'package:pentapol/common/plateau.dart';
import 'package:pentapol/common/point.dart';
import 'package:pentapol/common/pentomino_game_mixin.dart';
import 'package:pentapol/common/pentomino_symmetry_api.dart';
import 'package:pentapol/pentoscope/pentoscope_generator.dart';
import 'package:pentapol/pentoscope/pentoscope_solver.dart'
    show Solution, PentoscopeSolver;

// ============================================================================
// ÉTAT
// ============================================================================

final pentoscopeProvider =
    NotifierProvider<PentoscopeNotifier, PentoscopeState>(
      PentoscopeNotifier.new,
    );

// ============================================================================
// PROVIDER
// ============================================================================

enum PentoscopeDifficulty { easy, random, hard }

enum TransformationResult {
  success,      // Transformation réussie sans ajustement
  recentered,   // Transformation réussie avec recentrage
  impossible,   // Transformation impossible
}

class PentoscopeNotifier extends Notifier<PentoscopeState> 
    with PentominoGameMixin {
  late final PentoscopeGenerator _generator;
  late final PentoscopeSolver _solver;
  
  // ⏱️ Timer
  Timer? _gameTimer;
  DateTime? _startTime;
  
  // ============================================================================
  // IMPLÉMENTATION DES MÉTHODES ABSTRAITES DU MIXIN
  // ============================================================================
  
  @override
  Plateau get currentPlateau => state.plateau;
  
  @override
  Pento? get selectedPiece => state.selectedPiece;
  
  @override
  int get selectedPositionIndex => state.selectedPositionIndex;
  
  @override
  Point? get selectedCellInPiece => state.selectedCellInPiece;
  
  @override
  bool canPlacePiece(Pento piece, int positionIndex, int gridX, int gridY) {
    return state.canPlacePiece(piece, positionIndex, gridX, gridY);
  }

  TransformationResult applyIsometryRotationCW() {
    return _applyIsoUsingLookup((p, idx) => p.rotationCW(idx));
  }

  TransformationResult applyIsometryRotationTW() {
    return _applyIsoUsingLookup((p, idx) => p.rotationTW(idx));
  }

  TransformationResult applyIsometrySymmetryH() {
    if (state.viewOrientation == ViewOrientation.landscape) {
      if (state.selectedPlacedPiece != null && state.selectedCellInPiece != null) {
        return _applySymmetryAbs(SymmetryType.vertical);
      }
      return _applyIsoUsingLookup((p, idx) => p.symmetryV(idx));
    } else {
      if (state.selectedPlacedPiece != null && state.selectedCellInPiece != null) {
        return _applySymmetryAbs(SymmetryType.horizontal);
      }
      return _applyIsoUsingLookup((p, idx) => p.symmetryH(idx));
    }
  }

  TransformationResult applyIsometrySymmetryV() {
    if (state.viewOrientation == ViewOrientation.landscape) {
      if (state.selectedPlacedPiece != null && state.selectedCellInPiece != null) {
        return _applySymmetryAbs(SymmetryType.horizontal);
      }
      return _applyIsoUsingLookup((p, idx) => p.symmetryH(idx));
    } else {
      if (state.selectedPlacedPiece != null && state.selectedCellInPiece != null) {
        return _applySymmetryAbs(SymmetryType.vertical);
      }
      return _applyIsoUsingLookup((p, idx) => p.symmetryV(idx));
    }
  }

  @override
  PentoscopeState build() {
    _generator = PentoscopeGenerator();
    _solver = PentoscopeSolver();
    return PentoscopeState.initial();
  }

  // ==========================================================================
  // ⏱️ TIMER
  // ==========================================================================

  /// Démarre le chronomètre
  void startTimer() {
    if (_gameTimer != null) return; // Déjà démarré
    
    _startTime = DateTime.now();
    _gameTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      state = state.copyWith(
        elapsedSeconds: getElapsedSeconds(),
      );
    });
  }

  /// Arrête le chronomètre
  void stopTimer() {
    _gameTimer?.cancel();
    _gameTimer = null;
  }

  /// Retourne le temps écoulé en secondes
  int getElapsedSeconds() {
    if (_startTime == null) return 0;
    return DateTime.now().difference(_startTime!).inSeconds;
  }

  // ==========================================================================
  // 📊 NOTE / SCORE
  // ==========================================================================

  /// Calcule la note de "non-triche" (0-20)
  /// - 0 hints → 20/20
  /// - ≥ nbPieces - 1 hints → 0/20
  /// - Entre les deux → linéaire
  int calculateNote() {
    final nbPieces = state.puzzle?.size.numPieces ?? 1;
    final nbHints = state.hintCount;
    
    // Si 0 hint → 20/20
    if (nbHints == 0) return 20;
    
    // Si ≥ nbPieces - 1 hints → 0/20
    final maxHints = nbPieces - 1;
    if (nbHints >= maxHints) return 0;
    
    // Linéaire entre les deux
    // note = 20 - (nbHints * 20 / maxHints)
    final note = 20 - (nbHints * 20 ~/ maxHints);
    return note.clamp(0, 20);
  }

  // ==========================================================================
  // 💡 HINT SYSTEM - Vérifier et appliquer un indice
  // ==========================================================================

  /// Applique un indice en plaçant une pièce du slider selon une solution possible
  void applyHint() {
    if (state.puzzle == null) return;
    if (state.availablePieces.isEmpty) return;
    if (!state.hasPossibleSolution) return;

    final width = state.puzzle!.size.width;
    final height = state.puzzle!.size.height;

    // Récupérer les IDs des pièces non encore placées
    final remainingPieceIds = state.availablePieces.map((p) => p.id).toList();

    // Créer un plateau temporaire avec les pièces déjà placées
    final tempPlateau = List<List<int>>.generate(
      height,
      (_) => List<int>.filled(width, 0),
    );

    for (final placed in state.placedPieces) {
      for (final cell in placed.absoluteCells) {
        if (cell.x >= 0 && cell.x < width && cell.y >= 0 && cell.y < height) {
          tempPlateau[cell.y][cell.x] = placed.piece.id;
        }
      }
    }

    // Trouver une solution
    final solution = _solver.findSolutionFrom(remainingPieceIds, width, height, tempPlateau);
    if (solution == null || solution.isEmpty) {
      debugPrint('❌ HINT: Aucune solution trouvée');
      return;
    }

    // Prendre le premier placement de la solution (première pièce à placer)
    final hintPlacement = solution.first;
    final hintPiece = pentominos.firstWhere((p) => p.id == hintPlacement.pieceId);

    debugPrint('💡 HINT: Placer pièce ${hintPiece.id} à (${hintPlacement.gridX}, ${hintPlacement.gridY}) pos=${hintPlacement.positionIndex}');

    // Créer le nouveau plateau
    final newPlateau = Plateau.allVisible(width, height);

    // Copier les pièces existantes
    for (final p in state.placedPieces) {
      for (final cell in p.absoluteCells) {
        newPlateau.setCell(cell.x, cell.y, p.piece.id);
      }
    }

    // Placer la nouvelle pièce
    final newPlaced = PentoscopePlacedPiece(
      piece: hintPiece,
      positionIndex: hintPlacement.positionIndex,
      gridX: hintPlacement.gridX,
      gridY: hintPlacement.gridY,
    );

    for (final cell in newPlaced.absoluteCells) {
      newPlateau.setCell(cell.x, cell.y, hintPiece.id);
    }

    // Mettre à jour les listes
    final newPlacedPieces = [...state.placedPieces, newPlaced];
    final newAvailable = state.availablePieces
        .where((p) => p.id != hintPiece.id)
        .toList();

    final isComplete = newPlacedPieces.length == state.puzzle!.size.numPieces;

    // ⏱️ Arrêter le timer si puzzle complet
    if (isComplete) {
      stopTimer();
    }

    // Vérifier s'il reste des solutions possibles
    final hasPossibleSolution = newAvailable.isNotEmpty
        ? _checkHasPossibleSolutionWith(newPlateau, newAvailable, newPlacedPieces)
        : false;

    state = state.copyWith(
      plateau: newPlateau,
      availablePieces: newAvailable,
      placedPieces: newPlacedPieces,
      isComplete: isComplete,
      hasPossibleSolution: hasPossibleSolution,
      hintCount: state.hintCount + 1, // 💡 Incrémenter le compteur de hints
      clearSelectedPiece: true,
      clearSelectedPlacedPiece: true,
      clearPreview: true,
      validPlacements: [],
    );
  }

  /// Version interne pour vérifier avec un état spécifique
  bool _checkHasPossibleSolutionWith(
    Plateau plateau,
    List<Pento> availablePieces,
    List<PentoscopePlacedPiece> placedPieces,
  ) {
    if (state.puzzle == null) return false;
    if (availablePieces.isEmpty) return false;

    final width = state.puzzle!.size.width;
    final height = state.puzzle!.size.height;
    final remainingPieceIds = availablePieces.map((p) => p.id).toList();

    final tempPlateau = List<List<int>>.generate(
      height,
      (_) => List<int>.filled(width, 0),
    );

    for (final placed in placedPieces) {
      for (final cell in placed.absoluteCells) {
        if (cell.x >= 0 && cell.x < width && cell.y >= 0 && cell.y < height) {
          tempPlateau[cell.y][cell.x] = placed.piece.id;
        }
      }
    }

    return _solver.canSolveFrom(remainingPieceIds, width, height, tempPlateau);
  }

  // ==========================================================================
  // ✨ NOUVELLE FONCTION: Générer tous les placements valides
  // ==========================================================================

  // ==========================================================================
  // CORRECTION 1: cancelSelection - reconstruire le plateau
  // ==========================================================================

  void cancelSelection() {
    // Si on avait une pièce placée sélectionnée, il faut la remettre sur le plateau
    if (state.selectedPlacedPiece != null) {
      // Reconstruire le plateau avec TOUTES les pièces y compris celle sélectionnée
      final newPlateau = Plateau.allVisible(
        state.plateau.width,
        state.plateau.height,
      );
      for (final p in state.placedPieces) {
        for (final cell in p.absoluteCells) {
          newPlateau.setCell(cell.x, cell.y, p.piece.id);
        }
      }

      state = state.copyWith(
        plateau: newPlateau,
        clearSelectedPiece: true,
        clearSelectedPlacedPiece: true,
        clearSelectedCellInPiece: true,
        clearPreview: true,
        validPlacements: [], // ✨ NOUVEAU
      );
    } else {
      state = state.copyWith(
        clearSelectedPiece: true,
        clearSelectedPlacedPiece: true,
        clearSelectedCellInPiece: true,
        clearPreview: true,
        validPlacements: [], // ✨ NOUVEAU
      );
    }
  }

  // ==========================================================================
  // ✨ NOUVELLE FONCTION: Trouver la position la plus proche
  // ==========================================================================

  void clearPreview() {
    state = state.copyWith(clearPreview: true);
  }

  void cycleToNextOrientation() {
    if (state.selectedPiece == null) return;

    final piece = state.selectedPiece!;
    final newIndex = (state.selectedPositionIndex + 1) % piece.numOrientations;
    final newCell = _calculateDefaultCell(piece, newIndex);

    final newIndices = Map<int, int>.from(state.piecePositionIndices);
    newIndices[piece.id] = newIndex;

    // ✨ NOUVEAU: Régénérer les placements valides après rotation
    final newValidPlacements = _generateValidPlacements(piece, newIndex);

    state = state.copyWith(
      selectedPositionIndex: newIndex,
      piecePositionIndices: newIndices,
      selectedCellInPiece: newCell,
      validPlacements: newValidPlacements, // ✨ Mettre à jour
    );
  }

  PentoscopePlacedPiece? getPlacedPieceAt(int x, int y) {
    for (final placed in state.placedPieces) {
      for (final cell in placed.absoluteCells) {
        if (cell.x == x && cell.y == y) {
          return placed;
        }
      }
    }
    return null;
  }

  void removePlacedPiece(PentoscopePlacedPiece placed) {
    final newPlateau = Plateau.allVisible(
      state.plateau.width,
      state.plateau.height,
    );

    for (final p in state.placedPieces) {
      if (p.piece.id == placed.piece.id) continue;
      for (final cell in p.absoluteCells) {
        newPlateau.setCell(cell.x, cell.y, p.piece.id);
      }
    }

    final newPlaced = state.placedPieces
        .where((p) => p.piece.id != placed.piece.id)
        .toList();
    final newAvailable = [...state.availablePieces, placed.piece];

    // 💡 HINT: Recalculer si une solution est encore possible
    final hasPossibleSolution = _checkHasPossibleSolutionWith(
      newPlateau,
      newAvailable,
      newPlaced,
    );

    state = state.copyWith(
      plateau: newPlateau,
      placedPieces: newPlaced,
      availablePieces: newAvailable,
      clearSelectedPiece: true,
      clearSelectedPlacedPiece: true,
      clearSelectedCellInPiece: true,
      isComplete: false,
      validPlacements: [],
      hasPossibleSolution: hasPossibleSolution,
      deleteCount: state.deleteCount + 1, // 🗑️ Incrémenter le compteur de suppressions
    );
  }

  // ==========================================================================
  // RESET - génère un nouveau puzzle
  // ==========================================================================

  Future<void> reset() async {
    final puzzle = state.puzzle;
    if (puzzle == null) return;

    // Générer un nouveau puzzle avec la même taille
    final newPuzzle = await _generator.generate(puzzle.size);

    final pieces = newPuzzle.pieceIds
        .map((id) => pentominos.firstWhere((p) => p.id == id))
        .toList();

    final plateau = Plateau.allVisible(puzzle.size.width, puzzle.size.height);

    Solution? firstSolution;
    if (state.showSolution && newPuzzle.solutions.isNotEmpty) {
      firstSolution = newPuzzle.solutions[0];
    }

    // ⏱️ Reset sans démarrer le timer
    stopTimer();
    
    state = PentoscopeState(
      viewOrientation: state.viewOrientation,
      puzzle: newPuzzle,
      plateau: plateau,
      availablePieces: pieces,
      placedPieces: [],
      piecePositionIndices: {},
      isComplete: false,
      isometryCount: 0,
      translationCount: 0,
      showSolution: state.showSolution,
      // ✅ Récupérer de state
      currentSolution: firstSolution,
      // ✅ Stocker la solution
      validPlacements: [], // ✨ NOUVEAU
      hasPossibleSolution: true, // 💡 Reset
      elapsedSeconds: 0, // ⏱️ Reset timer
    );
    
  }

  // ==========================================================================
  // SÉLECTION PIÈCE (SLIDER)
  // ==========================================================================
  void selectPiece(Pento piece) {
    // ✨ BUGFIX: Si la pièce est déjà sélectionnée, utiliser selectedPositionIndex
    // (qui a été mis à jour par l'isométrie)
    // Sinon, récupérer l'index depuis piecePositionIndices
    final positionIndex = state.selectedPiece?.id == piece.id
        ? state.selectedPositionIndex
        : state.getPiecePositionIndex(piece.id);

    final defaultCell = _calculateDefaultCell(piece, positionIndex);
    _cancelSelectedPlacedPieceIfAny();

    // ✅ RESTAURER LE PLATEAU COMPLET avec TOUTES les pièces placées
    final newPlateau = Plateau.allVisible(
      state.plateau.width,
      state.plateau.height,
    );
    for (final p in state.placedPieces) {
      for (final cell in p.absoluteCells) {
        newPlateau.setCell(cell.x, cell.y, p.piece.id);
      }
    }

    // ✨ BUGFIX: Mettre à jour le plateau EN PREMIER
    state = state.copyWith(
      plateau: newPlateau,
      // ← CLÉ!
      selectedPiece: piece,
      selectedPositionIndex: positionIndex,
      clearSelectedPlacedPiece: true,
      selectedCellInPiece: defaultCell,
    );

    // ✨ PUIS générer les placements valides avec le NOUVEAU plateau
    final newValidPlacements = _generateValidPlacements(piece, positionIndex);

    state = state.copyWith(validPlacements: newValidPlacements);
  }

  // ==========================================================================
  // SÉLECTION PIÈCE PLACÉE (avec mastercase)
  // ==========================================================================

  void selectPlacedPiece(
    PentoscopePlacedPiece placed,
    int absoluteX,
    int absoluteY,
  ) {
    if (state.isComplete) return; // ← Bloquer si puzzle complet

    // Calculer la cellule locale cliquée (mastercase) en coordonnées brutes
    final rawLocalX = absoluteX - placed.gridX;
    final rawLocalY = absoluteY - placed.gridY;

    // Convertir en coordonnées normalisées (comme dans _remapSelectedCell)
    final position = placed.piece.orientations[placed.positionIndex];
    final coords = position.map((cellNum) {
      final x = (cellNum - 1) % 5;
      final y = (cellNum - 1) ~/ 5;
      return Point(x, y);
    }).toList();

    final minX = coords.map((p) => p.x).reduce((a, b) => a < b ? a : b);
    final minY = coords.map((p) => p.y).reduce((a, b) => a < b ? a : b);
    final normalizedCoords = coords.map((p) => Point(p.x - minX, p.y - minY)).toList();

    // Trouver quelle cellule normalisée correspond à la position cliquée
    Point? normalizedMastercase;
    for (int i = 0; i < coords.length; i++) {
      if (coords[i].x == rawLocalX && coords[i].y == rawLocalY) {
        normalizedMastercase = normalizedCoords[i];
        break;
      }
    }

    // Si on n'a pas trouvé, utiliser les coordonnées brutes (fallback)
    final mastercase = normalizedMastercase ?? Point(rawLocalX, rawLocalY);

    // Retirer la pièce du plateau temporairement
    final newPlateau = Plateau.allVisible(
      state.plateau.width,
      state.plateau.height,
    );
    for (final p in state.placedPieces) {
      if (p.piece.id == placed.piece.id) continue;
      for (final cell in p.absoluteCells) {
        newPlateau.setCell(cell.x, cell.y, p.piece.id);
      }
    }

    // ✨ BUGFIX: Mettre à jour le plateau dans l'état EN PREMIER
    // Sinon _generateValidPlacements() utilise l'ancien plateau!
    state = state.copyWith(
      plateau: newPlateau,
      selectedPiece: placed.piece,
      selectedPlacedPiece: placed,
      selectedPositionIndex: placed.positionIndex,
      selectedCellInPiece: mastercase,
      clearPreview: true,
    );

    // ✨ PUIS générer les placements valides avec le NOUVEAU plateau
    var validPlacements = _generateValidPlacements(
      placed.piece,
      placed.positionIndex,
    );

    // 🔑 EXCLURE la position actuelle pour faciliter les translations
    // Sinon le snapping ramène toujours à la position d'origine
    validPlacements = validPlacements
        .where((p) => p.x != placed.gridX || p.y != placed.gridY)
        .toList();

    state = state.copyWith(validPlacements: validPlacements);
  }

  /// À appeler depuis l'UI (board) quand l'orientation change.
  /// Ne change aucune coordonnée: uniquement l'interprétation des actions
  /// (ex: Sym H/V) en mode paysage.
  void setViewOrientation(bool isLandscape) {
    final next = isLandscape
        ? ViewOrientation.landscape
        : ViewOrientation.portrait;
    if (state.viewOrientation == next) return;
    state = state.copyWith(viewOrientation: next);
  }

  // ==========================================================================
  // DÉMARRAGE
  // ==========================================================================

  Future<void> startPuzzle(
    PentoscopeSize size, {
    PentoscopeDifficulty difficulty = PentoscopeDifficulty.random,
    bool showSolution = false,
  }) async {
    final puzzle = await switch (difficulty) {
      PentoscopeDifficulty.easy => _generator.generateEasy(size),
      PentoscopeDifficulty.hard => _generator.generateHard(size),
      PentoscopeDifficulty.random => _generator.generate(size),
    };

    final pieces = puzzle.pieceIds
        .map((id) => pentominos.firstWhere((p) => p.id == id))
        .toList();

    final plateau = Plateau.allVisible(size.width, size.height);

    // 🎯 INITIALISER ALÉATOIREMENT LES POSITIONS
    final Random random = Random();
    final piecePositionIndices = <int, int>{};

    for (final piece in pieces) {
      final randomPos = random.nextInt(piece.numOrientations);
      piecePositionIndices[piece.id] = randomPos;
    }

    // ✅ TOUJOURS stocker la première solution (pour le calcul du score)
    Solution? firstSolution;
    if (showSolution && puzzle.solutions.isNotEmpty) {
      firstSolution = puzzle.solutions[0];

      for (final placement in firstSolution) {
        final pento = pentominos.firstWhere((p) => p.id == placement.pieceId);
        final initialPos = piecePositionIndices[placement.pieceId] ?? 0;

        pento.minIsometriesToReach(
          initialPos,
          placement.positionIndex,
        );
      }
    }

    // ⏱️ Démarrer le timer
    stopTimer();
    
    state = PentoscopeState(
      viewOrientation: ViewOrientation.portrait,
      puzzle: puzzle,
      plateau: plateau,
      availablePieces: pieces,
      placedPieces: [],
      piecePositionIndices: piecePositionIndices,
      isComplete: false,
      isometryCount: 0,
      translationCount: 0,
      showSolution: showSolution,
      // ✅ Flag pour contrôler l'AFFICHAGE
      currentSolution: firstSolution,
      // ✅ TOUJOURS fournie (pour le SCORE)
      validPlacements: [], // ✨ NOUVEAU
      hasPossibleSolution: true, // 💡 Au départ, une solution existe forcément
      elapsedSeconds: 0, // ⏱️ Reset timer
    );
    
    startTimer();
  }

  /// 🎮 Démarre un puzzle avec un seed et des pièces spécifiques (mode multiplayer)
  Future<void> startPuzzleFromSeed(
    PentoscopeSize size,
    int seed,
    List<int> pieceIds,
  ) async {
    // Générer le puzzle avec les paramètres fournis
    final puzzle = await _generator.generateFromSeed(size, seed, pieceIds);

    final pieces = pieceIds
        .map((id) => pentominos.firstWhere((p) => p.id == id))
        .toList();

    final plateau = Plateau.allVisible(size.width, size.height);

    // Initialiser les positions avec le même seed (pour cohérence)
    final Random random = Random(seed);
    final piecePositionIndices = <int, int>{};

    for (final piece in pieces) {
      final randomPos = random.nextInt(piece.numOrientations);
      piecePositionIndices[piece.id] = randomPos;
    }

    // Reset timer sans démarrer
    stopTimer();
    
    state = PentoscopeState(
      viewOrientation: ViewOrientation.portrait,
      puzzle: puzzle,
      plateau: plateau,
      availablePieces: pieces,
      placedPieces: [],
      piecePositionIndices: piecePositionIndices,
      isComplete: false,
      isometryCount: 0,
      translationCount: 0,
      showSolution: false,
      currentSolution: null,
      validPlacements: [],
      hasPossibleSolution: true,
      elapsedSeconds: 0,
    );
    
  }

  /// 🔄 Change la taille du plateau (redémarre avec un nouveau puzzle)
  Future<void> changeBoardSize(PentoscopeSize newSize) async {
    // Sauvegarder le temps actuel pour le niveau actuel

    // Générer un nouveau puzzle avec la nouvelle taille
    await startPuzzle(
      newSize,
      difficulty: PentoscopeDifficulty.random,
      showSolution: false,
    );

    debugPrint('📏 Plateau changé vers ${newSize.label} (${newSize.width}x${newSize.height})');
  }

  /// 💾 Sauvegarder le niveau terminé
  Future<void> _saveCompletedLevel() async {
    if (state.puzzle == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final progressData = {
        'boardSize': '${state.puzzle!.size.width}x${state.puzzle!.size.height}',
        'pieceIds': state.puzzle!.pieceIds.join(','),
        'completionTime': getElapsedSeconds(),
        'completedAt': DateTime.now().toIso8601String(),
      };

      // Sauvegarder sous forme de chaîne JSON-like
      final progressString = progressData.entries.map((e) => '${e.key}:${e.value}').join('|');
      await prefs.setString('pentoscope_last_completed', progressString);

      debugPrint('💾 Niveau sauvegardé: ${state.puzzle!.size.label}, temps: ${getElapsedSeconds()}s');
    } catch (e) {
      debugPrint('❌ Erreur lors de la sauvegarde du niveau: $e');
    }
  }

  // ==========================================================================
  // PLACEMENT
  // ==========================================================================

  /// Méthode publique pour obtenir les coordonnées brutes de la mastercase
  /// Utile pour le widget board qui doit reconstruire les coordonnées de drag
  /// 
  /// Note: Cette méthode publique est différente de celle du mixin (qui prend des paramètres)
  Point? getRawMastercaseCoordsPublic() {
    if (state.selectedPiece == null || state.selectedCellInPiece == null) {
      return null;
    }
    return super.getRawMastercaseCoords(
      state.selectedPiece!,
      state.selectedPositionIndex,
      state.selectedCellInPiece!,
    );
  }

  bool tryPlacePiece(int gridX, int gridY) {
    if (state.selectedPiece == null) return false;

    final piece = state.selectedPiece!;
    final positionIndex = state.selectedPositionIndex;

    int anchorX = gridX;
    int anchorY = gridY;

    if (state.selectedCellInPiece != null) {
      // ✅ Ancre calculée avec les coordonnées normalisées (mastercase)
      anchorX = gridX - state.selectedCellInPiece!.x;
      anchorY = gridY - state.selectedCellInPiece!.y;
    }

    if (!state.canPlacePiece(piece, positionIndex, anchorX, anchorY)) {
      return false;
    }

    // Créer le nouveau plateau
    final newPlateau = Plateau.allVisible(
      state.plateau.width,
      state.plateau.height,
    );

    // Copier les pièces existantes (sauf celle qu'on déplace si c'est une pièce placée)
    for (final p in state.placedPieces) {
      if (state.selectedPlacedPiece != null &&
          p.piece.id == state.selectedPlacedPiece!.piece.id) {
        continue;
      }
      for (final cell in p.absoluteCells) {
        newPlateau.setCell(cell.x, cell.y, p.piece.id);
      }
    }

    // Placer la nouvelle pièce
    final newPlaced = PentoscopePlacedPiece(
      piece: piece,
      positionIndex: positionIndex,
      gridX: anchorX,
      gridY: anchorY,
    );

    for (final cell in newPlaced.absoluteCells) {
      newPlateau.setCell(cell.x, cell.y, piece.id);
    }

    // Mettre à jour les listes
    List<PentoscopePlacedPiece> newPlacedPieces;
    List<Pento> newAvailable;

    if (state.selectedPlacedPiece != null) {
      // Déplacement d'une pièce existante
      newPlacedPieces = state.placedPieces
          .map((p) => p.piece.id == piece.id ? newPlaced : p)
          .toList();
      newAvailable = state.availablePieces;
    } else {
      // Nouvelle pièce
      newPlacedPieces = [...state.placedPieces, newPlaced];
      newAvailable = state.availablePieces
          .where((p) => p.id != piece.id)
          .toList();
    }

    final isComplete =
        newPlacedPieces.length == (state.puzzle?.size.numPieces ?? 0);

    // Compter les translations (déplacement d'une pièce déjà placée)
    final newTranslationCount = state.selectedPlacedPiece != null
        ? state.translationCount + 1
        : state.translationCount;

    // ⏱️ Arrêter le timer si puzzle complet
    if (isComplete) {
      stopTimer();
      // 💾 Sauvegarder le progrès du niveau réussi
      _saveCompletedLevel();
    }

    // 💡 HINT: Vérifier si une solution est encore possible
    final hasPossibleSolution = !isComplete && newAvailable.isNotEmpty
        ? _checkHasPossibleSolutionWith(newPlateau, newAvailable, newPlacedPieces)
        : false;

    state = state.copyWith(
      plateau: newPlateau,
      availablePieces: newAvailable,
      placedPieces: newPlacedPieces,
      clearSelectedPiece: true,
      clearSelectedPlacedPiece: true,
      clearSelectedCellInPiece: true,
      clearPreview: true,
      isComplete: isComplete,
      translationCount: newTranslationCount,
      currentSolution: state.currentSolution,
      validPlacements: [],
      hasPossibleSolution: hasPossibleSolution, // 💡 HINT
    );

    // ⏱️ Démarrer le timer au premier placement depuis le slider
    if (_gameTimer == null && state.selectedPlacedPiece == null) {
      startTimer();
    }

    return true;
  }

  // ==========================================================================
  // PREVIEW
  // ==========================================================================

  void updatePreview(int gridX, int gridY) {
    if (state.selectedPiece == null) {
      if (state.previewX != null || state.previewY != null) {
        state = state.copyWith(clearPreview: true);
      }
      return;
    }

    // ✨ CAS 1 - AUCUN PLACEMENT POSSIBLE → ROUGE PARTOUT
    if (state.validPlacements.isEmpty) {
      // Calculer où serait l'ancre si la mastercase était au doigt
      int previewX = gridX;
      int previewY = gridY;

      if (state.selectedCellInPiece != null) {
        // ✅ Ancre calculée avec les coordonnées normalisées (mastercase)
        previewX -= state.selectedCellInPiece!.x;
        previewY -= state.selectedCellInPiece!.y;
      }

      state = state.copyWith(
        previewX: previewX,
        previewY: previewY,
        isPreviewValid: false, // 🔴 ROUGE
      );
      return;
    }

    // ✨ CAS 2 - PLACEMENTS POSSIBLES → SNAPPING VERT
    final snappedPlacement = _findClosestValidPlacement(gridX, gridY);

    if (snappedPlacement == null) {
      if (state.previewX != null || state.previewY != null) {
        state = state.copyWith(clearPreview: true);
      }
      return;
    }

    // 🔑 Le snappedPlacement est déjà une position d'ancre valide
    // Pas besoin d'appliquer la mastercase, c'est déjà dedans
    state = state.copyWith(
      previewX: snappedPlacement.x,
      previewY: snappedPlacement.y,
      isPreviewValid: true, // 🟢 VERT
    );
  }

  // ============================================================================
  // VALIDATION ISOMÉTRIES - NOUVELLE MÉTHODE
  // ============================================================================

  TransformationResult _applyIsoUsingLookup(int Function(Pento p, int idx) f) {
    final piece = state.selectedPiece;
    if (piece == null) return TransformationResult.success;

    final oldIdx = state.selectedPositionIndex;
    final newIdx = f(piece, oldIdx);
    final didChange = oldIdx != newIdx;

    if (!didChange) return TransformationResult.success;

    // ========================================================================
    // CAS 1: Pièce du SLIDER sélectionnée (pas de validation nécessaire)
    // ========================================================================
    final sp = state.selectedPlacedPiece;
    if (sp == null) {
      state = state.copyWith(
        selectedPositionIndex: newIdx,
        selectedCellInPiece: _remapSelectedCell(
          piece: piece,
          oldIndex: oldIdx,
          newIndex: newIdx,
          oldCell: state.selectedCellInPiece,
        ),
        clearPreview: true,
        isometryCount: state.isometryCount + 1,
      );

      // ✨ BUGFIX: Régénérer validPlacements avec le NOUVEAU positionIndex
      final newValidPlacements = _generateValidPlacements(piece, newIdx);
      state = state.copyWith(validPlacements: newValidPlacements);
      return TransformationResult.success;
    }

    // ========================================================================
    // CAS 2: Pièce PLACÉE sur plateau (VALIDATION REQUISE!)
    // ========================================================================

    final transformedPiece = sp.copyWith(positionIndex: newIdx);

    // 🎯 LOGIQUE MASTERCACE FIXE
    late int adjustedGridX;
    late int adjustedGridY;
    bool neededRecentering = false;

    if (state.selectedCellInPiece != null) {
      // === LOG AVANT TRANSFO ===
      final originalPosition = sp.piece.orientations[oldIdx];
      final originalRawCoords = originalPosition.map((cellNum) {
        final x = (cellNum - 1) % 5;
        final y = (cellNum - 1) ~/ 5;
        return Point(x, y);
      }).toList();
      final minXOrig = originalRawCoords.map((p) => p.x).reduce((a, b) => a < b ? a : b);
      final minYOrig = originalRawCoords.map((p) => p.y).reduce((a, b) => a < b ? a : b);
      final normalizedOrigCoords = originalRawCoords
          .map((p) => Point(p.x - minXOrig, p.y - minYOrig))
          .toList();
      final masterIdxOrig = normalizedOrigCoords.indexWhere(
        (p) => p.x == state.selectedCellInPiece!.x && p.y == state.selectedCellInPiece!.y,
      );
      final masterRawOrig = masterIdxOrig == -1
          ? null
          : originalRawCoords[masterIdxOrig];
      final masterAbsOrig = masterRawOrig == null
          ? null
          : Point(sp.gridX + masterRawOrig.x, sp.gridY + masterRawOrig.y);
      debugPrint(
        '🧩 BEFORE: grid=(${sp.gridX},${sp.gridY}) '
        'masterNorm=(${state.selectedCellInPiece!.x},${state.selectedCellInPiece!.y}) '
        'masterRaw=${masterRawOrig == null ? "null" : "(${masterRawOrig.x},${masterRawOrig.y})"} '
        'masterAbs=${masterAbsOrig == null ? "null" : "(${masterAbsOrig.x},${masterAbsOrig.y})"}',
      );

      // Calculer la position pour maintenir la mastercase fixe
      final fixedPosition = _calculatePositionForFixedMastercase(
        originalPiece: sp,
        transformedPiece: transformedPiece,
        mastercase: state.selectedCellInPiece!,
      );

      adjustedGridX = fixedPosition.x;
      adjustedGridY = fixedPosition.y;

      debugPrint(
        '🎯 Mastercase fixe: (${sp.gridX},${sp.gridY}) → ($adjustedGridX,$adjustedGridY)',
      );
    } else {
      // Logique classique si pas de mastercase définie
      adjustedGridX = sp.gridX;
      adjustedGridY = sp.gridY;
    }

    // Créer une pièce temporaire pour tester la position initiale
    final initialPiece = transformedPiece.copyWith(
      gridX: adjustedGridX,
      gridY: adjustedGridY,
    );

    // Vérifier si la position initiale est valide
    if (!_canPlacePieceWithoutChecker(initialPiece)) {
      // Chercher une position valide proche
      if (state.selectedCellInPiece != null) {
        final mastercaseAbs = Point(
          sp.gridX + state.selectedCellInPiece!.x,
          sp.gridY + state.selectedCellInPiece!.y,
        );
        final nearestPosition = _findNearestValidPosition(
          piece: transformedPiece,
          mastercaseAbs: mastercaseAbs,
          mastercaseLocal: state.selectedCellInPiece!,
        );

        if (nearestPosition == null) {
          debugPrint('❌ Transformation impossible - aucune position valide trouvée');
          return TransformationResult.impossible;
        }

        adjustedGridX = nearestPosition.x;
        adjustedGridY = nearestPosition.y;
        neededRecentering = true;
      } else {
        debugPrint('❌ Transformation impossible - chevauchement et pas de mastercase');
        return TransformationResult.impossible;
      }
    }

    // 🔄 AJUSTEMENT AUTOMATIQUE si la pièce sort du plateau
    // Ajuster X si nécessaire
    while (adjustedGridX < 0 ||
        (adjustedGridX + _getMaxLocalX(transformedPiece) >= state.plateau.width)) {
      if (adjustedGridX > 0) {
        adjustedGridX--;
        neededRecentering = true;
      } else {
        // Ne peut pas aller plus à gauche, chercher une position valide
        if (state.selectedCellInPiece != null) {
          final mastercaseAbs = Point(
            sp.gridX + state.selectedCellInPiece!.x,
            sp.gridY + state.selectedCellInPiece!.y,
          );
          final nearestPosition = _findNearestValidPosition(
            piece: transformedPiece,
            mastercaseAbs: mastercaseAbs,
            mastercaseLocal: state.selectedCellInPiece!,
          );

          if (nearestPosition == null) {
            debugPrint('❌ Transformation impossible - pièce sortirait du plateau');
            return TransformationResult.impossible;
          }

          adjustedGridX = nearestPosition.x;
          adjustedGridY = nearestPosition.y;
          neededRecentering = true;
          break;
        } else {
          debugPrint('❌ Transformation impossible - pièce sortirait du plateau');
          return TransformationResult.impossible;
        }
      }
    }

    // Ajuster Y si nécessaire
    while (adjustedGridY < 0 ||
        (adjustedGridY + _getMaxLocalY(transformedPiece) >= state.plateau.height)) {
      if (adjustedGridY > 0) {
        adjustedGridY--;
        neededRecentering = true;
      } else {
        // Ne peut pas aller plus haut, chercher une position valide
        if (state.selectedCellInPiece != null) {
          final mastercaseAbs = Point(
            sp.gridX + state.selectedCellInPiece!.x,
            sp.gridY + state.selectedCellInPiece!.y,
          );
          final nearestPosition = _findNearestValidPosition(
            piece: transformedPiece,
            mastercaseAbs: mastercaseAbs,
            mastercaseLocal: state.selectedCellInPiece!,
          );

          if (nearestPosition == null) {
            debugPrint('❌ Transformation impossible - pièce sortirait du plateau');
            return TransformationResult.impossible;
          }

          adjustedGridX = nearestPosition.x;
          adjustedGridY = nearestPosition.y;
          neededRecentering = true;
          break;
        } else {
          debugPrint('❌ Transformation impossible - pièce sortirait du plateau');
          return TransformationResult.impossible;
        }
      }
    }

    final finalPiece = transformedPiece.copyWith(
      gridX: adjustedGridX,
      gridY: adjustedGridY,
    );

    // Vérifier une dernière fois que la position est valide
    if (!_canPlacePieceWithoutChecker(finalPiece)) {
      debugPrint('❌ Transformation impossible - position finale invalide');
      return TransformationResult.impossible;
    }

    // ✨ SAUVEGARDER la pièce avec la nouvelle position
    final updatedPlacedPieces = state.placedPieces.map((p) {
      if (p.piece.id == sp.piece.id) {
        return finalPiece;  // ← Utiliser finalPiece ajustée!
      }
      return p;
    }).toList();

    // 🔄 Reconstruire le plateau avec les pièces mises à jour
    final newPlateau = Plateau.allVisible(
      state.plateau.width,
      state.plateau.height,
    );
    for (final p in updatedPlacedPieces) {
      for (final cell in p.absoluteCells) {
        newPlateau.setCell(cell.x, cell.y, p.piece.id);
      }
    }

    // 💡 Recalculer si une solution est encore possible
    final hasPossibleSolution = state.availablePieces.isNotEmpty
        ? _checkHasPossibleSolutionWith(newPlateau, state.availablePieces, updatedPlacedPieces)
        : false;

    // Calculer la nouvelle position relative de la mastercase dans la pièce transformée
    Point? newSelectedCellInPiece;
    if (state.selectedCellInPiece != null) {
      // Utiliser l'index STABLE (ordre géométrique) pour remapper la mastercase
      final originalPosition = sp.piece.orientations[oldIdx];
      final transformedPosition = piece.orientations[newIdx];

      final originalCoords = originalPosition.map((cellNum) {
        final x = (cellNum - 1) % 5;
        final y = (cellNum - 1) ~/ 5;
        return Point(x, y);
      }).toList();

      final minXOrig = originalCoords.map((p) => p.x).reduce((a, b) => a < b ? a : b);
      final minYOrig = originalCoords.map((p) => p.y).reduce((a, b) => a < b ? a : b);
      final normalizedOrigCoords = originalCoords
          .map((p) => Point(p.x - minXOrig, p.y - minYOrig))
          .toList();

      final mastercaseIndex = normalizedOrigCoords.indexWhere(
        (p) => p.x == state.selectedCellInPiece!.x && p.y == state.selectedCellInPiece!.y,
      );

      if (mastercaseIndex != -1) {
        final transformedCoords = transformedPosition.map((cellNum) {
          final x = (cellNum - 1) % 5;
          final y = (cellNum - 1) ~/ 5;
          return Point(x, y);
        }).toList();

        final minXTrans = transformedCoords.map((p) => p.x).reduce((a, b) => a < b ? a : b);
        final minYTrans = transformedCoords.map((p) => p.y).reduce((a, b) => a < b ? a : b);
        final normalizedTransCoords = transformedCoords
            .map((p) => Point(p.x - minXTrans, p.y - minYTrans))
            .toList();

        newSelectedCellInPiece = normalizedTransCoords[mastercaseIndex];
      }
    }

    state = state.copyWith(
      plateau: newPlateau,
      selectedPlacedPiece: finalPiece,  // ← Mettre à jour!
      placedPieces: updatedPlacedPieces,
      selectedPositionIndex: newIdx,
      selectedCellInPiece: newSelectedCellInPiece ?? _remapSelectedCell(
        piece: piece,
        oldIndex: oldIdx,
        newIndex: newIdx,
        oldCell: state.selectedCellInPiece,
      ),
      clearPreview: true,
      isometryCount: state.isometryCount + 1,
      hasPossibleSolution: hasPossibleSolution, // 💡 Mise à jour!
    );

    // === LOG APRES TRANSFO ===
    if (state.selectedCellInPiece != null) {
      final transformedPosition = piece.orientations[newIdx];
      final transformedRawCoords = transformedPosition.map((cellNum) {
        final x = (cellNum - 1) % 5;
        final y = (cellNum - 1) ~/ 5;
        return Point(x, y);
      }).toList();
      final minXTrans = transformedRawCoords.map((p) => p.x).reduce((a, b) => a < b ? a : b);
      final minYTrans = transformedRawCoords.map((p) => p.y).reduce((a, b) => a < b ? a : b);
      final normalizedTransCoords = transformedRawCoords
          .map((p) => Point(p.x - minXTrans, p.y - minYTrans))
          .toList();
      final masterIdxTrans = normalizedTransCoords.indexWhere(
        (p) => p.x == state.selectedCellInPiece!.x && p.y == state.selectedCellInPiece!.y,
      );
      final masterRawTrans = masterIdxTrans == -1
          ? null
          : transformedRawCoords[masterIdxTrans];
      final masterAbsTrans = masterRawTrans == null
          ? null
          : Point(finalPiece.gridX + masterRawTrans.x, finalPiece.gridY + masterRawTrans.y);
      debugPrint(
        '🧩 AFTER: grid=(${finalPiece.gridX},${finalPiece.gridY}) '
        'masterNorm=(${state.selectedCellInPiece!.x},${state.selectedCellInPiece!.y}) '
        'masterRaw=${masterRawTrans == null ? "null" : "(${masterRawTrans.x},${masterRawTrans.y})"} '
        'masterAbs=${masterAbsTrans == null ? "null" : "(${masterAbsTrans.x},${masterAbsTrans.y})"}',
      );
    }

    return neededRecentering ? TransformationResult.recentered : TransformationResult.success;
  }

  TransformationResult _applySymmetryAbs(SymmetryType type) {
    final piece = state.selectedPiece;
    final sp = state.selectedPlacedPiece;
    if (piece == null || sp == null) return TransformationResult.success;
    if (state.selectedCellInPiece == null) {
      return TransformationResult.success;
    }

    final oldIdx = state.selectedPositionIndex;

    final masterRaw = getRawMastercaseCoords(
      piece,
      oldIdx,
      state.selectedCellInPiece!,
    );
    final masterAbs = Point(
      sp.gridX + masterRaw.x,
      sp.gridY + masterRaw.y,
    );

    final cellsAbs = sp.absoluteCells.toList();
    debugPrint(
      '🧩 SYM BEFORE: '
      'piece=${piece.id} oldIdx=$oldIdx '
      'grid=(${sp.gridX},${sp.gridY}) '
      'masterAbs=(${masterAbs.x},${masterAbs.y}) '
      'type=$type',
    );
    final symAbs = applySymmetryAbs(
      cellsAbs: cellsAbs,
      masterAbs: masterAbs,
      type: type,
    );

    final normalized = normalizeCoords(symAbs);
    debugPrint('🧮 SYM ABS: $symAbs');
    debugPrint('🧮 SYM NORM: $normalized');
    final newIdx = findOrientationIndexFromNormalized(
      piece: piece,
      normalizedCoords: normalized,
    );

    if (newIdx == null) {
      debugPrint('❌ Symétrie impossible - orientation introuvable');
      return TransformationResult.impossible;
    }
    debugPrint('✅ SYM ORIENTATION: $oldIdx → $newIdx');

    final minX = symAbs.map((p) => p.x).reduce((a, b) => a < b ? a : b);
    final minY = symAbs.map((p) => p.y).reduce((a, b) => a < b ? a : b);

    final transformedPiece = sp.copyWith(positionIndex: newIdx);

    int adjustedGridX = minX;
    int adjustedGridY = minY;
    debugPrint('🧮 SYM GRID INIT: ($adjustedGridX,$adjustedGridY)');
    bool neededRecentering = false;

    final initialPiece = transformedPiece.copyWith(
      gridX: adjustedGridX,
      gridY: adjustedGridY,
    );

    if (!_canPlacePieceWithoutChecker(initialPiece)) {
      final nearestPosition = _findNearestValidPosition(
        piece: transformedPiece,
        mastercaseAbs: masterAbs,
        mastercaseLocal: state.selectedCellInPiece!,
      );

      if (nearestPosition == null) {
        debugPrint('❌ Symétrie impossible - aucune position valide trouvée');
        return TransformationResult.impossible;
      }

      adjustedGridX = nearestPosition.x;
      adjustedGridY = nearestPosition.y;
      neededRecentering = true;
    }

    while (adjustedGridX < 0 ||
        (adjustedGridX + _getMaxLocalX(transformedPiece) >=
            state.plateau.width)) {
      if (adjustedGridX > 0) {
        adjustedGridX--;
        neededRecentering = true;
      } else {
        final nearestPosition = _findNearestValidPosition(
          piece: transformedPiece,
          mastercaseAbs: masterAbs,
          mastercaseLocal: state.selectedCellInPiece!,
        );

        if (nearestPosition == null) {
          debugPrint('❌ Symétrie impossible - pièce sortirait du plateau');
          return TransformationResult.impossible;
        }

        adjustedGridX = nearestPosition.x;
        adjustedGridY = nearestPosition.y;
        neededRecentering = true;
        break;
      }
    }

    while (adjustedGridY < 0 ||
        (adjustedGridY + _getMaxLocalY(transformedPiece) >=
            state.plateau.height)) {
      if (adjustedGridY > 0) {
        adjustedGridY--;
        neededRecentering = true;
      } else {
        final nearestPosition = _findNearestValidPosition(
          piece: transformedPiece,
          mastercaseAbs: masterAbs,
          mastercaseLocal: state.selectedCellInPiece!,
        );

        if (nearestPosition == null) {
          debugPrint('❌ Symétrie impossible - pièce sortirait du plateau');
          return TransformationResult.impossible;
        }

        adjustedGridX = nearestPosition.x;
        adjustedGridY = nearestPosition.y;
        neededRecentering = true;
        break;
      }
    }

    final finalPiece = transformedPiece.copyWith(
      gridX: adjustedGridX,
      gridY: adjustedGridY,
    );

    if (!_canPlacePieceWithoutChecker(finalPiece)) {
      debugPrint('❌ Symétrie impossible - position finale invalide');
      return TransformationResult.impossible;
    }

    final updatedPlacedPieces = state.placedPieces.map((p) {
      if (p.piece.id == sp.piece.id) {
        return finalPiece;
      }
      return p;
    }).toList();

    final newPlateau = Plateau.allVisible(
      state.plateau.width,
      state.plateau.height,
    );
    for (final p in updatedPlacedPieces) {
      for (final cell in p.absoluteCells) {
        newPlateau.setCell(cell.x, cell.y, p.piece.id);
      }
    }

    final hasPossibleSolution = state.availablePieces.isNotEmpty
        ? _checkHasPossibleSolutionWith(
            newPlateau,
            state.availablePieces,
            updatedPlacedPieces,
          )
        : false;

    Point? newSelectedCellInPiece;
    if (state.selectedCellInPiece != null) {
      final transformedPosition = piece.orientations[newIdx];
      final transformedCoords = transformedPosition.map((cellNum) {
        final x = (cellNum - 1) % 5;
        final y = (cellNum - 1) ~/ 5;
        return Point(x, y);
      }).toList();

      final minXTrans =
          transformedCoords.map((p) => p.x).reduce((a, b) => a < b ? a : b);
      final minYTrans =
          transformedCoords.map((p) => p.y).reduce((a, b) => a < b ? a : b);
      final normalizedTransCoords = transformedCoords
          .map((p) => Point(p.x - minXTrans, p.y - minYTrans))
          .toList();

      final expectedRaw = Point(
        masterAbs.x - finalPiece.gridX,
        masterAbs.y - finalPiece.gridY,
      );
      final masterIdx = transformedCoords.indexWhere(
        (p) => p.x == expectedRaw.x && p.y == expectedRaw.y,
      );

      if (masterIdx != -1) {
        newSelectedCellInPiece = normalizedTransCoords[masterIdx];
      } else {
        debugPrint(
          '⚠️ SYM mastercase raw not found in new orientation: '
          'expected=(${expectedRaw.x},${expectedRaw.y})',
        );
      }
    }

    state = state.copyWith(
      plateau: newPlateau,
      selectedPlacedPiece: finalPiece,
      placedPieces: updatedPlacedPieces,
      selectedPositionIndex: newIdx,
      selectedCellInPiece: newSelectedCellInPiece ??
          _remapSelectedCell(
            piece: piece,
            oldIndex: oldIdx,
            newIndex: newIdx,
            oldCell: state.selectedCellInPiece,
          ),
      clearPreview: true,
      isometryCount: state.isometryCount + 1,
      hasPossibleSolution: hasPossibleSolution,
    );

    final finalMasterRaw = getRawMastercaseCoords(
      piece,
      newIdx,
      state.selectedCellInPiece!,
    );
    debugPrint(
      '🧩 SYM AFTER: '
      'grid=(${finalPiece.gridX},${finalPiece.gridY}) '
      'masterAbs=(${finalPiece.gridX + finalMasterRaw.x},${finalPiece.gridY + finalMasterRaw.y})',
    );

    return neededRecentering
        ? TransformationResult.recentered
        : TransformationResult.success;
  }

  /// Calcule la position gridX,gridY pour maintenir la mastercase fixe lors d'une transformation
  Point _calculatePositionForFixedMastercase({
    required PentoscopePlacedPiece originalPiece,
    required PentoscopePlacedPiece transformedPiece,
    required Point mastercase,
  }) {
    debugPrint(
      '🧮 CALC: origGrid=(${originalPiece.gridX},${originalPiece.gridY}) '
      'masterNorm=(${mastercase.x},${mastercase.y}) '
      'oldIdx=${originalPiece.positionIndex} newIdx=${transformedPiece.positionIndex}',
    );
    // 1. Trouver l'index STABLE (ordre géométrique) de la mastercase
    // On ne peut pas utiliser le cellNum (il change selon l'orientation).
    final originalPosition = originalPiece.piece.orientations[originalPiece.positionIndex];
    final originalCoords = originalPosition.map((cellNum) {
      final x = (cellNum - 1) % 5;
      final y = (cellNum - 1) ~/ 5;
      return Point(x, y);
    }).toList();

    final minXOrig = originalCoords.map((p) => p.x).reduce((a, b) => a < b ? a : b);
    final minYOrig = originalCoords.map((p) => p.y).reduce((a, b) => a < b ? a : b);
    final normalizedOrigCoords = originalCoords.map((p) => Point(p.x - minXOrig, p.y - minYOrig)).toList();

    // Trouver l'index de la mastercase dans les coordonnées normalisées
    final mastercaseIndex = normalizedOrigCoords.indexWhere(
      (p) => p.x == mastercase.x && p.y == mastercase.y,
    );
    if (mastercaseIndex == -1) {
      debugPrint('Warning: Mastercase not found in original position, keeping original position');
      return Point(originalPiece.gridX, originalPiece.gridY);
    }

    // 2. Calculer les coordonnées normalisées dans la nouvelle orientation
    // et réutiliser le même index (ordre stable)
    final transformedPosition = transformedPiece.piece.orientations[transformedPiece.positionIndex];
    final transformedCoords = transformedPosition.map((cellNum) {
      final x = (cellNum - 1) % 5;
      final y = (cellNum - 1) ~/ 5;
      return Point(x, y);
    }).toList();

    // 4. Position absolue actuelle de la mastercase (coord brute d'origine)
    final originalMasterRaw = originalCoords[mastercaseIndex];
    final mastercaseAbsX = originalPiece.gridX + originalMasterRaw.x;
    final mastercaseAbsY = originalPiece.gridY + originalMasterRaw.y;

    // 5. Calculer gridX, gridY pour que la mastercase reste à la position absolue
    // La cellule brute de la mastercase en orientation transformée est celle au même index
    final newLocalX = transformedCoords[mastercaseIndex].x;
    final newLocalY = transformedCoords[mastercaseIndex].y;

    final newGridX = mastercaseAbsX - newLocalX;
    final newGridY = mastercaseAbsY - newLocalY;

    debugPrint(
      '🧮 CALC: masterIdx=$mastercaseIndex '
      'origRaw=(${originalMasterRaw.x},${originalMasterRaw.y}) '
      'newRaw=($newLocalX,$newLocalY) '
      'newGrid=($newGridX,$newGridY)',
    );

    return Point(newGridX, newGridY);
  }

  /// Helper: calcule la mastercase par défaut (première cellule normalisée)
  /// 
  /// ✅ Utilise maintenant la méthode du mixin
  Point? _calculateDefaultCell(Pento piece, int positionIndex) {
    return calculateDefaultCell(piece, positionIndex);
  }


  /// Annule le mode "pièce placée en main" (sélection sur plateau) en
  /// reconstruisant le plateau complet à partir des pièces placées.
  /// À appeler avant de sélectionner une pièce du slider.
  void _cancelSelectedPlacedPieceIfAny() {
    if (state.selectedPlacedPiece == null) return;

    state = state.copyWith(
      plateau: _rebuildPlateauFromPlacedPieces(),
      clearSelectedPlacedPiece: true,
      clearPreview: true,
    );
  }

  bool _canPlacePieceWithoutChecker(PentoscopePlacedPiece placed) {
    debugPrint(
      '🔎 Vérification ${placed.piece.id} à gridX=${placed.gridX}, gridY=${placed.gridY}',
    );
    debugPrint('   Cells: ${placed.absoluteCells}');

    for (final cell in placed.absoluteCells) {
      // Vérifier les limites du plateau
      if (cell.x < 0 ||
          cell.x >= state.plateau.width ||
          cell.y < 0 ||
          cell.y >= state.plateau.height) {
        debugPrint(
          '   ❌ HORS LIMITES: ($cell.x, $cell.y) plateau=${state.plateau.width}×${state.plateau.height}',
        );
        return false;
      }

      // Vérifier chevauchement
      final cellValue = state.plateau.getCell(cell.x, cell.y);
      if (cellValue != 0 && cellValue != placed.piece.id) {
        debugPrint(
          '   ❌ CHEVAUCHEMENT: ($cell.x, $cell.y) occupée par $cellValue',
        );
        return false;
      }
    }

    debugPrint('   ✅ VALIDE');
    return true;
  }

  /// Cherche la position valide la plus proche autour de la mastercase
  /// Retourne null si aucune position valide n'est trouvée dans un rayon raisonnable
  Point? _findNearestValidPosition({
    required PentoscopePlacedPiece piece,
    required Point mastercaseAbs,
    required Point mastercaseLocal,
    int maxRadius = 5,
  }) {
    // Retirer temporairement la pièce du plateau pour la vérification
    final tempPlateau = Plateau.allVisible(
      state.plateau.width,
      state.plateau.height,
    );
    for (final p in state.placedPieces) {
      if (p.piece.id == piece.piece.id) continue; // Exclure la pièce transformée
      for (final cell in p.absoluteCells) {
        tempPlateau.setCell(cell.x, cell.y, p.piece.id);
      }
    }

    // Trouver la cellule de la mastercase dans la pièce transformée
    final transformedPosition = piece.piece.orientations[piece.positionIndex];
    final rawCoords = transformedPosition.map((cellNum) {
      final x = (cellNum - 1) % 5;
      final y = (cellNum - 1) ~/ 5;
      return Point(x, y);
    }).toList();

    final minX = rawCoords.map((p) => p.x).reduce((a, b) => a < b ? a : b);
    final minY = rawCoords.map((p) => p.y).reduce((a, b) => a < b ? a : b);
    final normalizedCoords = rawCoords
        .map((p) => Point(p.x - minX, p.y - minY))
        .toList();

    final mastercaseIndex = normalizedCoords
        .indexWhere((p) => p.x == mastercaseLocal.x && p.y == mastercaseLocal.y);
    if (mastercaseIndex == -1) {
      // La mastercase n'existe pas dans cette orientation
      return null;
    }

    final mastercaseRaw = rawCoords[mastercaseIndex];

    // Position initiale pour garder la mastercase fixe
    final initialGridX = mastercaseAbs.x - mastercaseRaw.x;
    final initialGridY = mastercaseAbs.y - mastercaseRaw.y;

    // Recherche en spirale autour de la position initiale
    for (int radius = 0; radius <= maxRadius; radius++) {
      // Générer toutes les positions à cette distance
      final candidates = <Point>[];
      
      if (radius == 0) {
        candidates.add(Point(initialGridX, initialGridY));
      } else {
        // Parcourir le périmètre du carré de rayon radius
        for (int dx = -radius; dx <= radius; dx++) {
          for (int dy = -radius; dy <= radius; dy++) {
            // Ne garder que les cases sur le périmètre (distance exacte = radius)
            if ((dx.abs() == radius || dy.abs() == radius)) {
              final testGridX = initialGridX + dx;
              final testGridY = initialGridY + dy;
              candidates.add(Point(testGridX, testGridY));
            }
          }
        }
      }

      // Tester chaque candidat
      for (final candidate in candidates) {
        final testPiece = piece.copyWith(
          gridX: candidate.x,
          gridY: candidate.y,
        );

        // Vérifier si cette position est valide
        bool isValid = true;
        for (final cell in testPiece.absoluteCells) {
          // Vérifier les limites
          if (cell.x < 0 ||
              cell.x >= state.plateau.width ||
              cell.y < 0 ||
              cell.y >= state.plateau.height) {
            isValid = false;
            break;
          }

          // Vérifier chevauchement
          final cellValue = tempPlateau.getCell(cell.x, cell.y);
          if (cellValue != 0 && cellValue != piece.piece.id) {
            isValid = false;
            break;
          }
        }

        if (isValid) {
          debugPrint('✅ Position valide trouvée à distance $radius: (${candidate.x}, ${candidate.y})');
          return candidate;
        }
      }
    }

    debugPrint('❌ Aucune position valide trouvée dans un rayon de $maxRadius');
    return null;
  }

  /// Trouve la position valide la plus proche du doigt
  /// dragGridX/Y = position du doigt sur le plateau
  /// Retourne la position d'ancre valide la plus proche
  /// 
  /// ✅ FIX: On cherche la position où la MASTERCASE serait la plus proche du doigt
  /// Si pas de mastercase définie, on utilise la première cellule normalisée
  Point? _findClosestValidPlacement(int dragGridX, int dragGridY) {
    if (state.validPlacements.isEmpty) return null;
    if (state.selectedPiece == null) return null;

    // Déterminer l'offset normalisé de la mastercase (ou 0,0 si pas définie)
    final mastercaseOffset = state.selectedCellInPiece ?? Point(0, 0);

    // Chercher le placement valide où la mastercase est la plus proche du doigt
    Point closest = state.validPlacements[0];
    double minDistance = double.infinity;

    for (final placement in state.validPlacements) {
      // Calculer où serait la mastercase pour ce placement
      final mastercaseX = placement.x + mastercaseOffset.x;
      final mastercaseY = placement.y + mastercaseOffset.y;
      
      // Distance entre le doigt et la mastercase
      final dx = (dragGridX - mastercaseX).toDouble();
      final dy = (dragGridY - mastercaseY).toDouble();
      final distance = dx * dx + dy * dy;

      if (distance < minDistance) {
        minDistance = distance;
        closest = placement;
      }
    }

    return closest;
  }

  /// Génère TOUS les placements possibles pour une pièce à une positionIndex donnée
  /// Retourne une liste de Point (gridX, gridY) où la pièce peut être placée
  List<Point> _generateValidPlacements(Pento piece, int positionIndex) {
    final validPlacements = <Point>[];
    

    // 🔧 FIX: Calculer les offsets de la pièce pour étendre le balayage
    // Certaines pièces ont des cellules avec des offsets positifs par rapport à l'ancre,
    // donc l'ancre peut être négative pour placer la pièce aux bords gauche/haut
    final position = piece.orientations[positionIndex];
    
    // Trouver les offsets min/max de la forme normalisée
    int minOffsetX = 5, minOffsetY = 5;
    int maxOffsetX = 0, maxOffsetY = 0;
    
    // D'abord calculer le min pour la normalisation (comme dans absoluteCells)
    int normMinX = 5, normMinY = 5;
    for (final cellNum in position) {
      final x = (cellNum - 1) % 5;
      final y = (cellNum - 1) ~/ 5;
      if (x < normMinX) normMinX = x;
      if (y < normMinY) normMinY = y;
    }
    
    // Puis calculer les offsets normalisés
    for (final cellNum in position) {
      final localX = (cellNum - 1) % 5 - normMinX;
      final localY = (cellNum - 1) ~/ 5 - normMinY;
      if (localX < minOffsetX) minOffsetX = localX;
      if (localY < minOffsetY) minOffsetY = localY;
      if (localX > maxOffsetX) maxOffsetX = localX;
      if (localY > maxOffsetY) maxOffsetY = localY;
    }

    // 🔧 FIX: Étendre le balayage pour inclure les positions d'ancre négatives
    // si nécessaire pour atteindre les bords du plateau
    // L'ancre peut aller de -maxOffset à (plateauSize - 1)
    final startX = -maxOffsetX;
    final startY = -maxOffsetY;
    final endX = state.plateau.width;
    final endY = state.plateau.height;

    for (int gridX = startX; gridX < endX; gridX++) {
      for (int gridY = startY; gridY < endY; gridY++) {
        if (state.canPlacePiece(piece, positionIndex, gridX, gridY)) {
          validPlacements.add(Point(gridX, gridY));
        }
      }
    }

    debugPrint('   → ${validPlacements.length} positions valides: $validPlacements');
    return validPlacements;
  }

  int _getMaxLocalX(PentoscopePlacedPiece piece) {
    return piece.absoluteCells.fold(
          0,
          (max, cell) => cell.x > max ? cell.x : max,
        ) -
        piece.gridX;
  }

  int _getMaxLocalY(PentoscopePlacedPiece piece) {
    return piece.absoluteCells.fold(
          0,
          (max, cell) => cell.y > max ? cell.y : max,
        ) -
        piece.gridY;
  }

  Plateau _rebuildPlateauFromPlacedPieces() {
    final newPlateau = Plateau.allVisible(
      state.plateau.width,
      state.plateau.height,
    );
    for (final p in state.placedPieces) {
      for (final cell in p.absoluteCells) {
        newPlateau.setCell(cell.x, cell.y, p.piece.id);
      }
    }
    return newPlateau;
  }

  // ========================================================================
  // ORIENTATION "VUE" (repère écran)
  // ========================================================================

  // ==========================================================================
  // ISOMÉTRIES (lookup robuste via Pento.cartesianCoords)
  // ==========================================================================

  /// Remapping de la cellule de référence lors d'une isométrie
  /// 
  /// ✅ Utilise maintenant la méthode du mixin (même implémentation)
  Point? _remapSelectedCell({
    required Pento piece,
    required int oldIndex,
    required int newIndex,
    required Point? oldCell,
  }) {
    return remapSelectedCell(
      piece: piece,
      oldIndex: oldIndex,
      newIndex: newIndex,
      oldCell: oldCell,
    );
  }

  // ============================================================================
  // MÉTHODES POUR TUTORIEL (ajoutées pour compatibilité)
  // ============================================================================

  /// Sélectionne une pièce depuis le slider (pour tutoriel)
  void selectPieceFromSliderForTutorial(int pieceNumber) {
    // pieceNumber commence à 1, mais les indices commencent à 0
    final pieceIndex = pieceNumber - 1;

    // Vérifier que l'index est valide
    if (pieceIndex < 0 || pieceIndex >= state.availablePieces.length) {
      print('[TUTORIAL] ⚠️ Pièce $pieceNumber invalide (index $pieceIndex)');
      return;
    }

    final piece = state.availablePieces[pieceIndex];
    selectPiece(piece);
    print('[TUTORIAL] ✅ Pièce $pieceNumber sélectionnée depuis slider');
  }

  /// Surligne une pièce dans le slider (pour tutoriel)
  void highlightPieceInSlider(int pieceNumber) {
    // Cette méthode est gérée par le widget PentoscopePieceSlider
    print('[TUTORIAL] ✅ Pièce $pieceNumber surlignée dans slider');
  }

  /// Efface le surlignage du slider (pour tutoriel)
  void clearSliderHighlight() {
    // Cette méthode est gérée par le widget PentoscopePieceSlider
    print('[TUTORIAL] ✅ Surlignage slider effacé');
  }

  /// Fait défiler le slider jusqu'à une pièce (pour tutoriel)
  void scrollSliderToPiece(int pieceNumber) {
    // Cette méthode est gérée par le widget PentoscopePieceSlider
    print('[TUTORIAL] ✅ Slider centré sur pièce $pieceNumber');
  }

  /// Place la pièce sélectionnée à une position donnée (pour tutoriel)
  void placeSelectedPieceForTutorial(int gridX, int gridY) {
    if (state.selectedPiece == null) {
      print('[TUTORIAL] ⚠️ Aucune pièce sélectionnée');
      return;
    }

    // Utiliser la méthode existante tryPlacePiece
    final success = tryPlacePiece(gridX, gridY);
    if (success) {
      print('[TUTORIAL] ✅ Pièce placée en ($gridX, $gridY)');
    } else {
      print('[TUTORIAL] ❌ Échec placement en ($gridX, $gridY)');
    }
  }

  /// Sélectionne une pièce placée sur le plateau (pour tutoriel)
  void selectPlacedPieceAt(int x, int y) {
    // Trouver la pièce aux coordonnées (x, y)
    for (final placed in state.placedPieces) {
      for (final cell in placed.absoluteCells) {
        if (cell.x == x && cell.y == y) {
          selectPlacedPiece(placed, x, y);
          print('[TUTORIAL] ✅ Pièce sélectionnée en ($x, $y)');
          return;
        }
      }
    }
    print('[TUTORIAL] ⚠️ Aucune pièce trouvée en ($x, $y)');
  }

  /// Applique une rotation autour de la mastercase (pour tutoriel)
  void rotateAroundMasterForTutorial(int pieceNumber, int quarterTurns) {
    // Cette logique devra être implémentée selon les besoins du tutoriel
    print('[TUTORIAL] ✅ Rotation pièce $pieceNumber de $quarterTurns quarts de tour');
  }
}

/// Pièce placée sur le plateau Pentoscope
class PentoscopePlacedPiece {
  final Pento piece;
  final int positionIndex;
  final int gridX;
  final int gridY;

  const PentoscopePlacedPiece({
    required this.piece,
    required this.positionIndex,
    required this.gridX,
    required this.gridY,
  });

  /// Coordonnées absolues des cellules occupées (normalisées)
  Iterable<Point> get absoluteCells sync* {
    final position = piece.orientations[positionIndex];

    // Trouver le décalage minimum pour normaliser
    int minLocalX = 5, minLocalY = 5;
    for (final cellNum in position) {
      final localX = (cellNum - 1) % 5;
      final localY = (cellNum - 1) ~/ 5;
      if (localX < minLocalX) minLocalX = localX;
      if (localY < minLocalY) minLocalY = localY;
    }

    for (final cellNum in position) {
      final localX = (cellNum - 1) % 5 - minLocalX;
      final localY = (cellNum - 1) ~/ 5 - minLocalY;
      yield Point(gridX + localX, gridY + localY);
    }
  }

  PentoscopePlacedPiece copyWith({
    Pento? piece,
    int? positionIndex,
    int? gridX,
    int? gridY,
  }) {
    return PentoscopePlacedPiece(
      piece: piece ?? this.piece,
      positionIndex: positionIndex ?? this.positionIndex,
      gridX: gridX ?? this.gridX,
      gridY: gridY ?? this.gridY,
    );
  }
}

/// État du jeu Pentoscope
class PentoscopeState {
  /// Orientation "vue" (repère écran). Ne change pas la logique.
  /// Sert à interpréter des actions (ex: Sym H/V) en paysage.
  final ViewOrientation viewOrientation;
  final PentoscopePuzzle? puzzle;
  final Plateau plateau;
  final List<Pento> availablePieces;
  final List<PentoscopePlacedPiece> placedPieces;

  // Sélection pièce du slider
  final Pento? selectedPiece;
  final int selectedPositionIndex;
  final Map<int, int> piecePositionIndices;

  // Sélection pièce placée
  final PentoscopePlacedPiece? selectedPlacedPiece;
  final Point? selectedCellInPiece; // Mastercase

  // Preview
  final int? previewX;
  final int? previewY;
  final bool isPreviewValid;

  // ✨ NOUVEAU: Liste des placements valides pour la pièce sélectionnée
  final List<Point> validPlacements;

  // État du jeu
  final bool isComplete;
  final int isometryCount;
  final int translationCount;
  final int hintCount;   // 💡 Nombre de fois où la lampe a été utilisée
  final int deleteCount; // 🗑️ Nombre de suppressions de pièces

  final bool isSnapped;
  final bool showSolution;
  final Solution? currentSolution;

  // 💡 HINT: Indique si au moins une solution est encore possible
  final bool hasPossibleSolution;

  // ⏱️ Timer
  final int elapsedSeconds;

  const PentoscopeState({
    this.viewOrientation = ViewOrientation.portrait,
    this.puzzle,
    required this.plateau,
    this.availablePieces = const [],
    this.placedPieces = const [],
    this.selectedPiece,
    this.selectedPositionIndex = 0,
    this.piecePositionIndices = const {},
    this.selectedPlacedPiece,
    this.selectedCellInPiece,
    this.previewX,
    this.previewY,
    this.isPreviewValid = false,
    this.validPlacements = const [], // ✨ NOUVEAU
    this.isComplete = false,
    this.isometryCount = 0,
    this.translationCount = 0,
    this.hintCount = 0,   // 💡
    this.deleteCount = 0, // 🗑️
    this.isSnapped = false,
    this.showSolution = false,
    this.currentSolution,
    this.hasPossibleSolution = true, // 💡 Par défaut true au démarrage
    this.elapsedSeconds = 0, // ⏱️ Timer
  });

  factory PentoscopeState.initial() {
    return PentoscopeState(
      plateau: Plateau.allVisible(5, 5),
      showSolution: false, // ✅ NOUVEAU
      currentSolution: null, // ✅ NOUVEAU
    );
  }

  bool canPlacePiece(Pento piece, int positionIndex, int gridX, int gridY) {
    final position = piece.orientations[positionIndex];

    // Trouver le décalage minimum pour normaliser la forme
    int minLocalX = 5, minLocalY = 5;
    for (final cellNum in position) {
      final localX = (cellNum - 1) % 5;
      final localY = (cellNum - 1) ~/ 5;
      if (localX < minLocalX) minLocalX = localX;
      if (localY < minLocalY) minLocalY = localY;
    }

    for (final cellNum in position) {
      final localX = (cellNum - 1) % 5 - minLocalX; // Normalisé
      final localY = (cellNum - 1) ~/ 5 - minLocalY; // Normalisé
      final x = gridX + localX;
      final y = gridY + localY;

      if (x < 0 || x >= plateau.width || y < 0 || y >= plateau.height) {
        return false;
      }

      final cellValue = plateau.getCell(x, y);
      if (cellValue != 0) {
        return false;
      }
    }

    return true;
  }

  PentoscopeState copyWith({
    ViewOrientation? viewOrientation,
    PentoscopePuzzle? puzzle,
    Plateau? plateau,
    List<Pento>? availablePieces,
    List<PentoscopePlacedPiece>? placedPieces,
    Pento? selectedPiece,
    bool clearSelectedPiece = false,
    int? selectedPositionIndex,
    Map<int, int>? piecePositionIndices,
    PentoscopePlacedPiece? selectedPlacedPiece,
    bool clearSelectedPlacedPiece = false,
    Point? selectedCellInPiece,
    bool clearSelectedCellInPiece = false,
    int? previewX,
    int? previewY,
    bool? isPreviewValid,
    bool clearPreview = false,
    List<Point>? validPlacements, // ✨ NOUVEAU
    bool? isComplete,
    int? isometryCount,
    int? translationCount,
    int? hintCount,   // 💡
    int? deleteCount, // 🗑️
    bool? isSnapped,
    bool? showSolution, // ✅ NOUVEAU
    Solution? currentSolution, // ✅ NOUVEAU
    bool? hasPossibleSolution, // 💡 HINT
    int? elapsedSeconds, // ⏱️ Timer
  }) {
    return PentoscopeState(
      viewOrientation: viewOrientation ?? this.viewOrientation,
      puzzle: puzzle ?? this.puzzle,
      plateau: plateau ?? this.plateau,
      availablePieces: availablePieces ?? this.availablePieces,
      placedPieces: placedPieces ?? this.placedPieces,
      selectedPiece: clearSelectedPiece
          ? null
          : (selectedPiece ?? this.selectedPiece),
      selectedPositionIndex:
          selectedPositionIndex ?? this.selectedPositionIndex,
      piecePositionIndices: piecePositionIndices ?? this.piecePositionIndices,
      selectedPlacedPiece: clearSelectedPlacedPiece
          ? null
          : (selectedPlacedPiece ?? this.selectedPlacedPiece),
      selectedCellInPiece: clearSelectedCellInPiece
          ? null
          : (selectedCellInPiece ?? this.selectedCellInPiece),
      previewX: clearPreview ? null : (previewX ?? this.previewX),
      previewY: clearPreview ? null : (previewY ?? this.previewY),
      isPreviewValid: clearPreview
          ? false
          : (isPreviewValid ?? this.isPreviewValid),
      validPlacements: validPlacements ?? this.validPlacements,
      // ✨ NOUVEAU
      isComplete: isComplete ?? this.isComplete,
      isometryCount: isometryCount ?? this.isometryCount,
      translationCount: translationCount ?? this.translationCount,
      hintCount: hintCount ?? this.hintCount,
      deleteCount: deleteCount ?? this.deleteCount,
      isSnapped: isSnapped ?? this.isSnapped,
      showSolution: showSolution ?? this.showSolution,
      // ✅ NOUVEAU
      currentSolution: currentSolution ?? this.currentSolution, // ✅ NOUVEAU
      hasPossibleSolution: hasPossibleSolution ?? this.hasPossibleSolution, // 💡 HINT
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds, // ⏱️ Timer
    );
  }

  int getPiecePositionIndex(int pieceId) {
    return piecePositionIndices[pieceId] ?? 0;
  }
}

/// Orientation "vue" (repère écran).
///
/// Important: le provider reste en coordonnées logiques. Cette info sert
/// uniquement à interpréter les actions utilisateur (ex: Sym H/V) pour que
/// le ressenti soit cohérent en paysage.
enum ViewOrientation { portrait, landscape }
