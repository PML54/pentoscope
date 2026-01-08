// lib/config/ui_dimensions.dart
// Classes de données pour les dimensions UI adaptatives
// Créé: 2024-12-31

import 'package:flutter/material.dart';

/// Type d'appareil détecté
enum DeviceType {
  phone,       // < 600px de largeur
  tablet,      // 600-1000px
  largeTablet, // > 1000px (iPad Pro, etc.)
}

/// Orientation de l'écran
enum ScreenOrientation {
  portrait,
  landscape,
}

/// Dimensions du plateau de jeu
class BoardDimensions {
  /// Taille d'une cellule du plateau (en pixels)
  final double cellSize;
  
  /// Largeur totale du plateau (cellSize × colonnes)
  final double width;
  
  /// Hauteur totale du plateau (cellSize × lignes)
  final double height;
  
  /// Marge horizontale autour du plateau
  final double horizontalMargin;
  
  /// Épaisseur de la bordure
  final double borderWidth;
  
  /// Rayon des coins arrondis
  final double borderRadius;
  
  /// Nombre de colonnes visuelles
  final int visualCols;
  
  /// Nombre de lignes visuelles
  final int visualRows;

  const BoardDimensions({
    required this.cellSize,
    required this.width,
    required this.height,
    required this.horizontalMargin,
    required this.borderWidth,
    required this.borderRadius,
    required this.visualCols,
    required this.visualRows,
  });

  /// Dimensions par défaut (fallback)
  static const BoardDimensions defaults = BoardDimensions(
    cellSize: 40,
    width: 240,
    height: 400,
    horizontalMargin: 4,
    borderWidth: 3,
    borderRadius: 16,
    visualCols: 6,
    visualRows: 10,
  );
}

/// Dimensions du slider de pièces
class SliderDimensions {
  /// Largeur du slider (en paysage) ou null
  final double? width;
  
  /// Hauteur du slider (en portrait) ou null
  final double? height;
  
  /// Taille fixe d'un item (carré 5×5 pour contenir toute pièce)
  final double itemSize;
  
  /// Taille d'une cellule de pièce dans le slider
  final double pieceCellSize;
  
  /// Padding entre les pièces
  final EdgeInsets itemPadding;
  
  /// Padding global du slider
  final EdgeInsets sliderPadding;

  const SliderDimensions({
    this.width,
    this.height,
    required this.itemSize,
    required this.pieceCellSize,
    required this.itemPadding,
    required this.sliderPadding,
  });

  /// Dimensions par défaut
  static const SliderDimensions defaults = SliderDimensions(
    width: 140,
    height: 170,
    itemSize: 118,
    pieceCellSize: 22,
    itemPadding: EdgeInsets.all(4),
    sliderPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  );
}

/// Dimensions des barres d'actions (isométries, fonctionnement)
class ActionBarDimensions {
  /// Largeur de la colonne d'actions (en paysage)
  final double width;
  
  /// Taille des icônes
  final double iconSize;
  
  /// Padding autour de chaque icône
  final EdgeInsets iconPadding;
  
  /// Espacement vertical entre les icônes
  final double iconSpacing;
  
  /// Taille minimale de la zone cliquable
  final double buttonMinSize;
  
  /// Contraintes pour les IconButton
  BoxConstraints get buttonConstraints => BoxConstraints(
    minWidth: buttonMinSize,
    minHeight: buttonMinSize,
  );

  const ActionBarDimensions({
    required this.width,
    required this.iconSize,
    required this.iconPadding,
    required this.iconSpacing,
    required this.buttonMinSize,
  });

  /// Dimensions par défaut
  static const ActionBarDimensions defaults = ActionBarDimensions(
    width: 44,
    iconSize: 24,
    iconPadding: EdgeInsets.all(6),
    iconSpacing: 8,
    buttonMinSize: 36,
  );
}

/// Dimensions typographiques
class TextDimensions {
  /// Taille police du chronomètre
  final double timerFontSize;
  
  /// Taille police du score
  final double scoreFontSize;
  
  /// Taille police des labels généraux
  final double labelFontSize;
  
  /// Taille police des numéros de pièces (sur le plateau)
  final double pieceNumberFontSize;

  const TextDimensions({
    required this.timerFontSize,
    required this.scoreFontSize,
    required this.labelFontSize,
    required this.pieceNumberFontSize,
  });

  /// Dimensions par défaut
  static const TextDimensions defaults = TextDimensions(
    timerFontSize: 14,
    scoreFontSize: 18,
    labelFontSize: 12,
    pieceNumberFontSize: 14,
  );
}

/// Container principal regroupant toutes les dimensions UI
class UILayout {
  /// Type d'appareil détecté
  final DeviceType deviceType;
  
  /// Orientation actuelle
  final ScreenOrientation orientation;
  
  /// Facteur d'échelle global (1.0 = phone, 1.2 = tablet, 1.4 = largeTablet)
  final double scaleFactor;
  
  /// Dimensions du plateau
  final BoardDimensions board;
  
  /// Dimensions du slider
  final SliderDimensions slider;
  
  /// Dimensions de la barre d'actions
  final ActionBarDimensions actionBar;
  
  /// Dimensions typographiques
  final TextDimensions text;
  
  /// Largeur de l'écran
  final double screenWidth;
  
  /// Hauteur de l'écran
  final double screenHeight;

  const UILayout({
    required this.deviceType,
    required this.orientation,
    required this.scaleFactor,
    required this.board,
    required this.slider,
    required this.actionBar,
    required this.text,
    required this.screenWidth,
    required this.screenHeight,
  });

  /// Raccourci : est-on en mode paysage ?
  bool get isLandscape => orientation == ScreenOrientation.landscape;
  
  /// Raccourci : est-on en mode portrait ?
  bool get isPortrait => orientation == ScreenOrientation.portrait;
  
  /// Raccourci : est-ce une tablette ?
  bool get isTablet => deviceType == DeviceType.tablet || deviceType == DeviceType.largeTablet;

  /// Layout par défaut (fallback)
  static const UILayout defaults = UILayout(
    deviceType: DeviceType.phone,
    orientation: ScreenOrientation.portrait,
    scaleFactor: 1.0,
    board: BoardDimensions.defaults,
    slider: SliderDimensions.defaults,
    actionBar: ActionBarDimensions.defaults,
    text: TextDimensions.defaults,
    screenWidth: 375,
    screenHeight: 812,
  );
}



