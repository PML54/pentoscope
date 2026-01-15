# pentoscope_multiplayer/screens/pentoscope_mp_game_screen.dart

**Module:** pentoscope_multiplayer

## Fonctions

### PentoscopeMPGameScreen

⏱️ Formate le temps en secondes (max 999s) - format compact


```dart
const PentoscopeMPGameScreen({super.key});
```

### createState

```dart
ConsumerState<PentoscopeMPGameScreen> createState() => _PentoscopeMPGameScreenState();
```

### initState

```dart
void initState() {
```

### build

```dart
Widget build(BuildContext context) {
```

### Scaffold

```dart
return Scaffold( backgroundColor: Colors.white, appBar: isLandscape ? null : PreferredSize( preferredSize: const Size.fromHeight(56.0), child: AppBar( toolbarHeight: 56.0, backgroundColor: Colors.white, automaticallyImplyLeading: false, leading: (isPlacedPieceSelected || isSliderPieceSelected) ? null : Row( mainAxisSize: MainAxisSize.min, children: [ // ❌ Bouton quitter IconButton( icon: const Icon(Icons.close, color: Colors.red), onPressed: () => _showQuitDialog(context, ref), tooltip: 'Quitter', ), // ⏱️ Chronomètre Text( _formatTime(mpState.elapsedSeconds), style: const TextStyle( fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black, ), ), ], ), leadingWidth: (isPlacedPieceSelected || isSliderPieceSelected) ? 0 : 100, title: (isPlacedPieceSelected || isSliderPieceSelected) ? _buildFullWidthIsometryBar(localState, localNotifier) : _buildPlayersProgress(mpState), centerTitle: true, actions: (isPlacedPieceSelected || isSliderPieceSelected) ? null : [ // 💡 Indicateur solution possible (lampe) if (!localState.isComplete && localState.availablePieces.isNotEmpty) Padding( padding: const EdgeInsets.only(right: 4), child: Icon( localState.hasPossibleSolution ? Icons.lightbulb : Icons.lightbulb_outline, color: localState.hasPossibleSolution ? Colors.amber : Colors.grey.shade400, size: 24, ), ), // 👁️ Toggle adversaires IconButton( icon: Icon( _showOpponents ? Icons.visibility : Icons.visibility_off, color: _showOpponents ? Colors.blue : Colors.grey, ), onPressed: () {
```

### Container

```dart
return Container( color: Colors.black54, child: Center( child: TweenAnimationBuilder<double>( key: ValueKey(state.countdownValue), tween: Tween(begin: 1.5, end: 1.0), duration: const Duration(milliseconds: 500), curve: Curves.elasticOut, builder: (context, scale, child) {
```

### Row

```dart
return Row( mainAxisSize: MainAxisSize.min, children: state.players.map((player) {
```

### Padding

```dart
return Padding( padding: const EdgeInsets.symmetric(horizontal: 4), child: Column( mainAxisSize: MainAxisSize.min, children: [ Text( player.isMe ? 'Moi' : player.name.substring(0, min(4, player.name.length)), style: TextStyle( fontSize: 10, color: color, fontWeight: player.isMe ? FontWeight.bold : FontWeight.normal, ), ), const SizedBox(height: 2), SizedBox( width: 40, child: LinearProgressIndicator( value: progress, backgroundColor: Colors.grey[200], valueColor: AlwaysStoppedAnimation(color), ), ), Text( '${player.placedCount}/$totalPieces',
```

### SizedBox

```dart
const SizedBox(height: 2), SizedBox( width: 40, child: LinearProgressIndicator( value: progress, backgroundColor: Colors.grey[200], valueColor: AlwaysStoppedAnimation(color), ), ), Text( '${player.placedCount}/$totalPieces',
```

### Positioned

```dart
return Positioned( left: currentX, top: currentY, child: GestureDetector( onPanUpdate: (details) {
```

### AnimatedContainer

```dart
return AnimatedContainer( duration: const Duration(milliseconds: 150), width: size, height: size, decoration: BoxDecoration( color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: borderColor, width: 2), boxShadow: [ BoxShadow( color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 2), ), ], ), child: ClipRRect( borderRadius: BorderRadius.circular(10), child: Stack( children: [ // Grille avec les vraies pièces de l'adversaire Padding( padding: const EdgeInsets.only(top: 22), child: Center( child: SizedBox( width: cellSize * boardWidth, height: cellSize * boardHeight, child: GridView.builder( physics: const NeverScrollableScrollPhysics(), padding: EdgeInsets.zero, gridDelegate: SliverGridDelegateWithFixedCrossAxisCount( crossAxisCount: boardWidth, childAspectRatio: 1.0, ), itemCount: boardWidth * boardHeight, itemBuilder: (context, index) {
```

### Container

