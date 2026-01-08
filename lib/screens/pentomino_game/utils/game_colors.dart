// lib/screens/pentomino_game/utils/game_colors.dart
// Couleurs pour le jeu de pentominos

import 'package:flutter/material.dart';

/// Couleurs du jeu
class GameColors {
  GameColors._(); // Private constructor

  // Couleurs de mode
  static final Color normalModeAppBarColor = Colors.indigo.shade700;
  static final Color isometriesModeAppBarColor = Colors.deepPurple.shade700;
  static final Color isometriesModeBackgroundColor = Colors.deepPurple.shade100;
  
  // Couleurs de cellules
  static final Color hiddenCellColor = Colors.grey.shade800;
  static final Color emptyCellColor = Colors.grey.shade300;
  static final Color boardBackgroundStart = Colors.grey.shade50;
  static final Color boardBackgroundEnd = Colors.grey.shade100;
  
  // Couleurs de sélection et preview
  static const Color masterCellBorderColor = Colors.red;
  static const Color selectedPieceBorderColor = Colors.amber;
  static final Color selectedPieceBackgroundColor = Colors.amber.shade100;
  static final Color selectedPieceBorderStrongColor = Colors.amber.shade700;
  
  static const Color previewValidColor = Colors.green;
  static const Color previewInvalidColor = Colors.red;
  static final Color previewValidTextColor = Colors.green.shade900;
  static final Color previewInvalidTextColor = Colors.red.shade900;
  
  // Couleurs de bordures de pièces
  static const Color pieceBorderColor = Colors.black;
  static final Color pieceBorderLightColor = Colors.grey.shade400;
  static const Color pieceInnerBorderColor = Colors.white;
  
  // Couleurs de texte
  static const Color pieceTextColor = Colors.white;
  static const Color normalTextColor = Colors.white;
  
  // Couleurs de compteur de solutions
  static final Color solutionsFoundColor = Colors.green.shade700;
  static final Color noSolutionsColor = Colors.red.shade700;
  
  // Couleurs d'ombres
  static Color shadowColor = Colors.black.withValues(alpha: 0.1);
  static Color shadowColorDark = Colors.black.withValues(alpha: 0.2);
  static Color shadowColorLight = Colors.black.withValues(alpha: 0.05);
  static Color draggingShadowColor = Colors.black.withValues(alpha: 0.3);
  
  // Couleurs de fond
  static final Color sliderBackgroundColor = Colors.grey.shade100;
  static final Color toolbarBackgroundColor = Colors.grey.shade200;
  
  /// Obtenir la couleur d'une pièce par son ID
  /// Note: Cette méthode sera remplacée par settings.ui.getPieceColor(pieceId)
  /// dans le code qui utilise le SettingsProvider
  static Color getPieceColorFallback(int pieceId) {
    const colors = [
      Colors.black,     // 1
      Colors.blue,      // 2
      Colors.green,     // 3
      Colors.orange,    // 4
      Colors.red,       // 5
      Colors.teal,      // 6
      Colors.pink,      // 7
      Colors.brown,     // 8
      Colors.indigo,    // 9
      Colors.lime,      // 10
      Colors.cyan,      // 11
      Colors.amber,     // 12
    ];
    
    if (pieceId >= 1 && pieceId <= 12) {
      return colors[pieceId - 1];
    }
    return Colors.grey;
  }
}

