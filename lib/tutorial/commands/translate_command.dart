// lib/tutorial/commands/translate_command.dart
// Commande de translation (déplacement) de pièces

import 'package:pentapol/tutorial/models/scratch_command.dart';
import 'package:pentapol/tutorial/models/tutorial_context.dart';

/// TRANSLATE - Translate une pièce vers une nouvelle position
///
/// Déplace une pièce placée vers une nouvelle position en utilisant sa mastercase.
/// La position de départ est détectée automatiquement.
///
/// Paramètres :
/// - pieceNumber: numéro de la pièce à déplacer
/// - toX, toY: position finale de la mastercase
/// - duration: durée de l'animation en ms (défaut: 500)
/// - animated: si true, anime le déplacement case par case (défaut: false)
///
/// Syntaxe YAML :
/// ```yaml
/// - command: TRANSLATE
///   params:
///     pieceNumber: 6
///     toX: 5
///     toY: 7
///     duration: 1500
///     animated: true  # Animation progressive
/// ```
class TranslateCommand extends ScratchCommand {
  final int pieceNumber;
  final int toX;
  final int toY;
  final int durationMs;
  final bool animated;

  const TranslateCommand({
    required this.pieceNumber,
    required this.toX,
    required this.toY,
    this.durationMs = 500,
    this.animated = false,
  });

  @override
  Future<void> execute(TutorialContext context) async {
    // Trouver la pièce sur le plateau
    final gameState = context.gameNotifier.state;
    final targetPiece = gameState.placedPieces.firstWhere(
          (p) => p.piece.id == pieceNumber,
      orElse: () => throw StateError(
        'TRANSLATE: Pièce $pieceNumber non trouvée sur le plateau',
      ),
    );

    // Récupérer la position actuelle (ancre/gridX, gridY)
    final fromX = targetPiece.gridX;
    final fromY = targetPiece.gridY;
    final savedPositionIndex = targetPiece.positionIndex;

    // Calculer le vecteur de translation
    final dx = toX - fromX;
    final dy = toY - fromY;

    print('[TUTORIAL] 📍 Translation pièce $pieceNumber:');
    print('[TUTORIAL]   Position actuelle (ancre): ($fromX, $fromY)');
    print('[TUTORIAL]   Position cible (ancre): ($toX, $toY)');
    print('[TUTORIAL]   Vecteur de translation: (Δx=$dx, Δy=$dy)');
    print('[TUTORIAL]   Mode: ${animated ? "Animé (progressif)" : "Direct (saut)"}');

    if (animated) {
      // ✨ ANIMATION PROGRESSIVE CASE PAR CASE
      await _animatedTranslation(
        context,
        targetPiece,
        fromX,
        fromY,
        toX,
        toY,
        savedPositionIndex,
      );
    } else {
      // 🚀 TRANSLATION DIRECTE (comportement original)
      await _directTranslation(
        context,
        targetPiece,
        fromX,
        fromY,
        toX,
        toY,
        savedPositionIndex,
      );
    }

    print('[TUTORIAL]   ✅ Translation effectuée: ($fromX,$fromY) → ($toX,$toY)');
  }

  /// Translation directe (saut instantané)
  Future<void> _directTranslation(
      TutorialContext context,
      dynamic targetPiece,
      int fromX,
      int fromY,
      int toX,
      int toY,
      int savedPositionIndex,
      ) async {
    // Supprimer la pièce du plateau
    context.gameNotifier.removePlacedPiece(targetPiece);
    await Future.delayed(Duration(milliseconds: durationMs ~/ 4));

    // Sélectionner la pièce depuis le slider
    context.gameNotifier.selectPieceFromSliderForTutorial(pieceNumber);

    // Restaurer l'orientation
    final currentPositionIndex = context.gameNotifier.state.selectedPositionIndex;
    if (currentPositionIndex != savedPositionIndex) {
      final numPositions = targetPiece.piece.numPositions;
      var cycles = (savedPositionIndex - currentPositionIndex) % numPositions;
      if (cycles < 0) cycles += numPositions;

      for (var i = 0; i < cycles; i++) {
        context.gameNotifier.cycleToNextOrientation();
      }
    }

    await Future.delayed(Duration(milliseconds: durationMs ~/ 4));

    // Placer à la nouvelle position
    context.gameNotifier.placeSelectedPieceForTutorial(toX, toY);
    await Future.delayed(Duration(milliseconds: durationMs ~/ 2));
  }

