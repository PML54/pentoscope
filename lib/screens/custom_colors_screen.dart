// Modified: 2025-11-16 11:00:00
// lib/screens/custom_colors_screen.dart
// Écran pour personnaliser les couleurs des pièces

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pentapol/providers/settings_provider.dart';
import 'package:pentapol/common/pentominos.dart';
import 'package:pentapol/utils/piece_utils.dart';

class CustomColorsScreen extends ConsumerStatefulWidget {
  const CustomColorsScreen({super.key});

  @override
  ConsumerState<CustomColorsScreen> createState() => _CustomColorsScreenState();
}

class _CustomColorsScreenState extends ConsumerState<CustomColorsScreen> {
  late List<Color> _colors;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsProvider);
    
    // Si pas de couleurs personnalisées, utiliser les couleurs classiques par défaut
    if (settings.ui.customColors.isEmpty) {
      _colors = List.from(defaultPieceColors);
    } else {
      _colors = List.from(settings.ui.customColors);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Couleurs personnalisées'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: 'Enregistrer',
            onPressed: () async {
              await ref.read(settingsProvider.notifier).setCustomColors(_colors);
              if (mounted) {
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 12,
        itemBuilder: (context, index) {
          final pieceId = index + 1;
          final pieceName = getPieceName(pieceId);
          final piece = pentominos.firstWhere((p) => p.id == pieceId);
          
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: PieceIcon(
                pieceId: pieceId,
                color: _colors[index],
              ),
              title: Text('Pièce $pieceName (#$pieceId)'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(getColorHex(_colors[index])),
                  const SizedBox(height: 4),
                  PiecePreview(
                    piece: piece,
                    color: _colors[index],
                  ),
                ],
              ),
              trailing: const Icon(Icons.edit),
              onTap: () => _showColorPicker(index, pieceName),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _resetToDefault,
        icon: const Icon(Icons.refresh),
        label: const Text('Réinitialiser'),
      ),
    );
  }


  void _showColorPicker(int index, String pieceName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Couleur de la pièce $pieceName'),
        content: SingleChildScrollView(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              // Couleurs prédéfinies
              ...getPredefinedColors().map((color) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _colors[index] = color;
                    });
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _colors[index] == color
                            ? Colors.black
                            : Colors.grey.shade400,
                        width: _colors[index] == color ? 3 : 2,
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
  }

  void _resetToDefault() {
    setState(() {
      _colors = List.from(defaultPieceColors);
    });
  }
}


