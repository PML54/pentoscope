// DEBUG WIDGET - VERSION SIMPLIFIÉE ET SANS ERREURS
// 251226
// Widget pour afficher/tester les données sauvegardées en DB

import 'package:flutter/material.dart';
import 'package:pentapol/database/settings_database.dart';

/// Widget debug simple pour vérifier les données sauvegardées
class DatabaseDebugScreen extends StatefulWidget {
  const DatabaseDebugScreen({Key? key}) : super(key: key);

  @override
  State<DatabaseDebugScreen> createState() => _DatabaseDebugScreenState();
}

class _DatabaseDebugScreenState extends State<DatabaseDebugScreen> {
  final database = SettingsDatabase();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🐛 Database Debug'),
        backgroundColor: Colors.red[700],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 20,
          children: [
            // ========== STATS GLOBALES ==========
            _buildSection(
              title: '📊 STATS GLOBALES',
              child: FutureBuilder(
                future: database.getGlobalStats(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  if (snapshot.hasError) {
                    return Text('Erreur: ${snapshot.error}');
                  }

                  final stats = snapshot.data ?? {};
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 8,
                    children: [
                      _statRow('Sessions totales:', '${stats['totalSessions'] ?? 0}'),
                      _statRow('Solutions différentes:', '${stats['uniqueSolutions'] ?? 0}'),
                      _statRow('Temps total:', '${stats['totalTime'] ?? 0}s'),
                      _statRow('Temps moyen:', '${stats['averageTime'] ?? 0}s'),
                      _statRow('Meilleur score:', '${stats['bestScore'] ?? 0}'),
                    ],
                  );
                },
              ),
            ),

            // ========== SESSIONS SAUVEGARDÉES ==========
            _buildSection(
              title: '💾 SESSIONS SAUVEGARDÉES',
              child: FutureBuilder(
                future: database.getGameHistory(limit: 50),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  if (snapshot.hasError) {
                    return Text('Erreur: ${snapshot.error}');
                  }

                  final sessions = snapshot.data ?? [];

                  if (sessions.isEmpty) {
                    return const Text(
                      '❌ Aucune session sauvegardée',
                      style: TextStyle(color: Colors.grey),
                    );
                  }

                  return Column(
                    spacing: 8,
                    children: [
                      Text('${sessions.length} session(s) trouvée(s)'),
                      ...sessions.map<Widget>((session) {
                        return Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.blue),
                            borderRadius: BorderRadius.circular(6),
                            color: Colors.blue[50],
                          ),
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 4,
                            children: [
                              Text(
                                '🎮 Session #${session.id}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              _sessionRow('Solution:', '#${session.solutionNumber}'),
                              _sessionRow('Temps:', '${session.elapsedSeconds}s'),
                              _sessionRow('Score:', '${session.score ?? 0}'),
                              _sessionRow('Pièces:', '${session.piecesPlaced ?? 12}'),
                              _sessionRow('Isométries:', '${session.isometriesCount ?? 0}'),
                              _sessionRow('Visu solutions:', '${session.solutionsViewCount ?? 0}'),
                              _sessionRow('Complété:', session.completedAt.toString().split('.')[0]),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  );
                },
              ),
            ),

            // ========== ACTIONS ==========
            _buildSection(
              title: '⚙️ ACTIONS',
              child: Column(
                spacing: 8,
                children: [

                  ElevatedButton.icon(
                    onPressed: () => setState(() {}),
                    icon: const Icon(Icons.refresh),
                    label: const Text('🔄 Rafraîchir'),
                  ),
                  ElevatedButton.icon(
                    onPressed: _clearAllData,
                    icon: const Icon(Icons.delete),
                    label: const Text('🗑️ Effacer tout'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blue),
            borderRadius: BorderRadius.circular(8),
            color: Colors.blue[50],
          ),
          padding: const EdgeInsets.all(12),
          child: child,
        ),
      ],
    );
  }

  Widget _statRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(
          value,
          style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _sessionRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12)),
        Text(
          value,
          style: const TextStyle(fontSize: 12, color: Colors.green),
        ),
      ],
    );
  }

  Future<void> _addTestSession() async {
    try {
      await database.saveGameSession(
        solutionNumber: 42,
        elapsedSeconds: 225,
        score: 0,
        piecesPlaced: 12,
        numUndos: 0,
        isometriesCount: 15,
        solutionsViewCount: 3,
      );


    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _clearAllData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Confirmer'),
        content: const Text('Effacer toutes les données sauvegardées?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Oui, effacer'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      // Effacer toutes les sessions
      await (database.delete(database.gameSessions)).go();
      // Effacer toutes les stats
      await (database.delete(database.solutionStats)).go();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Toutes les données supprimées!'),
            backgroundColor: Colors.orange,
          ),
        );
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}