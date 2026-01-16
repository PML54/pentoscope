#!/usr/bin/env dart

// lib/pentapol/tools/check_duplicate_functions.dart
// Modified: 2025-01-15T11:00:00
// Détecte les VRAIES FONCTIONS dupliquées (exclut Flutter natives et classes)
// CHANGEMENTS:
// (1) Liste FLUTTER_NATIVES massamment étendue (150+ items uniques), ligne 17
// (2) Tous les doublons supprimés du Set (utilisation d'un outil de déduplication)
// (3) RegExp en final (non-const)
// (4) Suppression de COLOR_CYAN (utilisation COLOR_YELLOW)

import 'dart:io';
import 'dart:convert';
import 'config.dart';

class DuplicateFunctionsChecker {
  // ðŸ†• LISTE NOIRE: Classes/Widgets/Types Flutter natifs + stubs
  // DEDUPLIQUÉE: Chaque item apparaît UNE SEULE FOIS
  static const Set<String> FLUTTER_NATIVES = {
    // Layout
    'Align', 'AspectRatio', 'Center', 'Column', 'Container', 'Expanded',
    'FittedBox', 'Flow', 'GridView', 'ListView', 'Padding', 'Row', 'Stack',
    'Wrap', 'SliverAppBar', 'SliverFixedExtentList', 'SliverGrid',
    'SliverList', 'SliverPersistentHeader', 'SliverToBoxAdapter',
    'CustomScrollView', 'LayoutBuilder', 'ConstrainedBox', 'LimitedBox',
    'Offstage', 'Positioned', 'PositionedTransition', 'Transform',
    'ScaleTransition', 'RotationTransition', 'SlideTransition',
    'SizeTransition', 'FadeTransition', 'DefaultTabController',
    'OrientationBuilder', 'MediaQuery', 'SafeArea', 'Spacer', 'SingleChildScrollView',
    'SizedBox',

    // Material
    'AppBar', 'Scaffold', 'FloatingActionButton', 'Drawer', 'BottomSheet',
    'Dialog', 'AlertDialog', 'SnackBar', 'Tooltip', 'PopupMenuButton',
    'BottomNavigationBar', 'BottomAppBar', 'NavigationRail',
    'NavigationDrawer', 'TabBar', 'TabBarView', 'TabController', 'Stepper',
    'ProgressIndicator', 'Divider', 'VerticalDivider', 'ListTile',
    'ListTileTheme', 'CheckboxListTile', 'RadioListTile', 'SwitchListTile',

    // Form
    'TextField', 'TextFormField', 'Checkbox', 'Radio', 'Switch', 'Slider',
    'RangeSlider', 'DropdownButton', 'DropdownButtonFormField', 'Autocomplete',
    'Form', 'FormField', 'FormState', 'Semantics',

    // Buttons
    'ElevatedButton', 'TextButton', 'OutlinedButton', 'IconButton', 'ButtonBar',
    'SegmentedButton', 'ButtonStyle', 'MaterialButton',

    // Cards & Chips
    'Card', 'Chip', 'FilterChip', 'ChoiceChip', 'InputChip', 'ActionChip',
    'ChipTheme',

    // Dialogs & Menus
    'SimpleDialog', 'ExpansionTile', 'ExpansionPanel', 'ExpansionPanelList',
    'MenuAnchor', 'SubmenuButton', 'MenuItemButton',

    // Animation
    'AnimatedBuilder', 'AnimatedContainer', 'AnimatedCrossFade',
    'AnimatedDefaultTextStyle', 'AnimatedList', 'AnimatedOpacity',
    'AnimatedPadding', 'AnimatedPositioned', 'AnimatedRotation', 'AnimatedScale',
    'AnimatedSize', 'AnimatedSwitcher', 'AnimatedWidget', 'DecoratedBox',
    'DecoratedBoxTransition', 'TweenAnimationBuilder',

    // Clipping
    'ClipOval', 'ClipPath', 'ClipRect', 'ClipRRect', 'CustomClipper',

    // Custom Painting
    'CustomPaint', 'CustomPainter', 'Paint', 'Path', 'Canvas',
    'CustomSingleChildLayout', 'CustomMultiChildLayout',

    // Scrolling & Dragging
    'DraggableScrollableSheet', 'ScrollController', 'Draggable', 'DragTarget',
    'LongPressDraggable',

    // Interaction & Focus
    'GestureDetector', 'InkWell', 'InkResponse', 'MouseRegion', 'Listener',
    'Focus', 'FocusScope', 'FocusNode', 'RawMaterialButton',

    // Text & Typography
    'Text', 'RichText', 'TextSpan', 'SelectableText', 'EditableText',
    'DefaultTextStyle', 'TextTheme',

    // Image & Icon
    'Image', 'Icon', 'CircleAvatar', 'ImageIcon', 'AssetImage', 'NetworkImage',
    'FileImage', 'MemoryImage',

    // Progress
    'LinearProgressIndicator', 'CircularProgressIndicator',

    // Visibility
    'Visibility', 'IgnorePointer', 'AbsorbPointer', 'ErrorWidget', 'Placeholder',
    'Opacity',

    // Material & Styling
    'Material', 'MaterialBanner', 'ShapeDecoration', 'BoxDecoration', 'Border',
    'BorderSide', 'BorderRadius', 'BoxShadow', 'BoxConstraints', 'EdgeInsets',
    'Curve', 'Curves', 'Tween', 'Animation', 'AnimationController', 'TextStyle',
    'TextAlign', 'TextDirection', 'FontWeight', 'FontStyle', 'ThemeData',
    'MaterialApp', 'CupertinoApp', 'ColorScheme', 'InputDecoration',
    'OutlineInputBorder', 'RoundedRectangleBorder', 'LinearGradient',
    'RadialGradient',

    // Async & Streaming
    'StreamBuilder', 'FutureBuilder', 'ValueListenableBuilder', 'InheritedWidget',
    'InheritedModel', 'NotificationListener',

    // Provider & State Management
    'Provider', 'ChangeNotifier', 'ValueNotifier', 'ChangeNotifierProvider',
    'ValueNotifierProvider',

    // Navigation
    'Navigator', 'NavigatorState', 'Route', 'RouteSettings', 'PageRoute',
    'MaterialPageRoute', 'CupertinoPageRoute', 'ModalRoute', 'PopupRoute',
    'PageRouteBuilder',

    // Context & BuildContext
    'BuildContext', 'State', 'StatefulWidget', 'StatelessWidget', 'ProxyWidget',
    'RenderObjectWidget',

    // Standard Types & Exceptions
    'String', 'int', 'double', 'bool', 'List', 'Map', 'Set', 'Future', 'Stream',
    'Color', 'Duration', 'DateTime', 'File', 'Offset', 'Size', 'Rect', 'Radius',
    'RRect', 'Matrix4', 'Vector3', 'Widget', 'Key', 'ValueKey', 'ObjectKey',
    'UniqueKey', 'TextEditingController', 'Random', 'ArgumentError',
    'Exception', 'Error', 'StateError', 'TimeoutException', 'NoSuchMethodError',
    'UnimplementedError', 'PreferredSize', 'Timer', 'Stopwatch', 'Point',
    'NeverScrollableScrollPhysics', 'AlwaysScrollableScrollPhysics',
    'BouncingScrollPhysics', 'ClampingScrollPhysics', 'ScrollPhysics', 'Shadow',

    // Cupertino (iOS-style)
    'CupertinoButton', 'CupertinoSwitch', 'CupertinoSlider', 'CupertinoDatePicker',
    'CupertinoTimerPicker', 'CupertinoTextField', 'CupertinoActivityIndicator',
    'CupertinoActionSheet', 'CupertinoAlertDialog', 'CupertinoDialog',

    // Internal/Generated Stubs
    'Function', 'SolutionInfo', 'PieceRenderer', 'DraggablePieceWidget',
    'PentoscopeGenerator', 'PentoscopePieceSlider', 'PentoscopeSolver',
    'SettingsDatabase',
  };

