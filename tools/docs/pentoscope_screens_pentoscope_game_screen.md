# pentoscope/screens/pentoscope_game_screen.dart

**Module:** pentoscope

## Fonctions

### PentoscopeGameScreen

⏱️ Formate le temps en secondes (max 999s) - format compact


```dart
const PentoscopeGameScreen({super.key});
```

### createState

```dart
ConsumerState<PentoscopeGameScreen> createState() => _PentoscopeGameScreenState();
```

### SnackBar

Gère l'affichage des messages et vibrations selon le résultat de transformation


```dart
const SnackBar( content: Text('Recentrage'), duration: Duration(seconds: 2), backgroundColor: Colors.orange, ), );
```

### SnackBar

```dart
const SnackBar( content: Text('Transformation impossible'), duration: Duration(seconds: 2), backgroundColor: Colors.red, ), );
```

### build

```dart
Widget build(BuildContext context) {
```

### Scaffold

```dart
return Scaffold( backgroundColor: Colors.white, appBar: isLandscape ? null : PreferredSize( preferredSize: const Size.fromHeight(56.0), child: AppBar( toolbarHeight: 56.0, backgroundColor: Colors.white, automaticallyImplyLeading: false, // 🔑 En mode transformation: pas de leading, les icônes prennent toute la place leading: (isPlacedPieceSelected || isSliderPieceSelected) ? null : Row( mainAxisSize: MainAxisSize.min, children: [ IconButton( icon: const Icon(Icons.close, color: Colors.red), onPressed: () => Navigator.pop(context), ), // ⏱️ Chronomètre Text( _formatTime(state.elapsedSeconds), style: const TextStyle( fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black, ), ), ], ), leadingWidth: (isPlacedPieceSelected || isSliderPieceSelected) ? 0 : 100, // 🔑 En mode transformation: icônes isométrie pleine largeur title: (isPlacedPieceSelected || isSliderPieceSelected) ? _buildFullWidthIsometryBar(state, notifier) : state.isComplete ? TweenAnimationBuilder<double>( tween: Tween(begin: 0.0, end: 1.0), duration: const Duration(milliseconds: 800), curve: Curves.elasticOut, builder: (context, value, child) {
```

### SizedBox

```dart
const SizedBox(width: 6), Icon(Icons.open_with, size: 14, color: Colors.purple.shade600), Text('${state.translationCount}', style: const TextStyle(fontSize: 12, color: Colors.black54)),
```

### SizedBox

```dart
const SizedBox(width: 6), Icon(Icons.delete_outline, size: 14, color: Colors.red.shade600), Text('${state.deleteCount}', style: const TextStyle(fontSize: 12, color: Colors.black54)),
```

### Positioned

```dart
return Positioned( left: currentX, top: currentY, child: GestureDetector( // 🖐️ Drag pour déplacer onPanUpdate: (details) {
```

### SizedBox

```dart
const SizedBox(width: 4), const Text( '👤 Adversaire', style: TextStyle( color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, ), ), ], ), Text( '${_simulateOpponentProgress(state)}/${state.puzzle?.size.numPieces ?? 0}',
```

### Text

```dart
const Text( '👤 Adversaire', style: TextStyle( color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, ), ), ], ), Text( '${_simulateOpponentProgress(state)}/${state.puzzle?.size.numPieces ?? 0}',
```

### Padding

Simule la progression de l'adversaire (pour démo)
Construit le mini-plateau (vue simplifiée)


```dart
return Padding( padding: const EdgeInsets.only(top: 22), // Espace pour le bandeau child: Center( child: SizedBox( width: cellSize * boardWidth, height: cellSize * boardHeight, child: GridView.builder( physics: const NeverScrollableScrollPhysics(), padding: EdgeInsets.zero, gridDelegate: SliverGridDelegateWithFixedCrossAxisCount( crossAxisCount: boardWidth, childAspectRatio: 1.0, ), itemCount: boardWidth * boardHeight, itemBuilder: (context, index) {
```

### Container

```dart
return Container( decoration: BoxDecoration( color: pieceId != null ? settings.ui.getPieceColor(pieceId).withOpacity(0.8) : Colors.grey.shade200, border: Border.all(color: Colors.grey.shade400, width: 0.5), ), );
```

### Row

Simule les pièces de l'adversaire (pour démo)
En mode miroir : affiche les mêmes pièces que nous
Récupère l'ID de la pièce à une position donnée
Widget réutilisable pour les icônes isométrie (horizontal ou vertical)
🔑 Barre d'isométries pleine largeur avec icônes grandes et réparties uniformément


```dart
return Row( mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [ // Rotation anti-horaire IconButton( icon: Icon(GameIcons.isometryRotationTW.icon, size: iconSize), padding: EdgeInsets.zero, constraints: const BoxConstraints(), onPressed: () {
```

### Column

🔑 Barre d'isométries pleine hauteur (mode paysage) avec icônes grandes et réparties


```dart
return Column( mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [ // Rotation anti-horaire IconButton( icon: Icon(GameIcons.isometryRotationTW.icon, size: iconSize), padding: EdgeInsets.zero, constraints: const BoxConstraints(), onPressed: () {
```

### IconButton

Helper: bouton d'action isométrie


```dart
return IconButton( icon: Icon(icon.icon, size: iconSize), padding: const EdgeInsets.all(6), constraints: const BoxConstraints(minWidth: 36, minHeight: 36), onPressed: () {
```

### Text

Affiche le nombre de solutions


