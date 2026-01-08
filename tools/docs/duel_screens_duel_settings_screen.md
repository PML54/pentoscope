# duel/screens/duel_settings_screen.dart

**Module:** duel

## Fonctions

### DuelSettingsScreen

Durée de partie prédéfinie


```dart
const DuelSettingsScreen({super.key});
```

### createState

```dart
ConsumerState<DuelSettingsScreen> createState() => _DuelSettingsScreenState();
```

### initState

```dart
void initState() {
```

### dispose

```dart
void dispose() {
```

### build

```dart
Widget build(BuildContext context) {
```

### Scaffold

```dart
return Scaffold( appBar: AppBar( title: const Text('Paramètres Duel'), backgroundColor: Colors.deepPurple, foregroundColor: Colors.white, actions: [ IconButton( icon: const Icon(Icons.restore), onPressed: _resetToDefaults, tooltip: 'Réinitialiser', ), ], ), body: ListView( padding: const EdgeInsets.all(16), children: [ // === SECTION : Identité === _buildSectionHeader('👤 Identité', Icons.person), _buildNameField(), const SizedBox(height: 24),  // === SECTION : Durée de partie === _buildSectionHeader('⏱️ Durée de partie', Icons.timer), _buildDurationSelector(), if (_selectedDuration == DuelDuration.custom) _buildCustomDurationField(), const SizedBox(height: 24),  // === SECTION : Affichage === _buildSectionHeader('👁️ Affichage', Icons.visibility), _buildSwitchTile( title: 'Guide de solution', subtitle: 'Afficher la solution en filigrane', value: _showGuide, onChanged: (v) => setState(() => _showGuide = v), ), if (_showGuide) _buildSliderTile( title: 'Opacité du guide', value: _guideOpacity, min: 0.1, max: 0.5, divisions: 8, label: '${(_guideOpacity * 100).round()}%',
```

### SizedBox

```dart
const SizedBox(height: 24),  // === SECTION : Durée de partie === _buildSectionHeader('⏱️ Durée de partie', Icons.timer), _buildDurationSelector(), if (_selectedDuration == DuelDuration.custom) _buildCustomDurationField(), const SizedBox(height: 24),  // === SECTION : Affichage === _buildSectionHeader('👁️ Affichage', Icons.visibility), _buildSwitchTile( title: 'Guide de solution', subtitle: 'Afficher la solution en filigrane', value: _showGuide, onChanged: (v) => setState(() => _showGuide = v), ), if (_showGuide) _buildSliderTile( title: 'Opacité du guide', value: _guideOpacity, min: 0.1, max: 0.5, divisions: 8, label: '${(_guideOpacity * 100).round()}%',
```

### SizedBox

```dart
const SizedBox(height: 24),  // === SECTION : Affichage === _buildSectionHeader('👁️ Affichage', Icons.visibility), _buildSwitchTile( title: 'Guide de solution', subtitle: 'Afficher la solution en filigrane', value: _showGuide, onChanged: (v) => setState(() => _showGuide = v), ), if (_showGuide) _buildSliderTile( title: 'Opacité du guide', value: _guideOpacity, min: 0.1, max: 0.5, divisions: 8, label: '${(_guideOpacity * 100).round()}%',
```

### SizedBox

```dart
const SizedBox(height: 24),  // === SECTION : Feedback === _buildSectionHeader('📳 Feedback', Icons.vibration), _buildSwitchTile( title: 'Sons', subtitle: 'Placement, victoire, défaite', value: _enableSounds, onChanged: (v) => setState(() => _enableSounds = v), ), _buildSwitchTile( title: 'Vibrations', subtitle: 'Retour haptique', value: _enableVibration, onChanged: (v) => setState(() => _enableVibration = v), ), const SizedBox(height: 24),  // === SECTION : Statistiques === _buildSectionHeader('📊 Statistiques', Icons.bar_chart), _buildStatsCard(), const SizedBox(height: 32),  // === Bouton Sauvegarder === ElevatedButton.icon( onPressed: _saveSettings, icon: const Icon(Icons.save), label: const Text('Sauvegarder'), style: ElevatedButton.styleFrom( backgroundColor: Colors.deepPurple, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(12), ), ), ), ], ), );
```

