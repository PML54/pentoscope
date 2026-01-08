// Modified: 2025-11-15 06:45:00
// lib/services/pentapol_solutions_loader.dart

import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;

const int _boardCells = 60;
const int _bytesPerSolution = 45;

Future<List<BigInt>> loadNormalizedSolutionsAsBigInt() async {
  // Chemin EXACTEMENT identique à celui déclaré dans pubspec.yaml
  final data = await rootBundle.load('assets/data/solutions_6x10_normalisees.bin');
  final bytes = data.buffer.asUint8List();

  if (bytes.length % _bytesPerSolution != 0) {
    throw StateError(
      'Taille de fichier invalide: ${bytes.length} octets, '
          'pas multiple de $_bytesPerSolution.',
    );
  }

  final solutionCount = bytes.length ~/ _bytesPerSolution;
  final solutions = <BigInt>[];

  int offset = 0;
  for (int i = 0; i < solutionCount; i++) {
    final boardBit6 = _bytesToBit6Board(bytes, offset);
    offset += _bytesPerSolution;
    final big = _bit6BoardToBigInt(boardBit6);
    solutions.add(big);
  }

  return solutions;
}

List<int> _bytesToBit6Board(Uint8List bytes, int offset) {
  final board = List<int>.filled(_boardCells, 0);

  int byteIndex = offset;
  int currentByte = 0;
  int bitsLeft = 0;

  for (int cell = 0; cell < _boardCells; cell++) {
    int code = 0;
    for (int i = 0; i < 6; i++) {
      if (bitsLeft == 0) {
        currentByte = bytes[byteIndex++];
        bitsLeft = 8;
      }
      final bit = (currentByte >> (bitsLeft - 1)) & 1;
      bitsLeft--;
      code = (code << 1) | bit;
    }
    board[cell] = code;
  }

  return board;
}

BigInt _bit6BoardToBigInt(List<int> boardBit6) {
  BigInt acc = BigInt.zero;
  for (final code in boardBit6) {
    acc = (acc << 6) | BigInt.from(code);
  }
  return acc;
}
