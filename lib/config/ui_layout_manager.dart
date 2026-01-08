// lib/config/ui_layout_manager.dart
// Gestionnaire centralisé des dimensions UI adaptatives
// Créé: 2024-12-31

import 'package:flutter/material.dart';
import 'package:pentapol/config/ui_dimensions.dart';

/// Gestionnaire centralisé pour calculer toutes les dimensions UI
/// 
/// Utilisation:
/// ```dart
/// final layout = UILayoutManager.calculate(
///   screenWidth: MediaQuery.of(context).size.width,
///   screenHeight: MediaQuery.of(context).size.height,
///   boardCols: 6,
///   boardRows: 10,
/// );
/// ```
class UILayoutManager {
  UILayoutManager._();

  // ============================================================================
  // CONSTANTES DE BASE (valeurs de référence pour un téléphone)
  // ============================================================================
  
  /// Taille de base d'une icône (téléphone)
  static const double _baseIconSize = 24.0;
  
  /// Taille de base d'une cellule de pièce dans le slider
  static const double _basePieceCellSize = 22.0;
  
  /// Hauteur de base du slider en portrait
  static const double _baseSliderHeight = 160.0;
  
  /// Largeur de base de la colonne d'actions
  static const double _baseActionBarWidth = 44.0;
  
  /// Épaisseur de bordure du plateau
  static const double _boardBorderWidth = 3.0;
  
  /// Rayon des coins du plateau
  static const double _boardBorderRadius = 16.0;
  
  /// Marge horizontale du plateau en portrait
  static const double _boardHorizontalMargin = 8.0;

  // ============================================================================
  // MÉTHODE PRINCIPALE DE CALCUL
  // ============================================================================

  /// Calcule toutes les dimensions UI en fonction de l'écran et du plateau
  /// 
  /// [screenWidth] - Largeur de l'écran disponible
  /// [screenHeight] - Hauteur de l'écran disponible
  /// [boardCols] - Nombre de colonnes logiques du plateau (ex: 6)
  /// [boardRows] - Nombre de lignes logiques du plateau (ex: 10)
  /// [safeAreaTop] - Hauteur de la safe area en haut (optionnel)
  /// [safeAreaBottom] - Hauteur de la safe area en bas (optionnel)
  static UILayout calculate({
    required double screenWidth,
    required double screenHeight,
    int boardCols = 6,
    int boardRows = 10,
    double safeAreaTop = 0,
    double safeAreaBottom = 0,
  }) {
    // 1. Déterminer l'orientation
    final orientation = screenWidth > screenHeight 
        ? ScreenOrientation.landscape 
        : ScreenOrientation.portrait;
    final isLandscape = orientation == ScreenOrientation.landscape;

    // 2. Déterminer le type d'appareil (basé sur la plus petite dimension)
    final smallestDimension = isLandscape ? screenHeight : screenWidth;
    final deviceType = _detectDeviceType(smallestDimension);
    
    // 3. Calculer le facteur d'échelle
    final scaleFactor = _getScaleFactor(deviceType);

    // 4. Dimensions visuelles du plateau (swap en paysage)
    final visualCols = isLandscape ? boardRows : boardCols;
    final visualRows = isLandscape ? boardCols : boardRows;

    // 5. Calculer les dimensions des composants
    final actionBar = _calculateActionBar(scaleFactor, screenHeight, isLandscape);
    final slider = _calculateSlider(scaleFactor, screenHeight, isLandscape);
    final board = _calculateBoard(
      screenWidth: screenWidth,
      screenHeight: screenHeight,
      visualCols: visualCols,
      visualRows: visualRows,
      isLandscape: isLandscape,
      sliderSize: isLandscape ? slider.width! : slider.height!,
      actionBarWidth: isLandscape ? actionBar.width : 0,
    );
    final text = _calculateText(scaleFactor);

    return UILayout(
      deviceType: deviceType,
      orientation: orientation,
      scaleFactor: scaleFactor,
      board: board,
      slider: slider,
      actionBar: actionBar,
      text: text,
      screenWidth: screenWidth,
      screenHeight: screenHeight,
    );
  }

  // ============================================================================
  // MÉTHODES DE CALCUL INTERNES
  // ============================================================================

  /// Détecte le type d'appareil selon la plus petite dimension
  static DeviceType _detectDeviceType(double smallestDimension) {
    if (smallestDimension >= 800) {
      return DeviceType.largeTablet;
    } else if (smallestDimension >= 600) {
      return DeviceType.tablet;
    } else {
      return DeviceType.phone;
    }
  }

