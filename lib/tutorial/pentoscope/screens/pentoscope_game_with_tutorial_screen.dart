import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pentapol/pentoscope/screens/pentoscope_game_screen.dart';
import 'package:pentapol/pentoscope/pentoscope_provider.dart';
import 'package:pentapol/providers/settings_provider.dart';
import 'package:pentapol/pentoscope/widgets/pentoscope_board.dart';
import 'package:pentapol/pentoscope/widgets/pentoscope_piece_slider.dart';
import 'package:pentapol/tutorial/parser/yaml_parser.dart';
import 'package:pentapol/tutorial/models/tutorial_script.dart';
import 'package:pentapol/tutorial/models/scratch_command.dart';
import 'package:pentapol/tutorial/commands/message_commands.dart';
import 'package:pentapol/tutorial/commands/control_commands.dart';
import 'package:pentapol/tutorial/commands/selection_commands.dart';
import 'package:pentapol/tutorial/commands/placement_commands.dart';
import 'package:pentapol/tutorial/commands/highlight_commands.dart';

/// État du tutoriel pour contrôler l'interface
class TutorialUIState {
  final bool showTutorial;
  final String? message;
  final List<Map<String, dynamic>> highlights;
  final int? highlightedPiece;

  const TutorialUIState({
    this.showTutorial = false,
    this.message,
    this.highlights = const [],
    this.highlightedPiece,
  });

  TutorialUIState copyWith({
    bool? showTutorial,
    String? message,
    List<Map<String, dynamic>>? highlights,
    int? highlightedPiece,
  }) {
    return TutorialUIState(
      showTutorial: showTutorial ?? this.showTutorial,
      message: message ?? this.message,
      highlights: highlights ?? this.highlights,
      highlightedPiece: highlightedPiece ?? this.highlightedPiece,
    );
  }
}

/// Provider pour contrôler l'interface du tutoriel
final tutorialUIProvider = NotifierProvider<TutorialUINotifier, TutorialUIState>(
  TutorialUINotifier.new,
);

class TutorialUINotifier extends Notifier<TutorialUIState> {
  TutorialControlCallback? _boardCallback;
  TutorialControlCallback? _sliderCallback;

  @override
  TutorialUIState build() => const TutorialUIState();

  void _setControlCallbacks({
    TutorialControlCallback? boardCallback,
    TutorialControlCallback? sliderCallback,
  }) {
    _boardCallback = boardCallback;
    _sliderCallback = sliderCallback;
  }

  void startTutorial() {
    state = const TutorialUIState(showTutorial: true);
  }

  void stopTutorial() {
    state = const TutorialUIState();
  }

  void setMessage(String message) {
    state = state.copyWith(message: message);
  }

  void addHighlight(int x, int y, Color color) {
    final newHighlights = List<Map<String, dynamic>>.from(state.highlights)
      ..add({'x': x, 'y': y, 'color': color});
    state = state.copyWith(highlights: newHighlights);

    // Notifier le plateau
    _boardCallback?.call('highlightCell', {'x': x, 'y': y, 'color': color});
  }

  void clearHighlights() {
    state = state.copyWith(highlights: []);

    // Notifier le plateau
    _boardCallback?.call('clearHighlights', {});
  }

  void highlightPiece(int pieceIndex) {
    state = state.copyWith(highlightedPiece: pieceIndex);

    // Notifier le slider
    _sliderCallback?.call('highlightPiece', {'pieceIndex': pieceIndex});
  }

  void clearPieceHighlight() {
    state = state.copyWith(highlightedPiece: null);

    // Notifier le slider
    _sliderCallback?.call('clearHighlight', {});
  }

  // Méthodes pour déclencher des actions sur les widgets
  void triggerBoardAction(String action, Map<String, dynamic> params) {
    _boardCallback?.call(action, params);
  }

  void triggerSliderAction(String action, Map<String, dynamic> params) {
    _sliderCallback?.call(action, params);
  }
}

/// Contexte pour exécuter les commandes du tutoriel Pentoscope
class PentoscopeTutorialContext {
  final WidgetRef ref;

  PentoscopeTutorialContext(this.ref);

  Future<void> selectPieceFromSlider(int pieceIndex) async {
    print('[TUTORIAL_CONTEXT] Sélection pièce $pieceIndex dans le slider');

    // Utiliser la vraie méthode du slider
    final sliderState = sliderKey.currentState as dynamic;
    if (sliderState != null && sliderState.selectPiece != null) {
      sliderState.selectPiece(pieceIndex);
      print('[TUTORIAL_CONTEXT] ✅ Pièce $pieceIndex sélectionnée via slider');
    } else {
      print('[TUTORIAL_CONTEXT] ❌ Slider non accessible');
    }
  }