  // ðŸ†• PATTERNS À EXCLURE
  static final List<RegExp> EXCLUDED_PATTERNS = [
    RegExp(r'^[A-Z][a-z]*<'), // Génériques: List<T>, Map<K,V>
    RegExp(r'.*\$'), // Types synthétiques: \$1, etc.
    RegExp(r'^_'), // Privés: _buildCell, _applyIso
    RegExp(r'^[a-z]'), // Minuscules: build, add, get, set
  ];

  final Map<String, List<Map<String, String>>> functionsByName = {};
  int totalDuplicates = 0;

  Future<void> run() async {
    printf('$COLOR_BOLD=== Détection des VRAIES fonctions dupliquées ===$COLOR_RESET\n');
    printf('${COLOR_YELLOW}(exclusion: natives Flutter + classes + types)${COLOR_RESET}\n\n');

    if (!File(DB_FULL_PATH).existsSync()) {
      printf('$COLOR_REDâœ— Base de données non trouvée: $DB_FULL_PATH$COLOR_RESET\n');
      exit(1);
    }

    printf('${COLOR_YELLOW}Interrogation de la base de données...${COLOR_RESET}\n');

    final result = await _querySqlite();

    if (result.isEmpty) {
      printf('$COLOR_GREENâœ" Aucune fonction dupliquée détectée$COLOR_RESET\n');
      exit(0);
    }

    // Parser les résultats
    for (final line in result.split('\n')) {
      if (line.trim().isEmpty) continue;

      final parts = line.split('|');
      if (parts.length < 5) continue;

      final funcName = parts[0].trim();

      // FILTRE 1: Exclure les natives Flutter
      if (FLUTTER_NATIVES.contains(funcName)) {
        continue;
      }

      // FILTRE 2: Exclure les patterns non-fonctions
      if (EXCLUDED_PATTERNS.any((pattern) => pattern.hasMatch(funcName))) {
        continue;
      }

      final dartId = parts[1].trim();
      final relativePath = parts[2].trim();
      final firstDir = parts[3].trim();
      final count = parts[4].trim();

      functionsByName.putIfAbsent(funcName, () => []).add({
        'dart_id': dartId,
        'relative_path': relativePath,
        'first_dir': firstDir,
        'occurrence_count': count,
      });

      totalDuplicates++;
    }

    if (functionsByName.isEmpty) {
      printf('$COLOR_GREENâœ" Aucune VRAIE fonction dupliquée détectée (après filtrage)$COLOR_RESET\n');
      exit(0);
    }

    printf('$COLOR_GREENâœ" ${functionsByName.length} fonction(s) dupliquée(s) trouvée(s)$COLOR_RESET\n');
    printf('$COLOR_GREENâœ" $totalDuplicates occurrence(s) totales$COLOR_RESET\n\n');

    _printSummary();
    await _insertIntoDb();
  }

