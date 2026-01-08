// test/generate_6x10_solutions.dart
// Génère les solutions pour un plateau 6×10
// Crée 2 fichiers binaires :
//   - solutions_6x10_brutes.bin        (toutes les solutions, 45 octets / solution)
//   - solutions_6x10_normalisees.bin   (solutions uniques, 45 octets / solution)

import 'dart:io';
import 'dart:typed_data';
import 'package:pentapol/common/plateau.dart';
import 'package:pentapol/common/pentominos.dart';
import 'package:pentapol/services/pentomino_solver.dart';

const int _boardWidth = 6;
const int _boardHeight = 10;
const int _boardCells = _boardWidth * _boardHeight; // 60
const int _bytesPerSolution = 45; // 60 * 6 bits = 360 bits = 45 octets

void main() async {
  print('═════════════════════════════════════════════════');
  print('GÉNÉRATION DES SOLUTIONS (6×10)');
  print('═════════════════════════════════════════════════\n');

  final plateau = Plateau.allVisible(_boardWidth, _boardHeight);

  print('Configuration:');
  print('  Plateau: 6×10 = 60 cases');
  print('  Pièces: 12 pentominos (5 cases chacun)');
  print('');

  final pieceOrder = [9, 4, 12, 7, 2, 10, 1, 5, 8, 3, 11, 6];

  final solver = PentominoSolver.fromIds(
    plateau: plateau,
    pentominos: pentominos,
    pieceOrder: pieceOrder,
  );

  print('⚠️  ATTENTION: Cela va prendre plusieurs heures !\n');

  final startTime = DateTime.now();

  // ÉTAPE 1 : toutes les solutions brutes
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('ÉTAPE 1: Génération de toutes les solutions');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

  final allSolutions = await solver.findAllSolutions(
    onProgress: (count, elapsed) {
      if (count % 5000 == 0 || elapsed % 300 == 0) {
        final rate = count / elapsed;
        print('[${_formatDuration(Duration(seconds: elapsed))}] '
            'Solutions: $count (${rate.toStringAsFixed(1)}/s)');
      }
    },
  );

  final step1Duration = DateTime.now().difference(startTime);
  print('\n✓ ${allSolutions.length} solutions brutes trouvées en ${_formatDuration(step1Duration)}\n');

  // ÉTAPE 2 : normalisation (éliminer symétries)
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('ÉTAPE 2: Normalisation (élimination des symétries)');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

  final uniqueSolutions = <String, List<PlacementInfo>>{};
  int duplicates = 0;

  for (int i = 0; i < allSolutions.length; i++) {
    if ((i + 1) % 5000 == 0) {
      print('  Progression: ${i + 1}/${allSolutions.length} '
          '(${uniqueSolutions.length} uniques, $duplicates doublons)');
    }

    final normalized = _normalizeSolution(allSolutions[i], _boardWidth, _boardHeight);

    if (uniqueSolutions.containsKey(normalized)) {
      duplicates++;
    } else {
      uniqueSolutions[normalized] = allSolutions[i];
    }
  }

  final step2Duration = DateTime.now().difference(startTime);
  print('\n✓ ${uniqueSolutions.length} solutions uniques '
      '(${duplicates} doublons éliminés)\n');

  // ÉTAPE 3 : écriture des fichiers binaires
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('ÉTAPE 3: Écriture des fichiers binaires');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

  // 3.a Fichier binaire des BRUTES
  print('→ Écriture de solutions_6x10_brutes.bin...');
  final builderBrutes = BytesBuilder();
  for (final sol in allSolutions) {
    final boardBit6 = _solutionToBit6Board(sol);   // 60 codes 0..63
    final bytes = _bit6BoardToBytes(boardBit6);    // 45 octets
    builderBrutes.add(bytes);
  }
  final fileBrutes = File('solutions_6x10_brutes.bin');
  await fileBrutes.writeAsBytes(builderBrutes.toBytes());
  final sizeBrutes = await fileBrutes.length();
  print('✓ solutions_6x10_brutes.bin : '
      '${allSolutions.length} solutions, '
      '$sizeBrutes octets (~${(sizeBrutes / 1024).toStringAsFixed(1)} KB)\n');

  // 3.b Fichier binaire des NORMALISÉES
  print('→ Écriture de solutions_6x10_normalisees.bin...');
  final builderNorm = BytesBuilder();
  for (final sol in uniqueSolutions.values) {
    final boardBit6 = _solutionToBit6Board(sol);
    final bytes = _bit6BoardToBytes(boardBit6);
    builderNorm.add(bytes);
  }
  final fileNorm = File('solutions_6x10_normalisees.bin');
  await fileNorm.writeAsBytes(builderNorm.toBytes());
  final sizeNorm = await fileNorm.length();
  print('✓ solutions_6x10_normalisees.bin : '
      '${uniqueSolutions.length} solutions, '
      '$sizeNorm octets (~${(sizeNorm / 1024).toStringAsFixed(1)} KB)\n');

  // RÉSUMÉ FINAL
  final totalDuration = DateTime.now().difference(startTime);
  print('═════════════════════════════════════════════════');
  print('RÉSULTAT FINAL - PLATEAU 6×10');
  print('═════════════════════════════════════════════════');
  print('Solutions brutes       : ${allSolutions.length}');
  print('Solutions normalisées  : ${uniqueSolutions.length}');
  print('Doublons éliminés      : $duplicates');
  print('Facteur de réduction   : '
      '${(allSolutions.length / uniqueSolutions.length).toStringAsFixed(2)}x');
  print('');
  print('Fichiers créés:');
  print('  📦 solutions_6x10_brutes.bin');
  print('  📦 solutions_6x10_normalisees.bin');
  print('');
  print('Temps total: ${_formatDuration(totalDuration)}');
  print('═════════════════════════════════════════════════\n');
}

