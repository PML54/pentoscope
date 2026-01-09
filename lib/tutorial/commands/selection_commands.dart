// lib/tutorial/commands/selection_commands.dart
// Commandes de sélection dans le slider

import 'package:pentapol/tutorial/models/scratch_command.dart';
import 'package:pentapol/tutorial/models/tutorial_context.dart';

/// SELECT_PIECE_FROM_SLIDER
class SelectPieceFromSliderCommand extends ScratchCommand {
  final int pieceNumber;

  const SelectPieceFromSliderCommand({required this.pieceNumber});

  @override
  Future<void> execute(TutorialContext context) async {
    context.gameNotifier.selectPieceFromSliderForTutorial(pieceNumber);
  }

  @override
  String get name => 'SELECT_PIECE_FROM_SLIDER';

  @override
  String get description => 'Sélectionne la pièce $pieceNumber du slider';

  factory SelectPieceFromSliderCommand.fromMap(Map<String, dynamic> params) {
    final pieceNum = params['pieceNumber'];
    if (pieceNum == null) {
      throw FormatException(
        'SELECT_PIECE_FROM_SLIDER: le paramètre "pieceNumber" est obligatoire',
      );
    }
    return SelectPieceFromSliderCommand(
      pieceNumber: pieceNum is int ? pieceNum : int.parse(pieceNum.toString()),
    );
  }
}

/// HIGHLIGHT_PIECE_IN_SLIDER
class HighlightPieceInSliderCommand extends ScratchCommand {
  final int pieceNumber;

  const HighlightPieceInSliderCommand({required this.pieceNumber});

  @override
  Future<void> execute(TutorialContext context) async {
    context.gameNotifier.highlightPieceInSlider(pieceNumber);
  }

  @override
  String get name => 'HIGHLIGHT_PIECE_IN_SLIDER';

  @override
  String get description => 'Surligne la pièce $pieceNumber dans le slider';

  factory HighlightPieceInSliderCommand.fromMap(Map<String, dynamic> params) {
    final pieceNum = params['pieceNumber'];
    if (pieceNum == null) {
      throw FormatException(
        'HIGHLIGHT_PIECE_IN_SLIDER: le paramètre "pieceNumber" est obligatoire',
      );
    }
    return HighlightPieceInSliderCommand(
      pieceNumber: pieceNum is int ? pieceNum : int.parse(pieceNum.toString()),
    );
  }
}

/// CLEAR_SLIDER_HIGHLIGHT
class ClearSliderHighlightCommand extends ScratchCommand {
  const ClearSliderHighlightCommand();

  @override
  Future<void> execute(TutorialContext context) async {
    context.gameNotifier.clearSliderHighlight();
  }

  @override
  String get name => 'CLEAR_SLIDER_HIGHLIGHT';

  @override
  String get description => 'Efface le surlignage du slider';
}

/// SCROLL_SLIDER
class ScrollSliderCommand extends ScratchCommand {
  final int positions;

  const ScrollSliderCommand({required this.positions});

  @override
  Future<void> execute(TutorialContext context) async {
    context.gameNotifier.scrollSlider(positions);
  }

  @override
  String get name => 'SCROLL_SLIDER';

  @override
  String get description => 'Fait défiler le slider de $positions positions';

  factory ScrollSliderCommand.fromMap(Map<String, dynamic> params) {
    final pos = params['positions'];
    if (pos == null) {
      throw FormatException(
        'SCROLL_SLIDER: le paramètre "positions" est obligatoire',
      );
    }
    return ScrollSliderCommand(
      positions: pos is int ? pos : int.parse(pos.toString()),
    );
  }
}

/// SCROLL_SLIDER_TO_PIECE
class ScrollSliderToPieceCommand extends ScratchCommand {
  final int pieceNumber;

  const ScrollSliderToPieceCommand({required this.pieceNumber});

  @override
  Future<void> execute(TutorialContext context) async {
    context.gameNotifier.scrollSliderToPiece(pieceNumber);
  }

  @override
  String get name => 'SCROLL_SLIDER_TO_PIECE';

  @override
  String get description =>
      'Fait défiler le slider jusqu\'à la pièce $pieceNumber';

  factory ScrollSliderToPieceCommand.fromMap(Map<String, dynamic> params) {
    final pieceNum = params['pieceNumber'];
    if (pieceNum == null) {
      throw FormatException(
        'SCROLL_SLIDER_TO_PIECE: le paramètre "pieceNumber" est obligatoire',
      );
    }
    return ScrollSliderToPieceCommand(
      pieceNumber: pieceNum is int ? pieceNum : int.parse(pieceNum.toString()),
    );
  }
}

/// RESET_SLIDER_POSITION
class ResetSliderPositionCommand extends ScratchCommand {
  const ResetSliderPositionCommand();

  @override
  Future<void> execute(TutorialContext context) async {
    context.gameNotifier.resetSliderPosition();
  }

  @override
  String get name => 'RESET_SLIDER_POSITION';

  @override
  String get description => 'Remet le slider à sa position initiale';
}