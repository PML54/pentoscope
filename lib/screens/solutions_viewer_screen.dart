// Modified: 2025-11-16 11:15:00
// lib/screens/solutions_viewer_screen.dart
// Écran pour visualiser toutes les solutions canoniques.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pentapol/data/solution_database.dart';
import 'package:pentapol/utils/plateau_compressor.dart';
import 'package:pentapol/providers/settings_provider.dart';

class SolutionsViewerScreen extends ConsumerStatefulWidget {
  const SolutionsViewerScreen({super.key});

  @override
  ConsumerState<SolutionsViewerScreen> createState() => _SolutionsViewerScreenState();
}

class _SolutionsViewerScreenState extends ConsumerState<SolutionsViewerScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (!SolutionDatabase.isInitialized) {
      return Scaffold(
        appBar: AppBar(title: const Text('Solutions Canoniques')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.orange),
              SizedBox(height: 16),
              Text('Solutions non chargées'),
              SizedBox(height: 8),
              Text('Appelez SolutionDatabase.init() au démarrage'),
            ],
          ),
        ),
      );
    }

    final solutions = SolutionDatabase.allSolutions!;
    final currentSolution = solutions[_currentIndex];
    final plateau = PlateauCompressor.decode(currentSolution);

    return Scaffold(
      appBar: AppBar(
        title: Text('Solution ${_currentIndex + 1}/${solutions.length}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showStats(context, solutions),
          ),
        ],
      ),
      body: Column(
        children: [
          // Navigation
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.first_page),
                  onPressed: _currentIndex > 0
                      ? () => setState(() => _currentIndex = 0)
                      : null,
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _currentIndex > 0
                      ? () => setState(() => _currentIndex--)
                      : null,
                ),
                Expanded(
                  child: Slider(
                    value: _currentIndex.toDouble(),
                    min: 0,
                    max: (solutions.length - 1).toDouble(),
                    divisions: solutions.length - 1,
                    label: '${_currentIndex + 1}',
                    onChanged: (value) {
                      setState(() => _currentIndex = value.toInt());
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _currentIndex < solutions.length - 1
                      ? () => setState(() => _currentIndex++)
                      : null,
                ),
                IconButton(
                  icon: const Icon(Icons.last_page),
                  onPressed: _currentIndex < solutions.length - 1
                      ? () => setState(() => _currentIndex = solutions.length - 1)
                      : null,
                ),
              ],
            ),
          ),

          // Grille
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 6 / 10,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                    childAspectRatio: 1.0,
                    crossAxisSpacing: 1,
                    mainAxisSpacing: 1,
                  ),
                  itemCount: 60,
                  itemBuilder: (context, index) {
                    final x = index % 6;
                    final y = index ~/ 6;
                    final value = plateau.getCell(x, y);

                    Color color;
                    String text;

                    if (value == -1) {
                      color = Colors.grey.shade800;
                      text = '';
                    } else if (value == 0) {
                      color = Colors.grey.shade300;
                      text = '';
                    } else {
                      color = _getPieceColor(value);
                      text = value.toString();
                    }

                    return Container(
                      decoration: BoxDecoration(
                        color: color,
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                      child: Center(
                        child: Text(
                          text,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // Info
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Hash: ${PlateauCompressor.toDebugString(currentSolution).substring(0, 40)}...',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  /// Couleur d'une pièce selon les paramètres de l'utilisateur
  Color _getPieceColor(int pieceId) {
    final settings = ref.read(settingsProvider);
    return settings.ui.getPieceColor(pieceId);
  }

  void _showStats(BuildContext context, List<List<int>> solutions) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Statistiques'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Solutions totales: ${solutions.length}'),
            Text('Taille: ${(solutions.length * 32 / 1024).toStringAsFixed(1)} Ko'),
            const SizedBox(height: 16),
            const Text('Format:'),
            const Text('  • 8 × int32 par solution'),
            const Text('  • 4 bits par cellule'),
            const Text('  • 240 bits utilisés'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

