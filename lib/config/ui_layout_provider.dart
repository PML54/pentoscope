// lib/config/ui_layout_provider.dart
// Provider Riverpod pour les dimensions UI adaptatives
// Créé: 2024-12-31

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pentapol/config/ui_dimensions.dart';
import 'package:pentapol/config/ui_layout_manager.dart';

// ============================================================================
// STATE NOTIFIER POUR LE LAYOUT
// ============================================================================

/// State pour stocker les paramètres du layout
class UILayoutState {
  final double screenWidth;
  final double screenHeight;
  final int boardCols;
  final int boardRows;
  final UILayout layout;

  const UILayoutState({
    required this.screenWidth,
    required this.screenHeight,
    required this.boardCols,
    required this.boardRows,
    required this.layout,
  });

  /// État initial par défaut
  factory UILayoutState.initial() {
    return UILayoutState(
      screenWidth: 375,
      screenHeight: 812,
      boardCols: 6,
      boardRows: 10,
      layout: UILayout.defaults,
    );
  }

  /// Copie avec nouvelles valeurs
  UILayoutState copyWith({
    double? screenWidth,
    double? screenHeight,
    int? boardCols,
    int? boardRows,
    UILayout? layout,
  }) {
    return UILayoutState(
      screenWidth: screenWidth ?? this.screenWidth,
      screenHeight: screenHeight ?? this.screenHeight,
      boardCols: boardCols ?? this.boardCols,
      boardRows: boardRows ?? this.boardRows,
      layout: layout ?? this.layout,
    );
  }
}

/// Notifier pour gérer les mises à jour du layout
class UILayoutNotifier extends Notifier<UILayoutState> {
  @override
  UILayoutState build() {
    return UILayoutState.initial();
  }

  /// Met à jour le layout avec de nouvelles dimensions d'écran
  void updateScreenSize(double width, double height) {
    if (width == state.screenWidth && height == state.screenHeight) {
      return; // Pas de changement
    }

    final newLayout = UILayoutManager.calculate(
      screenWidth: width,
      screenHeight: height,
      boardCols: state.boardCols,
      boardRows: state.boardRows,
    );

    state = state.copyWith(
      screenWidth: width,
      screenHeight: height,
      layout: newLayout,
    );
  }

  /// Met à jour les dimensions du plateau (ex: Pentoscope avec plateau plus petit)
  void updateBoardSize(int cols, int rows) {
    if (cols == state.boardCols && rows == state.boardRows) {
      return; // Pas de changement
    }

    final newLayout = UILayoutManager.calculate(
      screenWidth: state.screenWidth,
      screenHeight: state.screenHeight,
      boardCols: cols,
      boardRows: rows,
    );

    state = state.copyWith(
      boardCols: cols,
      boardRows: rows,
      layout: newLayout,
    );
  }

  /// Recalcule le layout complet
  void recalculate({
    double? screenWidth,
    double? screenHeight,
    int? boardCols,
    int? boardRows,
  }) {
    final newLayout = UILayoutManager.calculate(
      screenWidth: screenWidth ?? state.screenWidth,
      screenHeight: screenHeight ?? state.screenHeight,
      boardCols: boardCols ?? state.boardCols,
      boardRows: boardRows ?? state.boardRows,
    );

    state = UILayoutState(
      screenWidth: screenWidth ?? state.screenWidth,
      screenHeight: screenHeight ?? state.screenHeight,
      boardCols: boardCols ?? state.boardCols,
      boardRows: boardRows ?? state.boardRows,
      layout: newLayout,
    );
  }
}

// ============================================================================
// PROVIDERS RIVERPOD
// ============================================================================

/// Provider principal pour le state du layout
final uiLayoutProvider = NotifierProvider<UILayoutNotifier, UILayoutState>(() {
  return UILayoutNotifier();
});

/// Provider de commodité pour accéder directement au layout calculé
final uiLayoutDataProvider = Provider<UILayout>((ref) {
  return ref.watch(uiLayoutProvider).layout;
});

/// Provider pour le type d'appareil
final deviceTypeProvider = Provider<DeviceType>((ref) {
  return ref.watch(uiLayoutDataProvider).deviceType;
});

/// Provider pour l'orientation
final orientationProvider = Provider<ScreenOrientation>((ref) {
  return ref.watch(uiLayoutDataProvider).orientation;
});

/// Provider pour savoir si on est en mode paysage
final isLandscapeProvider = Provider<bool>((ref) {
  return ref.watch(uiLayoutDataProvider).isLandscape;
});

/// Provider pour les dimensions du plateau
final boardDimensionsProvider = Provider<BoardDimensions>((ref) {
  return ref.watch(uiLayoutDataProvider).board;
});

/// Provider pour les dimensions du slider
final sliderDimensionsProvider = Provider<SliderDimensions>((ref) {
  return ref.watch(uiLayoutDataProvider).slider;
});

/// Provider pour les dimensions de la barre d'actions
final actionBarDimensionsProvider = Provider<ActionBarDimensions>((ref) {
  return ref.watch(uiLayoutDataProvider).actionBar;
});

