// lib/screens/pentomino_game/widgets/shared/piece_renderer.dart
// Widget pour afficher visuellement une pièce de pentomino

import 'package:flutter/material.dart';
import 'package:pentapol/common/pentominos.dart';
import 'package:pentapol/screens/pentomino_game/utils/game_colors.dart';

/// Widget qui affiche une pièce de pentomino
/// 
/// Utilisé dans :
/// - Le slider de pièces
/// - Le feedback de drag
/// - Partout où on doit afficher une pièce
class PieceRenderer extends StatelessWidget {
  final Pento piece;
  final int positionIndex;
  final bool isDragging;
  final Color Function(int pieceId) getPieceColor;

  const PieceRenderer({
    super.key,
    required this.piece,
    required this.positionIndex,
    this.isDragging = false,
    required this.getPieceColor,
  });

  @override
  Widget build(BuildContext context) {
    final position = piece.positions[positionIndex];

    // Convertir les cellNum (1-25) en coordonnées (x, y)
    final coords = position.map((cellNum) {
      final x = (cellNum - 1) % 5;
      final y = (cellNum - 1) ~/ 5;
      return {'x': x, 'y': y};
    }).toList();

    // Calculer les dimensions de la pièce
    int minX = coords[0]['x']!;
    int maxX = coords[0]['x']!;
    int minY = coords[0]['y']!;
    int maxY = coords[0]['y']!;

    for (final coord in coords) {
      final x = coord['x']!;
      final y = coord['y']!;
      if (x < minX) minX = x;
      if (x > maxX) maxX = x;
      if (y < minY) minY = y;
      if (y > maxY) maxY = y;
    }

    final width = maxX - minX + 1;
    final height = maxY - minY + 1;
    const cellSize = 22.0; // Taille des petits carrés (augmentée de 16 à 22)

    return Container(
      width: width * cellSize + 8,
      height: height * cellSize + 8,
      decoration: BoxDecoration(
        boxShadow: isDragging
            ? [
                BoxShadow(
                  color: GameColors.draggingShadowColor,
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ]
            : null,
      ),
      child: Stack(
        children: [
          // Les 5 carrés de la pièce
          for (final coord in coords)
            Positioned(
              left: (coord['x']! - minX) * cellSize + 4,
              top: (coord['y']! - minY) * cellSize + 4,
              child: Container(
                width: cellSize,
                height: cellSize,
                decoration: BoxDecoration(
                  color: getPieceColor(piece.id),
                  border: Border.all(color: GameColors.pieceInnerBorderColor, width: 1.5),
                  borderRadius: BorderRadius.circular(3),
                  boxShadow: [
                    BoxShadow(
                      color: GameColors.shadowColorDark,
                      blurRadius: 2,
                      offset: const Offset(1, 1),
                    ),
                  ],
                ),
                // Numéro de la pièce sur le premier carré
                child: coord == coords.first
                    ? Center(
                        child: Text(
                          piece.id.toString(),
                          style: const TextStyle(
                            color: GameColors.pieceTextColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: Colors.black54,
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      )
                    : null,
              ),
            ),
        ],
      ),
    );
  }
}

