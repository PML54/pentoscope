# pentoscope_multiplayer/screens/pentoscope_mp_lobby_screen.dart

**Module:** pentoscope_multiplayer

## Fonctions

### PentoscopeMPLobbyScreen

```dart
const PentoscopeMPLobbyScreen({super.key});
```

### createState

```dart
ConsumerState<PentoscopeMPLobbyScreen> createState() => _PentoscopeMPLobbyScreenState();
```

### initState

```dart
void initState() {
```

### SnackBar

```dart
const SnackBar( content: Text('🎯 Lobby chargé - test DB'), duration: Duration(seconds: 1), backgroundColor: Colors.purple, ), );
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
return Scaffold( appBar: AppBar( title: const Text('Pentoscope Multiplayer'), centerTitle: true, leading: IconButton( icon: const Icon(Icons.close), onPressed: () async {
```

### SingleChildScrollView

```dart
return SingleChildScrollView( padding: const EdgeInsets.all(24), child: Column( crossAxisAlignment: CrossAxisAlignment.stretch, children: [ // Nom du joueur TextField( controller: _playerNameController, decoration: InputDecoration( labelText: 'Ton pseudo', prefixIcon: const Icon(Icons.person), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), ), textCapitalization: TextCapitalization.words, ),  const SizedBox(height: 32),  // Contenu selon l'état AnimatedSwitcher( duration: const Duration(milliseconds: 200), child: _showJoinInput ? _buildJoinInputSection() : _buildMainButtonsSection(), ), ], ), );
```

### SizedBox

```dart
const SizedBox(height: 32),  // Contenu selon l'état AnimatedSwitcher( duration: const Duration(milliseconds: 200), child: _showJoinInput ? _buildJoinInputSection() : _buildMainButtonsSection(), ), ], ), );
```

### Column

```dart
return Column( key: const ValueKey('main_buttons'), crossAxisAlignment: CrossAxisAlignment.stretch, children: [ // Bouton Créer une Partie ElevatedButton.icon( onPressed: () async {
```

### SnackBar

```dart
const SnackBar(content: Text('Entre ton pseudo')), );
```

### SizedBox

```dart
const SizedBox(height: 16),  // Bouton Rejoindre une Partie OutlinedButton.icon( onPressed: () => setState(() => _showJoinInput = true), icon: const Icon(Icons.login), label: const Text('Rejoindre une Partie'), style: OutlinedButton.styleFrom( padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), side: BorderSide(color: Theme.of(context).primaryColor), ), ), ], );
```

### Column

```dart
return Column( key: const ValueKey('join_input'), crossAxisAlignment: CrossAxisAlignment.stretch, children: [ // Code de la room TextField( controller: _roomCodeController, autofocus: true, decoration: InputDecoration( labelText: 'Code de la room', hintText: 'Ex: ABCD', prefixIcon: const Icon(Icons.tag), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), suffixIcon: IconButton( icon: const Icon(Icons.arrow_back), onPressed: () => setState(() => _showJoinInput = false), tooltip: 'Retour', ), ), textCapitalization: TextCapitalization.characters, maxLength: 4, inputFormatters: [ FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')), UpperCaseTextFormatter(), ], ),  const SizedBox(height: 16),  // Bouton Go ElevatedButton.icon( onPressed: _joinRoom, icon: const Icon(Icons.play_arrow), label: const Text('Go'), style: ElevatedButton.styleFrom( padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), ), ), ], );
```

### SizedBox

```dart
const SizedBox(height: 16),  // Bouton Go ElevatedButton.icon( onPressed: _joinRoom, icon: const Icon(Icons.play_arrow), label: const Text('Go'), style: ElevatedButton.styleFrom( padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), ), ), ], );
```

### Padding

```dart
return Padding( padding: const EdgeInsets.all(24), child: Column( crossAxisAlignment: CrossAxisAlignment.stretch, children: [ // Code de la room _buildRoomCodeCard(state.roomCode ?? '????'),  const SizedBox(height: 24),  // Config if (state.config != null) _buildConfigCard(state.config!),  const SizedBox(height: 24),  // Liste des joueurs const Text( 'Joueurs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), ), const SizedBox(height: 12),  Expanded( child: ListView.builder( itemCount: state.players.length, itemBuilder: (context, index) {
```

