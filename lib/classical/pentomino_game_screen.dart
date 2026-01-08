// lib/classical/pentomino_game_screen.dart
// Modified: 251226120030
// Démarrage du timer à la première pièce touchée
// CHANGEMENTS: (1) Variable _timerStarted ligne 34, (2) Logique dans build() lignes 49-54, (3) initState() réduit à reset() seul, (4) Démarrage au premier touch sans listener

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pentapol/classical/pentomino_game_provider.dart';
import 'package:pentapol/classical/pentomino_game_screen_spec.dart';

import 'package:pentapol/common/pentominos.dart';
import 'package:pentapol/config/game_icons_config.dart';
import 'package:pentapol/config/ui_sizes_config.dart';
import 'package:pentapol/providers/settings_provider.dart';
import 'package:pentapol/screens/pentomino_game/widgets/game_mode/piece_slider.dart';
import 'package:pentapol/screens/pentomino_game/widgets/shared/action_slider.dart'
    show ActionSlider, getCompatibleSolutionsIncludingSelected;
import 'package:pentapol/screens/pentomino_game/widgets/shared/game_board.dart';
import 'package:pentapol/screens/solutions_browser_screen.dart';


import 'package:pentapol/screens/pentomino_game/widgets/shared/highlighted_icon_button.dart';
import 'package:pentapol/services/solution_matcher.dart' show SolutionInfo;




class PentominoGameScreen extends ConsumerStatefulWidget {
  const PentominoGameScreen({super.key});

  @override
  ConsumerState<PentominoGameScreen> createState() => _PentominoGameScreenState();
}

class _PentominoGameScreenState extends ConsumerState<PentominoGameScreen> {

  late bool _timerStarted;
  bool _completionProcessed = false;  // ✨ Flag pour ne pas répéter

