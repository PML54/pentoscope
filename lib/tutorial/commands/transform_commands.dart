// lib/tutorial/commands/transform_commands.dart
// Commandes de transformation de pièces

import 'package:pentapol/tutorial/models/scratch_command.dart';
import 'package:pentapol/tutorial/models/tutorial_context.dart';

/// ROTATE_AROUND_MASTER
/// Fait pivoter une pièce autour de sa mastercase
///
/// Paramètres :
/// - pieceNumber: numéro de la pièce
/// - quarterTurns: nombre de quarts de tour (1=90°, 2=180°, 3=270°)
/// - direction: 'cw' (horaire) ou 'ccw' (anti-horaire), défaut: 'cw'
/// - duration: durée de l'animation en ms (défaut: 500)
class RotateAroundMasterCommand extends ScratchCommand {
  final int pieceNumber;
  final int quarterTurns;
  final String direction; // 'cw' ou 'ccw'
  final int durationMs;

  const RotateAroundMasterCommand({
    required this.pieceNumber,
    required this.quarterTurns,
    this.direction = 'cw',
    this.durationMs = 500,
  });

  @override
  Future<void> execute(TutorialContext context) async {
    final turns = quarterTurns.abs();

    // Appliquer la rotation dans la bonne direction
    for (int i = 0; i < turns; i++) {
      if (direction.toLowerCase() == 'ccw') {
        // Anti-horaire (Counter-ClockWise)
        context.gameNotifier.applyIsometryRotationTW();
      } else {
        // Horaire (ClockWise) - par défaut
        context.gameNotifier.applyIsometryRotationCW();
      }

      // Petit délai entre chaque quart de tour pour l'animation
      if (i < turns - 1) {
        await Future.delayed(Duration(milliseconds: durationMs ~/ turns));
      }
    }

    await Future.delayed(Duration(milliseconds: durationMs ~/ turns));
  }

  @override
  String get name => 'ROTATE_AROUND_MASTER';

  @override
  String get description {
    final dirStr = direction == 'ccw' ? 'anti-horaire' : 'horaire';
    return 'Fait pivoter la pièce $pieceNumber de ${quarterTurns * 90}° $dirStr';
  }

  factory RotateAroundMasterCommand.fromMap(Map<String, dynamic> params) {
    // Conversion robuste des paramètres
    final pieceNum = params['pieceNumber'];
    final qTurns = params['quarterTurns'];
    final dur = params['duration'];

    if (pieceNum == null) {
      throw FormatException(
        'ROTATE_AROUND_MASTER: le paramètre "pieceNumber" est obligatoire',
      );
    }

    if (qTurns == null) {
      throw FormatException(
        'ROTATE_AROUND_MASTER: le paramètre "quarterTurns" est obligatoire',
      );
    }

    return RotateAroundMasterCommand(
      pieceNumber: pieceNum is int ? pieceNum : int.parse(pieceNum.toString()),
      quarterTurns: qTurns is int ? qTurns : int.parse(qTurns.toString()),
      direction: params['direction'] as String? ?? 'cw',
      durationMs: dur == null
          ? 500
          : (dur is int ? dur : int.parse(dur.toString())),
    );
  }
}

/// SYMMETRY_AROUND_MASTER
/// Applique une symétrie à une pièce autour de sa mastercase
///
/// Paramètres :
/// - pieceNumber: numéro de la pièce
/// - symmetryKind: 'H' (horizontale) ou 'V' (verticale)
/// - duration: durée de l'animation en ms (défaut: 500)
class SymmetryAroundMasterCommand extends ScratchCommand {
  final int pieceNumber;
  final String symmetryKind; // 'H' ou 'V'
  final int durationMs;

  const SymmetryAroundMasterCommand({
    required this.pieceNumber,
    required this.symmetryKind,
    this.durationMs = 500,
  });

  @override
  Future<void> execute(TutorialContext context) async {
    final kind = symmetryKind.toUpperCase();

    if (kind != 'H' && kind != 'V') {
      throw FormatException(
        'SYMMETRY_AROUND_MASTER: symmetryKind doit être "H" ou "V", reçu: "$symmetryKind"',
      );
    }

    // Appliquer symétrie H ou V
    if (kind == 'H') {
      context.gameNotifier.applyIsometrySymmetryH();
    } else {
      context.gameNotifier.applyIsometrySymmetryV();
    }

    await Future.delayed(Duration(milliseconds: durationMs));
  }

  @override
  String get name => 'SYMMETRY_AROUND_MASTER';

  @override
  String get description {
    final axisName = symmetryKind.toUpperCase() == 'H' ? 'horizontale' : 'verticale';
    return 'Applique une symétrie $axisName à la pièce $pieceNumber';
  }

  factory SymmetryAroundMasterCommand.fromMap(Map<String, dynamic> params) {
    // Conversion robuste des paramètres
    final pieceNum = params['pieceNumber'];
    final symKind = params['symmetryKind'];
    final dur = params['duration'];

    if (pieceNum == null) {
      throw FormatException(
        'SYMMETRY_AROUND_MASTER: le paramètre "pieceNumber" est obligatoire',
      );
    }

    if (symKind == null) {
      throw FormatException(
        'SYMMETRY_AROUND_MASTER: le paramètre "symmetryKind" est obligatoire',
      );
    }

    return SymmetryAroundMasterCommand(
      pieceNumber: pieceNum is int ? pieceNum : int.parse(pieceNum.toString()),
      symmetryKind: symKind.toString(),
      durationMs: dur == null
          ? 500
          : (dur is int ? dur : int.parse(dur.toString())),
    );
  }
}