### SizedBox

```dart
const SizedBox(height: 24),  // Config if (state.config != null) _buildConfigCard(state.config!),  const SizedBox(height: 24),  // Liste des joueurs const Text( 'Joueurs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), ), const SizedBox(height: 12),  Expanded( child: ListView.builder( itemCount: state.players.length, itemBuilder: (context, index) {
```

### SizedBox

```dart
const SizedBox(height: 24),  // Liste des joueurs const Text( 'Joueurs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), ), const SizedBox(height: 12),  Expanded( child: ListView.builder( itemCount: state.players.length, itemBuilder: (context, index) {
```

### Text

```dart
const Text( 'Joueurs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), ), const SizedBox(height: 12),  Expanded( child: ListView.builder( itemCount: state.players.length, itemBuilder: (context, index) {
```

### SizedBox

```dart
const SizedBox(height: 12),  Expanded( child: ListView.builder( itemCount: state.players.length, itemBuilder: (context, index) {
```

### SizedBox

```dart
const SizedBox(height: 16), ElevatedButton.icon( onPressed: state.canStart ? _startGame : null, icon: const Icon(Icons.play_arrow), label: Text(state.playerCount < 2 ? 'En attente de joueurs (${state.playerCount}/4)'
```

### SizedBox

```dart
const SizedBox(height: 16), Container( padding: const EdgeInsets.all(16), decoration: BoxDecoration( color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12), ), child: const Row( mainAxisAlignment: MainAxisAlignment.center, children: [ SizedBox( width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2), ), SizedBox(width: 12), Text('En attente du lancement...'), ], ), ), ],  // Bouton Quitter const SizedBox(height: 12), TextButton.icon( onPressed: () async {
```

### SizedBox

```dart
const SizedBox(height: 12), TextButton.icon( onPressed: () async {
```

### Container

```dart
return Container( padding: const EdgeInsets.all(20), decoration: BoxDecoration( gradient: LinearGradient( colors: [Colors.indigo.shade400, Colors.purple.shade400], begin: Alignment.topLeft, end: Alignment.bottomRight, ), borderRadius: BorderRadius.circular(16), boxShadow: [ BoxShadow( color: Colors.indigo.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6), ), ], ), child: Column( children: [ const Text( 'Code de la room', style: TextStyle(color: Colors.white70, fontSize: 14), ), const SizedBox(height: 8), Row( mainAxisAlignment: MainAxisAlignment.center, children: [ Text( code, style: const TextStyle( color: Colors.white, fontSize: 42, fontWeight: FontWeight.bold, letterSpacing: 8, ), ), const SizedBox(width: 12), IconButton( icon: const Icon(Icons.copy, color: Colors.white70), onPressed: () {
```

### Text

```dart
const Text( 'Code de la room', style: TextStyle(color: Colors.white70, fontSize: 14), ), const SizedBox(height: 8), Row( mainAxisAlignment: MainAxisAlignment.center, children: [ Text( code, style: const TextStyle( color: Colors.white, fontSize: 42, fontWeight: FontWeight.bold, letterSpacing: 8, ), ), const SizedBox(width: 12), IconButton( icon: const Icon(Icons.copy, color: Colors.white70), onPressed: () {
```

### SizedBox

```dart
const SizedBox(height: 8), Row( mainAxisAlignment: MainAxisAlignment.center, children: [ Text( code, style: const TextStyle( color: Colors.white, fontSize: 42, fontWeight: FontWeight.bold, letterSpacing: 8, ), ), const SizedBox(width: 12), IconButton( icon: const Icon(Icons.copy, color: Colors.white70), onPressed: () {
```

### SizedBox

```dart
const SizedBox(width: 12), IconButton( icon: const Icon(Icons.copy, color: Colors.white70), onPressed: () {
```

### SnackBar

```dart
const SnackBar( content: Text('Code copié !'), duration: Duration(seconds: 1), ), );
```

### SizedBox

```dart
const SizedBox(height: 8), const Text( 'Partage ce code avec tes amis', style: TextStyle(color: Colors.white70, fontSize: 12), ), ], ), );
```

### Text

```dart
const Text( 'Partage ce code avec tes amis', style: TextStyle(color: Colors.white70, fontSize: 12), ), ], ), );
```

### Container

