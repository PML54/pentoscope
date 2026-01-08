// Modified: 2025-11-15 06:45:00
// lib/models/bigint_plateau.dart

import 'package:pentapol/common/pentominos.dart';

class BigIntPlateau {
  final BigInt pieces; // 360 bits: codes bit6 (0 si vide)
  final BigInt mask;   // 360 bits: 0x3F par case occupée, 0 sinon

  BigIntPlateau._(this.pieces, this.mask);

  static const int width = 6;
  static const int height = 10;
  static const int cellsCount = width * height; // 60

  // table globale bit6 -> pieceId (1..12)
  static final Map<int, int> _idByBit6 = {
    for (final p in pentominos) p.bit6: p.id,
  };

  factory BigIntPlateau.empty() => BigIntPlateau._(BigInt.zero, BigInt.zero);

  /// Calcule le décalage (en bits) pour une case [cellIndex] 0..59.
  /// case 59 -> bits 0..5, case 58 -> 6..11, ..., case 0 -> 354..359
  static int _shiftForCellIndex(int cellIndex) {
    return (cellsCount - 1 - cellIndex) * 6;
  }

  static int _cellIndexFromXY(int x, int y) => y * width + x;

  /// Place une pièce (par id) sur une liste de cases [cellIndices] (indices 0..59).
  /// [bit6ById] vient de pentominos : {id -> bit6}
  BigIntPlateau placePiece({
    required int pieceId,
    required Iterable<int> cellIndices,
    required Map<int, int> bit6ById,
  }) {
    final code = bit6ById[pieceId];
    if (code == null) {
      throw ArgumentError('bit6 introuvable pour pieceId=$pieceId');
    }

    var p = pieces;
    var m = mask;

    for (final cellIndex in cellIndices) {
      if (cellIndex < 0 || cellIndex >= cellsCount) {
        throw ArgumentError('cellIndex hors limites: $cellIndex');
      }

      final shift = _shiftForCellIndex(cellIndex);
      final fieldMask = BigInt.from(0x3F) << shift;

      // On efface d’abord la case (au cas où)
      p &= ~fieldMask;
      m &= ~fieldMask;

      // On pose la pièce
      p |= (BigInt.from(code) << shift);
      m |= (BigInt.from(0x3F) << shift);
    }

    return BigIntPlateau._(p, m);
  }

  /// Efface une liste de cases (les remet à vide).
  BigIntPlateau clearCells(Iterable<int> cellIndices) {
    var p = pieces;
    var m = mask;

    for (final cellIndex in cellIndices) {
      if (cellIndex < 0 || cellIndex >= cellsCount) {
        throw ArgumentError('cellIndex hors limites: $cellIndex');
      }

      final shift = _shiftForCellIndex(cellIndex);
      final fieldMask = BigInt.from(0x3F) << shift;

      p &= ~fieldMask;
      m &= ~fieldMask;
    }

    return BigIntPlateau._(p, m);
  }

  /// Retourne la valeur de la case (x, y) :
  /// - 0 si vide
  /// - 1..12 = pieceId si occupée
  int getCell(int x, int y) {
    if (x < 0 || x >= width || y < 0 || y >= height) {
      throw ArgumentError('Coordonnées hors plateau: ($x, $y)');
    }

    final cellIndex = _cellIndexFromXY(x, y);
    final shift = _shiftForCellIndex(cellIndex);
    final fieldMask = BigInt.from(0x3F) << shift;

    // Si le mask n'a pas les 6 bits à 1 -> case vide
    final masked = mask & fieldMask;
    if (masked == BigInt.zero) {
      return 0;
    }

    // Récupérer le code 6 bits depuis pieces
    final code = ((pieces & fieldMask) >> shift).toInt();

    // Convertir bit6 -> pieceId
    final id = _idByBit6[code];
    return id ?? 0;
  }
}
