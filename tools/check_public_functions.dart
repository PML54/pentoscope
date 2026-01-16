import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

/// Nouvelle stratégie: Au lieu de chercher les fonctions publiques,
/// on cherche les NOMS DE CLASSE et on les retourne.
/// C'est ce qu'on veut vraiment: détecter les classes dupliquées!
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
      // ✨ NOUVELLE APPROCHE: Extraire UNIQUEMENT les noms de classe
      final classNames = _extractClassNames(content);

      // Dedup dans un même fichier
      final seen = <String>{};
      for (final name in classNames) {
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
    stdout.writeln('Inserted unique class names: $inserted');

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

/// ✨ NOUVELLE STRATÉGIE:
/// Extraire UNIQUEMENT les noms de classe (class Foo, abstract class Bar)
/// Filtrer:
///   - Les classes des packages Flutter/dart stdlib (Widget, Material, etc.)
///   - Les classes syntétiques
List<String> _extractClassNames(String source) {
  final lines = const LineSplitter().convert(source);
  final out = <String>[];

  // Regex pour détecter: class Foo ou abstract class Foo
  final classRegex = RegExp(r'^\s*(?:abstract\s+)?class\s+([A-Za-z_][A-Za-z0-9_]*)\b');

  final blockState = _BlockState();

  for (final raw in lines) {
    var line = _stripCommentsOneLine(raw, blockState);
    if (blockState.inBlockComment) continue;

    final m = classRegex.firstMatch(line);
    if (m == null) continue;

    final className = m.group(1)!;

    // Filtrer les bannedNames
    if (_bannedNames.contains(className)) {
      continue;
    }

    // Filtrer synthétiques
    if (className.startsWith(r'$')) {
      continue;
    }

    // Filtrer privés
    if (className.startsWith('_')) {
      continue;
    }

    out.add(className);
  }

  return out;
}

class _BlockState {
  bool inBlockComment = false;
}

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

  _Args({
    required this.dbPath,
    required this.rootPath,
    required this.outCsvPath,
    required this.includeGenerated,
  });

  static _Args parse(List<String> args) {
    String? db;
    String? root;
    String? out;
    bool includeGen = false;

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
      }
    }

    if (db == null || root == null) {
      stderr.writeln(
        'Usage: dart run tools/check_public_functions.dart --db <dbfile> --root <projectRoot> '
            '[--out <csv>] [--include-generated true|false]',
      );
      exit(2);
    }

    return _Args(
      dbPath: db,
      rootPath: root,
      outCsvPath: out,
      includeGenerated: includeGen,
    );
  }
}

