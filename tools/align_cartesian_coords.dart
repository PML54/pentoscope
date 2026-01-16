// Aligne cartesianCoords sur l'ordre de positions pour toutes les pieces.
//
// Usage:
//   dart run tools/align_cartesian_coords.dart
//
// Ce script parse lib/common/pentominos.dart sans importer Flutter,
// reconstruit cartesianCoords a partir de positions (ordre stable),
// puis remplace les blocs cartesianCoords dans le fichier.

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
    while (i < src.length &&
        (src[i] == ' ' ||
            src[i] == '\n' ||
            src[i] == '\r' ||
            src[i] == '\t' ||
            src[i] == ',')) {
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
    while (i < src.length &&
        src[i].codeUnitAt(0) >= 48 &&
        src[i].codeUnitAt(0) <= 57) {
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

int findMatchingBracket(String src, int openIndex) {
  int depth = 0;
  for (int i = openIndex; i < src.length; i++) {
    if (src[i] == '[') depth++;
    if (src[i] == ']') depth--;
    if (depth == 0) return i;
  }
  throw FormatException('No matching bracket for index $openIndex');
}

List<List<int>> buildCartesianFromPositions(List<List<int>> positions) {
  final result = <List<int>>[];
  for (final position in positions) {
    final coords = position.map(cellNumToCoord).toList();
    int minX = coords.map((c) => c.x).reduce((a, b) => a < b ? a : b);
    int minY = coords.map((c) => c.y).reduce((a, b) => a < b ? a : b);
    for (final c in coords) {
      result.add([c.x - minX, c.y - minY]);
    }
  }
  return result;
}

String formatCartesianCoords(List<List<int>> positions, String baseIndent) {
  final sb = StringBuffer();
  final indent1 = baseIndent; // field indent
  final indent2 = baseIndent + '  '; // orientation indent
  final indent3 = baseIndent + '    '; // coord indent

  sb.writeln('[');

  for (final position in positions) {
    final coords = position.map(cellNumToCoord).toList();
    int minX = coords.map((c) => c.x).reduce((a, b) => a < b ? a : b);
    int minY = coords.map((c) => c.y).reduce((a, b) => a < b ? a : b);

    sb.writeln('$indent2[');
    for (final c in coords) {
      final nx = c.x - minX;
      final ny = c.y - minY;
      sb.writeln('$indent3[$nx, $ny],');
    }
    sb.writeln('$indent2],');
  }

  sb.write('$indent1]');
  return sb.toString();
}

class Replacement {
  final int start;
  final int end;
  final String text;

  Replacement(this.start, this.end, this.text);
}

void main() {
  final file = File('lib/common/pentominos.dart');
  if (!file.existsSync()) {
    print('Erreur: fichier introuvable');
    return;
  }

  final content = file.readAsStringSync();
  final replacements = <Replacement>[];

  int i = 0;
  while (true) {
    final pentoIdx = content.indexOf('Pento(', i);
    if (pentoIdx == -1) break;

    final posIdx = content.indexOf('orientations:', pentoIdx);
    if (posIdx == -1) break;
    final posListStart = content.indexOf('[', posIdx);
    final posParsed = parseList(content, posListStart);
    final positions = (posParsed.value as List)
        .map((e) => (e as List).cast<int>())
        .toList();

    final cartIdx = content.indexOf('cartesianCoords:', pentoIdx);
    if (cartIdx == -1) break;
    final cartListStart = content.indexOf('[', cartIdx);
    final cartListEnd = findMatchingBracket(content, cartListStart);

    // Detect indentation from line containing cartesianCoords
    int lineStart = content.lastIndexOf('\n', cartIdx);
    if (lineStart == -1) lineStart = 0; else lineStart += 1;
    final line = content.substring(lineStart, content.indexOf('\n', cartIdx));
    final indentMatch = RegExp(r'^(\s*)cartesianCoords:').firstMatch(line);
    final baseIndent = indentMatch?.group(1) ?? '    ';

    final newCart = formatCartesianCoords(positions, baseIndent + '  ');

    // Replace only the list content (including brackets)
    replacements.add(Replacement(cartListStart, cartListEnd + 1, newCart));

    i = cartListEnd + 1;
  }

  if (replacements.isEmpty) {
    print('Aucune replacement a faire.');
    return;
  }

  final sb = StringBuffer();
  int last = 0;
  for (final r in replacements..sort((a, b) => a.start.compareTo(b.start))) {
    sb.write(content.substring(last, r.start));
    sb.write(r.text);
    last = r.end;
  }
  sb.write(content.substring(last));

  file.writeAsStringSync(sb.toString());
  print('cartesianCoords realignes pour ${replacements.length} pieces.');
}
