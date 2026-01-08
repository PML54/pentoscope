// lib/pentoscope_multiplayer/screens/pentoscope_mp_lobby_screen.dart
// Écran de lobby pour Pentoscope Multiplayer (1-4 joueurs)

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pentapol/pentoscope/pentoscope_generator.dart';
import 'package:pentapol/pentoscope_multiplayer/models/pentoscope_mp_state.dart';
import 'package:pentapol/pentoscope_multiplayer/providers/pentoscope_mp_provider.dart';
import 'package:pentapol/pentoscope_multiplayer/screens/pentoscope_mp_game_screen.dart';
import 'package:pentapol/database/settings_database.dart';

// Clé pour stocker le nom du joueur
const String _playerNameKey = 'multiplayer_player_name';

class PentoscopeMPLobbyScreen extends ConsumerStatefulWidget {
  const PentoscopeMPLobbyScreen({super.key});

  @override
  ConsumerState<PentoscopeMPLobbyScreen> createState() => _PentoscopeMPLobbyScreenState();
}

class _PentoscopeMPLobbyScreenState extends ConsumerState<PentoscopeMPLobbyScreen> {
  final _playerNameController = TextEditingController();
  final _roomCodeController = TextEditingController();
  final _db = SettingsDatabase();
  
  PentoscopeSize _selectedSize = PentoscopeSize.size5x5;
  bool _isCreating = true; // true = créer, false = rejoindre

  @override
  void initState() {
    super.initState();
    _loadSavedPlayerName();
  }

  Future<void> _loadSavedPlayerName() async {
    final savedName = await _db.getSetting(_playerNameKey);
    if (savedName != null && savedName.isNotEmpty) {
      _playerNameController.text = savedName;
    } else {
      _playerNameController.text = 'Joueur';
    }
    if (mounted) setState(() {});
  }

  Future<void> _savePlayerName(String name) async {
    if (name.isNotEmpty) {
      await _db.setSetting(_playerNameKey, name);
    }
  }

  @override
  void dispose() {
    _playerNameController.dispose();
    _roomCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pentoscopeMPProvider);
    
