// lib/tutorial/commands/highlight_commands.dart
// Commandes de surlignage de cases

import 'package:flutter/material.dart';
import 'package:pentapol/tutorial/models/scratch_command.dart';
import 'package:pentapol/tutorial/models/tutorial_context.dart';
import 'package:pentapol/common/point.dart'; // ← AJOUTER cette ligne

/// HIGHLIGHT_CELL
class HighlightCellCommand extends ScratchCommand {
  final int x;
  final int y;
  final Color color;

  const HighlightCellCommand({
    required this.x,
    required this.y,
    required this.color,
  });

  @override
  Future<void> execute(TutorialContext context) async {
    context.gameNotifier.highlightCell(x, y, color);
  }

  @override
  String get name => 'HIGHLIGHT_CELL';

  @override
  String get description => 'Surligne la case ($x, $y)';

  factory HighlightCellCommand.fromMap(Map<String, dynamic> params) {
    final xValue = params['x'];
    final yValue = params['y'];

    if (xValue == null || yValue == null) {
      throw FormatException(
        'HIGHLIGHT_CELL: les paramètres x et y sont obligatoires',
      );
    }

    final colorStr = params['color'] as String? ?? 'yellow';
    return HighlightCellCommand(
      x: xValue is int ? xValue : int.parse(xValue.toString()),
      y: yValue is int ? yValue : int.parse(yValue.toString()),
      color: _parseColor(colorStr),
    );
  }

  static Color _parseColor(String colorStr) {
    switch (colorStr.toLowerCase()) {
      case 'yellow':
        return Colors.yellow;
      case 'green':
        return Colors.green;
      case 'blue':
        return Colors.blue;
      case 'red':
        return Colors.red;
      case 'orange':
        return Colors.orange;
      default:
        return Colors.yellow;
    }
  }
}

/// HIGHLIGHT_CELLS
class HighlightCellsCommand extends ScratchCommand {
  final List<Map<String, int>> cells;
  final Color color;

  const HighlightCellsCommand({required this.cells, required this.color});

  @override
  Future<void> execute(TutorialContext context) async {
    for (final cell in cells) {
      context.gameNotifier.highlightCell(cell['x']!, cell['y']!, color);
    }
  }

  @override
  String get name => 'HIGHLIGHT_CELLS';

  @override
  String get description => 'Surligne ${cells.length} cases';

  factory HighlightCellsCommand.fromMap(Map<String, dynamic> params) {
    final cellsList = params['cells'] as List;
    final cells = cellsList.map((c) {
      final cell = c as Map;
      return {'x': cell['x'] as int, 'y': cell['y'] as int};
    }).toList();

    final colorStr = params['color'] as String? ?? 'yellow';
    return HighlightCellsCommand(
      cells: cells,
      color: HighlightCellCommand._parseColor(colorStr),
    );
  }
}

/// HIGHLIGHT_VALID_POSITIONS
class HighlightValidPositionsCommand extends ScratchCommand {
  final int pieceNumber;
  final Color color;

  const HighlightValidPositionsCommand({
    required this.pieceNumber,
    this.color = Colors.green,
  });

  @override
  Future<void> execute(TutorialContext context) async {
    // Convertir pieceNumber en Pento et appeler la méthode
    final pento = _numberToPento(pieceNumber);
    context.gameNotifier.highlightValidPositions(pento, pieceNumber, color);
  }

  @override
  String get name => 'HIGHLIGHT_VALID_POSITIONS';

  @override
  String get description =>
      'Surligne les positions valides pour la pièce $pieceNumber';

  factory HighlightValidPositionsCommand.fromMap(Map<String, dynamic> params) {
    final pieceNum = params['pieceNumber'];

    if (pieceNum == null) {
      throw FormatException(
        'HIGHLIGHT_VALID_POSITIONS: le paramètre pieceNumber est obligatoire',
      );
    }

    final colorStr = params['color'] as String? ?? 'green';
    return HighlightValidPositionsCommand(
      pieceNumber: pieceNum is int ? pieceNum : int.parse(pieceNum.toString()),
      color: HighlightCellCommand._parseColor(colorStr),
    );
  }

  // Conversion pieceNumber -> Pento enum
  static dynamic _numberToPento(int number) {
    const pentos = ['F', 'I', 'L', 'N', 'P', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'];
    if (number >= 1 && number <= 12) {
      return pentos[number - 1];
    }
    return 'I';
  }
}

/// CLEAR_HIGHLIGHTS
class ClearHighlightsCommand extends ScratchCommand {
  const ClearHighlightsCommand();

  @override
  Future<void> execute(TutorialContext context) async {
    context.gameNotifier.clearCellHighlights();
  }

  @override
  String get name => 'CLEAR_HIGHLIGHTS';

  @override
  String get description => 'Efface tous les surlignages';
}

/// HIGHLIGHT_MASTERCASE
class HighlightMastercaseCommand extends ScratchCommand {
  final int x;
  final int y;

  const HighlightMastercaseCommand({required this.x, required this.y});

  @override
  Future<void> execute(TutorialContext context) async {
    context.gameNotifier.highlightMastercase(Point(x, y));
  }

  @override
  String get name => 'HIGHLIGHT_MASTERCASE';

  @override
  String get description => 'Surligne la mastercase à ($x, $y)';

  factory HighlightMastercaseCommand.fromMap(Map<String, dynamic> params) {
    // Accepter 'x' OU 'gridX' (et 'y' OU 'gridY')
    final xValue = params['x'] ?? params['gridX'];
    final yValue = params['y'] ?? params['gridY'];

    if (xValue == null || yValue == null) {
      throw FormatException(
        'HIGHLIGHT_MASTERCASE: les paramètres x/gridX et y/gridY sont obligatoires',
      );
    }

    return HighlightMastercaseCommand(
      x: xValue is int ? xValue : int.parse(xValue.toString()),
      y: yValue is int ? yValue : int.parse(yValue.toString()),
    );
  }
}

/// CLEAR_MASTERCASE_HIGHLIGHT
class ClearMastercaseHighlightCommand extends ScratchCommand {
  const ClearMastercaseHighlightCommand();

  @override
  Future<void> execute(TutorialContext context) async {
    context.gameNotifier.clearMastercaseHighlight();
  }

  @override
  String get name => 'CLEAR_MASTERCASE_HIGHLIGHT';

  @override
  String get description => 'Efface le surlignage de la mastercase';
}