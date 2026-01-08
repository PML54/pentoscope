// lib/screens/pentomino_game/widgets/shared/action_slider.dart
// Slider vertical d'actions (mode paysage uniquement)
// Adapté automatiquement selon la sélection de pièce

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pentapol/config/game_icons_config.dart';
import 'package:pentapol/config/ui_sizes_config.dart';
import 'package:pentapol/common/plateau.dart';  // ✅ AJOUT
import 'package:pentapol/classical/pentomino_game_provider.dart';
import 'package:pentapol/classical/pentomino_game_state.dart';
import 'package:pentapol/providers/settings_provider.dart';
import 'package:pentapol/screens/solutions_browser_screen.dart';
import 'package:pentapol/services/plateau_solution_counter.dart';

/// ✅ Fonction helper en dehors de la classe
List<BigInt> getCompatibleSolutionsIncludingSelected(PentominoGameState state) {
  if (state.selectedPlacedPiece == null) {
    return state.plateau.getCompatibleSolutionsBigInt();
  }

  final tempPlateau = Plateau.allVisible(6, 10);

  for (final placed in state.placedPieces) {
    final position = placed.piece.positions[placed.positionIndex];
    for (final cellNum in position) {
      final localX = (cellNum - 1) % 5;
      final localY = (cellNum - 1) ~/ 5;
      final x = placed.gridX + localX;
      final y = placed.gridY + localY;
      if (x >= 0 && x < 6 && y >= 0 && y < 10) {
        tempPlateau.setCell(x, y, placed.piece.id);
      }
    }
  }

  final selectedPiece = state.selectedPlacedPiece!;
  final position = selectedPiece.piece.positions[state.selectedPositionIndex];
  for (final cellNum in position) {
    final localX = (cellNum - 1) % 5;
    final localY = (cellNum - 1) ~/ 5;
    final x = selectedPiece.gridX + localX;
    final y = selectedPiece.gridY + localY;
    if (x >= 0 && x < 6 && y >= 0 && y < 10) {
      tempPlateau.setCell(x, y, selectedPiece.piece.id);
    }
  }

  return tempPlateau.getCompatibleSolutionsBigInt();
}

/// Formate le temps en secondes (max 999s)
String _formatTimeCompact(int seconds) {
  final clamped = seconds.clamp(0, 999);
  return '${clamped}s';
}

/// Slider vertical d'actions en mode paysage
class ActionSlider extends ConsumerWidget {
  final bool isLandscape;

  const ActionSlider({
    super.key,
    this.isLandscape = true, // Par défaut true car utilisé principalement en paysage
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pentominoGameProvider);
    final notifier = ref.read(pentominoGameProvider.notifier);
    final settings = ref.watch(settingsProvider);

    // Détection automatique du mode
    final isInTransformMode = state.selectedPiece != null || state.selectedPlacedPiece != null;

    // Adapter les tailles selon l'espace disponible
    return LayoutBuilder(
      builder: (context, constraints) {
        // Taille adaptative des icônes basée sur la hauteur disponible
        final availableHeight = constraints.maxHeight;
        final iconSize = (availableHeight * 0.08).clamp(20.0, 36.0);

    if (isInTransformMode) {
          return _buildTransformActions(context, state, notifier, settings, iconSize);
    } else {
          return _buildGeneralActions(context, state, notifier, iconSize);
    }
      },
    );
  }