/// Provider pour les dimensions typographiques
final textDimensionsProvider = Provider<TextDimensions>((ref) {
  return ref.watch(uiLayoutDataProvider).text;
});

// ============================================================================
// WIDGET HELPER POUR INITIALISER LE LAYOUT
// ============================================================================

/// Widget qui initialise automatiquement le UILayout au démarrage
/// 
/// À placer en haut de l'arbre de widgets d'un écran de jeu :
/// ```dart
/// @override
/// Widget build(BuildContext context) {
///   return UILayoutInitializer(
///     boardCols: 6,
///     boardRows: 10,
///     child: Scaffold(...),
///   );
/// }
/// ```
class UILayoutInitializer extends ConsumerStatefulWidget {
  final Widget child;
  final int boardCols;
  final int boardRows;

  const UILayoutInitializer({
    super.key,
    required this.child,
    this.boardCols = 6,
    this.boardRows = 10,
  });

  @override
  ConsumerState<UILayoutInitializer> createState() => _UILayoutInitializerState();
}

class _UILayoutInitializerState extends ConsumerState<UILayoutInitializer> {
  bool _initialized = false;
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ✅ Reporter la mise à jour après le build pour éviter l'erreur Riverpod
    // Mais seulement après la première initialisation
    if (_initialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _updateLayout();
        }
      });
    }
  }

  void _updateLayout() {
    final mediaQuery = MediaQuery.of(context);
    final notifier = ref.read(uiLayoutProvider.notifier);
    
    // Mettre à jour les dimensions du plateau si différentes
    final currentState = ref.read(uiLayoutProvider);
    if (currentState.boardCols != widget.boardCols || 
        currentState.boardRows != widget.boardRows) {
      notifier.updateBoardSize(widget.boardCols, widget.boardRows);
    }
    
    // Mettre à jour les dimensions de l'écran
    notifier.updateScreenSize(
      mediaQuery.size.width,
      mediaQuery.size.height,
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    
    // ✅ Première initialisation synchrone dans le build
    // pour avoir les bonnes dimensions dès le premier frame
    if (!_initialized) {
      _initialized = true;
      // Utiliser Future.microtask pour éviter l'erreur Riverpod
      // tout en étant quasi-synchrone
      Future.microtask(() {
        if (mounted) {
          final notifier = ref.read(uiLayoutProvider.notifier);
          notifier.recalculate(
            screenWidth: mediaQuery.size.width,
            screenHeight: mediaQuery.size.height,
            boardCols: widget.boardCols,
            boardRows: widget.boardRows,
          );
        }
      });
    }
    
    return widget.child;
  }
}

// ============================================================================
// EXTENSION POUR ACCÈS FACILE
// ============================================================================

/// Extension sur WidgetRef pour un accès simplifié
extension UILayoutRefExtension on WidgetRef {
  /// Accès direct au layout
  UILayout get uiLayout => watch(uiLayoutDataProvider);
  
  /// Accès aux dimensions du plateau
  BoardDimensions get boardDimensions => watch(boardDimensionsProvider);
  
  /// Accès aux dimensions du slider
  SliderDimensions get sliderDimensions => watch(sliderDimensionsProvider);
  
  /// Accès aux dimensions des actions
  ActionBarDimensions get actionBarDimensions => watch(actionBarDimensionsProvider);
  
  /// Accès aux dimensions texte
  TextDimensions get textDimensions => watch(textDimensionsProvider);
  
  /// Est-on en mode paysage ?
  bool get isLandscape => watch(isLandscapeProvider);
}

// ============================================================================
// EXTENSION POUR CALCUL DIRECT (sans provider)
// ============================================================================

/// Extension sur BuildContext pour calcul direct des dimensions
/// Utile quand on veut les dimensions immédiatement sans passer par le provider
extension UILayoutContextExtension on BuildContext {
  /// Calcule le layout directement depuis le contexte
  UILayout calculateLayout({int boardCols = 6, int boardRows = 10}) {
    final size = MediaQuery.of(this).size;
    return UILayoutManager.calculate(
      screenWidth: size.width,
      screenHeight: size.height,
      boardCols: boardCols,
      boardRows: boardRows,
    );
  }
  
  /// Raccourci pour les dimensions du plateau
  BoardDimensions calculateBoardDimensions({int boardCols = 6, int boardRows = 10}) {
    return calculateLayout(boardCols: boardCols, boardRows: boardRows).board;
  }
  
  /// Raccourci pour les dimensions du slider
  SliderDimensions calculateSliderDimensions({int boardCols = 6, int boardRows = 10}) {
    return calculateLayout(boardCols: boardCols, boardRows: boardRows).slider;
  }
  
  /// Raccourci pour les dimensions de la barre d'actions
  ActionBarDimensions calculateActionBarDimensions({int boardCols = 6, int boardRows = 10}) {
    return calculateLayout(boardCols: boardCols, boardRows: boardRows).actionBar;
  }
}

