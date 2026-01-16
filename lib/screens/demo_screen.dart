// lib/screens/demo_screen.dart
// Écran de démonstration automatique du jeu Pentominos

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pentapol/classical/pentomino_game_provider.dart';
import 'package:pentapol/classical/pentomino_game_screen.dart';
import 'package:pentapol/common/pentominos.dart';

class DemoScreen extends ConsumerStatefulWidget {
  const DemoScreen({super.key});

  @override
  ConsumerState<DemoScreen> createState() => _DemoScreenState();
}

class _DemoScreenState extends ConsumerState<DemoScreen> {
  Timer? _demoTimer;
  int _step = 0;
  bool _isPlaying = false;
  String _currentMessage = 'Préparation de la démonstration...';

  final List<DemoStep> _demoSteps = [

    DemoStep(
      message: 'Voici le jeu de Pentominos Classique',
      duration: 1500,
      action: DemoAction.wait,
    ),
    DemoStep(
      message: 'Découvrez les 12 pièces disponibles',
      duration: 2000,
      action: DemoAction.scrollSlider,
      orientations: 6,
    ),
    DemoStep(
      message: 'Chaque pièce a sa forme unique',
      duration: 1000,
      action: DemoAction.scrollSlider,
      orientations: 6,
    ),
    DemoStep(
      message: 'On peut aussi transformer les pièces dans le slider !',
      duration: 2000,
      action: DemoAction.wait,
    ),
    DemoStep(
      message: 'Sélection d\'une pièce pour transformation',
      duration: 2000,
      action: DemoAction.selectPiece,
      pieceNumber: 3,
    ),
    DemoStep(
      message: 'Rotation d\'une pièce dans le slider',
      duration: 1500,
      action: DemoAction.highlightIcon,
      iconName: 'rotation',
    ),
    DemoStep(
      message: 'Transformation dans le slider !',
      duration: 1000,
      action: DemoAction.rotateCW,
    ),
    DemoStep(
      message: 'Effacer la surbrillance',
      duration: 500,
      action: DemoAction.clearIconHighlight,
    ),
    DemoStep(
      message: 'Maintenant on peut placer la pièce transformée',
      duration: 2000,
      action: DemoAction.wait,
    ),
    DemoStep(
      message: 'Sélection d\'une pièce  depuis le slider...',
      duration: 3000,
      action: DemoAction.selectPiece,
      pieceNumber: 2,
    ),
    DemoStep(
      message: 'Animation du déplacement vers le plateau',
      duration: 3000,
      action: DemoAction.animatePiecePlacement,
      gridX: 2,
      gridY: 2,
    ),
    DemoStep(
      message: 'Sélection de la pièce pour la transformation',
      duration: 2000,
      action: DemoAction.selectPlacedPiece,
      pieceNumber: 2,
    ),
    DemoStep(
      message: 'Voici l\'icône de rotation',
      duration: 1500,
      action: DemoAction.highlightIcon,
      iconName: 'rotation',
    ),
    DemoStep(
      message: 'Rotation horaire de 90°',
      duration: 1500,
      action: DemoAction.rotateCW,
    ),
    DemoStep(
      message: 'Effacer la surbrillance',
      duration: 500,
      action: DemoAction.clearIconHighlight,
    ),
    DemoStep(
      message: 'Rotation horaire de 90°',
      duration: 1500,
      action: DemoAction.rotateCW,
    ),
    DemoStep(
      message: 'Rotation horaire de 90°',
      duration: 2500,
      action: DemoAction.rotateCW,
    ),
    DemoStep(
      message: 'Rotation horaire de 90°',
      duration: 2500,
      action: DemoAction.rotateCW,
    ),
    DemoStep(
      message: 'Effacer la surbrillance',
      duration: 500,
      action: DemoAction.clearIconHighlight,
    ),
    DemoStep(
      message: 'Voici l\'icône de rotation anti-horaire',
      duration: 1500,
      action: DemoAction.highlightIcon,
      iconName: 'rotation_cw',
    ),
    DemoStep(
      message: 'Rotation anti-horaire maintenant',
      duration: 2500,
      action: DemoAction.rotateCCW,
    ),
    DemoStep(
      message: 'Rotation anti-horaire maintenant',
      duration: 2500,
      action: DemoAction.rotateCCW,
    ),
    DemoStep(
      message: 'Rotation anti-horaire maintenant',
      duration: 2500,
      action: DemoAction.rotateCCW,
    ),
    DemoStep(
      message: 'Rotation anti-horaire maintenant',
      duration: 2500,
      action: DemoAction.rotateCCW,
    ),

    DemoStep(
      message: 'Voici l\'icône de symétrie verticale',
      duration: 1500,
      action: DemoAction.highlightIcon,
      iconName: 'symmetry_v',
    ),
    DemoStep(
      message: 'Symétrie verticale de la pièce L',
      duration: 2500,
      action: DemoAction.symmetryV,
    ),
    DemoStep(
      message: 'Effacer la surbrillance',
      duration: 500,
      action: DemoAction.clearIconHighlight,
    ),
    DemoStep(
      message: 'Voici l\'icône de symétrie horizontale',
      duration: 1500,
      action: DemoAction.highlightIcon,
      iconName: 'symmetry_h',
    ),
    DemoStep(
      message: 'Puis symétrie horizontale',
      duration: 2500,
      action: DemoAction.symmetryH,
    ),
    DemoStep(
      message: 'Effacer la surbrillance',
      duration: 500,
      action: DemoAction.clearIconHighlight,
    ),


    DemoStep(
      message: 'Maintenant c\'est à vous de jouer !',
      duration: 2000,
      action: DemoAction.finish,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startDemo();
  }

  @override
  void dispose() {
    _demoTimer?.cancel();
    super.dispose();
  }

  void _startDemo() {
    setState(() {
      _isPlaying = true;
      _step = 0;
    });

    // Démarrer la séquence automatiquement
    _runDemoStep();
  }

  Future<void> _runDemoStep() async {
    if (_step >= _demoSteps.length) {
      _finishDemo();
      return;
    }

    final step = _demoSteps[_step];

    setState(() {
      _currentMessage = step.message;
    });

    // Exécuter l'action de l'étape
    await _executeDemoAction(step);

    // Programmer l'étape suivante (pour les actions non-async)
    if (step.action != DemoAction.animatePiecePlacement) {
      _demoTimer = Timer(Duration(milliseconds: step.duration), () {
        setState(() {
          _step++;
        });
        _runDemoStep();
      });
    }
    // Pour animatePiecePlacement, l'animation gère elle-même le délai
  }

  Future<void> _executeDemoAction(DemoStep step) async {
    final gameNotifier = ref.read(pentominoGameProvider.notifier);

    switch (step.action) {
      case DemoAction.wait:
        // Rien à faire, juste attendre
        break;

      case DemoAction.selectPiece:
        if (step.pieceNumber != null) {
          final piece = pentominos.firstWhere(
            (p) => p.id == step.pieceNumber,
            orElse: () => pentominos.first,
          );
          gameNotifier.selectPiece(piece);
        }
        break;

      case DemoAction.placePiece:
        if (step.gridX != null && step.gridY != null) {
          gameNotifier.tryPlacePiece(step.gridX!, step.gridY!);
        }
        break;

      case DemoAction.selectPlacedPiece:
        if (step.pieceNumber != null) {
          final placedPiece = gameNotifier.findPlacedPieceById(
            step.pieceNumber!,
          );
          if (placedPiece != null) {
            // Calculer la mastercase (première cellule de la pièce)
            final position =
                placedPiece.piece.orientations[placedPiece.positionIndex];
            if (position.isNotEmpty) {
              final firstCellNum = position.first;
              final mastercaseX = placedPiece.gridX + (firstCellNum - 1) % 5;
              final mastercaseY = placedPiece.gridY + (firstCellNum - 1) ~/ 5;
              gameNotifier.selectPlacedPieceWithMastercaseForTutorial(
                step.pieceNumber!,
                mastercaseX,
                mastercaseY,
              );
            }
          }
        }
        break;

      case DemoAction.rotateCW:
        gameNotifier.applyIsometryRotationCW();
        break;

      case DemoAction.rotateCCW:
        gameNotifier
            .applyIsometryRotationTW(); // TW = Three Quarter = 270° = anti-horaire de 90°
        break;

      case DemoAction.symmetryH:
        gameNotifier.applyIsometrySymmetryH();
        break;

      case DemoAction.symmetryV:
        gameNotifier.applyIsometrySymmetryV();
        break;

      case DemoAction.scrollSlider:
        if (step.orientations != null) {
          gameNotifier.scrollSlider(step.orientations!);
        }
        break;

      case DemoAction.highlightIcon:
        if (step.iconName != null) {
          gameNotifier.highlightIsometryIcon(step.iconName!);
        }
        break;

      case DemoAction.clearIconHighlight:
        gameNotifier.clearIsometryIconHighlight();
        break;

      case DemoAction.animatePiecePlacement:
        await _animatePiecePlacement(step);
        break;

      case DemoAction.finish:
        _finishDemo();
        break;
    }
  }

  void _finishDemo() {
    setState(() {
      _isPlaying = false;
    });
  }

  /// Anime le placement d'une pièce depuis le slider vers le plateau
  Future<void> _animatePiecePlacement(DemoStep step) async {
    if (step.gridX == null || step.gridY == null) return;

    final overlay = Overlay.of(context);
    final gameNotifier = ref.read(pentominoGameProvider.notifier);

    // Trouver la pièce sélectionnée (normalement pièce n°2 dans la démo)
    final piece = pentominos.firstWhere(
      (p) => p.id == 2,
      orElse: () => pentominos.first,
    );

    // Créer un RenderBox pour mesurer les positions
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    // Position de départ : milieu bas de l'écran (où est le slider)
    final startPosition = Offset(
      renderBox.size.width / 2 - 50, // Centrer horizontalement, ajuster pour la taille de la pièce
      renderBox.size.height * 0.85 - 50, // Bas de l'écran où est le slider
    );

    // Position d'arrivée : calculer précisément où la pièce sera sur le plateau
    // Le plateau prend environ 70% de la largeur et est centré
    final boardWidth = renderBox.size.width * 0.7;
    final boardHeight = boardWidth * (10 / 6); // Ratio 6x10
    final boardLeft = (renderBox.size.width - boardWidth) / 2;
    final boardTop = renderBox.size.height * 0.25; // Le plateau commence vers le 1/4 supérieur

    // Chaque cellule fait boardWidth/6 en largeur et boardHeight/10 en hauteur
    final cellWidth = boardWidth / 6;
    final cellHeight = boardHeight / 10;

    final endPosition = Offset(
      boardLeft + (step.gridX! * cellWidth) + (cellWidth / 2) - 50, // Centrer sur la cellule
      boardTop + (step.gridY! * cellHeight) + (cellHeight / 2) - 50,
    );

    // Créer l'animation
    late OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) {
        return AnimatedPieceWidget(
          piece: piece,
          startPosition: startPosition,
          endPosition: endPosition,
          duration: const Duration(milliseconds: 2000),
          onComplete: () {
            overlayEntry.remove();
            // Placer réellement la pièce après l'animation
            gameNotifier.tryPlacePiece(step.gridX!, step.gridY!);
            // Passer à l'étape suivante après l'animation
            setState(() {
              _step++;
            });
            _runDemoStep();
          },
        );
      },
    );