```dart
return Container( padding: const EdgeInsets.all(16), decoration: BoxDecoration( color: Colors.grey[100], borderRadius: BorderRadius.circular(12), ), child: Row( mainAxisAlignment: MainAxisAlignment.spaceAround, children: [ _buildConfigItem(Icons.grid_4x4, 'Format', config.format), _buildConfigItem(Icons.extension, 'Pièces', '${config.pieceCount}'),
```

### Column

```dart
return Column( children: [ Icon(icon, color: Colors.grey[600], size: 20), const SizedBox(height: 4), Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)), Text(value, style: const TextStyle(fontWeight: FontWeight.bold)), ], );
```

### SizedBox

```dart
const SizedBox(height: 4), Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)), Text(value, style: const TextStyle(fontWeight: FontWeight.bold)), ], );
```

### Container

```dart
return Container( margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(12), decoration: BoxDecoration( color: player.isMe ? Colors.blue.shade50 : Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all( color: player.isMe ? Colors.blue.shade200 : Colors.grey.shade200, ), ), child: Row( children: [ // Avatar CircleAvatar( backgroundColor: player.isHost ? Colors.amber : Colors.grey[300], child: Icon( player.isHost ? Icons.star : Icons.person, color: player.isHost ? Colors.white : Colors.grey[600], ), ), const SizedBox(width: 12),  // Nom Expanded( child: Column( crossAxisAlignment: CrossAxisAlignment.start, children: [ Text( player.name, style: const TextStyle(fontWeight: FontWeight.bold), ), if (player.isHost) Text( 'Hôte', style: TextStyle(color: Colors.amber.shade700, fontSize: 12), ), ], ), ),  // Badge "Moi" if (player.isMe) Container( padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration( color: Colors.blue, borderRadius: BorderRadius.circular(12), ), child: const Text( 'Moi', style: TextStyle(color: Colors.white, fontSize: 12), ), ), ], ), );
```

### SizedBox

```dart
const SizedBox(width: 12),  // Nom Expanded( child: Column( crossAxisAlignment: CrossAxisAlignment.start, children: [ Text( player.name, style: const TextStyle(fontWeight: FontWeight.bold), ), if (player.isHost) Text( 'Hôte', style: TextStyle(color: Colors.amber.shade700, fontSize: 12), ), ], ), ),  // Badge "Moi" if (player.isMe) Container( padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration( color: Colors.blue, borderRadius: BorderRadius.circular(12), ), child: const Text( 'Moi', style: TextStyle(color: Colors.white, fontSize: 12), ), ), ], ), );
```

### Center

```dart
return Center( child: Padding( padding: const EdgeInsets.all(24), child: Column( mainAxisSize: MainAxisSize.min, children: [ const Icon(Icons.error_outline, size: 64, color: Colors.red), const SizedBox(height: 16), Text( state.errorMessage ?? 'Une erreur est survenue', textAlign: TextAlign.center, style: const TextStyle(fontSize: 16), ), const SizedBox(height: 24), ElevatedButton.icon( onPressed: () async {
```

### Icon

```dart
const Icon(Icons.error_outline, size: 64, color: Colors.red), const SizedBox(height: 16), Text( state.errorMessage ?? 'Une erreur est survenue', textAlign: TextAlign.center, style: const TextStyle(fontSize: 16), ), const SizedBox(height: 24), ElevatedButton.icon( onPressed: () async {
```

### SizedBox

```dart
const SizedBox(height: 16), Text( state.errorMessage ?? 'Une erreur est survenue', textAlign: TextAlign.center, style: const TextStyle(fontSize: 16), ), const SizedBox(height: 24), ElevatedButton.icon( onPressed: () async {
```

### SizedBox

```dart
const SizedBox(height: 24), ElevatedButton.icon( onPressed: () async {
```

### SnackBar

```dart
const SnackBar(content: Text('Entre ton pseudo')), );
```

### SnackBar

```dart
const SnackBar(content: Text('Le code doit faire 4 caractères')), );
```

### formatEditUpdate

Formatter pour convertir en majuscules


```dart
TextEditingValue formatEditUpdate( TextEditingValue oldValue, TextEditingValue newValue, ) {
```

### TextEditingValue

```dart
return TextEditingValue( text: newValue.text.toUpperCase(), selection: newValue.selection, );
```

