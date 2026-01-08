#!/usr/bin/env dart

// tools/scan_dart_files.dart
// Scanne tous les fichiers .dart et génère un CSV
// Utilise config.dart pour la configuration centralisée

import 'dart:io';
import 'config.dart';

class DartFilesScanner {
  final List<Map<String, String>> dartFiles = [];

  Future<void> run() async {
    printf('$COLOR_BOLD=== Scanner des fichiers .dart ===$COLOR_RESET\n\n');

    final libDir = Directory(LIB_PATH);
    if (!libDir.existsSync()) {
      printf('$COLOR_RED✗ Répertoire $LIB_PATH/ non trouvé$COLOR_RESET\n');
      exit(1);
    }

    printf('${COLOR_YELLOW}Scanning...$COLOR_RESET\n');

    final allFiles = libDir
        .listSync(recursive: true, followLinks: false)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'));

    for (final file in allFiles) {
      final stat = file.statSync();
      final relativePath = file.path.replaceFirst('$LIB_PATH/', '');
      final parts = relativePath.split('/');
      final firstDir = parts.isNotEmpty ? parts.first : '';
      final filename = parts.isNotEmpty ? parts.last : '';

      final modTime = stat.modified;
      final modDate = '${modTime.year % 100}${modTime.month.toString().padLeft(2, '0')}${modTime.day.toString().padLeft(2, '0')}';
      final modHour = '${modTime.hour.toString().padLeft(2, '0')}${modTime.minute.toString().padLeft(2, '0')}${modTime.second.toString().padLeft(2, '0')}';

      dartFiles.add({
        'filename': filename,
        'firstDir': firstDir,
        'relativePath': relativePath,
        'sizeBytes': stat.size.toString(),
        'modDate': modDate,
        'modTime': modHour,
      });
    }

    printf('$COLOR_GREEN✓ ${dartFiles.length} fichiers trouvés$COLOR_RESET\n\n');

    _printSummary();
    await _exportCsv();
  }

  void _printSummary() {
    printf('$COLOR_BOLD=== Résumé par répertoire ===$COLOR_RESET\n\n');

    final byDir = <String, List<Map<String, String>>>{};
    int totalSize = 0;

    for (final file in dartFiles) {
      final dir = file['firstDir']!;
      byDir.putIfAbsent(dir, () => []).add(file);
      totalSize += int.parse(file['sizeBytes']!);
    }

    for (final dir in byDir.keys.toList()..sort()) {
      final files = byDir[dir]!;
      final dirSize = files.fold<int>(0, (sum, f) => sum + int.parse(f['sizeBytes']!));
      printf('$COLOR_YELLOW$dir$COLOR_RESET: ${files.length} fichiers (${_formatSize(dirSize)})\n');
    }

    printf('\n$COLOR_BOLD=== Total ===$COLOR_RESET\n');
    printf('Fichiers: $COLOR_BOLD${dartFiles.length}$COLOR_RESET\n');
    printf('Taille: $COLOR_BOLD${_formatSize(totalSize)}$COLOR_RESET\n\n');
  }

  Future<void> _exportCsv() async {
    Directory(CSV_PATH).createSync(recursive: true);

    final buffer = StringBuffer();
    buffer.writeln('filename,firstDir,relativePath,sizeBytes,modDate,modTime');

    for (final file in dartFiles) {
      buffer.writeln('"${file['filename']}","${file['firstDir']}","${file['relativePath']}",${file['sizeBytes']},"${file['modDate']}","${file['modTime']}"');
    }

    await File(CSV_DARTFILES).writeAsString(buffer.toString());
    printf('$COLOR_GREEN✓ Export CSV: $COLOR_BOLD$CSV_DARTFILES$COLOR_RESET\n');
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }
}

void printf(String msg) => stdout.write(msg);

Future<void> main(List<String> args) async {
  try {
    await DartFilesScanner().run();
  } catch (e) {
    printf('$COLOR_RED✗ Erreur: $e$COLOR_RESET\n');
    exit(1);
  }
}