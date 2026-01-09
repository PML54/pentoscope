// lib/tutorial/commands/board_selection_commands.dart
// Commandes de sélection sur le plateau

import 'package:pentapol/tutorial/models/scratch_command.dart';
import 'package:pentapol/tutorial/models/tutorial_context.dart';

/// SELECT_PIECE_ON_BOARD_AT
class SelectPieceOnBoardAtCommand extends ScratchCommand {
  final int x;
  final int y;

  const SelectPieceOnBoardAtCommand({required this.x, required this.y});

  @override
  Future<void> execute(TutorialContext context) async {
    context.gameNotifier.selectPlacedPieceAtForTutorial(x, y);
  }

  @override
  String get name => 'SELECT_PIECE_ON_BOARD_AT';

  @override
  String get description => 'Sélectionne la pièce à ($x, $y)';

  factory SelectPieceOnBoardAtCommand.fromMap(Map<String, dynamic> params) {
    return SelectPieceOnBoardAtCommand(
      x: params['x'] as int,
      y: params['y'] as int,
    );
  }
}

/// SELECT_PIECE_ON_BOARD_WITH_MASTERCASE
class SelectPieceOnBoardWithMastercaseCommand extends ScratchCommand {
  final int pieceNumber;
  final int mastercaseX;
  final int mastercaseY;

  const SelectPieceOnBoardWithMastercaseCommand({
    required this.pieceNumber,
    required this.mastercaseX,
    required this.mastercaseY,
  });

  @override
  Future<void> execute(TutorialContext context) async {
    context.gameNotifier.selectPlacedPieceWithMastercaseForTutorial(
      pieceNumber,
      mastercaseX,
      mastercaseY,
    );
  }

  @override
  String get name => 'SELECT_PIECE_ON_BOARD_WITH_MASTERCASE';

  @override
  String get description =>
      'Sélectionne la pièce $pieceNumber avec mastercase à ($mastercaseX, $mastercaseY)';

  factory SelectPieceOnBoardWithMastercaseCommand.fromMap(
    Map<String, dynamic> params,
  ) {
    return SelectPieceOnBoardWithMastercaseCommand(
      pieceNumber: params['pieceNumber'] as int,
      mastercaseX: params['mastercaseX'] as int,
      mastercaseY: params['mastercaseY'] as int,
    );
  }
}

/// HIGHLIGHT_PIECE_ON_BOARD
class HighlightPieceOnBoardCommand extends ScratchCommand {
  final int pieceNumber;

  const HighlightPieceOnBoardCommand({required this.pieceNumber});

  @override
  Future<void> execute(TutorialContext context) async {
    context.gameNotifier.highlightPieceOnBoard(pieceNumber);
  }

  @override
  String get name => 'HIGHLIGHT_PIECE_ON_BOARD';

  @override
  String get description => 'Surligne la pièce $pieceNumber sur le plateau';

  factory HighlightPieceOnBoardCommand.fromMap(Map<String, dynamic> params) {
    return HighlightPieceOnBoardCommand(
      pieceNumber: params['pieceNumber'] as int,
    );
  }
}

/// CANCEL_SELECTION
class CancelSelectionCommand extends ScratchCommand {
  const CancelSelectionCommand();

  @override
  Future<void> execute(TutorialContext context) async {
    context.gameNotifier.cancelSelection();
  }

  @override
  String get name => 'CANCEL_SELECTION';

  @override
  String get description => 'Annule la sélection en cours';
}
