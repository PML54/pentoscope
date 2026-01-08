import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

/// Usage:
///   dart run tools/check_public_functions.dart --db tools/db/pentapol.db --root /Users/pml/StudioProjects/pentapol
///
/// Options:
///   --out tools/db/public_functions.csv
///   --include-generated true|false   (default false)
///   --include-ctors true|false       (default false)  // constructeurs
///   --include-call true|false        (default true)   // méthode "call"
///
/// Remplit (ou exporte) des fonctions/méthodes PUBLIQUES uniques par fichier.
/// L’objectif est une table functions fiable pour ensuite détecter les doublons inter-fichiers.
void main(List<String> args) {
  final arg = _Args.parse(args);

  final dbFile = File(arg.dbPath);
  if (!dbFile.existsSync()) {
    stderr.writeln('DB not found: ${dbFile.path}');
    exit(2);
  }

  final rootDir = Directory(arg.rootPath);
  if (!rootDir.existsSync()) {
    stderr.writeln('Project root not found: ${rootDir.path}');
    exit(2);
  }

  final db = sqlite3.open(dbFile.path);
  IOSink? csvSink;
  try {
    final tables = db.select(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='dartfiles';",
    );
    if (tables.isEmpty) {
      stderr.writeln("Table 'dartfiles' not found.");
      exit(2);
    }

    final dartfilesCols = db.select("PRAGMA table_info(dartfiles);");
    final dartfilesHasFilename = dartfilesCols.any((r) => r['name'] == 'filename');

    final dartRows = db.select(
      dartfilesHasFilename
          ? "SELECT dart_id, relative_path, filename, first_dir FROM dartfiles;"
          : "SELECT dart_id, relative_path, first_dir FROM dartfiles;",
    );

    if (dartRows.isEmpty) {
      stdout.writeln('No dartfiles.');
      exit(0);
    }

    if (arg.outCsvPath != null) {
      final outFile = File(arg.outCsvPath!);
      outFile.parent.createSync(recursive: true);
      csvSink = outFile.openWrite();
      csvSink.writeln('dart_id,function_name');
    } else {
      db.execute('DELETE FROM functions;');
    }

    final insertStmt = (arg.outCsvPath == null)
        ? db.prepare('INSERT INTO functions (dart_id, function_name) VALUES (?, ?);')
        : null;

    var scanned = 0;
    var inserted = 0;

    for (final r in dartRows) {
      final dartId = r['dart_id'] as int;
      final relativePath = (r['relative_path'] as String).trim();
      final filename = dartfilesHasFilename
          ? (r['filename'] as String).trim()
          : p.basename(relativePath);

      if (!arg.includeGenerated && _isGenerated(filename)) {
        continue;
      }

      final file = _resolveDartFile(rootDir.path, relativePath);
      if (file == null || !file.existsSync()) {
        continue;
      }

      scanned++;

      final content = file.readAsStringSync();
      final extracted = _extractPublicApiStrict(
        content,
        includeConstructors: arg.includeCtors,
        includeCall: arg.includeCall,
      );

      // Dedup dans un même fichier
      final seen = <String>{};
      for (final name in extracted) {
        if (!seen.add(name)) continue;

        if (csvSink != null) {
          csvSink.writeln('$dartId,${_csvEscape(name)}');
        } else {
          insertStmt!.execute([dartId, name]);
        }
        inserted++;
      }
    }

    insertStmt?.dispose();
    csvSink?.close();

    stdout.writeln('Scanned files: $scanned');
    stdout.writeln('Inserted unique public functions: $inserted');

    // Contrôle (devrait être 0)
    if (arg.outCsvPath == null) {
      final dup = db.select('''
        SELECT function_name, dart_id, COUNT(*) AS n
        FROM functions
        GROUP BY function_name, dart_id
        HAVING n > 1
        LIMIT 10;
      ''');
      if (dup.isNotEmpty) {
        stderr.writeln('WARNING: duplicates still present in functions for same dart_id (unexpected).');
      }
    }
  } finally {
    db.dispose();
  }
}

bool _isGenerated(String filename) {
  // Ajuste selon tes habitudes
  return filename.endsWith('.g.dart') ||
      filename.endsWith('.freezed.dart') ||
      filename.endsWith('.gr.dart') ||
      filename.endsWith('.mocks.dart') ||
      filename.endsWith('.config.dart');
}

