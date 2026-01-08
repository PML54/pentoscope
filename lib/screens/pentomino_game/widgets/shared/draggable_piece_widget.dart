// lib/screens/pentomino_game/widgets/shared/draggable_piece_widget.dart
// Widget pour gérer le drag & drop d'une pièce avec double-tap

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pentapol/common/pentominos.dart';

/// Widget pour gérer proprement le double-tap sans propagation
/// 
/// Gère deux modes :
/// - Pièce non sélectionnée : LongPressDraggable (long press pour drag)
/// - Pièce sélectionnée : Draggable normal (drag immédiat)
/// 
/// Interactions :
/// - Tap simple : sélectionner la pièce
/// - Double-tap : faire pivoter (si déjà sélectionnée)
/// - Long press : commencer le drag (si non sélectionnée)
/// - Drag immédiat : si déjà sélectionnée
class DraggablePieceWidget extends StatefulWidget {
  final Pento piece;
  final int positionIndex;
  final bool isSelected;
  final int selectedPositionIndex;
  final Duration longPressDuration;
  final VoidCallback onSelect;
  final VoidCallback onCycle;
  final VoidCallback onCancel;
  final Widget Function(bool isDragging) childBuilder;

  const DraggablePieceWidget({
    super.key,
    required this.piece,
    required this.positionIndex,
    required this.isSelected,
    required this.selectedPositionIndex,
    required this.longPressDuration,
    required this.onSelect,
    required this.onCycle,
    required this.onCancel,
    required this.childBuilder,
  });

  @override
  State<DraggablePieceWidget> createState() => _DraggablePieceWidgetState();
}

class _DraggablePieceWidgetState extends State<DraggablePieceWidget> {
  Timer? _tapTimer;
  bool _isProcessing = false;

  @override
  void dispose() {
    _tapTimer?.cancel();
    super.dispose();
  }

  void _handleTap() {
    // Annuler le timer précédent s'il existe
    _tapTimer?.cancel();

    // Si on est déjà en train de traiter un double-tap, ignorer
    if (_isProcessing) return;

    // Attendre un peu pour voir si c'est un double-tap
    _tapTimer = Timer(const Duration(milliseconds: 300), () {
      // C'était un tap simple → sélectionner la pièce
      if (!widget.isSelected) {
        widget.onSelect();
      }
    });
  }

  void _handleDoubleTap() {
    // Annuler le timer du tap simple
    _tapTimer?.cancel();

    // Éviter les doubles exécutions
    if (_isProcessing) return;
    _isProcessing = true;

    // Si la pièce est déjà sélectionnée dans le slider,
    // le double-tap sert à faire pivoter
    if (widget.isSelected) {
      widget.onCycle();
    } else {
      // Sinon, sélectionner la pièce
      widget.onSelect();
    }

    // Réinitialiser après un court délai
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Si la pièce est déjà sélectionnée, utiliser Draggable normal
    // Sinon, utiliser LongPressDraggable
    if (widget.isSelected) {
      return Draggable<Pento>(
        data: widget.piece,
        onDragStarted: () {
          // Déjà sélectionnée, pas besoin de rappeler onSelect
        },
        onDragEnd: (details) {
          if (!details.wasAccepted) {
            widget.onCancel();
          }
        },
        feedback: Material(
          color: Colors.transparent,
          child: widget.childBuilder(true),
        ),
        childWhenDragging: Opacity(
          opacity: 0.3,
          child: widget.childBuilder(false),
        ),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _handleTap,
          onDoubleTap: _handleDoubleTap,
          child: widget.childBuilder(false),
        ),
      );
    } else {
      return LongPressDraggable<Pento>(
        data: widget.piece,
        delay: widget.longPressDuration,
        onDragStarted: () {
          widget.onSelect();
        },
        onDragEnd: (details) {
          if (!details.wasAccepted) {
            widget.onCancel();
          }
        },
        feedback: Material(
          color: Colors.transparent,
          child: widget.childBuilder(true),
        ),
        childWhenDragging: Opacity(
          opacity: 0.3,
          child: widget.childBuilder(false),
        ),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _handleTap,
          onDoubleTap: _handleDoubleTap,
          child: widget.childBuilder(false),
        ),
      );
    }
  }
}

