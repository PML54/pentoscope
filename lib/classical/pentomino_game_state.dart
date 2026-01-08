// Modified: 2025-12-01 (Snap intelligent ajouté)
// lib/providers/pentomino_game_state.dart
// État du jeu de pentominos (mode libre + mode tutoriel)

import 'package:flutter/material.dart';
import 'package:pentapol/common/pentominos.dart';
import 'package:pentapol/common/placed_piece.dart';
import 'package:pentapol/common/plateau.dart';
import 'package:pentapol/common/point.dart';

/// État du jeu de pentominos
class PentominoGameState {
  final Plateau plateau;
  final List<Pento> availablePieces; // Pièces encore disponibles dans le slider
  final List<PlacedPiece> placedPieces; // Pièces déjà placées sur le plateau
  final Pento?
  selectedPiece; // Pièce actuellement sélectionnée (en cours de drag)
  final int selectedPositionIndex; // Position de la pièce sélectionnée
  final PlacedPiece?
  selectedPlacedPiece; // Référence à la pièce placée sélectionnée
  final Map<int, int>
  piecePositionIndices; // Index de position pour chaque pièce (par ID)
  final Point?
  selectedCellInPiece; // Case sélectionnée dans la pièce (point de référence pour le drag)

  // Prévisualisation du placement
  final int? previewX; // Position X de la preview
  final int? previewY; // Position Y de la preview
  final bool isPreviewValid; // La preview est-elle un placement valide ?
  final bool isSnapped; // 🆕 La preview est-elle "aimantée" (snap) ?

  // Validation du plateau
  final bool boardIsValid; // true si pas de chevauchement ni débordement
  final Set<Point>
  overlappingCells; // Cases où au moins 2 pièces se chevauchent
  final Set<Point> offBoardCells; // Cases de pièces en dehors du plateau

  // Nombre de solutions possibles
  final int? solutionsCount; // Nombre de solutions possibles avec l'état actuel

  // 🆕 Index de la solution trouvée (quand puzzle complété)
  final int? solvedSolutionIndex; // null = non résolu, 0-9355 = index de la solution

  // Mode isométries
  final bool
  isIsometriesMode; // true = mode isométries, false = mode jeu normal
  final PentominoGameState?
  savedGameState; // État du jeu sauvegardé (isométries OU tutoriel)

  // 🆕 MODE TUTORIEL
  final bool isInTutorial; // true = en mode tutoriel, false = jeu normal

  // 🆕 HIGHLIGHTS TUTORIEL
  final int?
  highlightedSliderPiece; // ID de la pièce surlignée dans le slider (null = aucune)
  final int?
  highlightedBoardPiece; // ID de la pièce surlignée sur le plateau (null = aucune)
  final Point?
  highlightedMastercase; // Position de la mastercase surlignée (null = aucune)
  final Map<Point, Color>
  cellHighlights; // Highlights de cases individuelles avec couleur
  final String?
  highlightedIsometryIcon; // Icône d'isométrie surlignée ('rotation', 'rotation_cw', 'symmetry_h', 'symmetry_v')

  // 🆕 SLIDER POSITION
  final int
  sliderOffset; // Offset de défilement du slider (0 = position initiale)

  // 🆕 ORIENTATION
  final ViewOrientation viewOrientation; // portrait ou landscape
  final int elapsedSeconds;

  // 🆕 COMPTEURS DE SESSION
  final int isometriesCount; // Nombre d'isométries appliquées pendant la session
  final int solutionsViewCount; // Nombre de fois où le user a consulté les solutions
  PentominoGameState({
    required this.plateau,
    required this.availablePieces,
    required this.placedPieces,
    this.selectedPiece,
    this.selectedPositionIndex = 0,
    this.selectedPlacedPiece,
    Map<int, int>? piecePositionIndices,
    this.selectedCellInPiece,
    this.previewX,
    this.previewY,
    this.isPreviewValid = false,
    this.isSnapped = false, // 🆕
    this.solutionsCount,
    this.solvedSolutionIndex, // 🆕
    this.isIsometriesMode = false,
    this.savedGameState,

    // Validation
    this.boardIsValid = true,
    Set<Point>? overlappingCells,
    Set<Point>? offBoardCells,

    // 🆕 Tutoriel
    this.isInTutorial = false,
    this.highlightedSliderPiece,
    this.highlightedBoardPiece,
    this.highlightedMastercase,
    Map<Point, Color>? cellHighlights,
    this.sliderOffset = 0,
    this.highlightedIsometryIcon,
    this.viewOrientation = ViewOrientation.portrait,
    this.elapsedSeconds = 0,
    this.isometriesCount = 0,
    this.solutionsViewCount = 0,
  }) : piecePositionIndices = piecePositionIndices ?? {},
       overlappingCells = overlappingCells ?? <Point>{},
       offBoardCells = offBoardCells ?? <Point>{},
       cellHighlights = cellHighlights ?? <Point, Color>{};

  /// État initial du jeu
  factory PentominoGameState.initial() {
    return PentominoGameState(
      plateau: Plateau.allVisible(6, 10),
      availablePieces: List.from(pentominos),
      placedPieces: [],
      selectedPiece: null,
      selectedPositionIndex: 0,
      piecePositionIndices: {},
      boardIsValid: true,
      overlappingCells: <Point>{},
      offBoardCells: <Point>{},
      isInTutorial: false,
      sliderOffset: 0,
      cellHighlights: <Point, Color>{},
      viewOrientation: ViewOrientation.portrait,
      elapsedSeconds: 0, // ✨ NOUVEAU
    );
  }