File? _resolveDartFile(String projectRoot, String relativePath) {
  final candidates = <String>[
    p.join(projectRoot, 'lib', relativePath),
    p.join(projectRoot, relativePath),
  ];
  for (final c in candidates) {
    final f = File(c);
    if (f.existsSync()) return f;
  }
  return File(candidates.first);
}

/// Extraction stricte:
/// - supprime commentaires // et /* */
/// - assemble des "chunks" de signature sur plusieurs lignes
/// - détecte uniquement un identifiant suivi de '(' OU 'get name'
/// - exclut mots-clés, types courants, faux positifs
/// - par défaut exclut les constructeurs (nom == classe) sauf option includeConstructors
List<String> _extractPublicApiStrict(
    String source, {
      required bool includeConstructors,
      required bool includeCall,
    }) {
  final lines = const LineSplitter().convert(source);

  final out = <String>[];

  // On garde une idée des noms de classes pour exclure les constructeurs
  final classNames = <String>{};

  // D’abord, petite passe pour collecter les classes (sans parser complet)
  final classRegex = RegExp(r'^\s*(?:abstract\s+)?class\s+([A-Za-z_$][A-Za-z0-9_$]*)\b');
  for (final raw in lines) {
    final line = _stripCommentsOneLine(raw, _BlockState());
    final m = classRegex.firstMatch(line);
    if (m != null) classNames.add(m.group(1)!);
  }

  final blockState = _BlockState();
  var buffer = '';

  // Une signature "int foo(" ou "foo(" ou "Future<T> foo(" etc.
  // On capture le dernier identifiant avant '('


  // Getter
  final getterRegex = RegExp(r'\bget\s+([A-Za-z_$][A-Za-z0-9_$]*)\b');

  for (final raw in lines) {
    var line = _stripCommentsOneLine(raw, blockState);
    if (blockState.inBlockComment) continue;

    line = line.trim();
    if (line.isEmpty) continue;

    // Ignorer les lignes "structure"
    if (_ignoreLineStarters.any((s) => line.startsWith(s))) continue;

    // Accumule la signature tant qu’on n’a pas atteint un "déclencheur"
    // Déclencheurs typiques: '{' ou '=>' ou ';'
    buffer = buffer.isEmpty ? line : '$buffer $line';

    final hasTrigger = buffer.contains('{') || buffer.contains('=>') || buffer.contains(';');
    final hasParen = buffer.contains('(');

    // Tant qu’il n’y a pas de '(' on continue à accumuler
    if (!hasParen && !hasTrigger) continue;

    // Si on n’a pas de '(' → ce n’est pas une fonction
    if (!hasParen) {
      buffer = '';
      continue;
    }

    // Exclure les déclarations lambda/closures évidentes en plein milieu
    // (heuristique : si "=>" apparaît avant le premier '(' c’est louche)
    final firstParen = buffer.indexOf('(');
    final arrow = buffer.indexOf('=>');
    if (arrow != -1 && arrow < firstParen) {
      buffer = '';
      continue;
    }

    // Getter ?
    final gm = getterRegex.firstMatch(buffer);
    if (gm != null) {
      final name = gm.group(1)!;
      if (_isValidName(
        name,
        classNames: classNames,
        includeConstructors: includeConstructors,
        includeCall: includeCall,
      )) {
        out.add(name);
      }
      buffer = '';
      continue;
    }

    // Fonction/méthode: on prend le dernier "ident(" avant le premier '('
    final prefix = buffer.substring(0, firstParen);
    final matches = RegExp(r'([A-Za-z_$][A-Za-z0-9_$]*)\s*$').firstMatch(prefix);
    if (matches == null) {
      buffer = '';
      continue;
    }

    final name = matches.group(1)!;

    if (_isValidName(
      name,
      classNames: classNames,
      includeConstructors: includeConstructors,
      includeCall: includeCall,
    )) {
      out.add(name);
    }

    buffer = '';
  }

  return out;
}