### SizedBox

```dart
const SizedBox(height: 24),  // === SECTION : Statistiques === _buildSectionHeader('📊 Statistiques', Icons.bar_chart), _buildStatsCard(), const SizedBox(height: 32),  // === Bouton Sauvegarder === ElevatedButton.icon( onPressed: _saveSettings, icon: const Icon(Icons.save), label: const Text('Sauvegarder'), style: ElevatedButton.styleFrom( backgroundColor: Colors.deepPurple, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(12), ), ), ), ], ), );
```

### SizedBox

```dart
const SizedBox(height: 32),  // === Bouton Sauvegarder === ElevatedButton.icon( onPressed: _saveSettings, icon: const Icon(Icons.save), label: const Text('Sauvegarder'), style: ElevatedButton.styleFrom( backgroundColor: Colors.deepPurple, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(12), ), ), ), ], ), );
```

### Padding

```dart
return Padding( padding: const EdgeInsets.only(bottom: 12), child: Row( children: [ Icon(icon, color: Colors.deepPurple, size: 24), const SizedBox(width: 8), Text( title, style: const TextStyle( fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple, ), ), ], ), );
```

### SizedBox

```dart
const SizedBox(width: 8), Text( title, style: const TextStyle( fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple, ), ), ], ), );
```

### TextField

```dart
return TextField( controller: _nameController, decoration: InputDecoration( labelText: 'Nom du joueur', hintText: 'Entrez votre pseudo', prefixIcon: const Icon(Icons.person_outline), border: OutlineInputBorder( borderRadius: BorderRadius.circular(12), ), filled: true, fillColor: Colors.grey.shade50, ), maxLength: 20, textCapitalization: TextCapitalization.words, );
```

### Wrap

```dart
return Wrap( spacing: 8, runSpacing: 8, children: DuelDuration.values.map((duration) {
```

### ChoiceChip

```dart
return ChoiceChip( label: Row( mainAxisSize: MainAxisSize.min, children: [ Text(duration.icon), const SizedBox(width: 4), Text(duration.label), ], ), selected: isSelected, selectedColor: Colors.deepPurple.shade100, onSelected: (selected) {
```

### SizedBox

```dart
const SizedBox(width: 4), Text(duration.label), ], ), selected: isSelected, selectedColor: Colors.deepPurple.shade100, onSelected: (selected) {
```

### Padding

```dart
return Padding( padding: const EdgeInsets.only(top: 12), child: Row( children: [ Expanded( child: TextField( controller: _customDurationController, keyboardType: TextInputType.number, decoration: InputDecoration( labelText: 'Durée (secondes)', hintText: '60 - 1800', prefixIcon: const Icon(Icons.edit), border: OutlineInputBorder( borderRadius: BorderRadius.circular(12), ), ), ), ), const SizedBox(width: 12), Text( _formatDuration(int.tryParse(_customDurationController.text) ?? 180), style: const TextStyle( fontSize: 16, fontWeight: FontWeight.w500, color: Colors.deepPurple, ), ), ], ), );
```

### SizedBox

```dart
const SizedBox(width: 12), Text( _formatDuration(int.tryParse(_customDurationController.text) ?? 180), style: const TextStyle( fontSize: 16, fontWeight: FontWeight.w500, color: Colors.deepPurple, ), ), ], ), );
```

### SwitchListTile

```dart
return SwitchListTile( title: Text(title), subtitle: subtitle != null ? Text(subtitle, style: TextStyle(color: Colors.grey.shade600)) : null, value: value, onChanged: onChanged, activeColor: Colors.deepPurple, contentPadding: EdgeInsets.zero, );
```

