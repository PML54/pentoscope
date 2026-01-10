// lib/pentoscope/screens/pentoscope_game_screen.dart
// Modified: 2512191000
// Refactorisation UI: Actions isométrie contextuelles (slider vs plateau)
// CHANGEMENTS: (1) Extraction Widget _buildIsometryActionsBar() lignes 67-110, (2) Portrait: Actions au-dessus slider si pièce sélectionnée (lignes 280-310), (3) Landscape: Actions verticales contextuelles (lignes 312-365)

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pentapol/common/pentominos.dart';
import 'package:pentapol/providers/settings_provider.dart';
import 'package:pentapol/config/game_icons_config.dart';
import 'package:pentapol/pentoscope/pentoscope_provider.dart';
import 'package:pentapol/pentoscope/pentoscope_generator.dart';
import 'package:pentapol/pentoscope/widgets/pentoscope_board.dart';
import 'package:pentapol/pentoscope/widgets/pentoscope_piece_slider.dart';
import 'package:pentapol/pentoscope_multiplayer/screens/pentoscope_mp_lobby_screen.dart';
import 'package:pentapol/tutorial/pentoscope/screens/pentoscope_game_with_tutorial_screen.dart';
import 'package:pentapol/config/ui_sizes_config.dart';

/// ⏱️ Formate le temps en secondes (max 999s) - format compact
String _formatTime(int seconds) {
  final clamped = seconds.clamp(0, 999);
  return '${clamped}s';
}

class PentoscopeGameScreen extends ConsumerStatefulWidget {
  const PentoscopeGameScreen({super.key});

  @override
  ConsumerState<PentoscopeGameScreen> createState() => _PentoscopeGameScreenState();
}

class _PentoscopeGameScreenState extends ConsumerState<PentoscopeGameScreen> {
  // 👁️ État du mini-plateau adversaire
  bool _showOpponentOverlay = false;
  