bool _isValidName(
    String name, {
      required Set<String> classNames,
      required bool includeConstructors,
      required bool includeCall,
    }) {
  if (name.isEmpty) return false;
  if (name.startsWith('_')) return false; // public only
  if (_keywords.contains(name)) return false;
  if (_bannedNames.contains(name)) return false;

  // Exclure "call" si tu ne veux pas
  if (!includeCall && name == 'call') return false;

  // Exclure constructeurs
  if (!includeConstructors && classNames.contains(name)) return false;

  // Exclure certains patterns inutiles
  if (name == 'operator') return false;

  return true;
}

class _BlockState {
  bool inBlockComment = false;
}

/// Retire commentaires de ligne et gère /* ... */ sur une ligne.
/// (Assez robuste pour notre usage)
String _stripCommentsOneLine(String line, _BlockState st) {
  var s = line;

  if (st.inBlockComment) {
    final end = s.indexOf('*/');
    if (end == -1) return '';
    s = s.substring(end + 2);
    st.inBlockComment = false;
  }

  while (true) {
    final start = s.indexOf('/*');
    if (start == -1) break;
    final end = s.indexOf('*/', start + 2);
    if (end == -1) {
      s = s.substring(0, start);
      st.inBlockComment = true;
      break;
    }
    s = s.substring(0, start) + s.substring(end + 2);
  }

  final sl = s.indexOf('//');
  if (sl != -1) s = s.substring(0, sl);

  return s;
}

String _csvEscape(String s) {
  if (s.contains(',') || s.contains('"')) {
    return '"${s.replaceAll('"', '""')}"';
  }
  return s;
}

class _Args {
  final String dbPath;
  final String rootPath;
  final String? outCsvPath;
  final bool includeGenerated;
  final bool includeCtors;
  final bool includeCall;

  _Args({
    required this.dbPath,
    required this.rootPath,
    required this.outCsvPath,
    required this.includeGenerated,
    required this.includeCtors,
    required this.includeCall,
  });

  static _Args parse(List<String> args) {
    String? db;
    String? root;
    String? out;
    bool includeGen = false;
    bool includeCtors = false;
    bool includeCall = true;

    for (var i = 0; i < args.length; i++) {
      final a = args[i];
      String? v() => (i + 1 < args.length) ? args[++i] : null;

      switch (a) {
        case '--db':
          db = v();
          break;
        case '--root':
          root = v();
          break;
        case '--out':
          out = v();
          break;
        case '--include-generated':
          final val = v()?.toLowerCase();
          includeGen = (val == 'true' || val == '1' || val == 'yes' || val == 'y');
          break;
        case '--include-ctors':
          final val = v()?.toLowerCase();
          includeCtors = (val == 'true' || val == '1' || val == 'yes' || val == 'y');
          break;
        case '--include-call':
          final val = v()?.toLowerCase();
          includeCall = (val == 'true' || val == '1' || val == 'yes' || val == 'y');
          break;
      }
    }

    if (db == null || root == null) {
      stderr.writeln(
        'Usage: dart run tools/check_public_functions.dart --db <dbfile> --root <projectRoot> '
            '[--out <csv>] [--include-generated true|false] [--include-ctors true|false] [--include-call true|false]',
      );
      exit(2);
    }

    return _Args(
      dbPath: db,
      rootPath: root,
      outCsvPath: out,
      includeGenerated: includeGen,
      includeCtors: includeCtors,
      includeCall: includeCall,
    );
  }
}

const _ignoreLineStarters = <String>[
  'class ',
  'mixin ',
  'enum ',
  'typedef ',
  'extension ',
  'import ',
  'export ',
  'part ',
  'library ',
  '@', // annotation line only -> will be merged in buffer but safe to skip standalone
];

const _keywords = <String>{
  'if',
  'for',
  'while',
  'switch',
  'catch',
  'on',
  'return',
  'new',
  'throw',
  'await',
  'yield',
  'late',
  'final',
  'var',
};

/// Anti-bruit — à adapter selon ce que tu vois remonter.
/// Avec la version stricte + exclusion constructeurs, tu devrais en avoir beaucoup moins.
const _bannedNames = <String>{
  'Function',
  'Widget',
  'Center',
  'Container',
  'SizedBox',
  'Row',
  'Column',
  'Stack',
  'copyWith',
  'debugPrint',
  'Scaffold',
  'all',
  'Text',
  'Padding',
  'map',
  'TextStyle',
  'read',
  'BoxDecoration',
  'print',
  'Icon',

};
