// lib/screens/pentomino_game/widgets/shared/game_board.dart
// Plateau de jeu 6×10 avec drag & drop
// v2: Support du snap visuel (bordure cyan + glow)

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pentapol/common/pentominos.dart';
import 'package:pentapol/classical/pentomino_game_provider.dart';
import 'package:pentapol/providers/settings_provider.dart';
import 'package:pentapol/screens/pentomino_game/widgets/shared/piece_border_calculator.dart';
import 'package:pentapol/screens/pentomino_game/widgets/shared/piece_renderer.dart';
import 'package:pentapol/common/point.dart';

/// Plateau de jeu 6×10
///
/// Gère :
/// - Affichage grille avec pièces
/// - Drag & drop des pièces
/// - Preview en temps réel avec SNAP intelligent
/// - Sélection et déplacement
/// - Rotation portrait/paysage
class GameBoard extends ConsumerWidget {
  final bool isLandscape;

  const GameBoard({
    super.key,
    required this.isLandscape,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pentominoGameProvider);
    final notifier = ref.read(pentominoGameProvider.notifier);
    final settings = ref.read(settingsProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Dimensions visuelles
        final visualCols = isLandscape ? 10 : 6;
        final visualRows = isLandscape ? 6 : 10;

        // Réserver 8px de marge uniquement en portrait (largeur limitée)
        // En paysage, pas besoin de marge car le plateau a plus d'espace
        final availableWidth = isLandscape ? constraints.maxWidth : constraints.maxWidth - 8;
        final cellSize = (availableWidth / visualCols)
            .clamp(0.0, constraints.maxHeight / visualRows)
            .toDouble();

        return Align(
          // En paysage: aligner en haut pour éviter l'espace
          // En portrait: centrer
          alignment: isLandscape ? Alignment.topCenter : Alignment.center,
          child: Container(
            width: cellSize * visualCols,
            height: cellSize * visualRows,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.grey.shade50,
                  Colors.grey.shade100,
                ],
              ),
              border: Border.all(
                color: Colors.grey.shade700,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                  spreadRadius: 2,
                ),
              ],
              borderRadius: BorderRadius.circular(16),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  DragTarget<Pento>(
                onWillAcceptWithDetails: (details) => true,
                onMove: (details) {
                  final offset = (context.findRenderObject() as RenderBox?)
                      ?.globalToLocal(details.offset);

                  if (offset != null) {
                    final visualX =
                    (offset.dx / cellSize).floor().clamp(0, visualCols - 1);
                    final visualY =
                    (offset.dy / cellSize).floor().clamp(0, visualRows - 1);

                    int logicalX, logicalY;
                    if (isLandscape) {
                      logicalX = (visualRows - 1) - visualY;
                      logicalY = visualX;
                    } else {
                      logicalX = visualX;
                      logicalY = visualY;
                    }

                    notifier.updatePreview(logicalX, logicalY);
                  }
                },
                onLeave: (data) {
                  notifier.clearPreview();
                },
                onAcceptWithDetails: (details) {
                  // Utiliser la position snappée si disponible.
                  if (state.previewX == null || state.previewY == null) {
                    notifier.clearPreview();
                    return;
                  }

                  int reconstructedDragX = state.previewX!;
                  int reconstructedDragY = state.previewY!;

                  final rawMastercase = notifier.getRawMastercaseCoordsPublic();
                  if (rawMastercase != null) {
                    reconstructedDragX += rawMastercase.x;
                    reconstructedDragY += rawMastercase.y;
                  }

                  final success = notifier.tryPlacePiece(
                    reconstructedDragX,
                    reconstructedDragY,
                  );

                  if (success) {
                    HapticFeedback.mediumImpact();
                  } else {
                    HapticFeedback.heavyImpact();
                  }

                  notifier.clearPreview();
                },
                builder: (context, candidateData, rejectedData) {
                  return GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: visualCols,
                      childAspectRatio: 1.0,
                      crossAxisSpacing: 0,
                      mainAxisSpacing: 0,
                    ),
                    itemCount: 60,
                    itemBuilder: (context, index) {
                      final visualX = index % visualCols;
                      final visualY = index ~/ visualCols;

                      int logicalX, logicalY;
                      if (isLandscape) {
                        logicalX = (visualRows - 1) - visualY;
                        logicalY = visualX;
                      } else {
                        logicalX = visualX;
                        logicalY = visualY;
                      }

                      return _buildCell(
                        context,
                        ref,
                        state,
                        notifier,
                        settings,
                        logicalX,
                        logicalY,
                        isLandscape,
                      );
                    },
                  );
                },
              ),
                  if (state.selectedPlacedPiece != null && state.selectedPiece != null)
                    _buildPieceOverlay(state, notifier, settings, cellSize, visualRows, isLandscape),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Trouve la lettre (A-E) pour une pièce à une position donnée
  String? _findLetterForCell(state, int pieceId, int logicalX, int logicalY) {
    // Chercher dans toutes les pièces placées
    for (final placedPiece in state.placedPieces) {
      if (placedPiece.piece.id == pieceId) {
        final position = placedPiece.piece.orientations[placedPiece.positionIndex];
        for (final cellNum in position) {
          final localX = (cellNum - 1) % 5;
          final localY = (cellNum - 1) ~/ 5;
          final pieceX = placedPiece.gridX + localX;
          final pieceY = placedPiece.gridY + localY;

          if (pieceX == logicalX && pieceY == logicalY) {
            return placedPiece.piece.getLetterForPosition(placedPiece.positionIndex, cellNum);
          }
        }
      }
    }
    return null;
  }

  Widget _buildCell(
      BuildContext context,
      WidgetRef ref,
      state,
      notifier,
      settings,
      int logicalX,
      int logicalY,
      bool isLandscape,
      ) {
    final cellValue = state.plateau.getCell(logicalX, logicalY);
    final isIsometriesMode = state.isIsometriesMode;

    Color cellColor;
    String cellText = '';
    bool isOccupied = false;

    if (cellValue == -1) {
      cellColor = Colors.grey.shade800;
    } else if (cellValue == 0) {
      cellColor = Colors.grey.shade300;
    } else {
      cellColor = settings.ui.getPieceColor(cellValue);
      cellText = cellValue.toString();

      // Ajouter la lettre en mode isométries
      if (isIsometriesMode) {
        final letter = _findLetterForCell(state, cellValue, logicalX, logicalY);
        if (letter != null) {
          cellText += letter;
        }
      }

      isOccupied = true;
    }

    bool isSelected = false;
    bool isPreview = false;
    bool isSnappedPreview = false; // 🆕 Pour le snap

    if (state.selectedPlacedPiece != null) {
      final selectedPiece = state.selectedPlacedPiece!;
      final position =
      selectedPiece.piece.orientations[state.selectedPositionIndex];
      int minLocalX = 5, minLocalY = 5;
      for (final cellNum in position) {
        final lx = (cellNum - 1) % 5;
        final ly = (cellNum - 1) ~/ 5;
        if (lx < minLocalX) minLocalX = lx;
        if (ly < minLocalY) minLocalY = ly;
      }
      for (final cellNum in position) {
        final localX = (cellNum - 1) % 5 - minLocalX;
        final localY = (cellNum - 1) ~/ 5 - minLocalY;
        if (selectedPiece.gridX + localX == logicalX &&
            selectedPiece.gridY + localY == logicalY) {
          isSelected = true;
          break;
        }
      }
    }

    // Pièce sélectionnée : rendue via overlay, cellule grise sur la grille
    if (isSelected) {
      return Container(color: Colors.grey.shade300);
    }

    // Preview avec support du snap
    if (!isSelected &&
        state.selectedPiece != null &&
        state.previewX != null &&
        state.previewY != null) {
      final piece = state.selectedPiece!;
      final position = piece.orientations[state.selectedPositionIndex];

      for (final cellNum in position) {
        final localX = (cellNum - 1) % 5;
        final localY = (cellNum - 1) ~/ 5;
        final pieceX = state.previewX! + localX;
        final pieceY = state.previewY! + localY;

        if (pieceX == logicalX && pieceY == logicalY) {
          isPreview = true;
          isSnappedPreview = state.isSnapped; // 🆕 Récupérer l'état snap

          if (state.isPreviewValid) {
            // 🆕 Couleur légèrement différente pour le snap
            if (isSnappedPreview) {
              // Snap actif : plus opaque pour effet "magnétique"
              cellColor = settings.ui.getPieceColor(piece.id).withValues(alpha: 0.6);
            } else {
              // Position exacte
              cellColor = settings.ui.getPieceColor(piece.id).withValues(alpha: 0.4);
            }
          } else {
            cellColor = Colors.red.withValues(alpha: 0.3);
          }

          cellText = piece.id.toString();

          // Ajouter la lettre en mode isométries
          if (isIsometriesMode) {
            cellText += piece.getLetterForPosition(state.selectedPositionIndex, cellNum);
          }

          break;
        }
      }
    }

    // Bordure avec support du snap
    Border border;
    if (isPreview) {
      if (state.isPreviewValid) {
        if (isSnappedPreview) {
          // 🆕 Snap actif : bordure cyan/turquoise pour indiquer l'aimantation
          border = Border.all(color: Colors.cyan.shade400, width: 3);
        } else {
          // Position exacte valide
          border = Border.all(color: Colors.green, width: 3);
        }
      } else {
        border = Border.all(color: Colors.red, width: 3);
      }
    } else {
      border = PieceBorderCalculator.calculate(
          logicalX, logicalY, state.plateau, isLandscape);
    }

    // Vérifier si la cellule est highlightée (tutoriel)
    final highlightPoint = Point(logicalX, logicalY);
    final highlightColor = state.cellHighlights[highlightPoint];
    if (highlightColor != null) {
      // Superposer la couleur de highlight
      cellColor = Color.alphaBlend(
        highlightColor.withValues(alpha: 0.6),
        cellColor,
      );
    }

    Widget cellWidget = Container(
      decoration: BoxDecoration(
        color: cellColor,
        border: border,
        // 🆕 Effet de glow subtil pour le snap
        boxShadow: isSnappedPreview && state.isPreviewValid
            ? [
          BoxShadow(
            color: Colors.cyan.withValues(alpha: 0.3),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ]
            : null,
      ),
      child: Center(
        child: Text(
          cellText,
          style: TextStyle(
            color: isPreview
                ? (state.isPreviewValid
                ? (isSnappedPreview ? Colors.cyan.shade900 : Colors.green.shade900) // 🆕
                : Colors.red.shade900)
                : Colors.white,
            fontWeight: isPreview ? FontWeight.w900 : FontWeight.bold,
            fontSize: isPreview ? 16 : 14,
          ),
        ),
      ),
    );

    if (isOccupied && !isSelected) {
      cellWidget = GestureDetector(
        onTap: () {
          final piece = notifier.getPlacedPieceAt(logicalX, logicalY);
          if (piece != null) {
            HapticFeedback.selectionClick();
            notifier.selectPlacedPiece(piece, logicalX, logicalY);
          }
        },
        child: cellWidget,
      );
    } else if (!isOccupied && state.selectedPiece != null && cellValue == 0) {
      cellWidget = GestureDetector(
        onTap: () {
          notifier.cancelSelection();
        },
        child: cellWidget,
      );
    }

    return cellWidget;
  }

  /// Overlay unique pour la pièce sélectionnée sur le plateau.
  /// Remplace les 5 Draggables individuels par un seul widget (comme le slider).
  Widget _buildPieceOverlay(
      state, notifier, settings, double cellSize, int visualRows, bool isLandscape) {
    final placed = state.selectedPlacedPiece!;
    final piece = state.selectedPiece!;
    final positionIndex = state.selectedPositionIndex;
    final position = piece.orientations[positionIndex];

    // Normalisation
    int minX = 5, minY = 5;
    for (final cellNum in position) {
      final lx = (cellNum - 1) % 5;
      final ly = (cellNum - 1) ~/ 5;
      if (lx < minX) minX = lx;
      if (ly < minY) minY = ly;
    }

    // Coordonnées visuelles de chaque cellule
    final cells = <({int visX, int visY, int localX, int localY, int cellNum})>[];
    int minVisX = 999, minVisY = 999, maxVisX = 0, maxVisY = 0;
    for (final cellNum in position) {
      final localX = (cellNum - 1) % 5 - minX;
      final localY = (cellNum - 1) ~/ 5 - minY;
      final absX = placed.gridX + localX;
      final absY = placed.gridY + localY;
      final int visX, visY;
      if (isLandscape) {
        visX = absY;
        visY = (visualRows - 1 - absX).toInt();
      } else {
        visX = absX;
        visY = absY;
      }
      cells.add((visX: visX, visY: visY, localX: localX, localY: localY, cellNum: cellNum));
      if (visX < minVisX) minVisX = visX;
      if (visX > maxVisX) maxVisX = visX;
      if (visY < minVisY) minVisY = visY;
      if (visY > maxVisY) maxVisY = visY;
    }

    final overlayW = (maxVisX - minVisX + 1) * cellSize;
    final overlayH = (maxVisY - minVisY + 1) * cellSize;
    final displayIndex = isLandscape
        ? (positionIndex - 1 + piece.numOrientations) % piece.numOrientations
        : positionIndex;

    return Positioned(
      left: minVisX * cellSize,
      top: minVisY * cellSize,
      width: overlayW,
      height: overlayH,
      child: Draggable<Pento>(
        data: piece,
        feedback: Material(
          color: Colors.transparent,
          child: PieceRenderer(
            piece: piece,
            positionIndex: displayIndex,
            isDragging: true,
            getPieceColor: (id) => settings.ui.getPieceColor(id),
          ),
        ),
        childWhenDragging: SizedBox(width: overlayW, height: overlayH),
        child: Stack(
          children: [
            for (final cell in cells)
              Positioned(
                left: (cell.visX - minVisX) * cellSize,
                top: (cell.visY - minVisY) * cellSize,
                width: cellSize,
                height: cellSize,
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    notifier.selectPlacedPiece(
                        placed, placed.gridX + cell.localX, placed.gridY + cell.localY);
                  },
                  onDoubleTap: () {
                    HapticFeedback.selectionClick();
                    notifier.applyIsometryRotation();
                  },
                  child: _buildOverlayCell(
                      cell.localX, cell.localY, cell.cellNum, piece, state, settings),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverlayCell(
      int localX, int localY, int cellNum, piece, state, settings) {
    final isRef = state.selectedCellInPiece != null &&
        localX == state.selectedCellInPiece!.x &&
        localY == state.selectedCellInPiece!.y;
    final pieceColor = settings.ui.getPieceColor(piece.id);

    String cellText = piece.id.toString();
    if (state.isIsometriesMode) {
      cellText += piece.getLetterForPosition(state.selectedPositionIndex, cellNum);
    }

    return Container(
      decoration: BoxDecoration(
        color: pieceColor,
        border: isRef
            ? Border.all(color: Colors.red, width: 4)
            : Border.all(color: Colors.amber, width: 3),
      ),
      child: Center(
        child: Text(
          cellText,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}