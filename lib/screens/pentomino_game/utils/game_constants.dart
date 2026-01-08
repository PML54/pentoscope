// lib/screens/pentomino_game/utils/game_constants.dart
// Constantes pour le jeu de pentominos

/// Constantes du plateau et du jeu
class GameConstants {
  GameConstants._(); // Private constructor pour empêcher l'instanciation

  // Dimensions du plateau
  static const int boardWidth = 6;
  static const int boardHeight = 10;
  static const int totalCells = boardWidth * boardHeight; // 60

  // Dimensions de la grille de pièce (5×5)
  static const int pieceGridSize = 5;

  // Bordures
  static const double masterCellBorderWidth = 4.0;
  static const double selectedPieceBorderWidth = 3.0;
  static const double previewBorderWidth = 3.0;
  static const double cellBorderWidth = 1.0;
  static const double pieceBorderWidthOuter = 2.0;
  static const double pieceBorderWidthInner = 0.5;

  // Slider
  static const double sliderItemSize = 140.0; // padding + width/height approximative (cellSize 22 × 5 + padding)
  static const int sliderItemsPerPage = 1000; // Pour le scroll infini

  // Animations et feedback
  static const int doubleTapDelayMs = 300;
  
  // Ombres
  static const double shadowBlurRadius = 10.0;
  static const double shadowOffsetY = 5.0;
  static const double shadowOpacity = 0.3;
}