    overlay.insert(overlayEntry);
  }

  void _stopDemo() {
    _demoTimer?.cancel();
    setState(() {
      _isPlaying = false;
      _currentMessage = 'Démonstration arrêtée';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Démonstration automatique'),
        actions: [
          if (_isPlaying)
            IconButton(
              icon: const Icon(Icons.stop),
              onPressed: _stopDemo,
              tooltip: 'Arrêter la démo',
            )
          else
            IconButton(
              icon: const Icon(Icons.play_arrow),
              onPressed: _startDemo,
              tooltip: 'Relancer la démo',
            ),
        ],
      ),
      body: Column(
        children: [
          // Zone de message
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: colorScheme.primaryContainer.withOpacity(0.3),
            child: Text(
              _currentMessage,
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Indicateur de progression
          LinearProgressIndicator(
            value: _step / _demoSteps.length,
            backgroundColor: colorScheme.surfaceVariant,
            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
          ),

          // Jeu Pentominos (avec overlay pour la démo)
          Expanded(
            child: Stack(
              children: [
                const PentominoGameScreen(),

/*                // Overlay semi-transparent pendant la démo
                if (_isPlaying)
                  Container(
                    color: Colors.black.withOpacity(0.1),
                    child: const Center(
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'Démonstration en cours...\nRegardez les actions automatiques',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),*/

                // Bouton pour arrêter/recommencer en bas
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: FloatingActionButton(
                    onPressed: _isPlaying ? _stopDemo : _startDemo,
                    child: Icon(_isPlaying ? Icons.stop : Icons.play_arrow),
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

/// Étape de démonstration
class DemoStep {
  final String message;
  final int duration; // en millisecondes
  final DemoAction action;
  final int? pieceNumber;
  final int? gridX;
  final int? gridY;
  final int? orientations; // pour scrollSlider
  final String? iconName; // pour highlightIcon

  const DemoStep({
    required this.message,
    required this.duration,
    required this.action,
    this.pieceNumber,
    this.gridX,
    this.gridY,
    this.orientations,
    this.iconName,
  });
}

/// Actions possibles dans la démo
enum DemoAction {
  wait,
  selectPiece,
  placePiece,
  animatePiecePlacement, // Nouvelle action pour simuler la trajectoire
  selectPlacedPiece,
  rotateCW,
  rotateCCW,
  symmetryH,
  symmetryV,
  scrollSlider,
  highlightIcon, // Nouvelle action pour surligner une icône
  clearIconHighlight, // Nouvelle action pour effacer la surbrillance
  finish,
}

/// Widget pour animer une pièce se déplaçant du slider vers le plateau
class AnimatedPieceWidget extends StatefulWidget {
  final Pento piece;
  final Offset startPosition;
  final Offset endPosition;
  final Duration duration;
  final VoidCallback onComplete;

  const AnimatedPieceWidget({
    super.key,
    required this.piece,
    required this.startPosition,
    required this.endPosition,
    required this.duration,
    required this.onComplete,
  });

  @override
  State<AnimatedPieceWidget> createState() => _AnimatedPieceWidgetState();
}

class _AnimatedPieceWidgetState extends State<AnimatedPieceWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _positionAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _positionAnimation = Tween<Offset>(
      begin: widget.startPosition,
      end: widget.endPosition,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    // Animation d'échelle pour un effet plus naturel
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward().then((_) {
      widget.onComplete();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _positionAnimation,
      builder: (context, child) {
        return Positioned(
          left: _positionAnimation.value.dx,
          top: _positionAnimation.value.dy,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: 0.9,
              child: PentominoPieceWidget(
                piece: widget.piece,
                cellSize: 24, // Taille adaptée pour l'animation
                positionIndex: 0, // Position par défaut
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Widget pour afficher une pièce pentomino
class PentominoPieceWidget extends StatelessWidget {
  final Pento piece;
  final double cellSize;
  final int positionIndex;

  const PentominoPieceWidget({
    super.key,
    required this.piece,
    required this.cellSize,
    required this.positionIndex,
  });

  @override
  Widget build(BuildContext context) {
    final position = piece.orientations[positionIndex];

    // Calculer les dimensions de la pièce
    int minX = 5, maxX = 0, minY = 5, maxY = 0;
    for (final cellNum in position) {
      final x = (cellNum - 1) % 5;
      final y = (cellNum - 1) ~/ 5;
      minX = minX < x ? minX : x;
      maxX = maxX > x ? maxX : x;
      minY = minY < y ? minY : y;
      maxY = maxY > y ? maxY : y;
    }

    final width = (maxX - minX + 1) * cellSize;
    final height = (maxY - minY + 1) * cellSize;

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: position.map((cellNum) {
          final localX = (cellNum - 1) % 5;
          final localY = (cellNum - 1) ~/ 5;

          // Ajuster les coordonnées par rapport au coin supérieur gauche
          final adjustedX = (localX - minX) * cellSize;
          final adjustedY = (localY - minY) * cellSize;

          return Positioned(
            left: adjustedX,
            top: adjustedY,
            child: Container(
              width: cellSize - 1, // Petit espacement
              height: cellSize - 1,
              decoration: BoxDecoration(
                color: Colors.blue.shade600,
                border: Border.all(
                  color: Colors.white,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
