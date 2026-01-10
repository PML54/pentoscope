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

class PentoscopePieceSlider extends ConsumerStatefulWidget {
  final bool isLandscape;

  const PentoscopePieceSlider({
    super.key,
    required this.isLandscape,
  });

  @override
  ConsumerState<PentoscopePieceSlider> createState() => _PentoscopePieceSliderState();

  // Méthode statique pour accéder au state depuis l'extérieur
  static _PentoscopePieceSliderState? of(BuildContext context) {
    return context.findAncestorStateOfType<_PentoscopePieceSliderState>();
  }
}

class _PentoscopePieceSliderState extends ConsumerState<PentoscopePieceSlider> {
  final ScrollController _scrollController = ScrollController();
  int? _highlightedIndex;

  // Méthodes publiques pour le tutoriel
  void highlightPiece(int index) {
    setState(() {
      _highlightedIndex = index;
    });
  }

  void clearHighlight() {
    setState(() {
      _highlightedIndex = null;
    });
  }

  void scrollToPiece(int pieceIndex) {
    // Calculer la position approximative
    final estimatedItemWidth = widget.isLandscape ? 120.0 : 100.0;
    final targetOffset = pieceIndex * estimatedItemWidth;

    _scrollController.animateTo(
      targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
    );
  }

  void selectPiece(int pieceIndex) {
    final state = ref.read(pentoscopeProvider);
    final notifier = ref.read(pentoscopeProvider.notifier);

    if (pieceIndex >= 0 && pieceIndex < state.availablePieces.length) {
      final piece = state.availablePieces[pieceIndex];
      notifier.selectPiece(piece);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ref = context as WidgetRef;
    final state = ref.watch(pentoscopeProvider);
    final notifier = ref.read(pentoscopeProvider.notifier);
    final settings = ref.read(settingsProvider);
    

    final pieces = state.availablePieces;

    if (pieces.isEmpty) {
      return const SizedBox.shrink();
    }

    final scrollDirection = widget.isLandscape ? Axis.vertical : Axis.horizontal;
    final padding = widget.isLandscape
        ? const EdgeInsets.symmetric(vertical: 16, horizontal: 8)
        : const EdgeInsets.symmetric(horizontal: 16, vertical: 12);

    return ListView.builder(
      controller: _scrollController,
      scrollDirection: scrollDirection,
      padding: padding,
      itemCount: pieces.length,
      itemBuilder: (context, index) {
        final piece = pieces[index];
        final isHighlighted = _highlightedIndex == index;

        return Container(
          decoration: isHighlighted ? BoxDecoration(
            border: Border.all(color: Colors.yellow, width: 3),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.yellow.withOpacity(0.5),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ) : null,
          child: _buildDraggablePiece(piece, notifier, state, settings, widget.isLandscape),
        );
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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}