  /// Retourne le facteur d'échelle selon le type d'appareil
  static double _getScaleFactor(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.largeTablet:
        return 1.5;
      case DeviceType.tablet:
        return 1.25;
      case DeviceType.phone:
        return 1.0;
    }
  }

  /// Calcule les dimensions de la barre d'actions
  static ActionBarDimensions _calculateActionBar(
    double scaleFactor,
    double screenHeight,
    bool isLandscape,
  ) {
    // En paysage, adapter à la hauteur disponible
    final baseSize = _baseIconSize * scaleFactor;
    
    // Calculer la taille des icônes avec clamp pour éviter les extrêmes
    final iconSize = isLandscape
        ? (screenHeight * 0.05).clamp(20.0, 40.0)
        : baseSize.clamp(20.0, 36.0);
    
    final width = (_baseActionBarWidth * scaleFactor).clamp(44.0, 80.0);
    final buttonMinSize = iconSize + 12;
    final iconSpacing = (iconSize * 0.35).clamp(6.0, 16.0);
    
    return ActionBarDimensions(
      width: width,
      iconSize: iconSize,
      iconPadding: EdgeInsets.all(iconSize * 0.25),
      iconSpacing: iconSpacing,
      buttonMinSize: buttonMinSize,
    );
  }

  /// Calcule les dimensions du slider de pièces
  static SliderDimensions _calculateSlider(
    double scaleFactor,
    double screenHeight,
    bool isLandscape,
  ) {
    // Taille des cellules de pièce
    final pieceCellSize = (_basePieceCellSize * scaleFactor).clamp(18.0, 32.0);
    
    // Taille d'un item (5×5 + padding)
    final itemSize = pieceCellSize * 5 + 8;
    
    // Dimensions du slider
    double? width;
    double? height;
    EdgeInsets sliderPadding;
    EdgeInsets itemPadding;
    
    if (isLandscape) {
      // Slider vertical à droite
      width = (screenHeight * 0.20).clamp(100.0, 200.0);
      height = null;
      sliderPadding = const EdgeInsets.symmetric(vertical: 16, horizontal: 8);
      itemPadding = const EdgeInsets.symmetric(horizontal: 4, vertical: 8);
    } else {
      // Slider horizontal en bas
      width = null;
      height = (_baseSliderHeight * scaleFactor).clamp(140.0, 220.0);
      sliderPadding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
      itemPadding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4);
    }
    
    return SliderDimensions(
      width: width,
      height: height,
      itemSize: itemSize,
      pieceCellSize: pieceCellSize,
      itemPadding: itemPadding,
      sliderPadding: sliderPadding,
    );
  }

  /// Calcule les dimensions du plateau
  static BoardDimensions _calculateBoard({
    required double screenWidth,
    required double screenHeight,
    required int visualCols,
    required int visualRows,
    required bool isLandscape,
    required double sliderSize,
    required double actionBarWidth,
  }) {
    // Espace disponible pour le plateau
    double availableWidth;
    double availableHeight;
    double horizontalMargin;
    
    if (isLandscape) {
      // Paysage : plateau à gauche, slider + actions à droite
      availableWidth = screenWidth - sliderSize - actionBarWidth;
      availableHeight = screenHeight;
      horizontalMargin = 0; // Pas de marge en paysage
    } else {
      // Portrait : plateau en haut, slider en bas
      availableWidth = screenWidth - _boardHorizontalMargin;
      availableHeight = screenHeight - sliderSize;
      horizontalMargin = _boardHorizontalMargin / 2;
    }
    
    // Calculer la taille de cellule pour que le plateau tienne
    final cellSizeByWidth = availableWidth / visualCols;
    final cellSizeByHeight = availableHeight / visualRows;
    final cellSize = cellSizeByWidth.clamp(0.0, cellSizeByHeight).toDouble();
    
    // Dimensions finales
    final boardWidth = cellSize * visualCols;
    final boardHeight = cellSize * visualRows;
    
    return BoardDimensions(
      cellSize: cellSize,
      width: boardWidth.toDouble(),
      height: boardHeight.toDouble(),
      horizontalMargin: horizontalMargin,
      borderWidth: _boardBorderWidth,
      borderRadius: _boardBorderRadius,
      visualCols: visualCols,
      visualRows: visualRows,
    );
  }

  /// Calcule les dimensions typographiques
  static TextDimensions _calculateText(double scaleFactor) {
    return TextDimensions(
      timerFontSize: (14 * scaleFactor).clamp(12.0, 20.0),
      scoreFontSize: (18 * scaleFactor).clamp(14.0, 28.0),
      labelFontSize: (12 * scaleFactor).clamp(10.0, 18.0),
      pieceNumberFontSize: (14 * scaleFactor).clamp(12.0, 20.0),
    );
  }

  // ============================================================================
  // MÉTHODE UTILITAIRE POUR RECALCUL À PARTIR D'UN CONTEXT
  // ============================================================================

  /// Calcule le layout à partir d'un BuildContext
  /// 
  /// Pratique pour un usage direct dans un widget :
  /// ```dart
  /// final layout = UILayoutManager.fromContext(context);
  /// ```
  static UILayout fromContext(
    BuildContext context, {
    int boardCols = 6,
    int boardRows = 10,
  }) {
    final mediaQuery = MediaQuery.of(context);
    return calculate(
      screenWidth: mediaQuery.size.width,
      screenHeight: mediaQuery.size.height,
      boardCols: boardCols,
      boardRows: boardRows,
      safeAreaTop: mediaQuery.padding.top,
      safeAreaBottom: mediaQuery.padding.bottom,
    );
  }

  /// Calcule le layout à partir de BoxConstraints (LayoutBuilder)
  /// 
  /// Pratique dans un LayoutBuilder :
  /// ```dart
  /// LayoutBuilder(
  ///   builder: (context, constraints) {
  ///     final layout = UILayoutManager.fromConstraints(constraints);
  ///     return ...;
  ///   },
  /// )
  /// ```
  static UILayout fromConstraints(
    BoxConstraints constraints, {
    int boardCols = 6,
    int boardRows = 10,
  }) {
    return calculate(
      screenWidth: constraints.maxWidth,
      screenHeight: constraints.maxHeight,
      boardCols: boardCols,
      boardRows: boardRows,
    );
  }
}

