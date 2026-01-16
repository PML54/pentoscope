// Verifie la stabilite de l'ordre geometrique des cellules pour toutes les
// orientations des pieces, et compare positions vs cartesianCoords.
//
// Usage:
//   dart run tools/verify_pentomino_order.dart
//
// Sortie:
//   - OK / DIFF par piece
//   - details si une orientation casse l'ordre geometrique
//   - details si positions et cartesianCoords divergent

import 'dart:io';

class Coord {
  final int x;
  final int y;

  const Coord(this.x, this.y);
}

Coord cellNumToCoord(int cellNum) {
  final x = (cellNum - 1) % 5;
  final y = (cellNum - 1) ~/ 5;
  return Coord(x, y);
}

Set<String> adjacencySignature(List<Coord> coords) {
  final adj = <String>{};
  for (int i = 0; i < coords.length; i++) {
    for (int j = i + 1; j < coords.length; j++) {
      final dx = (coords[i].x - coords[j].x).abs();
      final dy = (coords[i].y - coords[j].y).abs();
      if (dx + dy == 1) {
        adj.add('$i-$j');
      }
    }
  }
  return adj;
}

bool setEquals<T>(Set<T> a, Set<T> b) {
  if (a.length != b.length) return false;
  for (final v in a) {
    if (!b.contains(v)) return false;
  }
  return true;
}

List<Coord> coordsFromPositions(List<int> position) {
  return position.map(cellNumToCoord).toList();
}

List<Coord> coordsFromCartesian(List<List<int>> coords) {
  return coords.map((pair) => Coord(pair[0], pair[1])).toList();
}

class ParseResult<T> {
  final T value;
  final int nextIndex;

  ParseResult(this.value, this.nextIndex);
}

ParseResult<dynamic> parseList(String src, int startIndex) {
  int i = startIndex;
  if (src[i] != '[') {
    throw FormatException('Expected [ at index $i');
  }
  i++; // skip '['
  final list = <dynamic>[];

  while (i < src.length) {
    // skip whitespace and commas
    while (i < src.length && (src[i] == ' ' || src[i] == '\n' || src[i] == '\r' || src[i] == '\t' || src[i] == ',')) {
      i++;
    }
    if (i >= src.length) break;

    if (src[i] == ']') {
      return ParseResult(list, i + 1);
    }

    if (src[i] == '[') {
      final nested = parseList(src, i);
      list.add(nested.value);
      i = nested.nextIndex;
      continue;
    }

    // parse integer
    bool neg = false;
    if (src[i] == '-') {
      neg = true;
      i++;
    }
    final startNum = i;
    while (i < src.length && src[i].codeUnitAt(0) >= 48 && src[i].codeUnitAt(0) <= 57) {
      i++;
    }
    if (startNum == i) {
      throw FormatException('Expected number at index $i');
    }
    final numStr = src.substring(startNum, i);
    final val = int.parse(numStr) * (neg ? -1 : 1);
    list.add(val);
  }

  throw FormatException('Unterminated list starting at $startIndex');
}

int indexAfter(String src, String token, int start) {
  final idx = src.indexOf(token, start);
  if (idx == -1) return -1;
  return idx + token.length;
}

class PieceData {
  final int id;
  final List<List<int>> orientations;
  final List<List<List<int>>> cartesian;

  PieceData(this.id, this.orientations, this.cartesian);
}

List<PieceData> parsePentominosFile(String content) {
  final pieces = <PieceData>[];
  int i = 0;
  while (true) {
    final pentoIdx = content.indexOf('Pento(', i);
    if (pentoIdx == -1) break;

    // find id
    final idIdx = content.indexOf('id:', pentoIdx);
    if (idIdx == -1) break;
    int j = idIdx + 3;
    while (j < content.length && (content[j] == ' ')) j++;
    final idStart = j;
    while (j < content.length && content[j].codeUnitAt(0) >= 48 && content[j].codeUnitAt(0) <= 57) j++;
    final id = int.parse(content.substring(idStart, j));

    // positions
    final posIdx = content.indexOf('orientations:', pentoIdx);
    if (posIdx == -1) break;
    int posListStart = content.indexOf('[', posIdx);
    final posParsed = parseList(content, posListStart);
    final positions = (posParsed.value as List).map((e) => (e as List).cast<int>()).toList();

    // cartesianCoords
    final cartIdx = content.indexOf('cartesianCoords:', pentoIdx);
    if (cartIdx == -1) break;
    int cartListStart = content.indexOf('[', cartIdx);
    final cartParsed = parseList(content, cartListStart);
    final cartesian = (cartParsed.value as List)
        .map((e) => (e as List).map((f) => (f as List).cast<int>()).toList())
        .toList();

    pieces.add(PieceData(id, positions, cartesian));
    i = cartParsed.nextIndex;
  }
  return pieces;
}

void main() {
  final file = File('lib/common/pentominos.dart');
  if (!file.existsSync()) {
    print('Erreur: fichier introuvable');
    return;
  }

  final content = file.readAsStringSync();
  final pieces = parsePentominosFile(content);

  if (pieces.isEmpty) {
    print('Aucune piece trouvee dans pentominos.dart');
    return;
  }

  bool globalOk = true;

  for (final piece in pieces) {
    final positions = piece.orientations;
    final cartesian = piece.cartesian;

    if (positions.isEmpty || cartesian.isEmpty) {
      print('Piece ${piece.id}: ORIENTATIONS VIDES');
      globalOk = false;
      continue;
    }

    if (positions.length != cartesian.length) {
      print('Piece ${piece.id}: NB ORIENTATIONS DIFFERENT');
      print('  positions=${positions.length}, cartesian=${cartesian.length}');
      globalOk = false;
      continue;
    }

    final baseAdj = adjacencySignature(coordsFromPositions(positions[0]));
    bool pieceOk = true;

    for (int k = 0; k < positions.length; k++) {
      final adjPos = adjacencySignature(coordsFromPositions(positions[k]));
      if (!setEquals(adjPos, baseAdj)) {
        pieceOk = false;
        globalOk = false;
        print('Piece ${piece.id}, orientation $k: ORDRE GEOMETRIQUE DIFF');
        print('  base: ${baseAdj.toList()..sort()}');
        print('  curr: ${adjPos.toList()..sort()}');
      }

      final adjCart = adjacencySignature(coordsFromCartesian(cartesian[k]));
      if (!setEquals(adjPos, adjCart)) {
        pieceOk = false;
        globalOk = false;
        print('Piece ${piece.id}, orientation $k: POSITIONS != CARTESIAN');
        print('  orientations: ${adjPos.toList()..sort()}');
        print('  cartesian: ${adjCart.toList()..sort()}');
      }
    }

    if (pieceOk) {
      print('Piece ${piece.id}: OK (${positions.length} orientations)');
    }
  }

  print('\nResultat final: ${globalOk ? "TOUT OK" : "ERREURS"}');
}
