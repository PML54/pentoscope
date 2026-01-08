#!/usr/bin/env dart

// tools/generate_dart_documentation.dart
// Génère la documentation Markdown pour chaque fichier
// Utilise config.dart pour la configuration centralisée

import 'dart:io';
import 'config.dart';

class DartDocumentationGenerator {
  final Map<String, DartFileDoc> fileDocumentation = {};

  Future<void> run() async {
    printf('$COLOR_BOLD=== Génération de la documentation ===$COLOR_RESET\n\n');

    final libDir = Directory(LIB_PATH);
    if (!libDir.existsSync()) {
      printf('$COLOR_RED✗ Répertoire $LIB_PATH/ non trouvé$COLOR_RESET\n');
      exit(1);
    }

    // Nettoyer le répertoire docs s'il existe
    final docsDir = Directory(DOCS_PATH);
    if (docsDir.existsSync()) {
      printf('${COLOR_YELLOW}Nettoyage des anciens fichiers...$COLOR_RESET\n');
      docsDir.deleteSync(recursive: true);
      printf('$COLOR_GREEN✓ Répertoire $DOCS_PATH/ vidé$COLOR_RESET\n\n');
    }

    printf('${COLOR_YELLOW}Scan des fichiers .dart...$COLOR_RESET\n');

    final dartFiles = libDir
        .listSync(recursive: true, followLinks: false)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'));

    for (final dartFile in dartFiles) {
      await extractDocumentation(dartFile);
    }

    printf('$COLOR_GREEN✓ ${fileDocumentation.length} fichiers documentés$COLOR_RESET\n\n');

    docsDir.createSync(recursive: true);

    await _generateMarkdownFiles();
    await _generateIndex();
  }

  Future<void> extractDocumentation(File file) async {
    final content = await file.readAsString();
    final lines = content.split('\n');

    final relativePath = file.path.replaceFirst('$LIB_PATH/', '');
    final fileDoc = DartFileDoc(relativePath);
    final module = relativePath.split('/').first;
    fileDoc.module = module;

    String? currentFunctionDoc;

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final trimmed = line.trim();

      if (trimmed.startsWith('///')) {
        final comment = trimmed.replaceFirst('///', '').trim();
        currentFunctionDoc = (currentFunctionDoc ?? '') + comment + '\n';
      }

      final functionPattern = RegExp(
        r'^\s*(static\s+)?(async\s+)?(\w+(<[^>]+>)?)\s+([a-zA-Z][a-zA-Z0-9_]*)\s*\(',
      );

      final funcMatch = functionPattern.firstMatch(line);
      if (funcMatch != null) {
        final funcName = funcMatch.group(5);
        if (funcName != null && !funcName.startsWith('_')) {
          String signature = line.trim();

          int j = i;
          while (j < lines.length && !lines[j].contains('{') && !lines[j].contains(';')) {
            j++;
            if (j < lines.length) {
              signature += ' ' + lines[j].trim();
            }
          }

          fileDoc.addFunction(
            FunctionDoc(
              name: funcName,
              signature: signature,
              documentation: currentFunctionDoc ?? '',
            ),
          );

          currentFunctionDoc = null;
        }
      }
    }

    if (fileDoc.functions.isNotEmpty) {
      fileDocumentation[relativePath] = fileDoc;
    }
  }

  Future<void> _generateMarkdownFiles() async {
    printf('${COLOR_YELLOW}Génération des fichiers Markdown...$COLOR_RESET\n\n');

    for (final entry in fileDocumentation.entries) {
      final relativePath = entry.key;
      final fileDoc = entry.value;

      final mdContent = fileDoc.toMarkdown();
      final mdPath = '$DOCS_PATH/${relativePath.replaceAll('/', '_').replaceAll('.dart', '.md')}';

      final mdFile = File(mdPath);
      mdFile.parent.createSync(recursive: true);
      await mdFile.writeAsString(mdContent);

      printf('  $COLOR_GREEN✓$COLOR_RESET $relativePath\n');
    }

    printf('\n');
  }

  Future<void> _generateIndex() async {
    printf('${COLOR_YELLOW}Génération de l\'INDEX...$COLOR_RESET\n');

    final buffer = StringBuffer();
    buffer.writeln('# $APP_NAME - Documentation\n');
    buffer.writeln('*$APP_DESCRIPTION*\n');

    final byModule = <String, List<DartFileDoc>>{};
    for (final doc in fileDocumentation.values) {
      byModule.putIfAbsent(doc.module, () => []).add(doc);
    }

    buffer.writeln('## Modules\n');
    for (final module in byModule.keys.toList()..sort()) {
      buffer.writeln('- **$module** (${byModule[module]!.length} fichiers)');
    }
    buffer.writeln();

    for (final module in byModule.keys.toList()..sort()) {
      buffer.writeln('---\n');
      buffer.writeln('## Module: $module\n');

      final docs = byModule[module]!..sort((a, b) => a.relativePath.compareTo(b.relativePath));

      for (final doc in docs) {
        buffer.writeln('### ${doc.relativePath}\n');
        if (doc.functions.isNotEmpty) {
          buffer.writeln('**Fonctions :**\n');
          for (final func in doc.functions) {
            buffer.writeln('- `${func.name}()`');
          }
        }
        buffer.writeln();
      }
    }

    await File('$DOCS_PATH/INDEX.md').writeAsString(buffer.toString());
    printf('$COLOR_GREEN✓ INDEX.md généré$COLOR_RESET\n\n');
  }
}

class DartFileDoc {
  final String relativePath;
  final List<FunctionDoc> functions = [];
  late String module;

  DartFileDoc(this.relativePath);

  void addFunction(FunctionDoc func) => functions.add(func);

  String toMarkdown() {
    final buffer = StringBuffer();
    buffer.writeln('# $relativePath\n');
    buffer.writeln('**Module:** $module\n');

    if (functions.isNotEmpty) {
      buffer.writeln('## Fonctions\n');
      for (final func in functions) {
        buffer.writeln('### ${func.name}\n');
        if (func.documentation.isNotEmpty) {
          buffer.writeln('${func.documentation}\n');
        }
        buffer.writeln('```dart\n${func.signature}\n```\n');
      }
    }

    return buffer.toString();
  }
}

class FunctionDoc {
  final String name;
  final String signature;
  final String documentation;

  FunctionDoc({
    required this.name,
    required this.signature,
    required this.documentation,
  });
}

void printf(String msg) => stdout.write(msg);

Future<void> main(List<String> args) async {
  try {
    await DartDocumentationGenerator().run();
  } catch (e) {
    printf('$COLOR_RED✗ Erreur: $e$COLOR_RESET\n');
    exit(1);
  }
}