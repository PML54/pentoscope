// lib/tutorial/commands/placement_commands.dart
// Commandes de placement de pièces

import 'package:pentapol/tutorial/models/scratch_command.dart';
import 'package:pentapol/tutorial/models/tutorial_context.dart';

/// PLACE_SELECTED_PIECE_AT
class PlaceSelectedPieceAtCommand extends ScratchCommand {
  final int gridX;
  final int gridY;

  const PlaceSelectedPieceAtCommand({required this.gridX, required this.gridY});

  @override
  Future<void> execute(TutorialContext context) async {
    context.gameNotifier.placeSelectedPieceForTutorial(gridX, gridY);
  }

  @override
  String get name => 'PLACE_SELECTED_PIECE_AT';

  @override
  String get description => 'Place la pièce sélectionnée à ($gridX, $gridY)';

  factory PlaceSelectedPieceAtCommand.fromMap(Map<String, dynamic> params) {
    return PlaceSelectedPieceAtCommand(
      gridX: params['gridX'] as int,
      gridY: params['gridY'] as int,
    );
  }
}

/// REMOVE_PIECE_AT
class RemovePieceAtCommand extends ScratchCommand {
  final int x;
  final int y;

  const RemovePieceAtCommand({required this.x, required this.y});

  @override
  Future<void> execute(TutorialContext context) async {
    final placedPiece = context.gameNotifier.findPlacedPieceAt(x, y);
    if (placedPiece != null) {
      context.gameNotifier.removePlacedPiece(placedPiece);
    }
  }

  @override
  String get name => 'REMOVE_PIECE_AT';

  @override
  String get description => 'Retire la pièce à ($x, $y)';

  factory RemovePieceAtCommand.fromMap(Map<String, dynamic> params) {
    return RemovePieceAtCommand(x: params['x'] as int, y: params['y'] as int);
  }
}
