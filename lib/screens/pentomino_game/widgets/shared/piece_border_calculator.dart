// lib/screens/pentomino_game/widgets/shared/piece_border_calculator.dart
// Calcul des bordures de pièces sur le plateau

import 'package:flutter/material.dart';
import 'package:pentapol/common/plateau.dart';
import 'package:pentapol/screens/pentomino_game/utils/game_colors.dart';
import 'package:pentapol/screens/pentomino_game/utils/game_constants.dart';

/// Calcule les bordures d'une cellule sur le plateau
/// 
/// Affiche des bordures épaisses aux frontières entre pièces différentes
/// et des bordures fines à l'intérieur d'une même pièce.
/// 
/// En mode paysage, les bordures sont adaptées à la rotation visuelle.
class PieceBorderCalculator {
  PieceBorderCalculator._(); // Private constructor

  /// Construit un contour de pièce sur le plateau
  /// 
  /// [x], [y] : coordonnées logiques (toujours 6×10)
  /// [plateau] : le plateau de jeu
  /// [isLandscape] : true si en mode paysage (rotation 90° anti-horaire)
  static Border calculate(int x, int y, Plateau plateau, bool isLandscape) {
    const width = GameConstants.boardWidth;
    const height = GameConstants.boardHeight;

    final int id = plateau.getCell(x, y);
    // On considère 0 et -1 comme "pas de pièce"
    final int baseId = id > 0 ? id : 0;

    int neighborId(int nx, int ny) {
      if (nx < 0 || nx >= width || ny < 0 || ny >= height) return 0;
      final v = plateau.getCell(nx, ny);
      return v > 0 ? v : 0;
    }

    // Récupérer les IDs des voisins en coordonnées logiques
    final idLogicalTop = neighborId(x, y - 1);
    final idLogicalBottom = neighborId(x, y + 1);
    final idLogicalLeft = neighborId(x - 1, y);
    final idLogicalRight = neighborId(x + 1, y);

    const borderWidthOuter = GameConstants.pieceBorderWidthOuter;
    const borderWidthInner = GameConstants.pieceBorderWidthInner;

    // En paysage, rotation 90° anti-horaire :
    // - top visuel → right logique
    // - right visuel → bottom logique
    // - bottom visuel → left logique
    // - left visuel → top logique
    if (isLandscape) {
      return Border(
        top: BorderSide(
          color: (idLogicalRight != baseId) 
              ? GameColors.pieceBorderColor 
              : GameColors.pieceBorderLightColor,
          width: (idLogicalRight != baseId) ? borderWidthOuter : borderWidthInner,
        ),
        bottom: BorderSide(
          color: (idLogicalLeft != baseId) 
              ? GameColors.pieceBorderColor 
              : GameColors.pieceBorderLightColor,
          width: (idLogicalLeft != baseId) ? borderWidthOuter : borderWidthInner,
        ),
        left: BorderSide(
          color: (idLogicalTop != baseId) 
              ? GameColors.pieceBorderColor 
              : GameColors.pieceBorderLightColor,
          width: (idLogicalTop != baseId) ? borderWidthOuter : borderWidthInner,
        ),
        right: BorderSide(
          color: (idLogicalBottom != baseId) 
              ? GameColors.pieceBorderColor 
              : GameColors.pieceBorderLightColor,
          width: (idLogicalBottom != baseId) ? borderWidthOuter : borderWidthInner,
        ),
      );
    } else {
      // Portrait : bordures normales
      return Border(
        top: BorderSide(
          color: (idLogicalTop != baseId) 
              ? GameColors.pieceBorderColor 
              : GameColors.pieceBorderLightColor,
          width: (idLogicalTop != baseId) ? borderWidthOuter : borderWidthInner,
        ),
        bottom: BorderSide(
          color: (idLogicalBottom != baseId) 
              ? GameColors.pieceBorderColor 
              : GameColors.pieceBorderLightColor,
          width: (idLogicalBottom != baseId) ? borderWidthOuter : borderWidthInner,
        ),
        left: BorderSide(
          color: (idLogicalLeft != baseId) 
              ? GameColors.pieceBorderColor 
              : GameColors.pieceBorderLightColor,
          width: (idLogicalLeft != baseId) ? borderWidthOuter : borderWidthInner,
        ),
        right: BorderSide(
          color: (idLogicalRight != baseId) 
              ? GameColors.pieceBorderColor 
              : GameColors.pieceBorderLightColor,
          width: (idLogicalRight != baseId) ? borderWidthOuter : borderWidthInner,
        ),
      );
    }
  }
}