  /// Formate le temps en secondes (max 999s) - compact pour l'UI
  String _formatTimeCompact(int seconds) {
    final clamped = seconds.clamp(0, 999);
    return '${clamped}s';
  }


  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pentominoGameProvider);
    final notifier = ref.read(pentominoGameProvider.notifier);
    final settings = ref.watch(settingsProvider);

    // ✨ Démarrer le timer à la première interaction (pièce sélectionnée)
    if (!_timerStarted && (state.selectedPiece != null || state.selectedPlacedPiece != null)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifier.startTimer();
      });
      _timerStarted = true;
    }

    // ✨ AJOUT: Détecter la complétion du puzzle (12 pièces placées)
    // Vérifier aussi que le timer a tourné (elapsedSeconds > 0) pour éviter
    // les faux positifs lors de la réinitialisation
    if (state.placedPieces.length == 12 &&
        !_completionProcessed &&
        state.elapsedSeconds > 0 &&
        _timerStarted) {
      _completionProcessed = true;


      // Capturer les valeurs avant le callback
      final elapsedSeconds = state.elapsedSeconds;
      final score = notifier.calculateScore(elapsedSeconds);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifier.onPuzzleCompleted();

        // Récupérer l'état mis à jour pour avoir solvedSolutionIndex
        final updatedState = ref.read(pentominoGameProvider);
        final solutionIndex = updatedState.solvedSolutionIndex;
        final solutionInfo = solutionIndex != null ? SolutionInfo(solutionIndex) : null;

        // ✨ Afficher une dialog "Bravo!" avec le numéro de solution
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('🎉 Bravo!'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Puzzle complété en ${_formatTimeCompact(elapsedSeconds)}!',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'Score: $score ⭐',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                if (solutionInfo != null) ...[
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    'Solution #${solutionInfo.index + 1}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Famille ${solutionInfo.canonicalIndex + 1} • ${solutionInfo.variantName}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Fermer dialog
                  _completionProcessed = false; // Reset pour rejouer
                  _timerStarted = false;
                  notifier.reset(); // Recommencer
                },
                child: const Text('Rejouer'),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context); // Fermer dialog
                  Navigator.pop(context); // Quitter le jeu
                },
                icon: const Icon(Icons.check_circle),
                label: const Text('Terminer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        );
      });
    }

    // Détection automatique du mode selon la sélection
    final isInTransformMode = state.selectedPiece != null || state.selectedPlacedPiece != null;

    // Détecter l'orientation pour adapter l'AppBar
    final isLandscape = MediaQuery.of(context).size.width > MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
        // AppBar uniquement en mode portrait
        appBar: isLandscape ? null :
        PreferredSize(
        preferredSize: const Size.fromHeight(56.0),
        child:
        AppBar(
          toolbarHeight: UISizes.appBarHeight,
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,  // ✨ Pas de flèche retour automatique

          // ✨ Croix rouge + Chrono à gauche (masqués si pièce sélectionnée)
          leading: isInTransformMode
              ? null  // Pas de leading en mode transformation
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Croix rouge pour quitter
                    IconButton(
                      icon: const Icon(Icons.close),
                      color: Colors.red,
                      iconSize: UISizes.appBarIconSize,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      tooltip: 'Quitter',
                      padding: UISizes.compactIconPadding,
                      constraints: UISizes.compactIconConstraints,
                    ),
                    // Chrono
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _formatTimeCompact(state.elapsedSeconds),
                          style: const TextStyle(
                            fontSize: UISizes.timerFontSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        // ✨ Afficher la note seulement si puzzle complet
                        if (state.availablePieces.isEmpty)
                          Text(
                            '⭐ ${notifier.calculateScore(state.elapsedSeconds)}',
                            style: const TextStyle(
                              fontSize: UISizes.scoreFontSize,
                              color: Colors.orange,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
          leadingWidth: isInTransformMode ? 0 : UISizes.appBarLeadingWidth,
          
          // ✨ TITLE : Icônes centrées en mode transformation, bouton solutions sinon
          centerTitle: true,
          title: isInTransformMode
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _buildTransformActions(state, notifier, settings),
                )
              : (state.solutionsCount != null
                  ? FittedBox(
                      fit: BoxFit.scaleDown,
                      child: ElevatedButton(
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          notifier.incrementSolutionsViewCount();
                          final solutions = getCompatibleSolutionsIncludingSelected(state);
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => SolutionsBrowserScreen.forSolutions(
                                solutions: solutions,
                                title: 'Solutions',
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          minimumSize: const Size(45, 30),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 3,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          '${state.solutionsCount}',
                          style: const TextStyle(
                            fontSize: UISizes.solutionsCountFontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                  : null),
          
          // ✨ ACTIONS : Hint uniquement en mode normal (pas en transformation)
          actions: isInTransformMode
              ? null  // Pas d'actions à droite, tout est dans title
              : [
                  // 💡 Bouton hint (ampoule)
                  IconButton(
                    icon: const Icon(Icons.lightbulb),
                    color: Colors.amber.shade700,
                    tooltip: 'Indice aléatoire',
                    iconSize: UISizes.appBarIconSize,
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      notifier.applyHint();
                    },
                  ),
                ],
        ),
      ),
      body: Stack(
        children: [
          // Layout principal (portrait ou paysage)
          LayoutBuilder(
            builder: (context, constraints) {
              final isLandscape = constraints.maxWidth > constraints.maxHeight;

              if (isLandscape) {
                return _buildLandscapeLayout(context, ref, state, notifier, isInTransformMode);
              } else {
                return _buildPortraitLayout(context, ref, state, notifier);
              }
            },
          ),


        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _timerStarted = false;
    _completionProcessed = false;

    // Réinitialiser le jeu immédiatement à l'entrée de l'écran
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final notifier = ref.read(pentominoGameProvider.notifier);
        notifier.reset();
        // Forcer la réinitialisation des flags locaux après le reset
        setState(() {
          _timerStarted = false;
          _completionProcessed = false;
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // S'assurer que les flags sont réinitialisés si on revient sur cet écran
    _timerStarted = false;
    _completionProcessed = false;
  }


  /// Layout paysage : plateau à gauche, actions + slider vertical à droite
  Widget _buildLandscapeLayout(
      BuildContext context,
      WidgetRef ref,
      state,
      notifier,
      bool isInTransformMode,
      )
  {
    final settings = ref.watch(settingsProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Adapter les tailles selon l'espace disponible (iPad vs iPhone)
        final screenHeight = constraints.maxHeight;
        final actionColumnWidth = (screenHeight * 0.08).clamp(44.0, 70.0);
        final sliderWidth = (screenHeight * 0.22).clamp(120.0, 200.0);

        return Row(
          children: [
            // Plateau de jeu (10×6 visuel)
            Expanded(
              child: GameBoard(isLandscape: true),
            ),

            // Colonne de droite : actions + slider
            Row(
              children: [
                // Slider d'actions verticales (même logique que l'AppBar)
                Container(
                  width: actionColumnWidth,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 2,
                        offset: const Offset(-1, 0),
                      ),
                    ],
                  ),
                  child: const ActionSlider(isLandscape: true),
                ),

                // Slider de pièces vertical AVEC DragTarget
                _buildSliderWithDragTarget(ref: ref, isLandscape: true, width: sliderWidth),
              ],
            ),
          ],
        );
      },
    );
  }

  // ============================================================================
  // NOUVEAU: Widget slider avec DragTarget pour retirer les pièces
  // ============================================================================

  /// Layout portrait (classique) : plateau en haut, slider en bas
  Widget _buildPortraitLayout(
      BuildContext context,
      WidgetRef ref,
      state,
      notifier,
      )
  {

    return Column(
      children: [
        // Plateau de jeu
        Expanded(
          flex: 3,
          child: GameBoard(isLandscape: false),
        ),

        // Slider de pièces horizontal AVEC DragTarget
        _buildSliderWithDragTarget(ref: ref, isLandscape: false),
      ],
    );
  }

  /// Construit le slider enveloppé dans un DragTarget
  /// Quand on drag une pièce placée vers le slider, elle est retirée du plateau
  Widget _buildSliderWithDragTarget({
    required WidgetRef ref,
    required bool isLandscape,
    double? width,
  }) {
    final state = ref.watch(pentominoGameProvider);
    final notifier = ref.read(pentominoGameProvider.notifier);

    return DragTarget<Pento>(
      onWillAcceptWithDetails: (details) {
        // Accepter seulement si c'est une pièce placée (pas du slider)
        return state.selectedPlacedPiece != null;
      },
      onAcceptWithDetails: (details) {
        // Retirer la pièce du plateau
        if (state.selectedPlacedPiece != null) {
          HapticFeedback.mediumImpact();
          notifier.removePlacedPiece(state.selectedPlacedPiece!);
        }
      },
      builder: (context, candidateData, rejectedData) {
        // Highlight visuel quand on survole avec une pièce placée
        final isHovering = candidateData.isNotEmpty;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          height: isLandscape ? null : 170,
          width: isLandscape ? (width ?? 140) : null,
          decoration: BoxDecoration(
            color: isHovering ? Colors.red.shade50 : Colors.grey.shade100,
            border: isHovering
                ? Border.all(color: Colors.red.shade400, width: 3)
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: isLandscape ? const Offset(-2, 0) : const Offset(0, -2),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Le slider
              PieceSlider(isLandscape: isLandscape),

              // Overlay de suppression au survol
              if (isHovering)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      color: Colors.red.withOpacity(0.1),
                      child: Center(
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.8, end: 1.0),
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.elasticOut,
                          builder: (context, scale, child) {
                            return Transform.scale(
                              scale: scale,
                              child: child,
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.red.shade100,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withOpacity(0.3),
                                  blurRadius: 12,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.delete_outline,
                              color: Colors.red.shade700,
                              size: 36,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  /// Actions en mode TRANSFORMATION (pièce sélectionnée)
  /// Icônes centrées dans l'AppBar avec tailles de UISizes
  List<Widget> _buildTransformActions(state, notifier, settings) {
    return [
      // Rotation anti-horaire
      HighlightedIconButton(
        isHighlighted: state.highlightedIsometryIcon == 'rotation',
        child: IconButton(
          icon: Icon(GameIcons.isometryRotationTW.icon, size: UISizes.isometryIconSize),
          onPressed: () {
            HapticFeedback.selectionClick();
            notifier.applyIsometryRotationTW();
          },
          tooltip: GameIcons.isometryRotationTW.tooltip,
          color: GameIcons.isometryRotationTW.color,
          padding: UISizes.isometryIconPadding,
          constraints: UISizes.isometryIconConstraints,
        ),
      ),

      // Rotation horaire
      HighlightedIconButton(
        isHighlighted: state.highlightedIsometryIcon == 'rotation_cw',
        child: IconButton(
          icon: Icon(GameIcons.isometryRotationCW.icon, size: UISizes.isometryIconSize),
          onPressed: () {
            HapticFeedback.selectionClick();
            notifier.applyIsometryRotationCW();
          },
          tooltip: GameIcons.isometryRotationCW.tooltip,
          color: GameIcons.isometryRotationCW.color,
          padding: UISizes.isometryIconPadding,
          constraints: UISizes.isometryIconConstraints,
        ),
      ),

      // Symétrie horizontale
      HighlightedIconButton(
        isHighlighted: state.highlightedIsometryIcon == 'symmetry_h',
        child: IconButton(
          icon: Icon(GameIcons.isometrySymmetryH.icon, size: UISizes.isometryIconSize),
          onPressed: () {
            HapticFeedback.selectionClick();
            notifier.applyIsometrySymmetryH();
          },
          tooltip: GameIcons.isometrySymmetryH.tooltip,
          color: GameIcons.isometrySymmetryH.color,
          padding: UISizes.isometryIconPadding,
          constraints: UISizes.isometryIconConstraints,
        ),
      ),

      // Symétrie verticale
      HighlightedIconButton(
        isHighlighted: state.highlightedIsometryIcon == 'symmetry_v',
        child: IconButton(
          icon: Icon(GameIcons.isometrySymmetryV.icon, size: UISizes.isometryIconSize),
          onPressed: () {
            HapticFeedback.selectionClick();
            notifier.applyIsometrySymmetryV();
          },
          tooltip: GameIcons.isometrySymmetryV.tooltip,
          color: GameIcons.isometrySymmetryV.color,
          padding: UISizes.isometryIconPadding,
          constraints: UISizes.isometryIconConstraints,
        ),
      ),

      // Delete (uniquement si pièce placée sélectionnée)
      if (state.selectedPlacedPiece != null)
        IconButton(
          icon: Icon(GameIcons.removePiece.icon, size: UISizes.deleteIconSize),
          onPressed: () {
            HapticFeedback.mediumImpact();
            notifier.removePlacedPiece(state.selectedPlacedPiece!);
          },
          tooltip: GameIcons.removePiece.tooltip,
          color: GameIcons.removePiece.color,
          padding: UISizes.isometryIconPadding,
          constraints: UISizes.isometryIconConstraints,
        ),
    ];
  }
}