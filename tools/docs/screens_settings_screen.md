# screens/settings_screen.dart

**Module:** screens

## Fonctions

### SettingsScreen

```dart
const SettingsScreen({super.key});
```

### build

```dart
Widget build(BuildContext context, WidgetRef ref) {
```

### Scaffold

```dart
return Scaffold( appBar: AppBar( title: const Text('Paramètres'), actions: [ IconButton( icon: const Icon(Icons.refresh), tooltip: 'Réinitialiser', onPressed: () async {
```

### Divider

```dart
const Divider(),  // === SECTION JEU === _buildSectionHeader('Jeu'),  // Niveau de difficulté ListTile( leading: const Icon(Icons.speed), title: const Text('Niveau de difficulté'), subtitle: Text(_getDifficultyName(settings.game.difficulty)), onTap: () => _showDifficultyDialog(context, notifier, settings.game.difficulty), ),  // Compteur de solutions SwitchListTile( secondary: const Icon(Icons.emoji_events), title: const Text('Compteur de solutions'), subtitle: const Text('Afficher le nombre de solutions possibles'), value: settings.game.showSolutionCounter, onChanged: (value) => notifier.setShowSolutionCounter(value), ),  // Indices SwitchListTile( secondary: const Icon(Icons.lightbulb_outline), title: const Text('Indices'), subtitle: const Text('Activer les indices visuels'), value: settings.game.enableHints, onChanged: (value) => notifier.setEnableHints(value), ),  // Chronomètre SwitchListTile( secondary: const Icon(Icons.timer), title: const Text('Chronomètre'), subtitle: const Text('Afficher le temps de résolution'), value: settings.game.enableTimer, onChanged: (value) => notifier.setEnableTimer(value), ),  // Retour haptique SwitchListTile( secondary: const Icon(Icons.vibration), title: const Text('Retour haptique'), subtitle: const Text('Vibrations lors des actions'), value: settings.game.enableHaptics, onChanged: (value) => notifier.setEnableHaptics(value), ),  // Durée du long press ListTile( leading: const Icon(Icons.touch_app), title: const Text('Sensibilité du drag'), subtitle: Text('${settings.game.longPressDuration}ms'),
```

### Divider

```dart
const Divider(),  // === SECTION DUEL === _buildSectionHeader('Mode Duel'),  // Tile pour accéder aux paramètres Duel _buildDuelSettingsTile(context, ref, settings),  const Divider(),  // === SECTION À PROPOS === _buildSectionHeader('À propos'),  // Version de l'app _buildVersionTile(context),  const SizedBox(height: 32), ], ), );
```

### Divider

```dart
const Divider(),  // === SECTION À PROPOS === _buildSectionHeader('À propos'),  // Version de l'app _buildVersionTile(context),  const SizedBox(height: 32), ], ), );
```

### SizedBox

```dart
const SizedBox(height: 32), ], ), );
```

### ListTile

```dart
return ListTile( leading: Container( padding: const EdgeInsets.all(8), decoration: BoxDecoration( color: Colors.deepPurple.shade50, borderRadius: BorderRadius.circular(8), ), child: const Icon(Icons.sports_esports, color: Colors.deepPurple), ), title: const Text('Paramètres Duel'), subtitle: Text('$playerName • $duration • $stats'), trailing: const Icon(Icons.chevron_right), onTap: () => _showDuelSettingsDialog(context, ref), );
```

### Icon

```dart
const Icon(Icons.sports_esports, color: Colors.deepPurple, size: 28), const SizedBox(width: 12), const Text( 'Paramètres Duel', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), ), const Spacer(), IconButton( icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx), ), ], ), const SizedBox(height: 20),  // Nom du joueur TextField( controller: nameController, decoration: InputDecoration( labelText: 'Nom du joueur', hintText: 'Entrez votre pseudo', prefixIcon: const Icon(Icons.person_outline), border: OutlineInputBorder( borderRadius: BorderRadius.circular(12), ), ), maxLength: 20, textCapitalization: TextCapitalization.words, ), const SizedBox(height: 16),  // Durée de partie const Text( 'Durée de partie', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16), ), const SizedBox(height: 8), Wrap( spacing: 8, runSpacing: 8, children: DuelDuration.values.where((d) => d != DuelDuration.custom).map((duration) {
```

### SizedBox

