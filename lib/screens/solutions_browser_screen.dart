// Modified: 2025-11-16 11:35:00
// lib/screens/solutions_browser_screen.dart
// Navigateur pour parcourir des solutions de pentominos stockées en BigInt (360 bits)

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pentapol/services/solution_matcher.dart';
import 'package:pentapol/common/pentominos.dart';
import 'package:pentapol/providers/settings_provider.dart';

class SolutionsBrowserScreen extends ConsumerStatefulWidget {
  /// Liste de solutions à afficher (BigInt).
  /// Si null → on affiche toutes les solutions de solutionMatcher.
  final List<BigInt>? initialSolutions;

  /// Titre personnalisé (affiché en petit au-dessus des flèches si fourni).
  final String? title;

  /// Constructeur standard : affiche toutes les solutions.
  const SolutionsBrowserScreen({super.key})
      : initialSolutions = null,
        title = null;

  /// Constructeur pour afficher une liste donnée de solutions.
  const SolutionsBrowserScreen.forSolutions({
    super.key,
    required List<BigInt> solutions,
    String? title,
  })  : initialSolutions = solutions,
        title = title;

  @override
  ConsumerState<SolutionsBrowserScreen> createState() => _SolutionsBrowserScreenState();
}

class _SolutionsBrowserScreenState extends ConsumerState<SolutionsBrowserScreen> {
  final SolutionMatcher _matcher = solutionMatcher; // singleton
  late final Map<int, int> _idByBit6;
  late List<BigInt> _allSolutions;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    // bit6 -> id de pièce (1..12)
    _idByBit6 = {
      for (final p in pentominos) p.bit6: p.id,
    };