  Future<void> placePieceAt(int gridX, int gridY) async {
    print('[TUTORIAL_CONTEXT] Placement pièce en ($gridX, $gridY)');

    // Utiliser la vraie méthode du plateau
    final boardState = boardKey.currentState as dynamic;
    if (boardState != null && boardState.placeSelectedPiece != null) {
      boardState.placeSelectedPiece(gridX, gridY);
      print('[TUTORIAL_CONTEXT] ✅ Pièce placée en ($gridX, $gridY) via plateau');
    } else {
      print('[TUTORIAL_CONTEXT] ❌ Plateau non accessible');
    }
  }

  Future<void> highlightCell(int x, int y, Color color) async {
    print('[TUTORIAL_CONTEXT] Highlight cellule ($x, $y) en $color');

    // Utiliser la vraie méthode du plateau
    final boardState = boardKey.currentState as dynamic;
    if (boardState != null && boardState.highlightCell != null) {
      boardState.highlightCell(x, y, color);
      print('[TUTORIAL_CONTEXT] ✅ Cellule ($x, $y) surlignée en $color');
    } else {
      print('[TUTORIAL_CONTEXT] ❌ Plateau non accessible pour highlight');
    }
  }

  void setMessage(String message) {
    print('[TUTORIAL_CONTEXT] Message: $message');
    ref.read(tutorialUIProvider.notifier).setMessage(message);
  }

  void clearHighlights() {
    print('[TUTORIAL_CONTEXT] Clear highlights');

    // Utiliser la vraie méthode du plateau
    final boardState = boardKey.currentState as dynamic;
    if (boardState != null && boardState.clearHighlights != null) {
      boardState.clearHighlights();
      print('[TUTORIAL_CONTEXT] ✅ Highlights effacés');
    } else {
      print('[TUTORIAL_CONTEXT] ❌ Plateau non accessible pour clear highlights');
    }
  }

  Future<void> scrollSliderToPiece(int pieceNumber) async {
    print('[TUTORIAL_CONTEXT] Scroll slider vers pièce $pieceNumber');

    // Utiliser la vraie méthode du slider
    final sliderState = sliderKey.currentState as dynamic;
    if (sliderState != null && sliderState.scrollToPiece != null) {
      sliderState.scrollToPiece(pieceNumber);
      print('[TUTORIAL_CONTEXT] ✅ Slider scrolled vers pièce $pieceNumber');
    } else {
      print('[TUTORIAL_CONTEXT] ❌ Slider non accessible pour scroll');
    }
  }

  Future<void> highlightPieceInSlider(int pieceNumber) async {
    print('[TUTORIAL_CONTEXT] Highlight pièce $pieceNumber dans slider');

    // Utiliser la vraie méthode du slider
    final sliderState = sliderKey.currentState as dynamic;
    if (sliderState != null && sliderState.highlightPiece != null) {
      sliderState.highlightPiece(pieceNumber);
      print('[TUTORIAL_CONTEXT] ✅ Pièce $pieceNumber surlignée dans slider');
    } else {
      print('[TUTORIAL_CONTEXT] ❌ Slider non accessible pour highlight');
    }
  }

  void clearSliderHighlight() {
    print('[TUTORIAL_CONTEXT] Clear slider highlight');

    // Utiliser la vraie méthode du slider
    final sliderState = sliderKey.currentState as dynamic;
    if (sliderState != null && sliderState.clearHighlight != null) {
      sliderState.clearHighlight();
      print('[TUTORIAL_CONTEXT] ✅ Highlight slider effacé');
    } else {
      print('[TUTORIAL_CONTEXT] ❌ Slider non accessible pour clear highlight');
    }
  }
}

/// Écran de tutoriel Pentoscope qui exécute les scripts YAML
class PentoscopeGameWithTutorialScreen extends ConsumerStatefulWidget {
  const PentoscopeGameWithTutorialScreen({
    super.key,
    this.tutorialPath,
  });

  final String? tutorialPath;

  @override
  ConsumerState<PentoscopeGameWithTutorialScreen> createState() =>
      _PentoscopeGameWithTutorialScreenState();
}