```dart
const SizedBox(width: 12), const Text( 'Paramètres Duel', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), ), const Spacer(), IconButton( icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx), ), ], ), const SizedBox(height: 20),  // Nom du joueur TextField( controller: nameController, decoration: InputDecoration( labelText: 'Nom du joueur', hintText: 'Entrez votre pseudo', prefixIcon: const Icon(Icons.person_outline), border: OutlineInputBorder( borderRadius: BorderRadius.circular(12), ), ), maxLength: 20, textCapitalization: TextCapitalization.words, ), const SizedBox(height: 16),  // Durée de partie const Text( 'Durée de partie', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16), ), const SizedBox(height: 8), Wrap( spacing: 8, runSpacing: 8, children: DuelDuration.values.where((d) => d != DuelDuration.custom).map((duration) {
```

### Text

```dart
const Text( 'Paramètres Duel', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), ), const Spacer(), IconButton( icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx), ), ], ), const SizedBox(height: 20),  // Nom du joueur TextField( controller: nameController, decoration: InputDecoration( labelText: 'Nom du joueur', hintText: 'Entrez votre pseudo', prefixIcon: const Icon(Icons.person_outline), border: OutlineInputBorder( borderRadius: BorderRadius.circular(12), ), ), maxLength: 20, textCapitalization: TextCapitalization.words, ), const SizedBox(height: 16),  // Durée de partie const Text( 'Durée de partie', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16), ), const SizedBox(height: 8), Wrap( spacing: 8, runSpacing: 8, children: DuelDuration.values.where((d) => d != DuelDuration.custom).map((duration) {
```

### Spacer

```dart
const Spacer(), IconButton( icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx), ), ], ), const SizedBox(height: 20),  // Nom du joueur TextField( controller: nameController, decoration: InputDecoration( labelText: 'Nom du joueur', hintText: 'Entrez votre pseudo', prefixIcon: const Icon(Icons.person_outline), border: OutlineInputBorder( borderRadius: BorderRadius.circular(12), ), ), maxLength: 20, textCapitalization: TextCapitalization.words, ), const SizedBox(height: 16),  // Durée de partie const Text( 'Durée de partie', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16), ), const SizedBox(height: 8), Wrap( spacing: 8, runSpacing: 8, children: DuelDuration.values.where((d) => d != DuelDuration.custom).map((duration) {
```

### SizedBox

```dart
const SizedBox(height: 20),  // Nom du joueur TextField( controller: nameController, decoration: InputDecoration( labelText: 'Nom du joueur', hintText: 'Entrez votre pseudo', prefixIcon: const Icon(Icons.person_outline), border: OutlineInputBorder( borderRadius: BorderRadius.circular(12), ), ), maxLength: 20, textCapitalization: TextCapitalization.words, ), const SizedBox(height: 16),  // Durée de partie const Text( 'Durée de partie', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16), ), const SizedBox(height: 8), Wrap( spacing: 8, runSpacing: 8, children: DuelDuration.values.where((d) => d != DuelDuration.custom).map((duration) {
```

### SizedBox

```dart
const SizedBox(height: 16),  // Durée de partie const Text( 'Durée de partie', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16), ), const SizedBox(height: 8), Wrap( spacing: 8, runSpacing: 8, children: DuelDuration.values.where((d) => d != DuelDuration.custom).map((duration) {
```

### Text

```dart
const Text( 'Durée de partie', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16), ), const SizedBox(height: 8), Wrap( spacing: 8, runSpacing: 8, children: DuelDuration.values.where((d) => d != DuelDuration.custom).map((duration) {
```

### SizedBox

```dart
const SizedBox(height: 8), Wrap( spacing: 8, runSpacing: 8, children: DuelDuration.values.where((d) => d != DuelDuration.custom).map((duration) {
```

### ChoiceChip

```dart
return ChoiceChip( label: Text('${duration.icon} ${duration.label}'),
```

### SizedBox

```dart
const SizedBox(height: 20),  // Statistiques Container( padding: const EdgeInsets.all(16), decoration: BoxDecoration( color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12), ), child: Column( crossAxisAlignment: CrossAxisAlignment.start, children: [ const Text( '📊 Statistiques', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16), ), const SizedBox(height: 12), Row( mainAxisAlignment: MainAxisAlignment.spaceAround, children: [ _buildStatColumn('Parties', '${settings.duel.totalGamesPlayed}', Icons.sports_esports),
```