    try {
      if (widget.initialSolutions != null) {
        _allSolutions = List<BigInt>.from(widget.initialSolutions!);
        debugPrint('[BROWSER] ${_allSolutions.length} solutions (filtrées) chargées');
      } else {
        _allSolutions = _matcher.allSolutions;
        debugPrint('[BROWSER] ${_allSolutions.length} solutions (toutes) chargées');
      }
    } catch (e) {
      debugPrint('[BROWSER] Solutions non initialisées: $e');
      _allSolutions = const [];
    }
  }

  void _previousSolution() {
    setState(() {
      if (_allSolutions.isEmpty) return;
      if (_currentIndex > 0) {
        _currentIndex--;
      } else {
        _currentIndex = _allSolutions.length - 1; // Boucler au dernier
      }
    });
  }

  void _nextSolution() {
    setState(() {
      if (_allSolutions.isEmpty) return;
      if (_currentIndex < _allSolutions.length - 1) {
        _currentIndex++;
      } else {
        _currentIndex = 0; // Boucler au premier
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_allSolutions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Solutions'),
          backgroundColor: Colors.blue[700],
        ),
        body: const Center(
          child: Text(
            'Aucune solution chargée.\n'
                'Vérifie que SolutionMatcher est bien initialisé au démarrage.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final BigInt solutionBigInt = _allSolutions[_currentIndex];
    final grid = _decodeSolutionToIds(solutionBigInt); // 60 ids de pièces
    
    // Détecter l'orientation
    final isLandscape = MediaQuery.of(context).size.width > MediaQuery.of(context).size.height;
    final visualCols = isLandscape ? 10 : 6;
    final visualRows = isLandscape ? 6 : 10;
    final aspectRatio = isLandscape ? 10 / 6 : 6 / 10;

    // En mode paysage, pas d'AppBar
    if (isLandscape) {
      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          body: SafeArea(
            child: Row(
              children: [
                // Plateau (prend tout l'espace disponible)
                Expanded(
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: aspectRatio,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        child: _buildGrid(grid, visualCols, visualRows, isLandscape),
                      ),
                    ),
                  ),
                ),
                // Slider vertical à droite
                _buildVerticalSlider(),
              ],
            ),
          ),
        ),
      );
    }

    // Mode portrait : AppBar classique
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[700],
        iconTheme: IconThemeData(color: Colors.red.shade300),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.title != null)
              Text(
                widget.title!,
                style: TextStyle(fontSize: 12, color: Colors.red.shade100),
              ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.red.shade300),
                  tooltip: 'Précédente',
                  onPressed: _previousSolution,
                ),
                const SizedBox(width: 8),
                Text(
                  '${_currentIndex + 1} / ${_allSolutions.length}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade100,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.arrow_forward, color: Colors.red.shade300),
                  tooltip: 'Suivante',
                  onPressed: _nextSolution,
                ),
              ],
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Center(
        child: AspectRatio(
          aspectRatio: aspectRatio,
          child: Container(
            padding: const EdgeInsets.all(16),
            child: _buildGrid(grid, visualCols, visualRows, isLandscape),
          ),
        ),
      ),
    );
  }

  Widget _buildGrid(List<int> grid, int visualCols, int visualRows, bool isLandscape) {
    return GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: visualCols,
                childAspectRatio: 1.0,
                crossAxisSpacing: 0, // on gère les contours nous-mêmes
                mainAxisSpacing: 0,
              ),
              itemCount: 60,
              itemBuilder: (context, index) {
                // Calculer les coordonnées visuelles
                final visualX = index % visualCols;
                final visualY = index ~/ visualCols;
                
                // Transformer en coordonnées logiques (6×10)
                int logicalX, logicalY;
                if (isLandscape) {
                  // Paysage: rotation 90° anti-horaire
                  logicalX = (visualRows - 1) - visualY;
                  logicalY = visualX;
                } else {
                  // Portrait: pas de transformation
                  logicalX = visualX;
                  logicalY = visualY;
                }
                
                final cellIndex = logicalY * 6 + logicalX;
                final pieceId = grid[cellIndex];

                final border = _buildPieceBorder(logicalX, logicalY, grid, isLandscape);

                final backgroundColor = _getPieceColor(pieceId);
                
                return Container(
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    border: border,
                  ),
                  child: Center(
                    child: Text(
                      pieceId.toString(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: backgroundColor.computeLuminance() > 0.5
                            ? Colors.red.shade900
                            : Colors.red.shade100,
                      ),
                    ),
                  ),
                );
              },
            );
  }

  /// Slider vertical pour le mode paysage
  Widget _buildVerticalSlider() {
    return Container(
      width: 80,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(
          left: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Bouton retour
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: const EdgeInsets.all(12),
                child: Icon(Icons.close, color: Colors.grey.shade700),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Bouton précédent
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _previousSolution,
              child: Container(
                padding: const EdgeInsets.all(12),
                child: Icon(Icons.arrow_upward, color: Colors.blue.shade700, size: 32),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Compteur
          Text(
            '${_currentIndex + 1}',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade700,
            ),
          ),
          const Divider(height: 8),
          Text(
            '${_allSolutions.length}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 12),
          // Bouton suivant
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _nextSolution,
              child: Container(
                padding: const EdgeInsets.all(12),
                child: Icon(Icons.arrow_downward, color: Colors.blue.shade700, size: 32),
              ),
            ),
          ),
          if (widget.title != null) ...[
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                widget.title!,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Decode un BigInt (360 bits) en 60 ids de pièces (1..12).
  /// On suppose que le BigInt a été construit avec :
  ///   acc = (acc << 6) | code;
  /// dans l'ordre des 60 cases.
  List<int> _decodeSolutionToIds(BigInt value) {
    const int cells = 60;
    const int mask = 0x3F; // 6 bits

    final board = List<int>.filled(cells, 0);
    var v = value;

    // On lit de la fin à l'avant : cell 59, 58, ..., 0
    for (int i = cells - 1; i >= 0; i--) {
      final code = (v & BigInt.from(mask)).toInt();
      final id = _idByBit6[code] ?? 0;
      board[i] = id;
      v = v >> 6;
    }

    return board;
  }

  /// Couleur d'une pièce selon les paramètres de l'utilisateur
  Color _getPieceColor(int pieceId) {
    final settings = ref.read(settingsProvider);
    return settings.ui.getPieceColor(pieceId);
  }

  /// Construit un contour de pièce : trait épais aux frontières entre pièces.
  /// En paysage, les bordures sont adaptées à la rotation visuelle.
  Border _buildPieceBorder(int x, int y, List<int> grid, bool isLandscape) {
    const width = 6;
    const height = 10;

    final index = y * width + x;
    final id = grid[index];

    // Fonction pour récupérer l'id voisin ou -1 si hors plateau
    int neighborId(int nx, int ny) {
      if (nx < 0 || nx >= width || ny < 0 || ny >= height) return -1;
      return grid[ny * width + nx];
    }

    final idLogicalTop = neighborId(x, y - 1);
    final idLogicalBottom = neighborId(x, y + 1);
    final idLogicalLeft = neighborId(x - 1, y);
    final idLogicalRight = neighborId(x + 1, y);

    // Si voisin différent (ou bord du plateau), on trace un contour épais.
    const borderWidthOuter = 2.0;
    const borderWidthInner = 0.5;

    // En paysage, rotation 90° anti-horaire des bordures
    if (isLandscape) {
      return Border(
        top: BorderSide(
          color: (idLogicalRight != id) ? Colors.black : Colors.grey.shade400,
          width: (idLogicalRight != id) ? borderWidthOuter : borderWidthInner,
        ),
        bottom: BorderSide(
          color: (idLogicalLeft != id) ? Colors.black : Colors.grey.shade400,
          width: (idLogicalLeft != id) ? borderWidthOuter : borderWidthInner,
        ),
        left: BorderSide(
          color: (idLogicalTop != id) ? Colors.black : Colors.grey.shade400,
          width: (idLogicalTop != id) ? borderWidthOuter : borderWidthInner,
        ),
        right: BorderSide(
          color: (idLogicalBottom != id) ? Colors.black : Colors.grey.shade400,
          width: (idLogicalBottom != id) ? borderWidthOuter : borderWidthInner,
        ),
      );
    } else {
      // Portrait : bordures normales
      return Border(
        top: BorderSide(
          color: (idLogicalTop != id) ? Colors.black : Colors.grey.shade400,
          width: (idLogicalTop != id) ? borderWidthOuter : borderWidthInner,
        ),
        bottom: BorderSide(
          color: (idLogicalBottom != id) ? Colors.black : Colors.grey.shade400,
          width: (idLogicalBottom != id) ? borderWidthOuter : borderWidthInner,
        ),
        left: BorderSide(
          color: (idLogicalLeft != id) ? Colors.black : Colors.grey.shade400,
          width: (idLogicalLeft != id) ? borderWidthOuter : borderWidthInner,
        ),
        right: BorderSide(
          color: (idLogicalRight != id) ? Colors.black : Colors.grey.shade400,
          width: (idLogicalRight != id) ? borderWidthOuter : borderWidthInner,
        ),
      );
    }
  }
}