/// Modified: 2025-01-15T14:00:00
/// LISTE NOIRE COMPLÈTE ET DEDUPLIQUÉE (0 doublon!)
/// Flutter natives + stdlib + classes connues
const _bannedNames = <String>{
  'AbsorbPointer', 'ActionChip', 'AlertDialog', 'Align',
  'AlwaysScrollableScrollPhysics', 'AlwaysStoppedAnimation', 'AnimatedBuilder', 'AnimatedContainer',
  'AnimatedCrossFade', 'AnimatedDefaultTextStyle', 'AnimatedList', 'AnimatedOpacity',
  'AnimatedPadding', 'AnimatedPositioned', 'AnimatedRotation', 'AnimatedScale',
  'AnimatedSize', 'AnimatedSwitcher', 'AnimatedWidget', 'Animation',
  'AnimationController', 'AppBar', 'ArgumentError', 'AspectRatio',
  'AssertionError', 'AssetImage', 'Autocomplete', 'Border',
  'BorderRadius', 'BorderSide', 'BottomAppBar', 'BottomNavigationBar',
  'BottomSheet', 'BouncingScrollPhysics', 'BoxConstraints', 'BoxDecoration',
  'BoxShadow','build','BuildContext', 'Button', 'ButtonBar',
  'ButtonStyle', 'Canvas', 'Card', 'Center',
  'ChangeNotifier', 'ChangeNotifierProvider', 'Checkbox', 'CheckboxListTile',
  'Chip', 'ChipTheme', 'ChoiceChip', 'CircleAvatar',
  'CircularProgressIndicator', 'ClampingScrollPhysics', 'ClipOval', 'ClipPath',
  'ClipRRect', 'ClipRect', 'Color', 'ColorScheme',
  'ColorSwatch', 'Colors', 'Column', 'ConstrainedBox',
  'Container', 'CupertinoActionSheet', 'CupertinoActivityIndicator', 'CupertinoAlertDialog',
  'CupertinoApp', 'CupertinoButton', 'CupertinoDatePicker', 'CupertinoDialog',
  'CupertinoPageRoute', 'CupertinoPageScaffold', 'CupertinoSlider', 'CupertinoSwitch',
  'CupertinoTabBar', 'CupertinoTabScaffold', 'CupertinoTextField', 'CupertinoTimerPicker',
  'Curve', 'Curves', 'CustomClipper', 'CustomMultiChildLayout',
  'CustomPaint', 'CustomPainter', 'CustomScrollView', 'CustomSingleChildLayout',
  'DateTime', 'DecoratedBox', 'DecoratedBoxTransition', 'DefaultTabController',
  'DefaultTextHeightBehavior', 'DefaultTextStyle', 'Dialog', 'Directory',
  'Divider', 'DragTarget', 'Draggable', 'DraggableScrollableSheet',
  'Drawer', 'DropdownButton', 'DropdownButtonFormField', 'Duration',
  'EdgeInsets', 'EditableText', 'ElevatedButton', 'Enum',
  'Error', 'ErrorWidget', 'Exception', 'Expanded',
  'ExpansionPanel', 'ExpansionPanelList', 'ExpansionTile', 'FadeTransition',
  'File', 'FileImage', 'FileSystemEntity', 'FilterChip',
  'FittedBox', 'FlatButton', 'Flexible', 'FlexibleSpace',
  'FloatingActionButton', 'Flow', 'FlutterError', 'Focus',
  'FocusNode', 'FocusScope', 'FontStyle', 'FontWeight',
  'Form', 'FormField', 'FormState', 'FormatException',
  'Function', 'Future', 'FutureBuilder', 'GestureDetector',
  'GlobalKey', 'GradientTransform', 'GridView', 'Icon',
  'IconButton', 'IgnorePointer', 'Image', 'ImageIcon',
  'ImageProvider', 'InheritedModel', 'InheritedWidget', 'InkResponse',
  'InkWell', 'InputChip', 'InputDecoration', 'Iterable',
  'Key', 'LabeledGlobalKey', 'LayoutBuilder', 'LimitedBox',
  'LinearGradient', 'LinearProgressIndicator', 'List', 'ListTile',
  'ListTileTheme', 'ListView', 'Listener', 'LongPressDraggable',
  'Map', 'Material', 'MaterialApp', 'MaterialBanner',
  'MaterialButton', 'MaterialPageRoute', 'Matrix4', 'MediaQuery',
  'MemoryImage', 'MenuAnchor', 'MenuItemButton', 'ModalRoute',
  'MouseRegion', 'NavigationDrawer', 'NavigationRail', 'Navigator',
  'NavigatorState', 'NetworkImage', 'NeverScrollableScrollPhysics', 'NoSuchMethodError',
  'NotificationListener', 'Object', 'ObjectKey', 'Offset',
  'Offstage', 'Opacity', 'OrientationBuilder', 'OutlineInputBorder',
  'OutlinedButton', 'Padding', 'PageController', 'PageRoute',
  'PageRouteBuilder', 'PageStorageKey', 'Paint', 'Path',
  'Placeholder', 'Point', 'PopupMenuButton', 'PopupRoute',
  'Positioned', 'PositionedTransition', 'ProgressIndicator', 'Provider',
  'ProxyWidget', 'RRect', 'RadialGradient', 'Radio',
  'RadioListTile', 'Radius', 'RaisedButton', 'Random',
  'RangeError', 'RangeSlider', 'RawMaterialButton', 'Rect',
  'RenderObjectWidget', 'ReverseAnimation', 'RichText', 'RotationTransition',
  'RoundedRectangleBorder', 'Route', 'RouteSettings', 'Row',
  'SafeArea', 'Scaffold', 'ScaleTransition', 'ScrollController',
  'ScrollPhysics', 'SegmentedButton', 'SelectableText', 'Semantics',
  'Set', 'Shader', 'ShapeDecoration', 'SimpleDialog',
  'SingleChildScrollView', 'Size', 'SizeTransition', 'SizedBox',
  'SlideTransition', 'Slider', 'SliverAppBar', 'SliverFixedExtentList',
  'SliverGrid', 'SliverList', 'SliverPersistentHeader', 'SliverToBoxAdapter',
  'SnackBar', 'Spacer', 'Stack', 'State',
  'StateError', 'StatefulWidget', 'StatelessWidget', 'Stepper',
  'StopWatch', 'Stopwatch', 'Stream', 'StreamBuilder',
  'String', 'SubmenuButton', 'Switch', 'SwitchListTile',
  'TabBar', 'TabBarView', 'TabController', 'Text',
  'TextAlign', 'TextButton', 'TextDirection', 'TextEditingController',
  'TextField', 'TextFormField', 'TextSpan', 'TextStyle',
  'TextTheme', 'ThemeData', 'TimeoutException', 'Timer',
  'Tooltip', 'Transform', 'Tween', 'TweenAnimationBuilder',
  'Type', 'UnimplementedError', 'UniqueKey', 'UnsupportedError',
  'ValueKey', 'ValueListenableBuilder', 'ValueNotifier', 'ValueNotifierProvider',
  'Vector3', 'VerticalDivider', 'Visibility', 'Widget',
  'Wrap', 'bool', 'double', 'int',
};