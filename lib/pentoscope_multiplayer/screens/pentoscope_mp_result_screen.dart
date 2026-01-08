// lib/pentoscope_multiplayer/screens/pentoscope_mp_result_screen.dart
// Écran de résultats Pentoscope Multiplayer

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pentapol/pentoscope_multiplayer/models/pentoscope_mp_state.dart';
import 'package:pentapol/pentoscope_multiplayer/providers/pentoscope_mp_provider.dart';
import 'package:pentapol/pentoscope_multiplayer/screens/pentoscope_mp_lobby_screen.dart';

class PentoscopeMPResultScreen extends ConsumerWidget {
  const PentoscopeMPResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pentoscopeMPProvider);
    final rankings = state.rankings;
    final me = state.me;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            
            // Titre
            const Text(
              '🏆 Résultats',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Mon rang
            if (me != null)
              _buildMyRankCard(me, rankings.length),
            
            const SizedBox(height: 24),
            
            // Podium (top 3)
            if (rankings.length >= 1)
              _buildPodium(rankings.take(3).toList()),
            
            const SizedBox(height: 24),
            
            // Liste complète
            Expanded(
              child: _buildRankingsList(rankings, me?.id),
            ),
            
            // Boutons
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await ref.read(pentoscopeMPProvider.notifier).leaveRoom();
                        if (context.mounted) {
                          Navigator.popUntil(context, (route) => route.isFirst);
                        }
                      },
                      icon: const Icon(Icons.home),
                      label: const Text('Accueil'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await ref.read(pentoscopeMPProvider.notifier).leaveRoom();
                        if (context.mounted) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const PentoscopeMPLobbyScreen()),
                          );
                        }
                      },
                      icon: const Icon(Icons.replay),
                      label: const Text('Rejouer'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.green,
                      ),
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

  Widget _buildMyRankCard(MPPlayer me, int totalPlayers) {
    final isWinner = me.rank == 1;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isWinner 
              ? [Colors.amber.shade400, Colors.orange.shade400]
              : [Colors.blue.shade400, Colors.indigo.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (isWinner ? Colors.amber : Colors.blue).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Rang
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                isWinner ? '🥇' : '#${me.rank ?? "?"}',
                style: TextStyle(
                  fontSize: isWinner ? 32 : 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          // Infos
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isWinner ? 'Victoire ! 🎉' : 'Bien joué !',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  me.isCompleted 
                      ? 'Terminé en ${_formatTime(me.completionTime ?? 0)}'
                      : '${me.placedCount} pièces placées',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          
          // Position
          Text(
            '${me.rank ?? "?"}/$totalPlayers',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPodium(List<MPPlayer> topPlayers) {
    // Réorganiser pour l'affichage podium: 2ème, 1er, 3ème
    final orderedPlayers = <MPPlayer?>[];
    if (topPlayers.length >= 2) orderedPlayers.add(topPlayers[1]); else orderedPlayers.add(null);
    if (topPlayers.isNotEmpty) orderedPlayers.add(topPlayers[0]); else orderedPlayers.add(null);
    if (topPlayers.length >= 3) orderedPlayers.add(topPlayers[2]); else orderedPlayers.add(null);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 2ème place
          if (orderedPlayers[0] != null)
            _buildPodiumPlace(orderedPlayers[0]!, 2, 80)
          else
            const SizedBox(width: 80),
          
          const SizedBox(width: 8),
          
          // 1ère place
          if (orderedPlayers[1] != null)
            _buildPodiumPlace(orderedPlayers[1]!, 1, 100)
          else
            const SizedBox(width: 100),
          
          const SizedBox(width: 8),
          
          // 3ème place
          if (orderedPlayers[2] != null)
            _buildPodiumPlace(orderedPlayers[2]!, 3, 60)
          else
            const SizedBox(width: 80),
        ],
      ),
    );
  }

  Widget _buildPodiumPlace(MPPlayer player, int rank, double height) {
    final colors = {
      1: Colors.amber,
      2: Colors.grey.shade400,
      3: Colors.brown.shade300,
    };
    final emojis = {1: '🥇', 2: '🥈', 3: '🥉'};
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Avatar
        CircleAvatar(
          radius: rank == 1 ? 30 : 24,
          backgroundColor: colors[rank],
          child: Text(
            player.name.isNotEmpty ? player.name[0].toUpperCase() : '?',
            style: TextStyle(
              fontSize: rank == 1 ? 24 : 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 4),
        
        // Nom
        Text(
          player.name.length > 8 ? '${player.name.substring(0, 8)}...' : player.name,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        
        // Temps
        if (player.completionTime != null)
          Text(
            _formatTime(player.completionTime!),
            style: TextStyle(fontSize: 10, color: Colors.grey[600]),
          ),
        
        const SizedBox(height: 4),
        
        // Socle
        Container(
          width: rank == 1 ? 80 : 70,
          height: height,
          decoration: BoxDecoration(
            color: colors[rank],
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          child: Center(
            child: Text(
              emojis[rank] ?? '$rank',
              style: const TextStyle(fontSize: 28),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRankingsList(List<MPPlayer> rankings, String? myId) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: rankings.length,
      itemBuilder: (context, index) {
        final player = rankings[index];
        final isMe = player.id == myId;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isMe ? Colors.blue.shade50 : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isMe ? Colors.blue.shade200 : Colors.grey.shade200,
            ),
          ),
          child: Row(
            children: [
              // Rang
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _getRankColor(player.rank ?? index + 1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${player.rank ?? index + 1}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // Nom
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          player.name,
                          style: TextStyle(
                            fontWeight: isMe ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        if (isMe)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Moi',
                              style: TextStyle(color: Colors.white, fontSize: 10),
                            ),
                          ),
                      ],
                    ),
                    Text(
                      player.isCompleted 
                          ? 'Terminé' 
                          : '${player.placedCount} pièces',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Temps
              if (player.completionTime != null)
                Text(
                  _formatTime(player.completionTime!),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                )
              else
                const Text(
                  'DNF',
                  style: TextStyle(color: Colors.grey),
                ),
            ],
          ),
        );
      },
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1: return Colors.amber;
      case 2: return Colors.grey;
      case 3: return Colors.brown;
      default: return Colors.blueGrey;
    }
  }

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    if (mins > 0) {
      return '${mins}m ${secs}s';
    }
    return '${secs}s';
  }
}

