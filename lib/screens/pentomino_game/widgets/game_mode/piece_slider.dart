// lib/screens/pentomino_game/widgets/game_mode/piece_slider.dart
// Slider de pièces disponibles (horizontal en portrait, vertical en paysage)

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pentapol/common/pentominos.dart';
import 'package:pentapol/classical/pentomino_game_provider.dart';
import 'package:pentapol/classical/pentomino_game_state.dart';
import 'package:pentapol/providers/settings_provider.dart';
import 'package:pentapol/screens/pentomino_game/utils/game_constants.dart';
import 'package:pentapol/screens/pentomino_game/widgets/shared/draggable_piece_widget.dart';
import 'package:pentapol/screens/pentomino_game/widgets/shared/piece_renderer.dart';

/// Slider de pièces disponibles
///
/// Affiche les pièces non encore placées dans un slider infini.
/// - Portrait: horizontal en bas
/// - Paysage: vertical à droite
class PieceSlider extends ConsumerStatefulWidget {
  final bool isLandscape;

  const PieceSlider({
    super.key,
    required this.isLandscape,
  });

  @override
  ConsumerState<PieceSlider> createState() => _PieceSliderState();
}

class _PieceSliderState extends ConsumerState<PieceSlider> {
  final ScrollController _sliderController = ScrollController();
  int _lastSliderOffset = 0; // ← AJOUTER : tracker le dernier offset

  @override
  void dispose() {
    _sliderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pentominoGameProvider);
    final notifier = ref.read(pentominoGameProvider.notifier);


    // ← AJOUTER : Écouter les changements de sliderOffset
    if (state.sliderOffset != _lastSliderOffset && _sliderController.hasClients) {
      _lastSliderOffset = state.sliderOffset;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_sliderController.hasClients) {
          const itemSize = GameConstants.sliderItemSize;
          final targetOffset = state.sliderOffset * itemSize;
          print('[SLIDER] 📜 Scroll vers offset: $targetOffset (sliderOffset: ${state.sliderOffset})');
          _sliderController.animateTo(
            targetOffset,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      });
    }

    if (state.availablePieces.isEmpty) {
      return const SizedBox.shrink();
    }

    final pieces = state.availablePieces;
    if (pieces.isEmpty) return const SizedBox.shrink();

    final scrollDirection = widget.isLandscape ? Axis.vertical : Axis.horizontal;
    final padding = widget.isLandscape
        ? const EdgeInsets.symmetric(vertical: 16, horizontal: 8)
        : const EdgeInsets.symmetric(horizontal: 16, vertical: 12);

    // Si moins de 4 pièces restantes, afficher simplement la liste
    if (pieces.length < 4) {
      return ListView.builder(
        scrollDirection: scrollDirection,
        padding: padding,
        itemCount: pieces.length,
        itemBuilder: (context, index) {
          final piece = pieces[index];
          return _buildDraggablePiece(piece, notifier, state);
        },
      );
    }

    // Sinon, boucle infinie pour plus de 4 pièces
    const itemsPerPage = GameConstants.sliderItemsPerPage;
    final totalItems = pieces.length * itemsPerPage;

    // Initialiser le scroll au milieu une seule fois
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_sliderController.hasClients && _sliderController.offset == 0) {
        const itemSize = GameConstants.sliderItemSize;
        final middleOffset = (totalItems / 2) * itemSize;
        _sliderController.jumpTo(middleOffset);
      }
    });

    return ListView.builder(
      controller: _sliderController,
      scrollDirection: scrollDirection,
      padding: padding,
      itemCount: totalItems,
      itemBuilder: (context, index) {
        // Utiliser modulo pour boucler sur les pièces
        final pieceIndex = index % pieces.length;
        final piece = pieces[pieceIndex];

        return _buildDraggablePiece(piece, notifier, state);
      },
    );
  }

  /// Construit une pièce draggable
  Widget _buildDraggablePiece(Pento piece, PentominoGameNotifier notifier, PentominoGameState state) {
    // Trouver l'index de position actuel pour cette pièce
    int positionIndex = state.selectedPiece?.id == piece.id
        ? state.selectedPositionIndex
        : state.getPiecePositionIndex(piece.id);

    // ✅ En mode paysage : rotation visuelle de -90° (= +3 positions)
    // pour que les pièces correspondent visuellement à l'orientation du plateau
    int displayPositionIndex = positionIndex;
    if (widget.isLandscape) {
      displayPositionIndex = (positionIndex + 3) % piece.numPositions;
    }

    final isSelected = state.selectedPiece?.id == piece.id;
    final settings = ref.read(settingsProvider);

    // Taille fixe 5x5 pour éviter les chevauchements (cellSize=22, 5*22+8=118)
    const double fixedSize = 118;

    return SizedBox(
      width: fixedSize,
      height: fixedSize,
      child: Center(
      child: Container(
        decoration: BoxDecoration(
          boxShadow: isSelected
              ? [
            BoxShadow(
                      color: Colors.amber.withOpacity(0.7),
                      blurRadius: 14,
                      spreadRadius: 2,
            ),
          ]
              : null,
        ),
          child: DraggablePieceWidget(
          piece: piece,
          positionIndex: positionIndex,
          isSelected: isSelected,
          selectedPositionIndex: state.selectedPositionIndex,
          longPressDuration: Duration(milliseconds: settings.game.longPressDuration),
          onSelect: () {
            if (settings.game.enableHaptics) {
              HapticFeedback.selectionClick();
            }
            notifier.selectPiece(piece);
          },
          onCycle: () {
            if (settings.game.enableHaptics) {
              HapticFeedback.selectionClick();
            }
            notifier.cycleToNextOrientation();
          },
          onCancel: () {
            if (settings.game.enableHaptics) {
              HapticFeedback.lightImpact();
            }
            notifier.cancelSelection();
          },
          childBuilder: (isDragging) => PieceRenderer(
            piece: piece,
              positionIndex: displayPositionIndex,
            isDragging: isDragging,
            getPieceColor: (pieceId) => settings.ui.getPieceColor(pieceId),
            ),
          ),
        ),
      ),
    );
  }
}