class _PentoscopeGameWithTutorialScreenState
    extends ConsumerState<PentoscopeGameWithTutorialScreen> {

  TutorialScript? _script;
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    // Charger et démarrer le tutoriel automatiquement
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(tutorialUIProvider.notifier).startTutorial();
      _loadAndExecuteTutorial();
    });
  }

  Future<void> _loadAndExecuteTutorial() async {
    try {
      final path = widget.tutorialPath ?? 'assets/tutorials/01_intro_basics.yaml';
      print('[YAML_TUTORIAL] Chargement: $path');

      // Charger et parser le script YAML complet
      final yamlContent = await rootBundle.loadString(path);
      final script = YamlScriptParser.parse(yamlContent);

      _script = script;
      _currentStep = 0;

      print('[YAML_TUTORIAL] Script chargé: ${script.name} (${script.steps.length} étapes)');

      // Exécuter les vraies commandes du tutoriel
      await _executeTutorialCommands();

    } catch (e) {
      print('[YAML_TUTORIAL] Erreur: $e');
      ref.read(tutorialUIProvider.notifier).setMessage('Erreur tutoriel: $e');
    }
  }


  Future<void> _executeTutorialCommands() async {
    if (_script == null || !mounted) return;

    // Créer le contexte du tutoriel
    final tutorialContext = PentoscopeTutorialContext(ref);

    for (int i = 0; i < _script!.steps.length; i++) {
      if (!mounted) break;

      final command = _script!.steps[i];
      print('[YAML_TUTORIAL] Exécution étape ${i + 1}/${_script!.steps.length}: ${command.name}');

      _currentStep = i;

      try {
        // Exécuter la commande selon son type
        await _executeCommand(command, tutorialContext);
      } catch (e) {
        print('[YAML_TUTORIAL] Erreur exécution commande ${command.name}: $e');
      }
    }

    // Fin du tutoriel
    ref.read(tutorialUIProvider.notifier).clearHighlights();
  }

  Future<void> _executeCommand(ScratchCommand command, PentoscopeTutorialContext context) async {
    if (command is ShowMessageCommand) {
      context.setMessage(command.text);

    } else if (command is WaitCommand) {
      await Future.delayed(Duration(milliseconds: command.durationMs));

    } else if (command is SelectPieceFromSliderCommand) {
      await context.selectPieceFromSlider(command.pieceNumber - 1); // -1 car les indices commencent à 0

    } else if (command is PlaceSelectedPieceAtCommand) {
      await context.placePieceAt(command.gridX, command.gridY);

    } else if (command is HighlightCellCommand) {
      await context.highlightCell(command.x, command.y, command.color);

    } else if (command is ClearHighlightsCommand) {
      context.clearHighlights();

    } else if (command is ScrollSliderToPieceCommand) {
      await context.scrollSliderToPiece(command.pieceNumber);

    } else if (command is HighlightPieceInSliderCommand) {
      await context.highlightPieceInSlider(command.pieceNumber);

    } else if (command is ClearSliderHighlightCommand) {
      context.clearSliderHighlight();

    } else {
      // Commande non reconnue
      print('[YAML_TUTORIAL] Commande ${command.name} non implémentée');
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }



  @override
  Widget build(BuildContext context) {
    final tutorialUIState = ref.watch(tutorialUIProvider);

    return Stack(
      children: [
        const PentoscopeGameWithTutorialUI(),

        // Overlay du tutoriel
        if (tutorialUIState.showTutorial && tutorialUIState.message != null)
          Positioned(
            top: 120,
            left: 20,
            right: 20,
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(12),
              color: Colors.blue.shade700,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb_outline, color: Colors.white, size: 32),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        tutorialUIState.message!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // Bouton quitter
        if (tutorialUIState.showTutorial)
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: () {
                ref.read(tutorialUIProvider.notifier).stopTutorial();
                Navigator.of(context).pop();
              },
              backgroundColor: Colors.red.shade700,
              child: const Icon(Icons.close, color: Colors.white),
            ),
          ),
      ],
    );
  }
}

/// Callback pour les actions du tutoriel
typedef TutorialControlCallback = void Function(String action, Map<String, dynamic> params);

/// Overlay visuel pour montrer les actions du tutoriel
class TutorialVisualOverlay extends ConsumerWidget {
  const TutorialVisualOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tutorialState = ref.watch(tutorialUIProvider);

    // Debug overlay pour voir l'état
    print('[TUTORIAL_OVERLAY] Build - highlights: ${tutorialState.highlights.length}, highlightedPiece: ${tutorialState.highlightedPiece}, message: ${tutorialState.message}');