```dart
return Container( decoration: BoxDecoration( color: pieceId != null ? settings.ui.getPieceColor(pieceId).withOpacity(0.8) : Colors.grey.shade200, border: Border.all(color: Colors.grey.shade400, width: 0.5), ), );
```

### SizedBox

```dart
const SizedBox(width: 2), Text( opponent.name.length > 8 ? '${opponent.name.substring(0, 8)}...'
```

### Icon

```dart
const Icon(Icons.check_circle, color: Colors.white, size: 12), if (opponent.rank != null) Text( ' #${opponent.rank}',
```

### Column

Affiche une dialog de confirmation pour quitter
Récupère l'ID de la pièce à une position donnée sur le mini-plateau


```dart
return Column( children: [ // Plateau Expanded( child: Center( child: PentoscopeBoard( isLandscape: false, ), ), ),  // Slider Container( height: 140, decoration: BoxDecoration( color: Colors.grey.shade100, border: Border(top: BorderSide(color: Colors.grey.shade300)), ), child: PentoscopePieceSlider( isLandscape: false, ), ), ], );
```

### Row

```dart
return Row( children: [ // Colonne gauche: actions + chrono SizedBox( width: 50, child: Column( mainAxisAlignment: MainAxisAlignment.center, children: [ // Chrono Text( _formatTime(mpState.elapsedSeconds), style: const TextStyle( fontSize: 12, fontWeight: FontWeight.bold, ), ), const SizedBox(height: 8),  // 💡 Indicateur solution possible if (!state.isComplete && state.availablePieces.isNotEmpty) Icon( state.hasPossibleSolution ? Icons.lightbulb : Icons.lightbulb_outline, color: state.hasPossibleSolution ? Colors.amber : Colors.grey.shade400, size: 20, ),  const SizedBox(height: 8),  // Toggle adversaires IconButton( icon: Icon( _showOpponents ? Icons.visibility : Icons.visibility_off, color: _showOpponents ? Colors.blue : Colors.grey, size: 20, ), onPressed: () {
```

### SizedBox

```dart
const SizedBox(height: 8),  // 💡 Indicateur solution possible if (!state.isComplete && state.availablePieces.isNotEmpty) Icon( state.hasPossibleSolution ? Icons.lightbulb : Icons.lightbulb_outline, color: state.hasPossibleSolution ? Colors.amber : Colors.grey.shade400, size: 20, ),  const SizedBox(height: 8),  // Toggle adversaires IconButton( icon: Icon( _showOpponents ? Icons.visibility : Icons.visibility_off, color: _showOpponents ? Colors.blue : Colors.grey, size: 20, ), onPressed: () {
```

### SizedBox

```dart
const SizedBox(height: 8),  // Toggle adversaires IconButton( icon: Icon( _showOpponents ? Icons.visibility : Icons.visibility_off, color: _showOpponents ? Colors.blue : Colors.grey, size: 20, ), onPressed: () {
```

### Spacer

```dart
const Spacer(),  // Actions isométrie (si sélection) if (isPlacedPieceSelected || isSliderPieceSelected) _buildFullHeightIsometryBar(state, notifier, 50),  const Spacer(),  // ❌ Bouton quitter IconButton( icon: const Icon(Icons.close, color: Colors.red, size: 20), onPressed: () => _showQuitDialog(context, ref), tooltip: 'Quitter', ), ], ), ),  // Plateau Expanded( child: Center( child: PentoscopeBoard( isLandscape: true, ), ), ),  // Slider vertical Container( width: 120, decoration: BoxDecoration( color: Colors.grey.shade100, border: Border(left: BorderSide(color: Colors.grey.shade300)), ), child: PentoscopePieceSlider( isLandscape: true, ), ), ], );
```

### Spacer

```dart
const Spacer(),  // ❌ Bouton quitter IconButton( icon: const Icon(Icons.close, color: Colors.red, size: 20), onPressed: () => _showQuitDialog(context, ref), tooltip: 'Quitter', ), ], ), ),  // Plateau Expanded( child: Center( child: PentoscopeBoard( isLandscape: true, ), ), ),  // Slider vertical Container( width: 120, decoration: BoxDecoration( color: Colors.grey.shade100, border: Border(left: BorderSide(color: Colors.grey.shade300)), ), child: PentoscopePieceSlider( isLandscape: true, ), ), ], );
```

### Row

```dart
return Row( mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [ IconButton( icon: Icon(GameIcons.isometryRotationTW.icon, size: iconSize), padding: EdgeInsets.zero, constraints: const BoxConstraints(), onPressed: () {
```

### Column

```dart
return Column( mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [ IconButton( icon: Icon(GameIcons.isometryRotationTW.icon, size: iconSize), padding: EdgeInsets.zero, constraints: const BoxConstraints(), onPressed: () {
```

