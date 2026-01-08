// lib/config/ui_sizes_config.dart
// Configuration centralisée des tailles UI (icônes, textes, espacements)
// Créé: 2024-12-31

import 'package:flutter/material.dart';

/// Configuration des tailles UI pour l'application
class UISizes {
  UISizes._();

  // ============================================================================
  // ICÔNES
  // ============================================================================

  /// Taille des icônes dans l'AppBar (croix, hint, etc.)
  static const double appBarIconSize = 35.0;

  /// Taille des icônes d'isométrie (rotation, symétrie)
  static const double isometryIconSize = 55.0;

  /// Taille de l'icône poubelle (delete)
  static const double deleteIconSize = 26.0;

  /// Taille des petites icônes (indicateurs)
  static const double smallIconSize = 22.0;

  // ============================================================================
  // TEXTES
  // ============================================================================

  /// Taille du chronomètre
  static const double timerFontSize = 14.0;

  /// Taille du score
  static const double scoreFontSize = 10.0;

  /// Taille du compteur de solutions
  static const double solutionsCountFontSize = 15.0;

  /// Taille des labels dans les boutons
  static const double buttonLabelFontSize = 12.0;

  // ============================================================================
  // ESPACEMENTS AppBar
  // ============================================================================

  /// Largeur du leading (croix + chrono)
  static const double appBarLeadingWidth = 100.0;

  /// Hauteur de l'AppBar
  static const double appBarHeight = 56.0;

  /// Espacement entre les icônes d'isométrie
  static const double isometryIconSpacing = 4.0;

  // ============================================================================
  // CONTRAINTES
  // ============================================================================

  /// Taille minimale des boutons d'icône
  static const double iconButtonMinSize = 40.0;

  /// Contraintes pour les icônes compactes
  static BoxConstraints get compactIconConstraints => const BoxConstraints(
        minWidth: 36,
        minHeight: 36,
      );

  /// Contraintes pour les icônes d'isométrie
  static BoxConstraints get isometryIconConstraints => const BoxConstraints(
        minWidth: 40,
        minHeight: 40,
      );

  // ============================================================================
  // PADDINGS
  // ============================================================================

  /// Padding des icônes compactes
  static const EdgeInsets compactIconPadding = EdgeInsets.zero;

  /// Padding des icônes d'isométrie
  static const EdgeInsets isometryIconPadding = EdgeInsets.symmetric(horizontal: 2);
}