### Text

```dart
const Text( '📊 Statistiques', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16), ), const SizedBox(height: 12), Row( mainAxisAlignment: MainAxisAlignment.spaceAround, children: [ _buildStatColumn('Parties', '${settings.duel.totalGamesPlayed}', Icons.sports_esports),
```

### SizedBox

```dart
const SizedBox(height: 12), Row( mainAxisAlignment: MainAxisAlignment.spaceAround, children: [ _buildStatColumn('Parties', '${settings.duel.totalGamesPlayed}', Icons.sports_esports),
```

### SizedBox

```dart
const SizedBox(height: 8), Center( child: Text( 'Taux de victoire : ${settings.duel.winRate.toStringAsFixed(1)}%',
```

### SizedBox

```dart
const SizedBox(height: 20),  // Boutons Row( children: [ Expanded( child: OutlinedButton( onPressed: () {
```

### SizedBox

```dart
const SizedBox(width: 12), Expanded( flex: 2, child: ElevatedButton( onPressed: () async {
```

### Column

```dart
return Column( children: [ Icon(icon, color: color ?? Colors.deepPurple, size: 24), const SizedBox(height: 4), Text( value, style: TextStyle( fontSize: 18, fontWeight: FontWeight.bold, color: color ?? Colors.black87, ), ), Text( label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600), ), ], );
```

### SizedBox

```dart
const SizedBox(height: 4), Text( value, style: TextStyle( fontSize: 18, fontWeight: FontWeight.bold, color: color ?? Colors.black87, ), ), Text( label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600), ), ], );
```

### ListTile

```dart
return ListTile( leading: Container( padding: const EdgeInsets.all(8), decoration: BoxDecoration( color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8), ), child: const Icon(Icons.info_outline, color: Colors.blue), ), title: const Text('Version'), subtitle: Text( BuildInfo.versionWithDate, style: TextStyle(color: Colors.grey.shade600, fontSize: 12), ), onTap: () => _showAboutDialog(context), );
```

### SizedBox

```dart
const SizedBox(width: 12), const Text(BuildInfo.appName), ], ), content: Column( mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [ _buildAboutRow('Version', BuildInfo.fullVersion), _buildAboutRow('Build', BuildInfo.buildDateFormatted), _buildAboutRow('Auteur', BuildInfo.author), const Divider(height: 24), Text( BuildInfo.description, style: TextStyle( color: Colors.grey.shade600, fontStyle: FontStyle.italic, ), ), const SizedBox(height: 16), Text( '© ${BuildInfo.copyrightYear} ${BuildInfo.author}',
```

### Text

```dart
const Text(BuildInfo.appName), ], ), content: Column( mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [ _buildAboutRow('Version', BuildInfo.fullVersion), _buildAboutRow('Build', BuildInfo.buildDateFormatted), _buildAboutRow('Auteur', BuildInfo.author), const Divider(height: 24), Text( BuildInfo.description, style: TextStyle( color: Colors.grey.shade600, fontStyle: FontStyle.italic, ), ), const SizedBox(height: 16), Text( '© ${BuildInfo.copyrightYear} ${BuildInfo.author}',
```

### Divider

```dart
const Divider(height: 24), Text( BuildInfo.description, style: TextStyle( color: Colors.grey.shade600, fontStyle: FontStyle.italic, ), ), const SizedBox(height: 16), Text( '© ${BuildInfo.copyrightYear} ${BuildInfo.author}',
```

### SizedBox

```dart
const SizedBox(height: 16), Text( '© ${BuildInfo.copyrightYear} ${BuildInfo.author}',
```

### Padding

```dart
return Padding( padding: const EdgeInsets.symmetric(vertical: 4), child: Row( mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [ Text(label, style: const TextStyle(fontWeight: FontWeight.w500)), Text(value, style: TextStyle(color: Colors.grey.shade700)), ], ), );
```

### Padding

```dart
return Padding( padding: const EdgeInsets.fromLTRB(16, 16, 16, 8), child: Text( title.toUpperCase(), style: const TextStyle( fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue, ), ), );
```

### Color

