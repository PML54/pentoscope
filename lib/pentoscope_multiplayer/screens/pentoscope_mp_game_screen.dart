// lib/pentoscope_multiplayer/screens/pentoscope_mp_game_screen.dart
// Écran de jeu Pentoscope Multiplayer

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pentapol/common/pentominos.dart';
import 'package:pentapol/providers/settings_provider.dart';
import 'package:pentapol/config/game_icons_config.dart';
import 'package:pentapol/pentoscope/pentoscope_provider.dart';
import 'package:pentapol/pentoscope/widgets/pentoscope_board.dart';
import 'package:pentapol/pentoscope/widgets/pentoscope_piece_slider.dart';
import 'package:pentapol/pentoscope_multiplayer/models/pentoscope_mp_state.dart';
import 'package:pentapol/pentoscope_multiplayer/models/pentoscope_mp_messages.dart';
import 'package:pentapol/pentoscope_multiplayer/providers/pentoscope_mp_provider.dart';
import 'package:pentapol/pentoscope_multiplayer/screens/pentoscope_mp_result_screen.dart';

/// ⏱️ Formate le temps en secondes (max 999s) - format compact
String _formatTime(int seconds) {
  final clamped = seconds.clamp(0, 999);
  return '${clamped}s';
}

class PentoscopeMPGameScreen extends ConsumerStatefulWidget {
  const PentoscopeMPGameScreen({super.key});

  @override
  ConsumerState<PentoscopeMPGameScreen> createState() => _PentoscopeMPGameScreenState();
}

class _PentoscopeMPGameScreenState extends ConsumerState<PentoscopeMPGameScreen> {
  // 👁️ Afficher les mini-plateaux adversaires
  bool _showOpponents = true;
  
  // 📍 Positions des overlays (draggables)
  final Map<String, Offset?> _overlayPositions = {};

