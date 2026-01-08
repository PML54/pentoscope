// lib/tutorial/widgets/highlighted_icon_button.dart
// Widget wrapper pour IconButton avec surbrillance tutorial

import 'package:flutter/material.dart';

/// Widget qui wrappe un IconButton et affiche une surbrillance animée
/// quand isHighlighted == true
class HighlightedIconButton extends StatefulWidget {
  final Widget child; // L'IconButton à wrapper
  final bool isHighlighted; // true = afficher la surbrillance
  final Color highlightColor; // Couleur de la surbrillance (défaut: yellow)

  const HighlightedIconButton({
    super.key,
    required this.child,
    required this.isHighlighted,
    this.highlightColor = Colors.yellow,
  });

  @override
  State<HighlightedIconButton> createState() => _HighlightedIconButtonState();
}

class _HighlightedIconButtonState extends State<HighlightedIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isHighlighted) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.highlightColor.withOpacity(_animation.value * 0.6),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
            border: Border.all(
              color: widget.highlightColor.withOpacity(_animation.value),
              width: 3,
            ),
          ),
          child: widget.child,
        );
      },
    );
  }
}