### Column

```dart
return Column( crossAxisAlignment: CrossAxisAlignment.start, children: [ Padding( padding: const EdgeInsets.only(left: 4), child: Row( mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [ Text(title, style: const TextStyle(fontSize: 14)), Text(label, style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.w500)), ], ), ), Slider( value: value, min: min, max: max, divisions: divisions, activeColor: Colors.deepPurple, onChanged: onChanged, ), ], );
```

### Card

```dart
return Card( elevation: 2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), child: Padding( padding: const EdgeInsets.all(16), child: Column( children: [ Row( mainAxisAlignment: MainAxisAlignment.spaceAround, children: [ _buildStatItem('Parties', '$gamesPlayed', Icons.sports_esports), _buildStatItem('Victoires', '$wins', Icons.emoji_events, color: Colors.green), _buildStatItem('Défaites', '$losses', Icons.close, color: Colors.red), _buildStatItem('Égalités', '$draws', Icons.handshake, color: Colors.orange), ], ), const Divider(height: 24), Row( mainAxisAlignment: MainAxisAlignment.center, children: [ const Icon(Icons.percent, color: Colors.deepPurple), const SizedBox(width: 8), Text( 'Taux de victoire : ${winRate.toStringAsFixed(1)}%',
```

### Divider

```dart
const Divider(height: 24), Row( mainAxisAlignment: MainAxisAlignment.center, children: [ const Icon(Icons.percent, color: Colors.deepPurple), const SizedBox(width: 8), Text( 'Taux de victoire : ${winRate.toStringAsFixed(1)}%',
```

### Icon

```dart
const Icon(Icons.percent, color: Colors.deepPurple), const SizedBox(width: 8), Text( 'Taux de victoire : ${winRate.toStringAsFixed(1)}%',
```

### SizedBox

```dart
const SizedBox(width: 8), Text( 'Taux de victoire : ${winRate.toStringAsFixed(1)}%',
```

### SizedBox

```dart
const SizedBox(height: 12), TextButton.icon( onPressed: _confirmResetStats, icon: const Icon(Icons.delete_forever, size: 18), label: const Text('Réinitialiser les statistiques'), style: TextButton.styleFrom(foregroundColor: Colors.red), ), ], ), ), );
```

### Column

```dart
return Column( children: [ Icon(icon, color: color ?? Colors.deepPurple, size: 28), const SizedBox(height: 4), Text( value, style: TextStyle( fontSize: 20, fontWeight: FontWeight.bold, color: color ?? Colors.black87, ), ), Text( label, style: TextStyle( fontSize: 12, color: Colors.grey.shade600, ), ), ], );
```

### SizedBox

```dart
const SizedBox(height: 4), Text( value, style: TextStyle( fontSize: 20, fontWeight: FontWeight.bold, color: color ?? Colors.black87, ), ), Text( label, style: TextStyle( fontSize: 12, color: Colors.grey.shade600, ), ), ], );
```

### SnackBar

```dart
const SnackBar( content: Text('✅ Paramètres sauvegardés'), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating, ), );
```

### SnackBar

```dart
const SnackBar( content: Text('Statistiques effacées'), behavior: SnackBarBehavior.floating, ), );
```

### DuelSettingsTile

Tile pour accéder aux paramètres Duel depuis l'écran principal


```dart
const DuelSettingsTile({super.key});
```

### build

```dart
Widget build(BuildContext context, WidgetRef ref) {
```

### ListTile

```dart
return ListTile( leading: Container( padding: const EdgeInsets.all(8), decoration: BoxDecoration( color: Colors.deepPurple.shade50, borderRadius: BorderRadius.circular(8), ), child: const Icon(Icons.sports_esports, color: Colors.deepPurple), ), title: const Text('Mode Duel'), subtitle: Text('Joueur : $playerName'), // TODO: ajouter durée trailing: const Icon(Icons.chevron_right), onTap: () {
```