  @override
  void initState() {
    super.initState();
    
    // Initialiser le puzzle local avec le seed partagé
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initLocalPuzzle();
    });
  }

  void _initLocalPuzzle() {
    final mpState = ref.read(pentoscopeMPProvider);
    
    if (mpState.seed != null && mpState.config != null) {
      // Générer le puzzle avec le même seed que les autres joueurs
      ref.read(pentoscopeProvider.notifier).startPuzzleFromSeed(
        mpState.config!.toPentoscopeSize(),
        mpState.seed!,
        mpState.pieceIds ?? [],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mpState = ref.watch(pentoscopeMPProvider);
    final localState = ref.watch(pentoscopeProvider);
    final localNotifier = ref.read(pentoscopeProvider.notifier);
    final settings = ref.watch(settingsProvider);

    // Navigation vers résultats quand terminé
    ref.listen<PentoscopeMPState>(pentoscopeMPProvider, (prev, next) {
      if (next.gameState == PentoscopeMPGameState.finished) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const PentoscopeMPResultScreen()),
        );
      }
    });

    // Sync progression vers le serveur
    ref.listen<PentoscopeState>(pentoscopeProvider, (prev, next) {
      if (prev?.placedPieces.length != next.placedPieces.length) {
        // Convertir les pièces placées en PlacedPieceSummary
        final placedPieces = next.placedPieces.map((p) => PlacedPieceSummary(
          pieceId: p.piece.id,
          x: p.gridX,
          y: p.gridY,
          positionIndex: p.positionIndex,
        )).toList();
        
        ref.read(pentoscopeMPProvider.notifier).updateProgress(
          next.placedPieces.length,
          placedPieces: placedPieces,
        );
        
        // Si puzzle terminé, notifier le serveur
        if (next.isComplete && !(prev?.isComplete ?? false)) {
          ref.read(pentoscopeMPProvider.notifier).complete();
        }
      }
    });

    // Mode transformation
    final isPlacedPieceSelected = localState.selectedPlacedPiece != null;
    final isSliderPieceSelected = localState.selectedPiece != null;
    final isLandscape = MediaQuery.of(context).size.width > MediaQuery.of(context).size.height;

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
                leading: (isPlacedPieceSelected || isSliderPieceSelected)
                    ? null
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // ❌ Bouton quitter
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () => _showQuitDialog(context, ref),
                            tooltip: 'Quitter',
                          ),
                          // ⏱️ Chronomètre
                          Text(
                            _formatTime(mpState.elapsedSeconds),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                leadingWidth: (isPlacedPieceSelected || isSliderPieceSelected) ? 0 : 100,
                title: (isPlacedPieceSelected || isSliderPieceSelected)
                    ? _buildFullWidthIsometryBar(localState, localNotifier)
                    : _buildPlayersProgress(mpState),
                centerTitle: true,
                actions: (isPlacedPieceSelected || isSliderPieceSelected)
                    ? null
                    : [
                        // 💡 Indicateur solution possible (lampe)
                        if (!localState.isComplete && localState.availablePieces.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Icon(
                              localState.hasPossibleSolution 
                                  ? Icons.lightbulb 
                                  : Icons.lightbulb_outline,
                              color: localState.hasPossibleSolution 
                                  ? Colors.amber 
                                  : Colors.grey.shade400,
                              size: 24,
                            ),
                          ),
                        // 👁️ Toggle adversaires
                        IconButton(
                          icon: Icon(
                            _showOpponents ? Icons.visibility : Icons.visibility_off,
                            color: _showOpponents ? Colors.blue : Colors.grey,
                          ),
                          onPressed: () {
                            HapticFeedback.selectionClick();
                            setState(() => _showOpponents = !_showOpponents);
                          },
                        ),
                      ],
              ),
            ),
      body: Stack(
        children: [
          // Contenu principal (réutilise les widgets Pentoscope)
          LayoutBuilder(
            builder: (context, constraints) {
              final isLandscape = constraints.maxWidth > constraints.maxHeight;
              
              if (isLandscape) {
                return _buildLandscapeLayout(
                  context, ref, localState, localNotifier, settings,
                  isSliderPieceSelected, isPlacedPieceSelected, mpState,
                );
              } else {
                return _buildPortraitLayout(
                  context, ref, localState, localNotifier,
                  isSliderPieceSelected, isPlacedPieceSelected, mpState,
                );
              }
            },
          ),
          
          // Countdown overlay
          if (mpState.gameState == PentoscopeMPGameState.countdown)
            _buildCountdownOverlay(mpState),
          
          // Mini-plateaux adversaires
          if (_showOpponents && mpState.gameState == PentoscopeMPGameState.playing)
            ..._buildOpponentOverlays(context, mpState, settings),
        ],
      ),
    );
  }

  // ==========================================================================
  // COUNTDOWN OVERLAY
  // ==========================================================================

  Widget _buildCountdownOverlay(PentoscopeMPState state) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: TweenAnimationBuilder<double>(
          key: ValueKey(state.countdownValue),
          tween: Tween(begin: 1.5, end: 1.0),
          duration: const Duration(milliseconds: 500),
          curve: Curves.elasticOut,
          builder: (context, scale, child) {
            return Transform.scale(
              scale: scale,
              child: Text(
                state.countdownValue == 0 ? 'GO!' : '${state.countdownValue}',
                style: TextStyle(
                  fontSize: 120,
                  fontWeight: FontWeight.bold,
                  color: state.countdownValue == 0 ? Colors.green : Colors.white,
                  shadows: const [
                    Shadow(color: Colors.black, blurRadius: 20),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ==========================================================================
  // PROGRESS BAR
  // ==========================================================================

  Widget _buildPlayersProgress(PentoscopeMPState state) {
    final totalPieces = state.config?.pieceCount ?? 5;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: state.players.map((player) {
        final progress = player.placedCount / totalPieces;
        final color = player.isMe ? Colors.blue : Colors.orange;
        
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                player.isMe ? 'Moi' : player.name.substring(0, min(4, player.name.length)),
                style: TextStyle(
                  fontSize: 10,
                  color: color,
                  fontWeight: player.isMe ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              const SizedBox(height: 2),
              SizedBox(
                width: 40,
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              ),
              Text(
                '${player.placedCount}/$totalPieces',
                style: const TextStyle(fontSize: 8),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ==========================================================================
  // OPPONENT OVERLAYS
  // ==========================================================================

  List<Widget> _buildOpponentOverlays(
    BuildContext context,
    PentoscopeMPState mpState,
    dynamic settings,
  ) {
    final opponents = mpState.opponents;
    if (opponents.isEmpty) return [];

    final screenSize = MediaQuery.of(context).size;
    final isLandscape = screenSize.width > screenSize.height;
    
    // Taille du mini-plateau
    final overlaySize = isLandscape 
        ? screenSize.height * 0.25 
        : screenSize.width * 0.28;

    return opponents.asMap().entries.map((entry) {
      final index = entry.key;
      final opponent = entry.value;
      
      // Position par défaut (empilées verticalement à droite)
      final defaultX = screenSize.width - overlaySize - 8;
      final defaultY = 60.0 + (index * (overlaySize + 8));
      
      final currentPos = _overlayPositions[opponent.id];
      final currentX = currentPos?.dx ?? defaultX;
      final currentY = currentPos?.dy ?? defaultY;

      return Positioned(
        left: currentX,
        top: currentY,
        child: GestureDetector(
          onPanUpdate: (details) {
            setState(() {
              final newX = (currentX + details.delta.dx)
                  .clamp(0.0, screenSize.width - overlaySize);
              final newY = (currentY + details.delta.dy)
                  .clamp(0.0, screenSize.height - overlaySize - 60);
              _overlayPositions[opponent.id] = Offset(newX, newY);
            });
          },
          onDoubleTap: () {
            HapticFeedback.selectionClick();
            setState(() {
              _overlayPositions[opponent.id] = null;
            });
          },
          child: _buildOpponentMiniBoard(opponent, mpState, settings, overlaySize),
        ),
      );
    }).toList();
  }

  Widget _buildOpponentMiniBoard(
    MPPlayer opponent,
    PentoscopeMPState mpState,
    dynamic settings,
    double size,
  ) {
    final config = mpState.config;
    if (config == null) return const SizedBox();

    final boardWidth = config.width;
    final boardHeight = config.height;
    final totalPieces = config.pieceCount;
    
    final availableSize = size - 24;
    final maxDimension = max(boardWidth, boardHeight);
    final cellSize = availableSize / maxDimension;

    // Couleur selon l'état
    final borderColor = opponent.isCompleted 
        ? Colors.green 
        : opponent.placedCount > 0 ? Colors.orange : Colors.grey;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          children: [
            // Grille avec les vraies pièces de l'adversaire
            Padding(
              padding: const EdgeInsets.only(top: 22),
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
                      
                      // Chercher si une pièce occupe cette cellule
                      final pieceId = _getPieceAtPosition(opponent.placedPieces, x, y);
                      
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
            ),
            
            // Header
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: opponent.isCompleted 
                        ? [Colors.green.shade600, Colors.green.shade400]
                        : [Colors.orange.shade600, Colors.orange.shade400],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.drag_indicator, color: Colors.white.withOpacity(0.7), size: 10),
                        const SizedBox(width: 2),
                        Text(
                          opponent.name.length > 8 
                              ? '${opponent.name.substring(0, 8)}...' 
                              : opponent.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (opponent.isCompleted)
                          const Icon(Icons.check_circle, color: Colors.white, size: 12),
                        if (opponent.rank != null)
                          Text(
                            ' #${opponent.rank}',
                            style: const TextStyle(color: Colors.white, fontSize: 9),
                          ),
                        if (!opponent.isCompleted)
                          Text(
                            '${opponent.placedCount}/$totalPieces',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // HELPERS
  // ==========================================================================

  /// Affiche une dialog de confirmation pour quitter
  Future<void> _showQuitDialog(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quitter la partie ?'),
        content: const Text(
          'Tu vas abandonner la partie en cours.\nLes autres joueurs continueront sans toi.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Quitter'),
          ),
        ],
      ),
    );

    if (result == true && context.mounted) {
      await ref.read(pentoscopeMPProvider.notifier).leaveRoom();
      if (context.mounted) {
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    }
  }

  /// Récupère l'ID de la pièce à une position donnée sur le mini-plateau
  int? _getPieceAtPosition(List<MPPlacedPiece> placedPieces, int x, int y) {
    for (final placed in placedPieces) {
      // Récupérer le pentomino
      final pento = pentominos.firstWhere(
        (p) => p.id == placed.pieceId,
        orElse: () => pentominos.first,
      );
      
      // Récupérer les cellules de la pièce dans cette orientation (cartesianCoords)
      final posIndex = placed.positionIndex.clamp(0, pento.cartesianCoords.length - 1);
      final cells = pento.cartesianCoords[posIndex];
      
      // Vérifier si (x, y) est dans les cellules absolues
      for (final cell in cells) {
        final absX = placed.x + cell[0];
        final absY = placed.y + cell[1];
        if (absX == x && absY == y) {
          return placed.pieceId;
        }
      }
    }
    return null;
  }

  // ==========================================================================
  // LAYOUTS (adaptés de pentoscope_game_screen.dart)
  // ==========================================================================

  Widget _buildPortraitLayout(
    BuildContext context,
    WidgetRef ref,
    PentoscopeState state,
    PentoscopeNotifier notifier,
    bool isSliderPieceSelected,
    bool isPlacedPieceSelected,
    PentoscopeMPState mpState,
  ) {
    return Column(
      children: [
        // Plateau
        Expanded(
          child: Center(
            child: PentoscopeBoard(
              isLandscape: false,
            ),
          ),
        ),
        
        // Slider
        Container(
          height: 140,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            border: Border(top: BorderSide(color: Colors.grey.shade300)),
          ),
          child: PentoscopePieceSlider(
            isLandscape: false,
          ),
        ),
      ],
    );
  }

  Widget _buildLandscapeLayout(
    BuildContext context,
    WidgetRef ref,
    PentoscopeState state,
    PentoscopeNotifier notifier,
    dynamic settings,
    bool isSliderPieceSelected,
    bool isPlacedPieceSelected,
    PentoscopeMPState mpState,
  ) {
    return Row(
      children: [
        // Colonne gauche: actions + chrono
        SizedBox(
          width: 50,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Chrono
              Text(
                _formatTime(mpState.elapsedSeconds),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              
              // 💡 Indicateur solution possible
              if (!state.isComplete && state.availablePieces.isNotEmpty)
                Icon(
                  state.hasPossibleSolution 
                      ? Icons.lightbulb 
                      : Icons.lightbulb_outline,
                  color: state.hasPossibleSolution 
                      ? Colors.amber 
                      : Colors.grey.shade400,
                  size: 20,
                ),
              
              const SizedBox(height: 8),
              
              // Toggle adversaires
              IconButton(
                icon: Icon(
                  _showOpponents ? Icons.visibility : Icons.visibility_off,
                  color: _showOpponents ? Colors.blue : Colors.grey,
                  size: 20,
                ),
                onPressed: () {
                  setState(() => _showOpponents = !_showOpponents);
                },
              ),
              
              const Spacer(),
              
              // Actions isométrie (si sélection)
              if (isPlacedPieceSelected || isSliderPieceSelected)
                _buildFullHeightIsometryBar(state, notifier, 50),
              
              const Spacer(),
              
              // ❌ Bouton quitter
              IconButton(
                icon: const Icon(Icons.close, color: Colors.red, size: 20),
                onPressed: () => _showQuitDialog(context, ref),
                tooltip: 'Quitter',
              ),
            ],
          ),
        ),
        
        // Plateau
        Expanded(
          child: Center(
            child: PentoscopeBoard(
              isLandscape: true,
            ),
          ),
        ),
        
        // Slider vertical
        Container(
          width: 120,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            border: Border(left: BorderSide(color: Colors.grey.shade300)),
          ),
          child: PentoscopePieceSlider(
            isLandscape: true,
          ),
        ),
      ],
    );
  }

  // ==========================================================================
  // ISOMETRY BARS (copiés de pentoscope_game_screen.dart)
  // ==========================================================================

  Widget _buildFullWidthIsometryBar(PentoscopeState state, PentoscopeNotifier notifier) {
    const double iconSize = 42.0;
    final hasDeleteButton = state.selectedPlacedPiece != null;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          icon: Icon(GameIcons.isometryRotationTW.icon, size: iconSize),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          onPressed: () {
            HapticFeedback.selectionClick();
            notifier.applyIsometryRotationTW();
          },
          color: GameIcons.isometryRotationTW.color,
        ),
        IconButton(
          icon: Icon(GameIcons.isometryRotationCW.icon, size: iconSize),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          onPressed: () {
            HapticFeedback.selectionClick();
            notifier.applyIsometryRotationCW();
          },
          color: GameIcons.isometryRotationCW.color,
        ),
        IconButton(
          icon: Icon(GameIcons.isometrySymmetryH.icon, size: iconSize),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          onPressed: () {
            HapticFeedback.selectionClick();
            notifier.applyIsometrySymmetryH();
          },
          color: GameIcons.isometrySymmetryH.color,
        ),
        IconButton(
          icon: Icon(GameIcons.isometrySymmetryV.icon, size: iconSize),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          onPressed: () {
            HapticFeedback.selectionClick();
            notifier.applyIsometrySymmetryV();
          },
          color: GameIcons.isometrySymmetryV.color,
        ),
        if (hasDeleteButton)
          IconButton(
            icon: Icon(GameIcons.removePiece.icon, size: iconSize),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () {
              HapticFeedback.selectionClick();
              notifier.removePlacedPiece(state.selectedPlacedPiece!);
            },
            color: GameIcons.removePiece.color,
          ),
      ],
    );
  }

  Widget _buildFullHeightIsometryBar(
    PentoscopeState state,
    PentoscopeNotifier notifier,
    double columnWidth,
  ) {
    final iconSize = (columnWidth * 0.75).clamp(28.0, 50.0);
    final hasDeleteButton = state.selectedPlacedPiece != null;
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          icon: Icon(GameIcons.isometryRotationTW.icon, size: iconSize),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          onPressed: () {
            HapticFeedback.selectionClick();
            notifier.applyIsometryRotationTW();
          },
          color: GameIcons.isometryRotationTW.color,
        ),
        IconButton(
          icon: Icon(GameIcons.isometryRotationCW.icon, size: iconSize),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          onPressed: () {
            HapticFeedback.selectionClick();
            notifier.applyIsometryRotationCW();
          },
          color: GameIcons.isometryRotationCW.color,
        ),
        IconButton(
          icon: Icon(GameIcons.isometrySymmetryH.icon, size: iconSize),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          onPressed: () {
            HapticFeedback.selectionClick();
            notifier.applyIsometrySymmetryH();
          },
          color: GameIcons.isometrySymmetryH.color,
        ),
        IconButton(
          icon: Icon(GameIcons.isometrySymmetryV.icon, size: iconSize),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          onPressed: () {
            HapticFeedback.selectionClick();
            notifier.applyIsometrySymmetryV();
          },
          color: GameIcons.isometrySymmetryV.color,
        ),
        if (hasDeleteButton)
          IconButton(
            icon: Icon(GameIcons.removePiece.icon, size: iconSize),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () {
              HapticFeedback.selectionClick();
              notifier.removePlacedPiece(state.selectedPlacedPiece!);
            },
            color: GameIcons.removePiece.color,
          ),
      ],
    );
  }
}