    return Stack(
      children: [
        // Debug overlay temporaire
        Positioned(
          top: 100,
          left: 10,
          child: Container(
            padding: const EdgeInsets.all(8),
            color: Colors.red.withOpacity(0.8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('🎯 Highlights: ${tutorialState.highlights.length}',
                    style: const TextStyle(color: Colors.white, fontSize: 14)),
                Text('⭐ Piece: ${tutorialState.highlightedPiece}',
                    style: const TextStyle(color: Colors.white, fontSize: 14)),
                Text('💬 Message: ${tutorialState.message != null ? 'YES' : 'NO'}',
                    style: const TextStyle(color: Colors.white, fontSize: 14)),
                if (tutorialState.highlights.isNotEmpty)
                  Text('📍 First highlight: x=${tutorialState.highlights[0]['x']}, y=${tutorialState.highlights[0]['y']}',
                      style: const TextStyle(color: Colors.yellow, fontSize: 12)),
              ],
            ),
          ),
        ),

        // Highlights des cellules
        ...tutorialState.highlights.map((highlight) {
          // Position approximative des cellules (à affiner)
          final cellSize = 50.0; // Taille approximative d'une cellule
          final offsetX = highlight['x'] * cellSize + 100; // Offset horizontal
          final offsetY = highlight['y'] * cellSize + 200; // Offset vertical

          return Positioned(
            left: offsetX,
            top: offsetY,
            child: Container(
              width: cellSize,
              height: cellSize,
              decoration: BoxDecoration(
                border: Border.all(
                  color: highlight['color'] as Color,
                  width: 4,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.touch_app,
                color: Colors.white,
                size: 24,
              ),
            ),
          );
        }),

        // Highlight de pièce dans le slider
        if (tutorialState.highlightedPiece != null)
          Positioned(
            bottom: 20,
            left: tutorialState.highlightedPiece! * 60.0 + 50, // Position approximative
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.yellow,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: const Icon(
                Icons.star,
                color: Colors.black,
                size: 20,
              ),
            ),
          ),

        // Indicateur de scroll pour le slider
        // TODO: Ajouter des indicateurs visuels pour le scroll
      ],
    );
  }
}

/// Clés globales pour accéder aux widgets du tutoriel
final GlobalKey boardKey = GlobalKey();
final GlobalKey sliderKey = GlobalKey();

/// Wrapper pour PentoscopeGameScreen qui réagit au tutoriel
class PentoscopeGameWithTutorialUI extends ConsumerWidget {
  const PentoscopeGameWithTutorialUI({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        // Le jeu avec des clés pour le tutoriel
        PentoscopeGameScreenWithKeys(
          boardKey: boardKey,
          sliderKey: sliderKey,
        ),
        // Debug overlay
        const TutorialVisualOverlay(),
      ],
    );
  }
}

/// Version modifiée de PentoscopeGameScreen avec des clés pour le tutoriel
class PentoscopeGameScreenWithKeys extends ConsumerWidget {
  final GlobalKey boardKey;
  final GlobalKey sliderKey;

  const PentoscopeGameScreenWithKeys({
    super.key,
    required this.boardKey,
    required this.sliderKey,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pentoscopeProvider);
    final settings = ref.watch(settingsProvider);

    return OrientationBuilder(
      builder: (context, orientation) {
        final isLandscape = orientation == Orientation.landscape;
        final screenSize = MediaQuery.of(context).size;

        // Layout adaptatif selon l'orientation
        return isLandscape
            ? _buildLandscapeLayout(context, state, settings, screenSize)
            : _buildPortraitLayout(context, state, settings, screenSize);
      },
    );
  }

  Widget _buildPortraitLayout(BuildContext context, PentoscopeState state, settings, Size screenSize) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pentoscope'),
        actions: [
          // ... autres actions ...
          IconButton(
            icon: const Icon(Icons.school_outlined),
            color: Colors.teal,
            onPressed: () {
              HapticFeedback.selectionClick();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PentoscopeGameWithTutorialScreen(),
                ),
              );
            },
            tooltip: 'Tutoriel',
          ),
        ],
      ),
      body: Column(
        children: [
          // Plateau avec clé
          Expanded(
            flex: 3,
            child: PentoscopeBoard(
              key: boardKey,
              isLandscape: false,
            ),
          ),
          // Slider avec clé
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              border: const Border(top: BorderSide(color: Colors.grey)),
            ),
            child: PentoscopePieceSlider(
              key: sliderKey,
              isLandscape: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLandscapeLayout(BuildContext context, PentoscopeState state, settings, Size screenSize) {
    return Scaffold(
      body: Row(
        children: [
          // Plateau avec clé
          Expanded(
            flex: 3,
            child: PentoscopeBoard(
              key: boardKey,
              isLandscape: true,
            ),
          ),
          // Panel de droite avec slider et actions
          Container(
            width: 200,
            color: Colors.grey.shade50,
            child: Column(
              children: [
                // Actions en haut
                Container(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // ... autres actions ...
                      IconButton(
                        icon: const Icon(Icons.school_outlined),
                        color: Colors.teal,
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PentoscopeGameWithTutorialScreen(),
                            ),
                          );
                        },
                        tooltip: 'Tutoriel',
                      ),
                    ],
                  ),
                ),
                // Slider avec clé
                Expanded(
                  child: PentoscopePieceSlider(
                    key: sliderKey,
                    isLandscape: true,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