```dart
return Text( '$count solution${count != 1 ? "s" : ""}',
```

### AnimatedContainer

Construit le slider avec DragTarget (drag pièce vers slider = suppression)


```dart
return AnimatedContainer( duration: const Duration(milliseconds: 150), width: width, height: height, decoration: decoration.copyWith( border: isHovering ? Border.all(color: Colors.red.shade400, width: 3) : null, color: isHovering ? Colors.red.shade50 : decoration.color, ), child: Stack( children: [ sliderChild, // Icône poubelle au survol if (isHovering) Positioned.fill( child: IgnorePointer( child: Container( color: Colors.red.withOpacity(0.1), child: Center( child: Container( padding: const EdgeInsets.all(12), decoration: BoxDecoration( color: Colors.red.shade100, shape: BoxShape.circle, ), child: Icon( Icons.delete_outline, color: Colors.red.shade700, size: 32, ), ), ), ), ), ), ], ), );
```

### Column

Layout portrait : plateau en haut, actions + slider en bas


```dart
return Column( children: [ // Plateau de jeu const Expanded(flex: 3, child: PentoscopeBoard(isLandscape: false)),  // Slider de pièces horizontal _buildSliderWithDragTarget( ref: ref, isLandscape: false, height: 160, decoration: BoxDecoration( color: Colors.grey.shade100, boxShadow: [ BoxShadow( color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, -2), ), ], ), sliderChild: const PentoscopePieceSlider(isLandscape: false), ), ], );
```

### Expanded

```dart
const Expanded(flex: 3, child: PentoscopeBoard(isLandscape: false)),  // Slider de pièces horizontal _buildSliderWithDragTarget( ref: ref, isLandscape: false, height: 160, decoration: BoxDecoration( color: Colors.grey.shade100, boxShadow: [ BoxShadow( color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, -2), ), ], ), sliderChild: const PentoscopePieceSlider(isLandscape: false), ), ], );
```

### LayoutBuilder

Layout paysage : plateau à gauche, actions + slider vertical à droite


```dart
return LayoutBuilder( builder: (context, constraints) {
```

### Row

```dart
return Row( children: [ // Plateau de jeu const Expanded(child: PentoscopeBoard(isLandscape: true)),  // Colonne de droite : actions + slider Row( children: [ // 🎯 Colonne d'actions (contextuelles) Container( width: actionColumnWidth, decoration: BoxDecoration( color: Colors.white, boxShadow: [ BoxShadow( color: Colors.black.withOpacity(0.05), blurRadius: 2, offset: const Offset(-1, 0), ), ], ), child: (isPlacedPieceSelected || isSliderPieceSelected) // 🔑 Mode transformation: icônes pleine hauteur, réparties uniformément ? _buildFullHeightIsometryBar(state, notifier, actionColumnWidth) // Mode normal: actions centrées : Column( mainAxisAlignment: MainAxisAlignment.center, children: [ // ⏱️ Chronomètre Padding( padding: const EdgeInsets.symmetric(vertical: 8.0), child: Text( _formatTime(state.elapsedSeconds), style: TextStyle( fontSize: (iconSize * 0.5).clamp(10.0, 16.0), fontWeight: FontWeight.bold, color: Colors.black, ), ), ), // Actions générales (reset, close, hint) IconButton( icon: Icon(Icons.games, size: iconSize), onPressed: () {
```

### Expanded

```dart
const Expanded(child: PentoscopeBoard(isLandscape: true)),  // Colonne de droite : actions + slider Row( children: [ // 🎯 Colonne d'actions (contextuelles) Container( width: actionColumnWidth, decoration: BoxDecoration( color: Colors.white, boxShadow: [ BoxShadow( color: Colors.black.withOpacity(0.05), blurRadius: 2, offset: const Offset(-1, 0), ), ], ), child: (isPlacedPieceSelected || isSliderPieceSelected) // 🔑 Mode transformation: icônes pleine hauteur, réparties uniformément ? _buildFullHeightIsometryBar(state, notifier, actionColumnWidth) // Mode normal: actions centrées : Column( mainAxisAlignment: MainAxisAlignment.center, children: [ // ⏱️ Chronomètre Padding( padding: const EdgeInsets.symmetric(vertical: 8.0), child: Text( _formatTime(state.elapsedSeconds), style: TextStyle( fontSize: (iconSize * 0.5).clamp(10.0, 16.0), fontWeight: FontWeight.bold, color: Colors.black, ), ), ), // Actions générales (reset, close, hint) IconButton( icon: Icon(Icons.games, size: iconSize), onPressed: () {
```

### Column

Version adaptative de la barre d'isométries (taille variable)


```dart
return Column( mainAxisSize: MainAxisSize.min, children: [ // Rotation anti-horaire IconButton( icon: Icon(GameIcons.isometryRotationTW.icon, size: iconSize), padding: EdgeInsets.all(iconSize * 0.2), constraints: BoxConstraints(minWidth: iconSize + 8, minHeight: iconSize + 8), onPressed: () {
```

### Text

📏 Affiche le dialogue de changement de taille de plateau


```dart
const Text('Sélectionnez la nouvelle taille :'), const SizedBox(height: 16), ...PentoscopeSize.values.map((size) => RadioListTile<PentoscopeSize>( title: Text('${size.label} (${size.width}x${size.height})'),
```

### SizedBox

```dart
const SizedBox(height: 16), ...PentoscopeSize.values.map((size) => RadioListTile<PentoscopeSize>( title: Text('${size.label} (${size.width}x${size.height})'),
```

