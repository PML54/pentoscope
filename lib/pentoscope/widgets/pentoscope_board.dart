// lib/pentoscope/widgets/pentoscope_board.dart
// Plateau Pentoscope - calqué sur game_board.dart
// v2: Support du snap visuel

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pentapol/common/pentominos.dart';
import 'package:pentapol/pentoscope/pentoscope_provider.dart';

import 'package:pentapol/providers/settings_provider.dart';
import 'package:pentapol/screens/pentomino_game/widgets/shared/piece_border_calculator.dart';
import 'package:pentapol/screens/pentomino_game/widgets/shared/piece_renderer.dart';

class PentoscopeBoard extends ConsumerWidget {
  final bool isLandscape;

  const PentoscopeBoard({super.key, required this.isLandscape});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pentoscopeProvider);
    final notifier = ref.read(pentoscopeProvider.notifier);
    final settings = ref.read(settingsProvider);

    // Informe le provider APRÈS le build (sinon Riverpod assertion).
    // ✅ Ne PAS modifier le provider pendant le build.
    // On reporte l'info d'orientation après la frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifier.setViewOrientation(isLandscape);
    });

    final puzzle = state.puzzle;
    if (puzzle == null) {
      return const Center(child: Text('Aucun puzzle'));
    }

    final boardWidth = puzzle.size.width;
    final boardHeight = puzzle.size.height;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Dimensions visuelles (swap si paysage)
        final visualCols = isLandscape ? boardHeight : boardWidth;
        final visualRows = isLandscape ? boardWidth : boardHeight;

        // Réserver 8px de marge uniquement en portrait (largeur limitée)
        // En paysage, pas besoin de marge car le plateau a plus d'espace
        final availableWidth = isLandscape ? constraints.maxWidth : constraints.maxWidth - 8;
        final cellSize = (availableWidth / visualCols)
            .clamp(0.0, constraints.maxHeight / visualRows)
            .toDouble();

        final gridWidth = cellSize * visualCols;
        final gridHeight = cellSize * visualRows;

        // Offset du plateau centré
        final offsetX = (constraints.maxWidth - gridWidth) / 2;
        final offsetY = (constraints.maxHeight - gridHeight) / 2;

        // DragTarget englobe TOUT l'espace pour capturer le drag partout
        return DragTarget<Pento>(
          onWillAcceptWithDetails: (details) {
            debugPrint('🎯 DragTarget: pièce acceptée depuis slider');
            return true;
          },
          onMove: (details) {
            final renderBox = context.findRenderObject() as RenderBox?;
            if (renderBox == null) return;

            final localOffset = renderBox.globalToLocal(details.offset);

            // Coordonnées relatives au plateau centré
            final plateauX = localOffset.dx - offsetX;
            final plateauY = localOffset.dy - offsetY;

            // TEST: Agrandir drastiquement la zone pour device réel
            const double margin = 100.0; // Marge GIGANTESQUE pour test
            if (plateauX < -margin ||
                plateauX >= gridWidth + margin ||
                plateauY < -margin ||
                plateauY >= gridHeight + margin) {
              debugPrint('❌ LOIN du plateau: plateau=(${plateauX.toInt()},${plateauY.toInt()})');
              return;
            }

            // Debug seulement si on est proche des bords (pour éviter spam)
            if (plateauX < 20 || plateauX > gridWidth - 20 ||
                plateauY < 20 || plateauY > gridHeight - 20) {
              debugPrint('🎯 Drag près bord: plateau=(${plateauX.toInt()},${plateauY.toInt()}) gridSize=${gridWidth}x${gridHeight}');
            }

            final visualX = (plateauX / cellSize).floor().clamp(
              0,
              visualCols - 1,
            );
            final visualY = (plateauY / cellSize).floor().clamp(
              0,
              visualRows - 1,
            );

            int logicalX, logicalY;
            if (isLandscape) {
              logicalX = (visualRows - 1) - visualY;
              logicalY = visualX;
            } else {
              logicalX = visualX;
              logicalY = visualY;
            }

            // Log pour pièce 12 verticale seulement (pour éviter spam)
            if (state.selectedPiece?.id == 12 && state.selectedPositionIndex == 0) {
              debugPrint('🎯 Drag pièce 12 verticale: plateau=(${plateauX.toInt()},${plateauY.toInt()}) visual=(${visualX},${visualY}) logical=(${logicalX},${logicalY})');
            }

            notifier.updatePreview(logicalX, logicalY);
          },
          onLeave: (data) {
            // ✨ BUGFIX: Ne pas appeler clearPreview()
            // Garder le preview quand on sort du DragTarget

            notifier.clearPreview();
            // La pièce reste affichée à sa dernière position valide
          },
          onAcceptWithDetails: (details) {
            final renderBox = context.findRenderObject() as RenderBox?;
            if (renderBox == null) {
              notifier.clearPreview();
              return;
            }

            // ✨ NOUVEAU: Utiliser les coordonnées snappées du preview
            // (pas les coordonnées brutes du drop)
            if (state.previewX == null || state.previewY == null) {
              notifier.clearPreview();
              return;
            }

            // ✨ BUGFIX: tryPlacePiece() s'attend à la position du DOIGT, pas l'ancre
            // previewX/Y sont l'ancre snappée
            // Donc reconstruire: doigt = ancre + mastercase
            int reconstructedDragX = state.previewX!;
            int reconstructedDragY = state.previewY!;

            if (state.selectedCellInPiece != null) {
              reconstructedDragX += state.selectedCellInPiece!.x;  // ✅ Ajouter mastercase
              reconstructedDragY += state.selectedCellInPiece!.y;
            }

            final success = notifier.tryPlacePiece(reconstructedDragX, reconstructedDragY);

            if (success) {
              HapticFeedback.mediumImpact();
              final newState = ref.read(pentoscopeProvider);
              if (newState.isComplete) {
                //       _showVictoryDialog(context, ref);
              }
            } else {
              HapticFeedback.heavyImpact();
            }

            notifier.clearPreview();
          },
          builder: (context, candidateData, rejectedData) {
            return Align(
              // En paysage: aligner en haut pour éviter l'espace
              // En portrait: centrer
              alignment: isLandscape ? Alignment.topCenter : Alignment.center,
              child: Container(
                width: gridWidth,
                height: gridHeight,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.grey.shade50, Colors.grey.shade100],
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
                  child: GridView.builder(
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: visualCols,
                      childAspectRatio: 1.0,
                      crossAxisSpacing: 0,
                      mainAxisSpacing: 0,
                    ),
                    itemCount: boardWidth * boardHeight,
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
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ============================================================================
  // HELPER FUNCTIONS POUR _buildCell - À AJOUTER À LA FIN DE LA CLASSE
  // ============================================================================

  // ============================================================================
  // NOUVELLE FONCTION _buildCell - REFACTORISÉE ET LISIBLE
  // ============================================================================

  Widget _buildCell(
      BuildContext context,
      WidgetRef ref,
      PentoscopeState state,
      PentoscopeNotifier notifier,
      settings,
      int logicalX,
      int logicalY,
      bool isLandscape,
      ) {
    // 1️⃣ RÉCUPÉRER LES DONNÉES DE BASE
    var cellValue = state.plateau.getCell(logicalX, logicalY);

    // 🐛 FIX: Si cette cellule appartient à une pièce sélectionnée (en cours de déplacement),
    // ne pas l'afficher à son ancienne position
    if (state.selectedPlacedPiece != null) {
      // Vérifier si cette cellule fait partie de la pièce sélectionnée
      final selectedPiece = state.selectedPlacedPiece!;
      for (final cell in selectedPiece.absoluteCells) {
        if (cell.x == logicalX && cell.y == logicalY) {
          cellValue = 0; // Masquer cette cellule de la pièce sélectionnée
          break;
        }
      }
    }
    final isSolutionCell = _isSolutionCell(state, logicalX, logicalY);
    final solutionPieceId = _getSolutionPieceIdAt(state, logicalX, logicalY);

    // 2️⃣ DÉTERMINER LA COULEUR DE BASE
    Color cellColor = _getBaseCellColor(
      cellValue,
      isSolutionCell,
      solutionPieceId,
      settings,
    );

    // 3️⃣ DÉTECTER LA PIÈCE SÉLECTIONNÉE
    final selectedInfo = _detectSelectedPlacedPiece(
      state,
      logicalX,
      logicalY,
      cellValue,
      settings,
    );
    bool isSelected = selectedInfo.isSelected;
    bool isReferenceCell = false;

    if (isSelected && selectedInfo.selectedColor != null) {
      cellColor = selectedInfo.selectedColor!;
    }

    // Vérifier mastercase
    if (isSelected && state.selectedCellInPiece != null) {
      // Chercher position locale pour comparer
      final selectedPiece = state.selectedPlacedPiece!;
      final position =
      selectedPiece.piece.positions[state.selectedPositionIndex];
      final minOffset = _getMinOffset(position);

      for (final cellNum in position) {
        final localX = (cellNum - 1) % 5 - minOffset.$1;
        final localY = (cellNum - 1) ~/ 5 - minOffset.$2;
        final pieceX = selectedPiece.gridX + localX;
        final pieceY = selectedPiece.gridY + localY;

        if (pieceX == logicalX && pieceY == logicalY) {
          isReferenceCell =
          (localX == state.selectedCellInPiece!.x &&
              localY == state.selectedCellInPiece!.y);
          break;
        }
      }
    }

    // 4️⃣ DÉTECTER LA PREVIEW
    final previewInfo = _detectPreview(
      state,
      logicalX,
      logicalY,
      isSelected,
      settings,
    );

    if (previewInfo.isPreview && previewInfo.previewColor != null) {
      cellColor = previewInfo.previewColor!;
    }

    // 5️⃣ DÉTERMINER LE TEXTE
    String cellText = _getCellText(cellValue, isSolutionCell, solutionPieceId);

    if (isSelected && selectedInfo.selectedText != null) {
      cellText = selectedInfo.selectedText!;
    } else if (previewInfo.isPreview && previewInfo.previewText != null) {
      cellText = previewInfo.previewText!;
    }

    // 6️⃣ CALCULER LA BORDURE
    Border border = _calculateBorder(
      state,
      // ✅ AJOUTER en premier!
      isReferenceCell,
      previewInfo.isPreview,
      isSelected,
      previewInfo.isSnappedPreview,
      previewInfo.isPreviewValid,
      logicalX,
      logicalY,
      isLandscape,
    );

    // 7️⃣ CRÉER LE WIDGET DE CELLULE
    Widget cellWidget = Container(
      decoration: BoxDecoration(
        color: cellColor,
        border: border,
        boxShadow: previewInfo.isSnappedPreview && previewInfo.isPreviewValid
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
            color: _getTextColor(
              previewInfo.isPreview,
              isSelected,
              previewInfo.isPreviewValid,
              previewInfo.isSnappedPreview,
            ),
            fontWeight: _getTextWeight(previewInfo.isPreview, isSelected),
            fontSize: _getTextSize(isSelected, previewInfo.isPreview),
          ),
        ),
      ),
    );

    // 8️⃣ GÉRER LES INTERACTIONS
    bool isOccupied = cellValue > 0;

    if (isSelected && state.selectedPiece != null) {
      // Pièce sélectionnée: draggable
      cellWidget = Draggable<Pento>(
        data: state.selectedPiece!,
        feedback: Material(
          color: Colors.transparent,
          child: PieceRenderer(
            piece: state.selectedPiece!,
            positionIndex: _getDisplayPositionIndex(
              state.selectedPositionIndex,
              state.selectedPiece!,
              isLandscape,
            ),
            isDragging: true,
            getPieceColor: (pieceId) => settings.ui.getPieceColor(pieceId),
          ),
        ),
        childWhenDragging: Opacity(opacity: 0.3, child: cellWidget),
        child: GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            notifier.selectPlacedPiece(
              state.selectedPlacedPiece!,
              logicalX,
              logicalY,
            );
          },
          onDoubleTap: () {
            HapticFeedback.selectionClick();
            notifier.applyIsometryRotationTW();
          },
          child: cellWidget,
        ),
      );
    } else if (isOccupied && !isSelected) {
      // Pièce placée non sélectionnée: sélectionnable
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
      // Case vide avec pièce sélectionnée: annuler sélection
      cellWidget = GestureDetector(
        onTap: () {
          notifier.cancelSelection();
        },
        child: cellWidget,
      );
    }

    return cellWidget;
  }

  /// Détermine la bordure à afficher
  Border _calculateBorder(
      PentoscopeState state, // ✅ AJOUTER
      bool isReferenceCell,
      bool isPreview,
      bool isSelected,
      bool isSnappedPreview,
      bool isPreviewValid,
      int logicalX,
      int logicalY,
      bool isLandscape,
      ) {
    // Mastercase
    if (isReferenceCell) return Border.all(color: Colors.red, width: 4);

    // Preview
    if (isPreview) {
      if (isPreviewValid) {
        if (isSnappedPreview) {
          return Border.all(color: Colors.cyan.shade400, width: 3);
        } else {
          return Border.all(color: Colors.green, width: 3);
        }
      } else {
        return Border.all(color: Colors.red, width: 3);
      }
    }

    // Pièce sélectionnée
    if (isSelected) return Border.all(color: Colors.amber, width: 3);

    // Bordure fusionnée normale
    return PieceBorderCalculator.calculate(
      logicalX,
      logicalY,
      state.plateau,
      isLandscape,
    );
  }

  /// Détecte si une preview est à cette cellule
  ({
  bool isPreview,
  Color? previewColor,
  String? previewText,
  bool isSnappedPreview,
  bool isPreviewValid,
  })
  _detectPreview(
      PentoscopeState state,
      int logicalX,
      int logicalY,
      bool isSelected,
      dynamic settings,
      ) {
    if (isSelected ||
        state.selectedPiece == null ||
        state.previewX == null ||
        state.previewY == null) {
      return (
      isPreview: false,
      previewColor: null,
      previewText: null,
      isSnappedPreview: false,
      isPreviewValid: false,
      );
    }

    final piece = state.selectedPiece!;
    final position = piece.positions[state.selectedPositionIndex];
    final minOffset = _getMinOffset(position);

    for (final cellNum in position) {
      final localX = (cellNum - 1) % 5 - minOffset.$1;
      final localY = (cellNum - 1) ~/ 5 - minOffset.$2;
      final pieceX = state.previewX! + localX;
      final pieceY = state.previewY! + localY;

      if (pieceX == logicalX && pieceY == logicalY) {
        Color previewColor;
        bool isSnappedPreview = state.isSnapped;

        if (state.isPreviewValid) {
          if (isSnappedPreview) {
            previewColor = settings.ui
                .getPieceColor(piece.id)
                .withValues(alpha: 0.6);
          } else {
            previewColor = settings.ui
                .getPieceColor(piece.id)
                .withValues(alpha: 0.4);
          }
        } else {
          previewColor = Colors.red.withValues(alpha: 0.3);
        }

        return (
        isPreview: true,
        previewColor: previewColor,
        previewText: piece.id.toString(),
        isSnappedPreview: isSnappedPreview,
        isPreviewValid: state.isPreviewValid,
        );
      }
    }

    return (
    isPreview: false,
    previewColor: null,
    previewText: null,
    isSnappedPreview: false,
    isPreviewValid: false,
    );
  }

  /// Détecte si une pièce placée est sélectionnée à cette cellule
  ({bool isSelected, Color? selectedColor, String? selectedText})
  _detectSelectedPlacedPiece(
      PentoscopeState state,
      int logicalX,
      int logicalY,
      int cellValue,
      dynamic settings,
      ) {
    if (state.selectedPlacedPiece == null) {
      return (isSelected: false, selectedColor: null, selectedText: null);
    }

    final selectedPiece = state.selectedPlacedPiece!;
    final position = selectedPiece.piece.positions[state.selectedPositionIndex];
    final minOffset = _getMinOffset(position);

    for (final cellNum in position) {
      final localX = (cellNum - 1) % 5 - minOffset.$1;
      final localY = (cellNum - 1) ~/ 5 - minOffset.$2;
      final pieceX = selectedPiece.gridX + localX;
      final pieceY = selectedPiece.gridY + localY;

      if (pieceX == logicalX && pieceY == logicalY) {
        Color selectedColor = settings.ui.getPieceColor(selectedPiece.piece.id);

        if (cellValue == 0) {
          selectedColor = settings.ui.getPieceColor(selectedPiece.piece.id);
        }

        return (
        isSelected: true,
        selectedColor: selectedColor,
        selectedText: selectedPiece.piece.id.toString(),
        );
      }
    }

    return (isSelected: false, selectedColor: null, selectedText: null);
  }

  /// Détermine la couleur de base de la cellule
  Color _getBaseCellColor(
      int cellValue,
      bool isSolution,
      int? solutionPieceId,
      dynamic settings,
      ) {
    // Bordure de plateau
    if (cellValue == -1) return Colors.grey.shade800;

    // Cellule vide avec solution → afficher couleur VRAIE de la pièce!
    if (cellValue == 0 && isSolution && solutionPieceId != null) {
      return settings.ui
          .getPieceColor(solutionPieceId)
          .withOpacity(0.6); // ✅ COULEUR VRAIE!
    }
    // Cellule vide normale
    if (cellValue == 0) return Colors.grey.shade300;

    // Pièce placée
    return settings.ui.getPieceColor(cellValue);
  }

  /// Texte à afficher dans la cellule
  String _getCellText(int cellValue, bool isSolution, int? solutionPieceId) {
    // Solution: afficher numéro de pièce
    if (isSolution && solutionPieceId != null) {
      return solutionPieceId.toString();
    }

    // Pièce occupée: afficher son numéro
    if (cellValue > 0) return cellValue.toString();

    // Vide: rien
    return '';
  }

  int _getDisplayPositionIndex(
      int positionIndex,
      Pento piece,
      bool isLandscape,
      ) {
    if (isLandscape) {
      return (positionIndex - 1 + piece.numPositions) % piece.numPositions;
    }
    return positionIndex;
  }

  /// Calcule le décalage minimum pour normaliser une forme
  (int, int) _getMinOffset(List<int> position) {
    int minX = 5, minY = 5;
    for (final cellNum in position) {
      final localX = (cellNum - 1) % 5;
      final localY = (cellNum - 1) ~/ 5;
      if (localX < minX) minX = localX;
      if (localY < minY) minY = localY;
    }
    return (minX, minY);
  }

  /// Récupère le numéro de pièce solution à une cellule donnée
  int? _getSolutionPieceIdAt(
      PentoscopeState state,
      int logicalX,
      int logicalY,
      ) {
    if (state.currentSolution == null) return null;

    for (final placement in state.currentSolution!) {
      final piece = pentominos.firstWhere((p) => p.id == placement.pieceId);
      final position = piece.positions[placement.positionIndex];

      // Calculer le minOffset pour normalisation
      int minLocalX = 5, minLocalY = 5;
      for (final cellNum in position) {
        final lx = (cellNum - 1) % 5;
        final ly = (cellNum - 1) ~/ 5;
        if (lx < minLocalX) minLocalX = lx;
        if (ly < minLocalY) minLocalY = ly;
      }

      // Chercher la cellule
      for (final cellNum in position) {
        final localX = (cellNum - 1) % 5 - minLocalX;
        final localY = (cellNum - 1) ~/ 5 - minLocalY;
        final absX = placement.gridX + localX;
        final absY = placement.gridY + localY;

        if (absX == logicalX && absY == logicalY) {
          return placement.pieceId;
        }
      }
    }
    return null;
  }

  /// Couleur du texte selon le contexte
  Color _getTextColor(
      bool isPreview,
      bool isSelected,
      bool isPreviewValid,
      bool isSnappedPreview,
      ) {
    if (isPreview) {
      if (isPreviewValid) {
        return isSnappedPreview ? Colors.cyan.shade900 : Colors.green.shade900;
      } else {
        return Colors.red.shade900;
      }
    }
    return Colors.white;
  }

  /// Taille du texte
  double _getTextSize(bool isSelected, bool isPreview) {
    return (isSelected || isPreview) ? 16.0 : 14.0;
  }

  /// Épaisseur du texte
  FontWeight _getTextWeight(bool isSelected, bool isPreview) {
    return (isSelected || isPreview) ? FontWeight.w900 : FontWeight.bold;
  }

  /// Détecte si cette cellule est une pièce solution
  bool _isSolutionCell(PentoscopeState state, int logicalX, int logicalY) {
    return _getSolutionPieceIdAt(state, logicalX, logicalY) != null;
  }
  void _showVictoryDialog(BuildContext context, WidgetRef ref) {


    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 100),
          child: Material(
            borderRadius: BorderRadius.circular(12),
            elevation: 8,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),

                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          ref.read(pentoscopeProvider.notifier).reset();
                        },
                        child: const Text('Rejouer'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        child: const Text('Menu'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}