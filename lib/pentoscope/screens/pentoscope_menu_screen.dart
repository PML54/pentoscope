// lib/pentoscope/screens/pentoscope_menu_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pentapol/pentoscope/pentoscope_generator.dart';
import 'package:pentapol/pentoscope/pentoscope_provider.dart';
import 'package:pentapol/pentoscope/screens/pentoscope_game_screen.dart';
import 'package:pentapol/pentoscope_multiplayer/screens/pentoscope_mp_lobby_screen.dart';

class PentoscopeMenuScreen extends ConsumerStatefulWidget {
  const PentoscopeMenuScreen({super.key});

  @override
  ConsumerState<PentoscopeMenuScreen> createState() =>
      _PentoscopeMenuScreenState();
}

class _PentoscopeMenuScreenState extends ConsumerState<PentoscopeMenuScreen> {
  PentoscopeSize _selectedSize = PentoscopeSize.size3x5;
  PentoscopeDifficulty _selectedDifficulty = PentoscopeDifficulty.random;
  bool _showSolution = false; // ✅ NOUVEAU

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pentoscope'), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          // ← Rendre scrollable
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Choix plateau',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),
                _buildSizeSelector(),

                // ✅ NOUVEAU: Toggle "Afficher la solution"
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200, width: 1),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.lightbulb, color: Colors.blue.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Training',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _showSolution,
                        onChanged: (value) {
                          setState(() => _showSolution = value);
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Bouton Jouer Solo
                ElevatedButton(
                  onPressed: _startGame,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Solo',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Bouton Multiplayer
                OutlinedButton.icon(
                  onPressed: _startMultiplayer,
                  icon: const Icon(Icons.people),
                  label: const Text(
                    'Multiplayer (1-4)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: Theme.of(context).primaryColor, width: 2),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSizeSelector() {
    return Row(
      children: PentoscopeSize.values.map((size) {
        final isSelected = size == _selectedSize;

        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedSize = size),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.grey[300]!,
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    size.label,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _startGame() {
    ref
        .read(pentoscopeProvider.notifier)
        .startPuzzle(
          _selectedSize,
          difficulty: _selectedDifficulty,
          showSolution: _showSolution,
        );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PentoscopeGameScreen()),
    );
  }

  void _startMultiplayer() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PentoscopeMPLobbyScreen()),
    );
  }
}