    // Navigation automatique vers le jeu quand le countdown commence
    ref.listen<PentoscopeMPState>(pentoscopeMPProvider, (prev, next) {
      if (next.gameState == PentoscopeMPGameState.countdown ||
          next.gameState == PentoscopeMPGameState.playing) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const PentoscopeMPGameScreen()),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pentoscope Multiplayer'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () async {
            if (state.gameState != PentoscopeMPGameState.disconnected) {
              await ref.read(pentoscopeMPProvider.notifier).leaveRoom();
            }
            if (context.mounted) Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: _buildBody(state),
      ),
    );
  }

  Widget _buildBody(PentoscopeMPState state) {
    switch (state.gameState) {
      case PentoscopeMPGameState.disconnected:
        return _buildDisconnectedView();
      case PentoscopeMPGameState.connecting:
        return _buildConnectingView();
      case PentoscopeMPGameState.waiting:
        return _buildWaitingView(state);
      case PentoscopeMPGameState.error:
        return _buildErrorView(state);
      default:
        return const Center(child: CircularProgressIndicator());
    }
  }

  // ==========================================================================
  // VUE: Déconnecté - Choix créer/rejoindre
  // ==========================================================================

  Widget _buildDisconnectedView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Nom du joueur
          TextField(
            controller: _playerNameController,
            decoration: InputDecoration(
              labelText: 'Ton pseudo',
              prefixIcon: const Icon(Icons.person),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            textCapitalization: TextCapitalization.words,
          ),
          
          const SizedBox(height: 32),
          
          // Tabs Créer / Rejoindre
          Row(
            children: [
              Expanded(
                child: _buildTabButton(
                  'Créer',
                  Icons.add_circle_outline,
                  _isCreating,
                  () => setState(() => _isCreating = true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTabButton(
                  'Rejoindre',
                  Icons.login,
                  !_isCreating,
                  () => setState(() => _isCreating = false),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Contenu selon le mode
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _isCreating ? _buildCreateSection() : _buildJoinSection(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, IconData icon, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Theme.of(context).primaryColor : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? Colors.white : Colors.grey[600], size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateSection() {
    return Column(
      key: const ValueKey('create'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Sélecteur de taille
        const Text(
          'Format du plateau',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        _buildSizeSelector(),
        
        const SizedBox(height: 24),
        
        // Bouton Créer
        ElevatedButton.icon(
          onPressed: _createRoom,
          icon: const Icon(Icons.play_arrow),
          label: const Text('Créer la partie'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Widget _buildJoinSection() {
    return Column(
      key: const ValueKey('join'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Code de la room
        TextField(
          controller: _roomCodeController,
          decoration: InputDecoration(
            labelText: 'Code de la room',
            hintText: 'Ex: ABCD',
            prefixIcon: const Icon(Icons.tag),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          textCapitalization: TextCapitalization.characters,
          maxLength: 4,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
            UpperCaseTextFormatter(),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Bouton Rejoindre
        ElevatedButton.icon(
          onPressed: _joinRoom,
          icon: const Icon(Icons.login),
          label: const Text('Rejoindre'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
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
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? Theme.of(context).primaryColor : Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                size.label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ==========================================================================
  // VUE: Connexion en cours
  // ==========================================================================

  Widget _buildConnectingView() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 24),
          Text('Connexion...', style: TextStyle(fontSize: 18)),
        ],
      ),
    );
  }

  // ==========================================================================
  // VUE: Attente de joueurs
  // ==========================================================================

  Widget _buildWaitingView(PentoscopeMPState state) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Code de la room
          _buildRoomCodeCard(state.roomCode ?? '????'),
          
          const SizedBox(height: 24),
          
          // Config
          if (state.config != null)
            _buildConfigCard(state.config!),
          
          const SizedBox(height: 24),
          
          // Liste des joueurs
          const Text(
            'Joueurs',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          
          Expanded(
            child: ListView.builder(
              itemCount: state.players.length,
              itemBuilder: (context, index) {
                final player = state.players[index];
                return _buildPlayerTile(player);
              },
            ),
          ),
          
          // Bouton Démarrer (host only)
          if (state.isHost) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: state.canStart ? _startGame : null,
              icon: const Icon(Icons.play_arrow),
              label: Text(state.playerCount < 2 
                  ? 'En attente de joueurs (${state.playerCount}/4)'
                  : 'Démarrer (${state.playerCount} joueurs)'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: state.canStart ? Colors.green : Colors.grey,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ] else ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 12),
                  Text('En attente du lancement...'),
                ],
              ),
            ),
          ],
          
          // Bouton Quitter
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () async {
              await ref.read(pentoscopeMPProvider.notifier).leaveRoom();
            },
            icon: const Icon(Icons.exit_to_app, color: Colors.red),
            label: const Text('Quitter', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomCodeCard(String code) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade400, Colors.purple.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Code de la room',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                code,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 8,
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(Icons.copy, color: Colors.white70),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: code));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Code copié !'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Partage ce code avec tes amis',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigCard(MPGameConfig config) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildConfigItem(Icons.grid_4x4, 'Format', config.format),
          _buildConfigItem(Icons.extension, 'Pièces', '${config.pieceCount}'),
          if (config.timeLimit > 0)
            _buildConfigItem(Icons.timer, 'Limite', '${config.timeLimit}s'),
        ],
      ),
    );
  }

  Widget _buildConfigItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey[600], size: 20),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildPlayerTile(MPPlayer player) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: player.isMe ? Colors.blue.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: player.isMe ? Colors.blue.shade200 : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            backgroundColor: player.isHost ? Colors.amber : Colors.grey[300],
            child: Icon(
              player.isHost ? Icons.star : Icons.person,
              color: player.isHost ? Colors.white : Colors.grey[600],
            ),
          ),
          const SizedBox(width: 12),
          
          // Nom
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (player.isHost)
                  Text(
                    'Hôte',
                    style: TextStyle(color: Colors.amber.shade700, fontSize: 12),
                  ),
              ],
            ),
          ),
          
          // Badge "Moi"
          if (player.isMe)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Moi',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  // ==========================================================================
  // VUE: Erreur
  // ==========================================================================

  Widget _buildErrorView(PentoscopeMPState state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              state.errorMessage ?? 'Une erreur est survenue',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                await ref.read(pentoscopeMPProvider.notifier).leaveRoom();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // ACTIONS
  // ==========================================================================

  Future<void> _createRoom() async {
    final name = _playerNameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entre ton pseudo')),
      );
      return;
    }

    // Sauvegarder le nom pour la prochaine fois
    await _savePlayerName(name);

    await ref.read(pentoscopeMPProvider.notifier).createRoom(
      playerName: name,
      size: _selectedSize,
    );
  }

  Future<void> _joinRoom() async {
    final name = _playerNameController.text.trim();
    final code = _roomCodeController.text.trim().toUpperCase();
    
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entre ton pseudo')),
      );
      return;
    }
    
    if (code.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Le code doit faire 4 caractères')),
      );
      return;
    }

    // Sauvegarder le nom pour la prochaine fois
    await _savePlayerName(name);

    await ref.read(pentoscopeMPProvider.notifier).joinRoom(
      roomCode: code,
      playerName: name,
    );
  }

  void _startGame() {
    ref.read(pentoscopeMPProvider.notifier).startGame();
  }
}

// ==========================================================================
// UTILS
// ==========================================================================

/// Formatter pour convertir en majuscules
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