// ═══════════════════════════════════════════════════
// ENCODAGE 6 bits / case → 45 octets / solution
// ═══════════════════════════════════════════════════

/// Crée un tableau de 60 codes bit6 (int 0..63) pour une solution.
List<int> _solutionToBit6Board(List<PlacementInfo> solution) {
  final board = List<int>.filled(_boardCells, -1);

  for (final placement in solution) {
    final pento = pentominos[placement.pieceIndex];
    final code = pento.bit6; // code 6 bits de la pièce

    for (final cell in placement.occupiedCells) {
      final index = cell - 1; // 1..60 → 0..59

      if (index < 0 || index >= board.length) {
        throw StateError('Index hors limites : $cell');
      }

      if (board[index] != -1) {
        throw StateError(
          'Collision : case $cell déjà occupée (code=${board[index]}), '
              'on tente d\'y mettre code=$code',
        );
      }

      board[index] = code;
    }
  }

  if (board.any((v) => v == -1)) {
    throw StateError('Solution incomplète : il reste des cases vides.');
  }

  return board; // 60 codes bit6 (0..63)
}

/// Transforme 60 codes 6 bits en 45 octets, en packant les bits.
Uint8List _bit6BoardToBytes(List<int> board) {
  if (board.length != _boardCells) {
    throw ArgumentError('Un plateau doit avoir exactement $_boardCells cases.');
  }

  final bytes = Uint8List(_bytesPerSolution);
  int byteIndex = 0;
  int currentByte = 0;
  int bitsFilled = 0;

  for (final code in board) {
    // 6 bits de poids fort à poids faible
    for (int bitPos = 5; bitPos >= 0; bitPos--) {
      final bit = (code >> bitPos) & 1;
      currentByte = (currentByte << 1) | bit;
      bitsFilled++;

      if (bitsFilled == 8) {
        bytes[byteIndex++] = currentByte;
        currentByte = 0;
        bitsFilled = 0;
      }
    }
  }

  // 60×6 = 360 est multiple de 8 → bitsFilled doit être 0 ici
  if (bitsFilled != 0) {
    throw StateError('Erreur de packing: bitsFilled=$bitsFilled (devrait être 0).');
  }

  return bytes;
}

// ═══════════════════════════════════════════════════
// NORMALISATION (inchangée)
// ═══════════════════════════════════════════════════

String _normalizeSolution(List<PlacementInfo> solution, int width, int height) {
  final grid = List.generate(height, (_) => List.filled(width, 0));

  for (final placement in solution) {
    final pieceId = pentominos[placement.pieceIndex].id;
    for (final cell in placement.occupiedCells) {
      final x = (cell - 1) % width;
      final y = (cell - 1) ~/ width;
      if (y < height && x < width) {
        grid[y][x] = pieceId;
      }
    }
  }

  final variants = <String>[];

  var current = grid;
  for (int i = 0; i < 4; i++) {
    variants.add(_gridToString(current));
    current = _rotate90(current);
  }

  current = _flipHorizontal(grid);
  for (int i = 0; i < 4; i++) {
    variants.add(_gridToString(current));
    current = _rotate90(current);
  }

  variants.sort();
  return variants.first;
}

String _gridToString(List<List<int>> grid) {
  return grid.map((row) => row.join(',')).join('|');
}

List<List<int>> _rotate90(List<List<int>> grid) {
  final height = grid.length;
  final width = grid[0].length;
  final rotated = List.generate(width, (_) => List.filled(height, 0));

  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      rotated[x][height - 1 - y] = grid[y][x];
    }
  }

  return rotated;
}

List<List<int>> _flipHorizontal(List<List<int>> grid) {
  return grid.map((row) => row.reversed.toList()).toList();
}

String _formatDuration(Duration d) {
  if (d.inHours > 0) {
    return '${d.inHours}h ${d.inMinutes % 60}m ${d.inSeconds % 60}s';
  } else if (d.inMinutes > 0) {
    return '${d.inMinutes}m ${d.inSeconds % 60}s';
  } else {
    return '${d.inSeconds}s';
  }
}
