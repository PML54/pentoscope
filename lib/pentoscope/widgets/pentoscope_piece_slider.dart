// lib/pentapol/pentoscope/widgets/pentoscope_piece_slider.dart
// Modified: 2512100457
// FIX: Adopter _getDisplayPositionIndex() d'isopento pour rotation paysage stable (-90° compensation)

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pentapol/common/pentominos.dart';
import 'package:pentapol/providers/settings_provider.dart';
import 'package:pentapol/screens/pentomino_game/widgets/shared/draggable_piece_widget.dart';
import 'package:pentapol/screens/pentomino_game/widgets/shared/piece_renderer.dart';
import 'package:pentapol/pentoscope/pentoscope_provider.dart';

class PentoscopePieceSlider extends ConsumerWidget {
  final bool isLandscape;

  const PentoscopePieceSlider({
    super.key,
    required this.isLandscape,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pentoscopeProvider);
    final notifier = ref.read(pentoscopeProvider.notifier);
    final settings = ref.read(settingsProvider);
    

    final pieces = state.availablePieces;

    if (pieces.isEmpty) {
      return const SizedBox.shrink();
    }

    final scrollDirection = isLandscape ? Axis.vertical : Axis.horizontal;
    final padding = isLandscape
        ? const EdgeInsets.symmetric(vertical: 16, horizontal: 8)
        : const EdgeInsets.symmetric(horizontal: 16, vertical: 12);

    return ListView.builder(
      scrollDirection: scrollDirection,
      padding: padding,
      itemCount: pieces.length,
      itemBuilder: (context, index) {
        final piece = pieces[index];
        return _buildDraggablePiece(piece, notifier, state, settings, isLandscape);
      },
    );
  }

  /// Convertit positionIndex interne en displayPositionIndex pour l'affichage
  int _getDisplayPositionIndex(int positionIndex, Pento piece, bool isLandscape) {
    return positionIndex; // ✅ plus de -1 / modulo
  }


  Widget _buildDraggablePiece(
      Pento piece,
      PentoscopeNotifier notifier,
      PentoscopeState state,
      settings,
      bool isLandscape,
      ) {
    // Taille fixe 5x5 pour éviter les chevauchements (cellSize=22, 5*22+8=118)
    const double fixedSize = 118;
    int positionIndex = state.selectedPiece?.id == piece.id
        ? state.selectedPositionIndex
        : state.getPiecePositionIndex(piece.id);

    // Convertir pour l'affichage
    int displayPositionIndex = _getDisplayPositionIndex(positionIndex, piece, isLandscape);

    final isSelected = state.selectedPiece?.id == piece.id;

    return SizedBox(
      width: fixedSize,
      height: fixedSize,
      child: Center(
        child: Transform.rotate(
          angle: isLandscape ? -math.pi / 2 : 0.0,
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
              positionIndex: displayPositionIndex,
              isSelected: isSelected,
              selectedPositionIndex: isSelected ? displayPositionIndex : state.selectedPositionIndex,
              longPressDuration: Duration(milliseconds: settings.game.longPressDuration),
              onSelect: () {
                if (settings.game.enableHaptics) {
                  HapticFeedback.selectionClick();
                }
                notifier.selectPiece(piece);
              },
              onCycle: () {},
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
      ),
    );
  }
}