  // 📍 Position du mini-plateau (draggable)
  Offset? _overlayPosition; // null = position par défaut (coin bas-droit)

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pentoscopeProvider);
    final notifier = ref.read(pentoscopeProvider.notifier);
    final settings = ref.watch(settingsProvider);

    if (state.puzzle == null) {
      return const Scaffold(body: Center(child: Text('Aucun puzzle')));
    }

    // Détection du mode transformation
    final isPlacedPieceSelected = state.selectedPlacedPiece != null;
    final isSliderPieceSelected = state.selectedPiece != null;

    // Orientation
    final isLandscape =
        MediaQuery.of(context).size.width > MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: isLandscape
          ? null
          : PreferredSize(
        preferredSize: const Size.fromHeight(56.0),
        child: AppBar(
          toolbarHeight: 56.0,
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          // 🔑 En mode transformation: pas de leading, les icônes prennent toute la place
          leading: (isPlacedPieceSelected || isSliderPieceSelected)
              ? null
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () => Navigator.pop(context),
                    ),
                    // ⏱️ Chronomètre
                    Text(
                      _formatTime(state.elapsedSeconds),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
          leadingWidth: (isPlacedPieceSelected || isSliderPieceSelected) ? 0 : 100,
          // 🔑 En mode transformation: icônes isométrie pleine largeur
          title: (isPlacedPieceSelected || isSliderPieceSelected)
              ? _buildFullWidthIsometryBar(state, notifier)
              : state.isComplete
              ? TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 800),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Indicateurs de performance
                    Icon(Icons.rotate_right, size: 14, color: Colors.blue.shade600),
                    Text('${state.isometryCount}', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                    const SizedBox(width: 6),
                    Icon(Icons.open_with, size: 14, color: Colors.purple.shade600),
                    Text('${state.translationCount}', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                    const SizedBox(width: 6),
                    Icon(Icons.delete_outline, size: 14, color: Colors.red.shade600),
                    Text('${state.deleteCount}', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                  ],
                ),
              );
            },
          )
              : null,
          centerTitle: true,
          // 🔑 En mode transformation: pas d'actions, tout est dans le title
          actions: (isPlacedPieceSelected || isSliderPieceSelected)
              ? null
              : [
            // ➕ Bouton augmenter taille plateau
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              color: Colors.blue,
              onPressed: () => _showSizeChangeDialog(context, ref),
              tooltip: 'Changer taille plateau',
            ),
            // 👥 Bouton multijoueur
            IconButton(
              icon: const Icon(Icons.people_outline),
              color: Colors.purple,
              onPressed: () => _navigateToMultiplayer(context),
              tooltip: 'Mode multijoueur',
            ),
            // 👁️ Bouton voir adversaire
            IconButton(
              icon: Icon(
                _showOpponentOverlay ? Icons.visibility : Icons.visibility_outlined,
                color: _showOpponentOverlay ? Colors.blue : Colors.grey,
              ),
              onPressed: () {
                HapticFeedback.selectionClick();
                setState(() {
                  _showOpponentOverlay = !_showOpponentOverlay;
                });
              },
              tooltip: 'Voir adversaire',
            ),
            // 🎮 Manette pour réinitialiser
            IconButton(
              icon: Icon(
                Icons.sports_esports,
                color: state.isComplete ? Colors.green : Colors.indigo,
              ),
              onPressed: () {
                HapticFeedback.mediumImpact();
                notifier.reset();
              },
              tooltip: 'Nouvelle partie',
            ),
            // 💡 Bouton Hint (lampe)
            if (!state.isComplete &&
                state.hasPossibleSolution &&
                state.availablePieces.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.lightbulb_outline),
                color: Colors.amber,
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  notifier.applyHint();
                },
                tooltip: 'Indice',
              ),
            // 🎓 Tutoriel
            IconButton(
              icon: const Icon(Icons.school_outlined),
              color: Colors.teal,
              onPressed: () {
                HapticFeedback.selectionClick();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PentoscopeGameWithTutorialScreen(
                      tutorialPath: 'assets/tutorials/01_intro_basics.yaml',
                    ),
                  ),
                );
              },
              tooltip: 'Tutoriel',
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isLandscape = constraints.maxWidth > constraints.maxHeight;

              if (isLandscape) {
                return _buildLandscapeLayout(
                  context,
                  ref,
                  state,
                  notifier,
                  settings,
                  isSliderPieceSelected,
                  isPlacedPieceSelected,
                );
              } else {
                return _buildPortraitLayout(
                  context,
                  ref,
                  state,
                  notifier,
                  isSliderPieceSelected,
                  isPlacedPieceSelected,
                );
              }
            },
          ),
          
          // 👁️ Mini-plateau adversaire (overlay)
          if (_showOpponentOverlay)
            _buildOpponentOverlay(context, state, settings),
        ],
      ),
    );
  }

  // ============================================================================
  // 👁️ MINI-PLATEAU ADVERSAIRE (OVERLAY)
  // ============================================================================

  Widget _buildOpponentOverlay(
      BuildContext context,
      PentoscopeState state,
      dynamic settings,
      ) {
    final screenSize = MediaQuery.of(context).size;
    final isLandscape = screenSize.width > screenSize.height;
    
    // Taille du mini-plateau (35% de l'écran)
    final overlaySize = isLandscape 
        ? screenSize.height * 0.35 
        : screenSize.width * 0.35;
    
    // Position par défaut : coin bas-droit avec marge
    final defaultX = screenSize.width - overlaySize - 12;
    final defaultY = isLandscape 
        ? screenSize.height - overlaySize - 12 
        : screenSize.height - overlaySize - 170; // Au-dessus du slider en portrait
    
    // Utiliser la position custom ou la position par défaut
    final currentX = _overlayPosition?.dx ?? defaultX;
    final currentY = _overlayPosition?.dy ?? defaultY;

    return Positioned(
      left: currentX,
      top: currentY,
      child: GestureDetector(
        // 🖐️ Drag pour déplacer
        onPanUpdate: (details) {
          setState(() {
            final newX = (currentX + details.delta.dx)
                .clamp(0.0, screenSize.width - overlaySize);
            final newY = (currentY + details.delta.dy)
                .clamp(0.0, screenSize.height - overlaySize - 60); // Marge pour ne pas sortir
            _overlayPosition = Offset(newX, newY);
          });
        },
        // 🔄 Double-tap pour reset la position
        onDoubleTap: () {
          HapticFeedback.selectionClick();
          setState(() {
            _overlayPosition = null; // Reset à la position par défaut
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: overlaySize,
          height: overlaySize,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade300, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              children: [
                // 🎮 Mini-plateau (simulation adversaire)
                _buildMiniBoard(state, settings, overlaySize),
                
                // 📊 Bandeau info adversaire (aussi zone de drag)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade600, Colors.blue.shade400],
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // 🖐️ Icône drag
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.drag_indicator, color: Colors.white.withOpacity(0.7), size: 12),
                            const SizedBox(width: 4),
                            const Text(
                              '👤 Adversaire',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${_simulateOpponentProgress(state)}/${state.puzzle?.size.numPieces ?? 0}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // ❌ Bouton fermer
                Positioned(
                  top: 2,
                  right: 2,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _showOpponentOverlay = false;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red.shade400,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Simule la progression de l'adversaire (pour démo)
  int _simulateOpponentProgress(PentoscopeState state) {
    // Simulation miroir : même progression que nous
    return state.placedPieces.length;
  }

  /// Construit le mini-plateau (vue simplifiée)
  Widget _buildMiniBoard(PentoscopeState state, dynamic settings, double size) {
    final puzzle = state.puzzle;
    if (puzzle == null) return const SizedBox();

    final boardWidth = puzzle.size.width;
    final boardHeight = puzzle.size.height;
    
    // Calculer la taille des cellules pour le mini-plateau
    final availableSize = size - 24; // Marge pour le bandeau
    final maxDimension = boardWidth > boardHeight ? boardWidth : boardHeight;
    final cellSize = availableSize / maxDimension;

    return Padding(
      padding: const EdgeInsets.only(top: 22), // Espace pour le bandeau
      child: Center(
        child: SizedBox(
          width: cellSize * boardWidth,
          height: cellSize * boardHeight,
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: boardWidth,
              childAspectRatio: 1.0,
            ),
            itemCount: boardWidth * boardHeight,
            itemBuilder: (context, index) {
              final x = index % boardWidth;
              final y = index ~/ boardWidth;
              
              // Simuler le plateau adversaire (quelques pièces placées)
              final opponentPieces = _getSimulatedOpponentPieces(state);
              final pieceId = _getPieceAtPosition(opponentPieces, x, y);
              
              return Container(
                decoration: BoxDecoration(
                  color: pieceId != null 
                      ? settings.ui.getPieceColor(pieceId).withOpacity(0.8)
                      : Colors.grey.shade200,
                  border: Border.all(color: Colors.grey.shade400, width: 0.5),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// Simule les pièces de l'adversaire (pour démo)
  /// En mode miroir : affiche les mêmes pièces que nous
  List<PentoscopePlacedPiece> _getSimulatedOpponentPieces(PentoscopeState state) {
    // Simulation miroir : mêmes pièces que nous
    return state.placedPieces.toList();
  }

  /// Récupère l'ID de la pièce à une position donnée
  int? _getPieceAtPosition(List<PentoscopePlacedPiece> pieces, int x, int y) {
    for (final placed in pieces) {
      for (final cell in placed.absoluteCells) {
        if (cell.x == x && cell.y == y) {
          return placed.piece.id;
        }
      }
    }
    return null;
  }

  // ============================================================================
  // WIDGET RÉUTILISABLE: Barre d'actions isométrie
  // ============================================================================

  /// Widget réutilisable pour les icônes isométrie (horizontal ou vertical)
  Widget _buildIsometryActionsBar(
      PentoscopeState state,
      PentoscopeNotifier notifier,
      dynamic settings,
      Axis direction,
      ) {
    final children = [
      // Rotation anti-horaire (CCW)
      _buildIconButton(
        GameIcons.isometryRotationTW,
        settings,
            () => notifier.applyIsometryRotationTW(),
      ),

      // Rotation horaire (CW)
      _buildIconButton(
        GameIcons.isometryRotationCW,
        settings,
            () => notifier.applyIsometryRotationCW(),
      ),

      // Symétrie horizontale
      _buildIconButton(
        GameIcons.isometrySymmetryH,
        settings,
            () => notifier.applyIsometrySymmetryH(),
      ),

      // Symétrie verticale
      _buildIconButton(
        GameIcons.isometrySymmetryV,
        settings,
            () => notifier.applyIsometrySymmetryV(),
      ),

      // Supprimer (uniquement si pièce placée sélectionnée)
      if (state.selectedPlacedPiece != null)
        _buildIconButton(
          GameIcons.removePiece,
          settings,
              () => notifier.removePlacedPiece(state.selectedPlacedPiece!),
        ),
    ];

    return direction == Axis.horizontal
        ? Row(mainAxisSize: MainAxisSize.min, children: children)
        : Column(mainAxisSize: MainAxisSize.min, children: children);
  }

  /// 🔑 Barre d'isométries pleine largeur avec icônes grandes et réparties uniformément
  Widget _buildFullWidthIsometryBar(
      PentoscopeState state,
      PentoscopeNotifier notifier,
      ) {
    // Hauteur AppBar = 56, on prend ~75% pour les icônes
    const double iconSize = 42.0;
    
    final hasDeleteButton = state.selectedPlacedPiece != null;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Rotation anti-horaire
        IconButton(
          icon: Icon(GameIcons.isometryRotationTW.icon, size: iconSize),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          onPressed: () {
            HapticFeedback.selectionClick();
            notifier.applyIsometryRotationTW();
          },
          tooltip: GameIcons.isometryRotationTW.tooltip,
          color: GameIcons.isometryRotationTW.color,
        ),
        // Rotation horaire
        IconButton(
          icon: Icon(GameIcons.isometryRotationCW.icon, size: iconSize),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          onPressed: () {
            HapticFeedback.selectionClick();
            notifier.applyIsometryRotationCW();
          },
          tooltip: GameIcons.isometryRotationCW.tooltip,
          color: GameIcons.isometryRotationCW.color,
        ),
        // Symétrie horizontale
        IconButton(
          icon: Icon(GameIcons.isometrySymmetryH.icon, size: iconSize),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          onPressed: () {
            HapticFeedback.selectionClick();
            notifier.applyIsometrySymmetryH();
          },
          tooltip: GameIcons.isometrySymmetryH.tooltip,
          color: GameIcons.isometrySymmetryH.color,
        ),
        // Symétrie verticale
        IconButton(
          icon: Icon(GameIcons.isometrySymmetryV.icon, size: iconSize),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          onPressed: () {
            HapticFeedback.selectionClick();
            notifier.applyIsometrySymmetryV();
          },
          tooltip: GameIcons.isometrySymmetryV.tooltip,
          color: GameIcons.isometrySymmetryV.color,
        ),
        // Supprimer (si pièce placée)
        if (hasDeleteButton)
          IconButton(
            icon: Icon(GameIcons.removePiece.icon, size: iconSize),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () {
              HapticFeedback.selectionClick();
              notifier.removePlacedPiece(state.selectedPlacedPiece!);
            },
            tooltip: GameIcons.removePiece.tooltip,
            color: GameIcons.removePiece.color,
          ),
      ],
    );
  }

  /// 🔑 Barre d'isométries pleine hauteur (mode paysage) avec icônes grandes et réparties
  Widget _buildFullHeightIsometryBar(
      PentoscopeState state,
      PentoscopeNotifier notifier,
      double columnWidth,
      ) {
    // Icônes ~80% de la largeur de la colonne
    final iconSize = (columnWidth * 0.75).clamp(28.0, 50.0);
    final hasDeleteButton = state.selectedPlacedPiece != null;
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Rotation anti-horaire
        IconButton(
          icon: Icon(GameIcons.isometryRotationTW.icon, size: iconSize),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          onPressed: () {
            HapticFeedback.selectionClick();
            notifier.applyIsometryRotationTW();
          },
          tooltip: GameIcons.isometryRotationTW.tooltip,
          color: GameIcons.isometryRotationTW.color,
        ),
        // Rotation horaire
        IconButton(
          icon: Icon(GameIcons.isometryRotationCW.icon, size: iconSize),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          onPressed: () {
            HapticFeedback.selectionClick();
            notifier.applyIsometryRotationCW();
          },
          tooltip: GameIcons.isometryRotationCW.tooltip,
          color: GameIcons.isometryRotationCW.color,
        ),
        // Symétrie horizontale
        IconButton(
          icon: Icon(GameIcons.isometrySymmetryH.icon, size: iconSize),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          onPressed: () {
            HapticFeedback.selectionClick();
            notifier.applyIsometrySymmetryH();
          },
          tooltip: GameIcons.isometrySymmetryH.tooltip,
          color: GameIcons.isometrySymmetryH.color,
        ),
        // Symétrie verticale
        IconButton(
          icon: Icon(GameIcons.isometrySymmetryV.icon, size: iconSize),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          onPressed: () {
            HapticFeedback.selectionClick();
            notifier.applyIsometrySymmetryV();
          },
          tooltip: GameIcons.isometrySymmetryV.tooltip,
          color: GameIcons.isometrySymmetryV.color,
        ),
        // Supprimer (si pièce placée)
        if (hasDeleteButton)
          IconButton(
            icon: Icon(GameIcons.removePiece.icon, size: iconSize),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () {
              HapticFeedback.selectionClick();
              notifier.removePlacedPiece(state.selectedPlacedPiece!);
            },
            tooltip: GameIcons.removePiece.tooltip,
            color: GameIcons.removePiece.color,
          ),
      ],
    );
  }

  /// Helper: bouton d'action isométrie
  Widget _buildIconButton(
      dynamic icon,
      dynamic settings,
      VoidCallback onPressed,
      ) {
    // Taille réduite pour éviter le dépassement en mode paysage (colonne 44px)
    const double iconSize = 24;
    return IconButton(
      icon: Icon(icon.icon, size: iconSize),
      padding: const EdgeInsets.all(6),
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      onPressed: () {
        HapticFeedback.selectionClick();
        onPressed();
      },
      tooltip: icon.tooltip,
      color: icon.color,
    );
  }

  // ============================================================================
  // HELPERS
  // ============================================================================

  /// Affiche le nombre de solutions
  Widget _buildSolutionCountWidget(PentoscopeState state) {
    final count = state.puzzle?.solutionCount ?? 0;
    return Text(
      '$count solution${count != 1 ? "s" : ""}',
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.black87,
      ),
    );
  }

  /// Construit le slider avec DragTarget (drag pièce vers slider = suppression)
  Widget _buildSliderWithDragTarget({
    required WidgetRef ref,
    required bool isLandscape,
    required Widget sliderChild,
    required BoxDecoration decoration,
    double? width,
    double? height,
  }) {
    final state = ref.watch(pentoscopeProvider);
    final notifier = ref.read(pentoscopeProvider.notifier);

    return DragTarget<Pento>(
      onWillAcceptWithDetails: (details) {
        // Accepter seulement si c'est une pièce placée
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
        // Highlight visuel au survol
        final isHovering = candidateData.isNotEmpty;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: width,
          height: height,
          decoration: decoration.copyWith(
            border: isHovering
                ? Border.all(color: Colors.red.shade400, width: 3)
                : null,
            color: isHovering ? Colors.red.shade50 : decoration.color,
          ),
          child: Stack(
            children: [
              sliderChild,
              // Icône poubelle au survol
              if (isHovering)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      color: Colors.red.withOpacity(0.1),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.delete_outline,
                            color: Colors.red.shade700,
                            size: 32,
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

  // ============================================================================
  // LAYOUTS
  // ============================================================================

  /// Layout portrait : plateau en haut, actions + slider en bas
  Widget _buildPortraitLayout(
      BuildContext context,
      WidgetRef ref,
      PentoscopeState state,
      PentoscopeNotifier notifier,
      bool isSliderPieceSelected,
      bool isPlacedPieceSelected,
      ) {
    return Column(
      children: [
        // Plateau de jeu
        const Expanded(flex: 3, child: PentoscopeBoard(isLandscape: false)),

        // Slider de pièces horizontal
        _buildSliderWithDragTarget(
          ref: ref,
          isLandscape: false,
          height: 160,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          sliderChild: const PentoscopePieceSlider(isLandscape: false),
        ),
      ],
    );
  }

  /// Layout paysage : plateau à gauche, actions + slider vertical à droite
  Widget _buildLandscapeLayout(
      BuildContext context,
      WidgetRef ref,
      PentoscopeState state,
      PentoscopeNotifier notifier,
      dynamic settings,
      bool isSliderPieceSelected,
      bool isPlacedPieceSelected,
      ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Adapter les tailles selon l'espace disponible (iPad vs iPhone)
        final screenHeight = constraints.maxHeight;
        final actionColumnWidth = (screenHeight * 0.08).clamp(44.0, 70.0);
        final sliderWidth = (screenHeight * 0.18).clamp(100.0, 180.0);
        final iconSize = (screenHeight * 0.045).clamp(20.0, 36.0);

        return Row(
          children: [
            // Plateau de jeu
            const Expanded(child: PentoscopeBoard(isLandscape: true)),

            // Colonne de droite : actions + slider
            Row(
              children: [
                // 🎯 Colonne d'actions (contextuelles)
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
                  child: (isPlacedPieceSelected || isSliderPieceSelected)
                      // 🔑 Mode transformation: icônes pleine hauteur, réparties uniformément
                      ? _buildFullHeightIsometryBar(state, notifier, actionColumnWidth)
                      // Mode normal: actions centrées
                      : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // ⏱️ Chronomètre
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          _formatTime(state.elapsedSeconds),
                          style: TextStyle(
                            fontSize: (iconSize * 0.5).clamp(10.0, 16.0),
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      // Actions générales (reset, close, hint)
                      IconButton(
                        icon: Icon(Icons.games, size: iconSize),
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          notifier.reset();
                        },
                        tooltip: 'Recommencer',
                      ),
                      // 💡 Bouton Hint (lampe)
                      if (!state.isComplete &&
                          state.hasPossibleSolution &&
                          state.availablePieces.isNotEmpty)
                        IconButton(
                          icon: Icon(Icons.lightbulb_outline, size: iconSize),
                          color: Colors.amber,
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            notifier.applyHint();
                          },
                          tooltip: 'Indice',
                        ),
                      // 🎓 Tutoriel
                      IconButton(
                        icon: Icon(Icons.school_outlined, size: iconSize),
                        color: Colors.teal,
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PentoscopeGameWithTutorialScreen(
                                tutorialPath: 'assets/tutorials/01_intro_basics.yaml',
                              ),
                            ),
                          );
                        },
                        tooltip: 'Tutoriel',
                      ),
                      IconButton(
                        icon: Icon(Icons.close, size: iconSize),
                        onPressed: () => Navigator.pop(context),
                        tooltip: 'Retour',
                      ),
                    ],
                  ),
                ),

                // Slider de pièces vertical
                _buildSliderWithDragTarget(
                  ref: ref,
                  isLandscape: true,
                  width: sliderWidth,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(-2, 0),
                      ),
                    ],
                  ),
                  sliderChild: const PentoscopePieceSlider(isLandscape: true),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  /// Version adaptative de la barre d'isométries (taille variable)
  Widget _buildIsometryActionsBarAdaptive(
      PentoscopeState state,
      PentoscopeNotifier notifier,
      double iconSize,
      ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Rotation anti-horaire
        IconButton(
          icon: Icon(GameIcons.isometryRotationTW.icon, size: iconSize),
          padding: EdgeInsets.all(iconSize * 0.2),
          constraints: BoxConstraints(minWidth: iconSize + 8, minHeight: iconSize + 8),
          onPressed: () {
            HapticFeedback.selectionClick();
            notifier.applyIsometryRotationTW();
          },
          tooltip: GameIcons.isometryRotationTW.tooltip,
          color: GameIcons.isometryRotationTW.color,
        ),
        // Rotation horaire
        IconButton(
          icon: Icon(GameIcons.isometryRotationCW.icon, size: iconSize),
          padding: EdgeInsets.all(iconSize * 0.2),
          constraints: BoxConstraints(minWidth: iconSize + 8, minHeight: iconSize + 8),
          onPressed: () {
            HapticFeedback.selectionClick();
            notifier.applyIsometryRotationCW();
          },
          tooltip: GameIcons.isometryRotationCW.tooltip,
          color: GameIcons.isometryRotationCW.color,
        ),
        // Symétrie horizontale
        IconButton(
          icon: Icon(GameIcons.isometrySymmetryH.icon, size: iconSize),
          padding: EdgeInsets.all(iconSize * 0.2),
          constraints: BoxConstraints(minWidth: iconSize + 8, minHeight: iconSize + 8),
          onPressed: () {
            HapticFeedback.selectionClick();
            notifier.applyIsometrySymmetryH();
          },
          tooltip: GameIcons.isometrySymmetryH.tooltip,
          color: GameIcons.isometrySymmetryH.color,
        ),
        // Symétrie verticale
        IconButton(
          icon: Icon(GameIcons.isometrySymmetryV.icon, size: iconSize),
          padding: EdgeInsets.all(iconSize * 0.2),
          constraints: BoxConstraints(minWidth: iconSize + 8, minHeight: iconSize + 8),
          onPressed: () {
            HapticFeedback.selectionClick();
            notifier.applyIsometrySymmetryV();
          },
          tooltip: GameIcons.isometrySymmetryV.tooltip,
          color: GameIcons.isometrySymmetryV.color,
        ),
        // Supprimer (si pièce placée sélectionnée)
        if (state.selectedPlacedPiece != null)
          IconButton(
            icon: Icon(GameIcons.removePiece.icon, size: iconSize),
            padding: EdgeInsets.all(iconSize * 0.2),
            constraints: BoxConstraints(minWidth: iconSize + 8, minHeight: iconSize + 8),
            onPressed: () {
              HapticFeedback.selectionClick();
              notifier.removePlacedPiece(state.selectedPlacedPiece!);
            },
            tooltip: GameIcons.removePiece.tooltip,
            color: GameIcons.removePiece.color,
          ),
      ],
    );
  }

  /// 📏 Affiche le dialogue de changement de taille de plateau
  void _showSizeChangeDialog(BuildContext context, WidgetRef ref) {
    final currentSize = ref.read(pentoscopeProvider).puzzle?.size;
    final notifier = ref.read(pentoscopeProvider.notifier);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Changer la taille du plateau'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Sélectionnez la nouvelle taille :'),
            const SizedBox(height: 16),
            ...PentoscopeSize.values.map((size) => RadioListTile<PentoscopeSize>(
              title: Text('${size.label} (${size.width}x${size.height})'),

              value: size,
              groupValue: currentSize,
              onChanged: (value) {
                Navigator.pop(context);
                if (value != null && value != currentSize) {
                  notifier.changeBoardSize(value);
                }
              },
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
  }

  /// 👥 Navigation vers le mode multijoueur
  void _navigateToMultiplayer(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PentoscopeMPLobbyScreen(),
      ),
    );
  }
}