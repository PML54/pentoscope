// Modified: 2025-11-30 - Ajout section Duel et version
// lib/screens/settings_screen.dart
// Écran de paramètres de l'application

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pentapol/models/app_settings.dart';
import 'package:pentapol/providers/settings_provider.dart';
import 'package:pentapol/screens/custom_colors_screen.dart';
import 'package:pentapol/config/build_info.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Réinitialiser',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Réinitialiser'),
                  content: const Text(
                    'Voulez-vous réinitialiser tous les paramètres par défaut ?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Annuler'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Réinitialiser'),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await notifier.resetToDefaults();
              }
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          // === SECTION UI ===
          _buildSectionHeader('Interface'),

          // Schéma de couleurs
          ListTile(
            leading: const Icon(Icons.palette),
            title: const Text('Couleurs des pièces'),
            subtitle: Text(_getColorSchemeName(settings.ui.colorScheme)),
            onTap: () => _showColorSchemeDialog(context, notifier, settings.ui.colorScheme),
          ),

          // Personnaliser les couleurs (visible si schéma custom)
          if (settings.ui.colorScheme == PieceColorScheme.custom)
            ListTile(
              leading: const Icon(Icons.color_lens),
              title: const Text('Personnaliser les couleurs'),
              subtitle: const Text('Définir les 12 couleurs des pièces'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CustomColorsScreen()),
                );
              },
            ),

          // Afficher numéros
          SwitchListTile(
            secondary: const Icon(Icons.numbers),
            title: const Text('Numéros sur les pièces'),
            subtitle: const Text('Afficher les numéros des pièces'),
            value: settings.ui.showPieceNumbers,
            onChanged: (value) => notifier.setShowPieceNumbers(value),
          ),

          // Lignes de grille
          SwitchListTile(
            secondary: const Icon(Icons.grid_on),
            title: const Text('Lignes de grille'),
            subtitle: const Text('Afficher les lignes du plateau'),
            value: settings.ui.showGridLines,
            onChanged: (value) => notifier.setShowGridLines(value),
          ),

          // Animations
          SwitchListTile(
            secondary: const Icon(Icons.animation),
            title: const Text('Animations'),
            subtitle: const Text('Activer les animations'),
            value: settings.ui.enableAnimations,
            onChanged: (value) => notifier.setEnableAnimations(value),
          ),

          // Opacité des pièces
          ListTile(
            leading: const Icon(Icons.opacity),
            title: const Text('Opacité des pièces'),
            subtitle: Slider(
              value: settings.ui.pieceOpacity,
              min: 0.3,
              max: 1.0,
              divisions: 7,
              label: '${(settings.ui.pieceOpacity * 100).round()}%',
              onChanged: (value) => notifier.setPieceOpacity(value),
            ),
          ),

          // Taille des icônes
          ListTile(
            leading: const Icon(Icons.format_size),
            title: const Text('Taille des icônes'),
            subtitle: Slider(
              value: settings.ui.iconSize,
              min: 16.0,
              max: 48.0,
              divisions: 16,
              label: '${settings.ui.iconSize.round()}px',
              onChanged: (value) => notifier.setIconSize(value),
            ),
          ),

          // Couleur AppBar mode isométries
          ListTile(
            leading: const Icon(Icons.format_paint),
            title: const Text('Couleur mode isométries'),
            subtitle: const Text('Couleur de fond de l\'AppBar en mode apprentissage'),
            trailing: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: settings.ui.isometriesAppBarColor,
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onTap: () => _showIsometriesColorPicker(context, notifier, settings.ui.isometriesAppBarColor),
          ),

          const Divider(),

          // === SECTION JEU ===
          _buildSectionHeader('Jeu'),

          // Niveau de difficulté
          ListTile(
            leading: const Icon(Icons.speed),
            title: const Text('Niveau de difficulté'),
            subtitle: Text(_getDifficultyName(settings.game.difficulty)),
            onTap: () => _showDifficultyDialog(context, notifier, settings.game.difficulty),
          ),

          // Compteur de solutions
          SwitchListTile(
            secondary: const Icon(Icons.emoji_events),
            title: const Text('Compteur de solutions'),
            subtitle: const Text('Afficher le nombre de solutions possibles'),
            value: settings.game.showSolutionCounter,
            onChanged: (value) => notifier.setShowSolutionCounter(value),
          ),

          // Indices
          SwitchListTile(
            secondary: const Icon(Icons.lightbulb_outline),
            title: const Text('Indices'),
            subtitle: const Text('Activer les indices visuels'),
            value: settings.game.enableHints,
            onChanged: (value) => notifier.setEnableHints(value),
          ),

          // Chronomètre
          SwitchListTile(
            secondary: const Icon(Icons.timer),
            title: const Text('Chronomètre'),
            subtitle: const Text('Afficher le temps de résolution'),
            value: settings.game.enableTimer,
            onChanged: (value) => notifier.setEnableTimer(value),
          ),

          // Retour haptique
          SwitchListTile(
            secondary: const Icon(Icons.vibration),
            title: const Text('Retour haptique'),
            subtitle: const Text('Vibrations lors des actions'),
            value: settings.game.enableHaptics,
            onChanged: (value) => notifier.setEnableHaptics(value),
          ),

          // Durée du long press
          ListTile(
            leading: const Icon(Icons.touch_app),
            title: const Text('Sensibilité du drag'),
            subtitle: Text('${settings.game.longPressDuration}ms'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: settings.game.longPressDuration > 100
                      ? () => notifier.setLongPressDuration(settings.game.longPressDuration - 50)
                      : null,
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: settings.game.longPressDuration < 500
                      ? () => notifier.setLongPressDuration(settings.game.longPressDuration + 50)
                      : null,
                ),
              ],
            ),
          ),

          const Divider(),

          // === SECTION DUEL ===
          _buildSectionHeader('Mode Duel'),

          // Tile pour accéder aux paramètres Duel
          _buildDuelSettingsTile(context, ref, settings),

          const Divider(),

          // === SECTION À PROPOS ===
          _buildSectionHeader('À propos'),

          // Version de l'app
          _buildVersionTile(context),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // === WIDGETS DUEL ===

  Widget _buildDuelSettingsTile(BuildContext context, WidgetRef ref, AppSettings settings) {
    final playerName = settings.duel.playerName ?? 'Non défini';
    final duration = settings.duel.durationFormatted;
    final stats = '${settings.duel.totalWins}V / ${settings.duel.totalLosses}D / ${settings.duel.totalDraws}N';

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.deepPurple.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.sports_esports, color: Colors.deepPurple),
      ),
      title: const Text('Paramètres Duel'),
      subtitle: Text('$playerName • $duration • $stats'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showDuelSettingsDialog(context, ref),
    );
  }

  void _showDuelSettingsDialog(BuildContext context, WidgetRef ref) {
    final settings = ref.read(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    // Controllers
    final nameController = TextEditingController(text: settings.duel.playerName ?? '');
    DuelDuration selectedDuration = settings.duel.duration;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    const Icon(Icons.sports_esports, color: Colors.deepPurple, size: 28),
                    const SizedBox(width: 12),
                    const Text(
                      'Paramètres Duel',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Nom du joueur
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Nom du joueur',
                    hintText: 'Entrez votre pseudo',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  maxLength: 20,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),

                // Durée de partie
                const Text(
                  'Durée de partie',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: DuelDuration.values.where((d) => d != DuelDuration.custom).map((duration) {
                    final isSelected = selectedDuration == duration;
                    return ChoiceChip(
                      label: Text('${duration.icon} ${duration.label}'),
                      selected: isSelected,
                      selectedColor: Colors.deepPurple.shade100,
                      onSelected: (selected) {
                        if (selected) {
                          setModalState(() => selectedDuration = duration);
                        }
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // Statistiques
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '📊 Statistiques',
                        style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatColumn('Parties', '${settings.duel.totalGamesPlayed}', Icons.sports_esports),
                          _buildStatColumn('Victoires', '${settings.duel.totalWins}', Icons.emoji_events, Colors.green),
                          _buildStatColumn('Défaites', '${settings.duel.totalLosses}', Icons.close, Colors.red),
                          _buildStatColumn('Égalités', '${settings.duel.totalDraws}', Icons.handshake, Colors.orange),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          'Taux de victoire : ${settings.duel.winRate.toStringAsFixed(1)}%',
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Boutons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          _confirmResetDuelStats(ctx, notifier);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Réinit. stats'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () async {
                          final name = nameController.text.trim();
                          if (name.isNotEmpty) {
                            await notifier.setDuelPlayerName(name);
                          }
                          await notifier.setDuelDuration(selectedDuration);
                          if (ctx.mounted) Navigator.pop(ctx);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Sauvegarder'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, IconData icon, [Color? color]) {
    return Column(
      children: [
        Icon(icon, color: color ?? Colors.deepPurple, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color ?? Colors.black87,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  void _confirmResetDuelStats(BuildContext context, SettingsNotifier notifier) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Effacer les statistiques ?'),
        content: const Text('Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              await notifier.resetDuelStats();
              if (ctx.mounted) Navigator.pop(ctx);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Effacer'),
          ),
        ],
      ),
    );
  }

  // === WIDGET VERSION ===

  Widget _buildVersionTile(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.info_outline, color: Colors.blue),
      ),
      title: const Text('Version'),
      subtitle: Text(
        BuildInfo.versionWithDate,
        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
      ),
      onTap: () => _showAboutDialog(context),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.extension, color: Colors.deepPurple.shade400),
            const SizedBox(width: 12),
            const Text(BuildInfo.appName),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAboutRow('Version', BuildInfo.fullVersion),
            _buildAboutRow('Build', BuildInfo.buildDateFormatted),
            _buildAboutRow('Auteur', BuildInfo.author),
            const Divider(height: 24),
            Text(
              BuildInfo.description,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '© ${BuildInfo.copyrightYear} ${BuildInfo.author}',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: TextStyle(color: Colors.grey.shade700)),
        ],
      ),
    );
  }

  // === HELPERS EXISTANTS ===

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  String _getColorSchemeName(PieceColorScheme scheme) {
    switch (scheme) {
      case PieceColorScheme.classic:
        return 'Classique';
      case PieceColorScheme.pastel:
        return 'Pastel';
      case PieceColorScheme.neon:
        return 'Néon';
      case PieceColorScheme.monochrome:
        return 'Monochrome';
      case PieceColorScheme.rainbow:
        return 'Arc-en-ciel';
      case PieceColorScheme.custom:
        return 'Personnalisé';
    }
  }

  String _getDifficultyName(GameDifficulty difficulty) {
    switch (difficulty) {
      case GameDifficulty.easy:
        return 'Facile';
      case GameDifficulty.normal:
        return 'Normal';
      case GameDifficulty.hard:
        return 'Difficile';
      case GameDifficulty.expert:
        return 'Expert';
    }
  }

  void _showColorSchemeDialog(
      BuildContext context,
      SettingsNotifier notifier,
      PieceColorScheme current,
      ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Couleurs des pièces'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: PieceColorScheme.values.map((scheme) {
            return RadioListTile<PieceColorScheme>(
              title: Text(_getColorSchemeName(scheme)),
              value: scheme,
              groupValue: current,
              onChanged: (value) {
                if (value != null) {
                  notifier.setColorScheme(value);
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showDifficultyDialog(
      BuildContext context,
      SettingsNotifier notifier,
      GameDifficulty current,
      ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Niveau de difficulté'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: GameDifficulty.values.map((difficulty) {
            return RadioListTile<GameDifficulty>(
              title: Text(_getDifficultyName(difficulty)),
              value: difficulty,
              groupValue: current,
              onChanged: (value) {
                if (value != null) {
                  notifier.setDifficulty(value);
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showIsometriesColorPicker(
      BuildContext context,
      SettingsNotifier notifier,
      Color current,
      ) {
    // Couleurs prédéfinies pour le mode isométries (claires pour bien voir les icônes)
    final predefinedColors = [
      const Color(0xFF9575CD), // Violet clair (défaut)
      const Color(0xFF7986CB), // Indigo clair
      const Color(0xFF64B5F6), // Bleu clair
      const Color(0xFF4DD0E1), // Cyan clair
      const Color(0xFF4DB6AC), // Teal clair
      const Color(0xFF81C784), // Vert clair
      const Color(0xFFAED581), // Vert lime clair
      const Color(0xFFFFD54F), // Ambre clair
      const Color(0xFFFFB74D), // Orange clair
      const Color(0xFFFF8A65), // Orange profond clair
      const Color(0xFFA1887F), // Marron clair
      const Color(0xFF90A4AE), // Gris bleu clair
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Couleur mode isométries'),
        content: SizedBox(
          width: 300,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: predefinedColors.length,
            itemBuilder: (context, index) {
              final color = predefinedColors[index];
              final isSelected = color == current;

              return GestureDetector(
                onTap: () {
                  notifier.setIsometriesAppBarColor(color);
                  Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    border: Border.all(
                      color: isSelected ? Colors.black : Colors.grey,
                      width: isSelected ? 3 : 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 32)
                      : null,
                ),
              );
            },
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
}