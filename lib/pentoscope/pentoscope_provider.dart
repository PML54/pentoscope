// lib/pentoscope/pentoscope_provider.dart
// Provider Pentoscope - calqué sur pentomino_game_provider
// CORRIGÉ: Bug de disparition des pièces (sync plateau/placedPieces)
import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pentapol/common/pentominos.dart';
import 'package:pentapol/common/plateau.dart';
import 'package:pentapol/common/point.dart';
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

class PentoscopeNotifier extends Notifier<PentoscopeState> {
  late final PentoscopeGenerator _generator;
  late final PentoscopeSolver _solver;
  
  // ⏱️ Timer
  Timer? _gameTimer;
  DateTime? _startTime;

  void applyIsometryRotationCW() {
    _applyIsoUsingLookup((p, idx) => p.rotationCW(idx));
  }

  void applyIsometryRotationTW() {
    _applyIsoUsingLookup((p, idx) => p.rotationTW(idx));
  }

  void applyIsometrySymmetryH() {
    if (state.viewOrientation == ViewOrientation.landscape) {
      _applyIsoUsingLookup((p, idx) => p.symmetryV(idx));
    } else {
      _applyIsoUsingLookup((p, idx) => p.symmetryH(idx));
    }
  }

  void applyIsometrySymmetryV() {
    if (state.viewOrientation == ViewOrientation.landscape) {
      _applyIsoUsingLookup((p, idx) => p.symmetryH(idx));
    } else {
      _applyIsoUsingLookup((p, idx) => p.symmetryV(idx));
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
    final newIndex = (state.selectedPositionIndex + 1) % piece.numPositions;
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

    // ⏱️ Reset et démarrer le timer
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
    
    startTimer();
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

    // Calculer la cellule locale cliquée (mastercase)
    final localX = absoluteX - placed.gridX;
    final localY = absoluteY - placed.gridY;

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
      selectedCellInPiece: Point(localX, localY),
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
      final randomPos = random.nextInt(piece.numPositions);
      piecePositionIndices[piece.id] = randomPos;
    }

    // ✅ TOUJOURS stocker la première solution (pour le calcul du score)
    Solution? firstSolution;
    if (showSolution && puzzle.solutions.isNotEmpty) {
      firstSolution = puzzle.solutions[0];

      for (final placement in firstSolution) {
        final pento = pentominos.firstWhere((p) => p.id == placement.pieceId);
        final initialPos = piecePositionIndices[placement.pieceId] ?? 0;

        final minIso = pento.minIsometriesToReach(
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
      final randomPos = random.nextInt(piece.numPositions);
      piecePositionIndices[piece.id] = randomPos;
    }

    // Reset timer
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
    
    startTimer();
  }

  // ==========================================================================
  // PLACEMENT
  // ==========================================================================

  bool tryPlacePiece(int gridX, int gridY) {
    if (state.selectedPiece == null) return false;

    final piece = state.selectedPiece!;
    final positionIndex = state.selectedPositionIndex;

    int anchorX = gridX;
    int anchorY = gridY;

    if (state.selectedCellInPiece != null) {
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

  void _applyIsoUsingLookup(int Function(Pento p, int idx) f) {
    final piece = state.selectedPiece;
    if (piece == null) return;

    final oldIdx = state.selectedPositionIndex;
    final newIdx = f(piece, oldIdx);
    final didChange = oldIdx != newIdx;

    if (!didChange) return;

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
      return;
    }

    // ========================================================================
    // CAS 2: Pièce PLACÉE sur plateau (VALIDATION REQUISE!)
    // ========================================================================

    final transformedPiece = sp.copyWith(positionIndex: newIdx);

    // ✨ Ajuster gridX ET gridY si nécessaire
    int adjustedGridX = sp.gridX;
    int adjustedGridY = sp.gridY;

    // Ajuster X
    while (adjustedGridX > 0 &&
        (adjustedGridX + _getMaxLocalX(transformedPiece) >=
            state.plateau.width)) {
      adjustedGridX--;
    }

    // Ajuster Y
    while (adjustedGridY > 0 &&
        (adjustedGridY + _getMaxLocalY(transformedPiece) >=
            state.plateau.height)) {
      adjustedGridY--;
    }

    final finalPiece = transformedPiece.copyWith(
      gridX: adjustedGridX,
      gridY: adjustedGridY,
    );

    debugPrint(
      '✏️  Ajusté: (${sp.gridX},${sp.gridY}) → ($adjustedGridX,$adjustedGridY)',
    );

    if (!_canPlacePieceWithoutChecker(finalPiece)) {
      HapticFeedback.heavyImpact();
      return;
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

    state = state.copyWith(
      plateau: newPlateau,
      selectedPlacedPiece: finalPiece,  // ← Mettre à jour!
      placedPieces: updatedPlacedPieces,
      selectedPositionIndex: newIdx,
      selectedCellInPiece: _remapSelectedCell(
        piece: piece,
        oldIndex: oldIdx,
        newIndex: newIdx,
        oldCell: state.selectedCellInPiece,
      ),
      clearPreview: true,
      isometryCount: state.isometryCount + 1,
      hasPossibleSolution: hasPossibleSolution, // 💡 Mise à jour!
    );
  }

  /// Helper: calcule la mastercase par défaut (première cellule normalisée)
  Point? _calculateDefaultCell(Pento piece, int positionIndex) {
    final position = piece.positions[positionIndex];
    if (position.isEmpty) return null;

    int minX = 5, minY = 5;
    for (final cellNum in position) {
      final x = (cellNum - 1) % 5;
      final y = (cellNum - 1) ~/ 5;
      if (x < minX) minX = x;
      if (y < minY) minY = y;
    }
    final firstCellNum = position[0];
    final rawX = (firstCellNum - 1) % 5;
    final rawY = (firstCellNum - 1) ~/ 5;
    return Point(rawX - minX, rawY - minY);
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

  /// Trouve la position valide la plus proche du doigt
  /// dragGridX/Y = position du doigt sur le plateau
  /// Retourne la position d'ancre valide la plus proche
  /// 
  /// 🔧 FIX: On cherche la position où N'IMPORTE QUELLE cellule de la pièce
  /// serait la plus proche du doigt, pas seulement la mastercase.
  /// Cela permet de déplacer la pièce dans toutes les directions même si
  /// la mastercase est sur un bord de la pièce.
  Point? _findClosestValidPlacement(int dragGridX, int dragGridY) {
    if (state.validPlacements.isEmpty) return null;
    if (state.selectedPiece == null) return null;

    final piece = state.selectedPiece!;
    final positionIndex = state.selectedPositionIndex;
    
    // Calculer les offsets normalisés des cellules de la pièce
    final position = piece.positions[positionIndex];
    int normMinX = 5, normMinY = 5;
    for (final cellNum in position) {
      final x = (cellNum - 1) % 5;
      final y = (cellNum - 1) ~/ 5;
      if (x < normMinX) normMinX = x;
      if (y < normMinY) normMinY = y;
    }
    
    final cellOffsets = <Point>[];
    for (final cellNum in position) {
      final localX = (cellNum - 1) % 5 - normMinX;
      final localY = (cellNum - 1) ~/ 5 - normMinY;
      cellOffsets.add(Point(localX, localY));
    }

    // Chercher le placement valide où UNE cellule est la plus proche du doigt
    Point closest = state.validPlacements[0];
    double minDistance = double.infinity;

    for (final placement in state.validPlacements) {
      // Pour ce placement, calculer la distance minimale entre le doigt
      // et n'importe quelle cellule de la pièce
      for (final offset in cellOffsets) {
        final cellX = placement.x + offset.x;
        final cellY = placement.y + offset.y;
        final dx = (dragGridX - cellX).toDouble();
        final dy = (dragGridY - cellY).toDouble();
        final distance = dx * dx + dy * dy;

        if (distance < minDistance) {
          minDistance = distance;
          closest = placement;
        }
      }
    }

    // Log pour pièce 12 verticale seulement
    if (piece.id == 12 && positionIndex == 0) {
      debugPrint('🎯 Snap pièce 12 verticale: doigt=($dragGridX,$dragGridY) → ancre=(${closest.x},${closest.y}) dist=${minDistance.toStringAsFixed(1)}');
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
    final position = piece.positions[positionIndex];
    
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

  Point? _remapSelectedCell({
    required Pento piece,
    required int oldIndex,
    required int newIndex,
    required Point? oldCell,
  }) {
    if (oldCell == null) return null;

    // Coordonnées normalisées dans l'ordre STABLE des cellules (positions)
    List<Point> coordsInPositionOrder(int posIdx) {
      final cellNums = piece.positions[posIdx];

      final raw = cellNums.map((cellNum) {
        final x = (cellNum - 1) % 5;
        final y = (cellNum - 1) ~/ 5;
        return Point(x, y);
      }).toList();

      final minX = raw.map((p) => p.x).reduce((a, b) => a < b ? a : b);
      final minY = raw.map((p) => p.y).reduce((a, b) => a < b ? a : b);

      // normalisation SANS trier (on garde l'identité géométrique)
      return raw.map((p) => Point(p.x - minX, p.y - minY)).toList();
    }

    final oldCoords = coordsInPositionOrder(oldIndex);

    // retrouve l'indice géométrique stable (0..4)
    final k = oldCoords.indexWhere((p) => p.x == oldCell.x && p.y == oldCell.y);
    if (k < 0) return oldCell; // sécurité

    final newCoords = coordsInPositionOrder(newIndex);
    return newCoords[k];
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
    final position = piece.positions[positionIndex];

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
    final position = piece.positions[positionIndex];

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