```dart
const Color(0xFF9575CD), // Violet clair (défaut) const Color(0xFF7986CB), // Indigo clair const Color(0xFF64B5F6), // Bleu clair const Color(0xFF4DD0E1), // Cyan clair const Color(0xFF4DB6AC), // Teal clair const Color(0xFF81C784), // Vert clair const Color(0xFFAED581), // Vert lime clair const Color(0xFFFFD54F), // Ambre clair const Color(0xFFFFB74D), // Orange clair const Color(0xFFFF8A65), // Orange profond clair const Color(0xFFA1887F), // Marron clair const Color(0xFF90A4AE), // Gris bleu clair ];
```

### Color

```dart
const Color(0xFF7986CB), // Indigo clair const Color(0xFF64B5F6), // Bleu clair const Color(0xFF4DD0E1), // Cyan clair const Color(0xFF4DB6AC), // Teal clair const Color(0xFF81C784), // Vert clair const Color(0xFFAED581), // Vert lime clair const Color(0xFFFFD54F), // Ambre clair const Color(0xFFFFB74D), // Orange clair const Color(0xFFFF8A65), // Orange profond clair const Color(0xFFA1887F), // Marron clair const Color(0xFF90A4AE), // Gris bleu clair ];
```

### Color

```dart
const Color(0xFF64B5F6), // Bleu clair const Color(0xFF4DD0E1), // Cyan clair const Color(0xFF4DB6AC), // Teal clair const Color(0xFF81C784), // Vert clair const Color(0xFFAED581), // Vert lime clair const Color(0xFFFFD54F), // Ambre clair const Color(0xFFFFB74D), // Orange clair const Color(0xFFFF8A65), // Orange profond clair const Color(0xFFA1887F), // Marron clair const Color(0xFF90A4AE), // Gris bleu clair ];
```

### Color

```dart
const Color(0xFF4DD0E1), // Cyan clair const Color(0xFF4DB6AC), // Teal clair const Color(0xFF81C784), // Vert clair const Color(0xFFAED581), // Vert lime clair const Color(0xFFFFD54F), // Ambre clair const Color(0xFFFFB74D), // Orange clair const Color(0xFFFF8A65), // Orange profond clair const Color(0xFFA1887F), // Marron clair const Color(0xFF90A4AE), // Gris bleu clair ];
```

### Color

```dart
const Color(0xFF4DB6AC), // Teal clair const Color(0xFF81C784), // Vert clair const Color(0xFFAED581), // Vert lime clair const Color(0xFFFFD54F), // Ambre clair const Color(0xFFFFB74D), // Orange clair const Color(0xFFFF8A65), // Orange profond clair const Color(0xFFA1887F), // Marron clair const Color(0xFF90A4AE), // Gris bleu clair ];
```

### Color

```dart
const Color(0xFF81C784), // Vert clair const Color(0xFFAED581), // Vert lime clair const Color(0xFFFFD54F), // Ambre clair const Color(0xFFFFB74D), // Orange clair const Color(0xFFFF8A65), // Orange profond clair const Color(0xFFA1887F), // Marron clair const Color(0xFF90A4AE), // Gris bleu clair ];
```

### Color

```dart
const Color(0xFFAED581), // Vert lime clair const Color(0xFFFFD54F), // Ambre clair const Color(0xFFFFB74D), // Orange clair const Color(0xFFFF8A65), // Orange profond clair const Color(0xFFA1887F), // Marron clair const Color(0xFF90A4AE), // Gris bleu clair ];
```

### Color

```dart
const Color(0xFFFFD54F), // Ambre clair const Color(0xFFFFB74D), // Orange clair const Color(0xFFFF8A65), // Orange profond clair const Color(0xFFA1887F), // Marron clair const Color(0xFF90A4AE), // Gris bleu clair ];
```

### Color

```dart
const Color(0xFFFFB74D), // Orange clair const Color(0xFFFF8A65), // Orange profond clair const Color(0xFFA1887F), // Marron clair const Color(0xFF90A4AE), // Gris bleu clair ];
```

### Color

```dart
const Color(0xFFFF8A65), // Orange profond clair const Color(0xFFA1887F), // Marron clair const Color(0xFF90A4AE), // Gris bleu clair ];
```

### Color

```dart
const Color(0xFFA1887F), // Marron clair const Color(0xFF90A4AE), // Gris bleu clair ];
```

### Color

```dart
const Color(0xFF90A4AE), // Gris bleu clair ];
```

### GestureDetector

```dart
return GestureDetector( onTap: () {
```

