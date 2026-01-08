// Modified: 2025-11-15 06:45:00
// lib/services/plateau_solution_counter.dart

import 'package:pentapol/common/plateau.dart';
import 'package:pentapol/common/pentominos.dart';
import 'package:pentapol/services/solution_matcher.dart';

class _PlateauBigIntMask {
  final BigInt pieces;
  final BigInt mask;
  _PlateauBigIntMask(this.pieces, this.mask);
}

extension PlateauSolutionCounter on Plateau {
  _PlateauBigIntMask? _toBigIntMask() {
    try {
      if (width != 6 || height != 10) {
        throw StateError(
          'countPossibleSolutions() est défini pour un plateau 6x10, '
              'reçu ${width}x$height.',
        );
      }

      final Map<int, int> bit6ById = {
        for (final p in pentominos) p.id: p.bit6,
      };

      BigInt piecesBits = BigInt.zero;
      BigInt maskBits = BigInt.zero;

      for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
          final cellValue = getCell(x, y); // 0 ou 1..12

          piecesBits = piecesBits << 6;
          maskBits = maskBits << 6;

          if (cellValue == 0) {
            continue;
          }

          final code = bit6ById[cellValue];
          if (code == null) {
            throw StateError('Aucun bit6 pour pieceId=$cellValue');
          }

          piecesBits |= BigInt.from(code);
          maskBits |= BigInt.from(0x3F); // 6 bits à 1
        }
      }

      return _PlateauBigIntMask(piecesBits, maskBits);
    } catch (e, st) {
      print('[PlateauSolutionCounter] Erreur toBigIntMask: $e');
      print(st);
      return null;
    }
  }

  /// Compte les solutions compatibles (comme avant).
  int? countPossibleSolutions() {
    final mask = _toBigIntMask();
    if (mask == null) return null;

    try {
      return solutionMatcher.countCompatibleFromBigInts(
        mask.pieces,
        mask.mask,
      );
    } catch (e, st) {
      print('[PlateauSolutionCounter] Erreur countPossibleSolutions: $e');
      print(st);
      return null;
    }
  }

  /// Retourne la liste des solutions compatibles (BigInt) pour le plateau courant.
  /// Renvoie [] en cas d'erreur.
  List<BigInt> getCompatibleSolutionsBigInt() {
    final mask = _toBigIntMask();
    if (mask == null) return const [];

    try {
      return solutionMatcher.getCompatibleSolutionsFromBigInts(
        mask.pieces,
        mask.mask,
      );
    } catch (e, st) {
      print('[PlateauSolutionCounter] Erreur getCompatibleSolutionsBigInt: $e');
      print(st);
      return const [];
    }
  }

  /// Retourne les indices des solutions compatibles (0-9355).
  /// Utile pour stocker/identifier les solutions possibles.
  List<int> getCompatibleSolutionIndices() {
    final mask = _toBigIntMask();
    if (mask == null) return const [];

    try {
      return solutionMatcher.getCompatibleSolutionIndices(
        mask.pieces,
        mask.mask,
      );
    } catch (e, st) {
      print('[PlateauSolutionCounter] Erreur getCompatibleSolutionIndices: $e');
      print(st);
      return const [];
    }
  }

  /// Retourne l'index de la solution si le plateau est complet et correspond
  /// exactement à une solution connue. Retourne -1 sinon.
  int findExactSolutionIndex() {
    final mask = _toBigIntMask();
    if (mask == null) return -1;

    // Vérifier que toutes les cases sont occupées (plateau complet)
    // mask.mask doit avoir tous les bits à 1 (60 cases × 6 bits = 360 bits)
    final fullMask = (BigInt.one << 360) - BigInt.one;
    if (mask.mask != fullMask) {
      return -1; // Plateau incomplet
    }

    try {
      return solutionMatcher.findSolutionIndex(mask.pieces);
    } catch (e, st) {
      print('[PlateauSolutionCounter] Erreur findExactSolutionIndex: $e');
      print(st);
      return -1;
    }
  }
}