  /// Translation animée (déplacement progressif case par case)
  Future<void> _animatedTranslation(
      TutorialContext context,
      dynamic targetPiece,
      int fromX,
      int fromY,
      int toX,
      int toY,
      int savedPositionIndex,
      ) async {
    final dx = toX - fromX;
    final dy = toY - fromY;

    // Calculer le nombre d'étapes (distance de Manhattan)
    final distance = dx.abs() + dy.abs();
    if (distance == 0) return; // Déjà à la position cible

    print('[TUTORIAL]   🎬 Animation sur $distance étapes');

    // Calculer les positions intermédiaires
    final steps = <(int, int)>[];

    // Stratégie : déplacer d'abord en X, puis en Y (ou l'inverse selon la distance)
    // Pour un mouvement plus naturel, on peut faire une interpolation linéaire

    // Utiliser une interpolation linéaire pour un mouvement diagonal fluide
    for (int step = 1; step <= distance; step++) {
      final progress = step / distance;
      final currentX = fromX + (dx * progress).round();
      final currentY = fromY + (dy * progress).round();

      // Éviter les doublons
      if (steps.isEmpty || steps.last != (currentX, currentY)) {
        steps.add((currentX, currentY));
      }
    }

    // S'assurer que la position finale est bien incluse
    if (steps.isEmpty || steps.last != (toX, toY)) {
      steps.add((toX, toY));
    }

    print('[TUTORIAL]   📍 Chemin: ($fromX,$fromY) → ${steps.map((p) => "(${p.$1},${p.$2})").join(" → ")}');

    // Durée par étape
    final stepDuration = durationMs ~/ (steps.length + 1);

    // Déplacer progressivement
    for (int i = 0; i < steps.length; i++) {
      final (stepX, stepY) = steps[i];

      // Supprimer la pièce de sa position actuelle
      final currentState = context.gameNotifier.state;
      final currentPiece = currentState.placedPieces.firstWhere(
            (p) => p.piece.id == pieceNumber,
        orElse: () => targetPiece,
      );

      context.gameNotifier.removePlacedPiece(currentPiece);
      await Future.delayed(Duration(milliseconds: stepDuration ~/ 3));

      // Resélectionner et replacer
      context.gameNotifier.selectPieceFromSliderForTutorial(pieceNumber);

      // Restaurer l'orientation si nécessaire
      final currentPositionIndex = context.gameNotifier.state.selectedPositionIndex;
      if (currentPositionIndex != savedPositionIndex) {
        final numPositions = targetPiece.piece.numPositions;
        var cycles = (savedPositionIndex - currentPositionIndex) % numPositions;
        if (cycles < 0) cycles += numPositions;
        for (var j = 0; j < cycles; j++) {
          context.gameNotifier.cycleToNextOrientation();
        }
      }

      // Placer à la position intermédiaire
      context.gameNotifier.placeSelectedPieceForTutorial(stepX, stepY);

      print('[TUTORIAL]     ↳ Étape ${i + 1}/${steps.length}: ($stepX, $stepY)');

      await Future.delayed(Duration(milliseconds: (stepDuration * 2) ~/ 3));
    }
  }

  @override
  String get name => 'TRANSLATE';

  @override
  String get description =>
      'Translation de la pièce $pieceNumber vers ($toX,$toY)';

  factory TranslateCommand.fromMap(Map<String, dynamic> params) {
    // Conversion robuste des paramètres
    final pieceNum = params['pieceNumber'];
    final tX = params['toX'];
    final tY = params['toY'];
    final dur = params['duration'];
    final anim = params['animated'];

    // Validation
    if (pieceNum == null) {
      throw FormatException(
        'TRANSLATE: le paramètre "pieceNumber" est obligatoire',
      );
    }
    if (tX == null || tY == null) {
      throw FormatException(
        'TRANSLATE: les paramètres "toX" et "toY" sont obligatoires',
      );
    }

    return TranslateCommand(
      pieceNumber: pieceNum is int ? pieceNum : int.parse(pieceNum.toString()),
      toX: tX is int ? tX : int.parse(tX.toString()),
      toY: tY is int ? tY : int.parse(tY.toString()),
      durationMs: dur == null
          ? 500
          : (dur is int ? dur : int.parse(dur.toString())),
      animated: anim == true || anim == 'true', // Support bool et string
    );
  }
}