  Future<String> _querySqlite() async {
    const query = '''
SELECT 
  f.function_name,
  f.dart_id,
  df.relative_path,
  df.first_dir,
  COUNT(*) as occurrence_count
FROM functions f
JOIN dartfiles df ON f.dart_id = df.dart_id
GROUP BY f.function_name
HAVING COUNT(*) > 1
ORDER BY f.function_name, df.relative_path;
''';

    try {
      final process = await Process.run(
        'sqlite3',
        ['-separator', '|', DB_FULL_PATH, query],
      );

      if (process.exitCode != 0) {
        printf('$COLOR_REDâœ— Erreur sqlite3: ${process.stderr}$COLOR_RESET\n');
        exit(1);
      }

      return process.stdout as String;
    } catch (e) {
      printf('$COLOR_REDâœ— Erreur: $e$COLOR_RESET\n');
      exit(1);
    }
  }

  void _printSummary() {
    printf('$COLOR_BOLD=== Fonctions dupliquées ===$COLOR_RESET\n');
    printf('${COLOR_YELLOW}(natives Flutter et types sont exclus)${COLOR_RESET}\n\n');

    int count = 0;
    for (final funcName in functionsByName.keys.toList()..sort()) {
      final occurrences = functionsByName[funcName]!;
      count++;
      printf('$COLOR_YELLOW[$count] $funcName$COLOR_RESET (${occurrences.length} fichiers)\n');

      for (final occ in occurrences) {
        printf('  â€¢ [${occ['dart_id']}] ${occ['relative_path']}\n');
      }
      printf('\n');
    }

    printf('$COLOR_BOLD=== Résumé ===$COLOR_RESET\n');
    printf('Vraies fonctions dupliquées: $COLOR_BOLD${functionsByName.length}$COLOR_RESET\n');
    printf('Occurrences totales: $COLOR_BOLD$totalDuplicates$COLOR_RESET\n\n');
  }

  Future<void> _insertIntoDb() async {
    printf('${COLOR_YELLOW}Insertion dans la table duplicate_functions...${COLOR_RESET}\n');

    // Construire les INSERT
    final buffer = StringBuffer();
    buffer.writeln('BEGIN TRANSACTION;');

    for (final funcName in functionsByName.keys) {
      final occurrences = functionsByName[funcName]!;

      for (final occ in occurrences) {
        final dartId = occ['dart_id'];
        final relativePath = occ['relative_path'];
        final firstDir = occ['first_dir'];
        final count = occ['occurrence_count'];

        buffer.writeln('''INSERT INTO duplicate_functions (function_name, dart_id, relative_path, first_dir, occurrence_count)
VALUES ('$funcName', $dartId, '$relativePath', '$firstDir', $count);''');
      }
    }

    buffer.writeln('COMMIT;');

    try {
      final process = await Process.start(
        'sqlite3',
        [DB_FULL_PATH],
      );

      process.stdin.write(buffer.toString());
      await process.stdin.close();

      final exitCode = await process.exitCode;
      if (exitCode != 0) {
        final error = await process.stderr.transform(const Utf8Decoder()).join();
        printf('$COLOR_REDâœ— Erreur insertion: $error$COLOR_RESET\n');
        exit(1);
      }

      printf('$COLOR_GREENâœ" Table duplicate_functions remplie$COLOR_RESET\n');
    } catch (e) {
      printf('$COLOR_REDâœ— Erreur: $e$COLOR_RESET\n');
      exit(1);
    }
  }
}

void printf(String msg) => stdout.write(msg);

Future<void> main(List<String> args) async {
  try {
    await DuplicateFunctionsChecker().run();
  } catch (e) {
    printf('$COLOR_REDâœ— Erreur: $e$COLOR_RESET\n');
    exit(1);
  }
}