  /// Vérifie si une pièce peut être placée à une position donnée
  bool canPlacePiece(Pento piece, int positionIndex, int gridX, int gridY) {
    final position = piece.positions[positionIndex];

    for (final cellNum in position) {
      // Convertir cellNum (1-25 sur grille 5×5) en coordonnées (x, y)
      final localX = (cellNum - 1) % 5;
      final localY = (cellNum - 1) ~/ 5;

      // Position absolue sur le plateau
      final x = gridX + localX;
      final y = gridY + localY;

      // Hors limites ?
      if (x < 0 || x >= 6 || y < 0 || y >= 10) {
        return false;
      }

      // Case déjà occupée ?
      final cellValue = plateau.getCell(x, y);
      if (cellValue != 0) {
        return false;
      }
    }

    return true;
  }

  PentominoGameState copyWith({
    Plateau? plateau,
    List<Pento>? availablePieces,
    List<PlacedPiece>? placedPieces,
    Pento? selectedPiece,
    bool clearSelectedPiece = false,
    int? selectedPositionIndex,
    PlacedPiece? selectedPlacedPiece,
    bool clearSelectedPlacedPiece = false,
    Map<int, int>? piecePositionIndices,
    Point? selectedCellInPiece,
    bool clearSelectedCellInPiece = false,
    int? previewX,
    int? previewY,
    bool? isPreviewValid,
    bool? isSnapped, // 🆕
    bool clearPreview = false,
    int? solutionsCount,
    int? solvedSolutionIndex, // 🆕
    bool clearSolvedSolutionIndex = false, // 🆕
    bool? isIsometriesMode,
    PentominoGameState? savedGameState,
    bool clearSavedGameState = false,

    // Validation
    bool? boardIsValid,
    Set<Point>? overlappingCells,
    Set<Point>? offBoardCells,

    // 🆕 Tutoriel
    bool? isInTutorial,
    int? highlightedSliderPiece,
    bool clearHighlightedSliderPiece = false,
    int? highlightedBoardPiece,
    bool clearHighlightedBoardPiece = false,
    Point? highlightedMastercase,
    bool clearHighlightedMastercase = false,
    Map<Point, Color>? cellHighlights,
    bool clearCellHighlights = false,
    int? sliderOffset,
    String? highlightedIsometryIcon,
    bool clearHighlightedIsometryIcon = false,
    ViewOrientation? viewOrientation,

    // Timer et compteurs
    int? elapsedSeconds,
    int? isometriesCount,
    int? solutionsViewCount,
  }) {
    return PentominoGameState(
      plateau: plateau ?? this.plateau,
      availablePieces: availablePieces ?? this.availablePieces,
      placedPieces: placedPieces ?? this.placedPieces,
      selectedPiece: clearSelectedPiece
          ? null
          : (selectedPiece ?? this.selectedPiece),
      selectedPositionIndex:
          selectedPositionIndex ?? this.selectedPositionIndex,
      selectedPlacedPiece: clearSelectedPlacedPiece
          ? null
          : (selectedPlacedPiece ?? this.selectedPlacedPiece),
      piecePositionIndices: piecePositionIndices ?? this.piecePositionIndices,
      selectedCellInPiece: clearSelectedCellInPiece
          ? null
          : (selectedCellInPiece ?? this.selectedCellInPiece),
      previewX: clearPreview ? null : (previewX ?? this.previewX),
      previewY: clearPreview ? null : (previewY ?? this.previewY),
      isPreviewValid: clearPreview
          ? false
          : (isPreviewValid ?? this.isPreviewValid),
      isSnapped: clearPreview ? false : (isSnapped ?? this.isSnapped),
      // 🆕
      solutionsCount: solutionsCount ?? this.solutionsCount,
      solvedSolutionIndex: clearSolvedSolutionIndex
          ? null
          : (solvedSolutionIndex ?? this.solvedSolutionIndex), // 🆕
      isIsometriesMode: isIsometriesMode ?? this.isIsometriesMode,
      savedGameState: clearSavedGameState
          ? null
          : (savedGameState ?? this.savedGameState),

      // Validation
      boardIsValid: boardIsValid ?? this.boardIsValid,
      overlappingCells: overlappingCells ?? this.overlappingCells,
      offBoardCells: offBoardCells ?? this.offBoardCells,

      // 🆕 Tutoriel
      isInTutorial: isInTutorial ?? this.isInTutorial,
      highlightedSliderPiece: clearHighlightedSliderPiece
          ? null
          : (highlightedSliderPiece ?? this.highlightedSliderPiece),
      highlightedBoardPiece: clearHighlightedBoardPiece
          ? null
          : (highlightedBoardPiece ?? this.highlightedBoardPiece),
      highlightedMastercase: clearHighlightedMastercase
          ? null
          : (highlightedMastercase ?? this.highlightedMastercase),
      cellHighlights: clearCellHighlights
          ? <Point, Color>{}
          : (cellHighlights ?? this.cellHighlights),
      sliderOffset: sliderOffset ?? this.sliderOffset,
      highlightedIsometryIcon: clearHighlightedIsometryIcon
          ? null
          : (highlightedIsometryIcon ?? this.highlightedIsometryIcon),
      viewOrientation: viewOrientation ?? this.viewOrientation,

      // Timer et compteurs
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      isometriesCount: isometriesCount ?? this.isometriesCount,
      solutionsViewCount: solutionsViewCount ?? this.solutionsViewCount,
    );
  }

  /// Obtient l'index de position pour une pièce (par défaut 0)
  int getPiecePositionIndex(int pieceId) {
    return piecePositionIndices[pieceId] ?? 0;
  }
}

/// Orientation de la vue (repère écran)
enum ViewOrientation { portrait, landscape }