  /// Actions en mode TRANSFORMATION (pièce sélectionnée)
  /// ✨ Utilise les mêmes tailles que UISizes pour cohérence portrait/paysage
  Widget _buildTransformActions(
      BuildContext context,
      PentominoGameState state,
      PentominoGameNotifier notifier,
      settings,
      double iconSize,
      ) {
    // ✨ Utiliser UISizes pour cohérence avec le mode portrait
    final effectiveIconSize = UISizes.isometryIconSize;
    final buttonConstraints = UISizes.isometryIconConstraints;
    final buttonPadding = UISizes.isometryIconPadding;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Rotation anti-horaire
        IconButton(
          icon: Icon(GameIcons.isometryRotationTW.icon, size: effectiveIconSize),
          padding: buttonPadding,
          constraints: buttonConstraints,
          onPressed: () {
            HapticFeedback.selectionClick();
            notifier.applyIsometryRotationTW();
          },
          tooltip: GameIcons.isometryRotationTW.tooltip,
          color: GameIcons.isometryRotationTW.color,
        ),

        // Rotation horaire
        IconButton(
          icon: Icon(GameIcons.isometryRotationCW.icon, size: effectiveIconSize),
          padding: buttonPadding,
          constraints: buttonConstraints,
          onPressed: () {
            HapticFeedback.selectionClick();
            notifier.applyIsometryRotationCW();
          },
          tooltip: GameIcons.isometryRotationCW.tooltip,
          color: GameIcons.isometryRotationCW.color,
        ),

        // Symétrie Horizontale (visuelle)
        // ✅ En mode paysage : H visuel = V logique (à cause de la rotation du plateau)
        IconButton(
          icon: Icon(GameIcons.isometrySymmetryH.icon, size: effectiveIconSize),
          padding: buttonPadding,
          constraints: buttonConstraints,
          onPressed: () {
            HapticFeedback.selectionClick();
            if (isLandscape) {
              notifier.applyIsometrySymmetryV(); // Paysage: H visuel = V logique
            } else {
              notifier.applyIsometrySymmetryH(); // Portrait: H visuel = H logique
            }
          },
          tooltip: GameIcons.isometrySymmetryH.tooltip,
          color: GameIcons.isometrySymmetryH.color,
        ),

        // Symétrie Verticale (visuelle)
        // ✅ En mode paysage : V visuel = H logique (à cause de la rotation du plateau)
        IconButton(
          icon: Icon(GameIcons.isometrySymmetryV.icon, size: effectiveIconSize),
          padding: buttonPadding,
          constraints: buttonConstraints,
          onPressed: () {
            HapticFeedback.selectionClick();
            if (isLandscape) {
              notifier.applyIsometrySymmetryH(); // Paysage: V visuel = H logique
            } else {
              notifier.applyIsometrySymmetryV(); // Portrait: V visuel = V logique
            }
          },
          tooltip: GameIcons.isometrySymmetryV.tooltip,
          color: GameIcons.isometrySymmetryV.color,
        ),

        // Delete (uniquement si pièce placée sélectionnée)
        if (state.selectedPlacedPiece != null)
          IconButton(
            icon: Icon(GameIcons.removePiece.icon, size: UISizes.deleteIconSize),
            padding: buttonPadding,
            constraints: buttonConstraints,
            onPressed: () {
              HapticFeedback.mediumImpact();
              notifier.removePlacedPiece(state.selectedPlacedPiece!);
            },
            tooltip: GameIcons.removePiece.tooltip,
            color: GameIcons.removePiece.color,
          ),
      ],
    );
  }

  /// Actions en mode GÉNÉRAL (aucune pièce sélectionnée)
  /// ✨ Utilise les mêmes tailles que UISizes pour cohérence portrait/paysage
  Widget _buildGeneralActions(
      BuildContext context,
      PentominoGameState state,
      PentominoGameNotifier notifier,
      double iconSize,
      ) {
    // ✨ Utiliser UISizes pour cohérence
    final effectiveIconSize = UISizes.appBarIconSize;
    final buttonConstraints = UISizes.isometryIconConstraints;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // ⏱️ Chronomètre compact (secondes, max 999s)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            _formatTimeCompact(state.elapsedSeconds),
            style: const TextStyle(
              fontSize: UISizes.timerFontSize,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),

        // Compteur de solutions
        if (state.solutionsCount != null && state.solutionsCount! > 0 && state.placedPieces.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ElevatedButton(
              onPressed: () {
                HapticFeedback.selectionClick();
                final solutions = state.plateau.getCompatibleSolutionsBigInt();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SolutionsBrowserScreen.forSolutions(
                      solutions: solutions,
                      title: 'Solutions possibles',
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                minimumSize: const Size(40, 32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
              child: Text(
                '${state.solutionsCount}',
                style: const TextStyle(
                  fontSize: UISizes.buttonLabelFontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

        // Bouton Undo
        IconButton(
          icon: Icon(GameIcons.undo.icon, size: effectiveIconSize),
          padding: UISizes.isometryIconPadding,
          constraints: buttonConstraints,
          onPressed: state.placedPieces.isNotEmpty
              ? () {
            HapticFeedback.mediumImpact();
            notifier.undoLastPlacement();
          }
              : null,
          tooltip: GameIcons.undo.tooltip,
        ),

        // Bouton Hint (ampoule)
        IconButton(
          icon: const Icon(Icons.lightbulb),
          iconSize: effectiveIconSize,
          color: Colors.amber.shade700,
          constraints: buttonConstraints,
          padding: UISizes.isometryIconPadding,
          onPressed: () {
            HapticFeedback.selectionClick();
            notifier.applyHint();
          },
          tooltip: 'Indice',
        ),
      ],
    );
  }
}