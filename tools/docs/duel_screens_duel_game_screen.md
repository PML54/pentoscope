# duel/screens/duel_game_screen.dart

**Module:** duel

## Fonctions

### DuelGameScreen

Constantes pour le slider
🆕 Rayon de recherche pour le snap (en cases)
Palette DUEL : 12 couleurs VIVES et SATURÉES
Couleurs franches, très distinctes, parfaites pour le mode compétitif


```dart
const DuelGameScreen({super.key});
```

### createState

```dart
ConsumerState<DuelGameScreen> createState() => _DuelGameScreenState();
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

Initialise la position du slider après le countdown
Vérifie si une pièce peut être placée à une position donnée
Cherche la position valide la plus proche dans un rayon donné
Met à jour la preview avec snap


```dart
Widget build(BuildContext context) {
```

### WillPopScope

```dart
return WillPopScope( onWillPop: () async {
```

### IconButton

```dart
return IconButton( icon: Icon(icon, color: color, size: 28), onPressed: onPressed, tooltip: tooltip, splashRadius: 24, );
```

### Container

```dart
return Container( padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration( gradient: LinearGradient( colors: [Colors.grey.shade900, Colors.black, Colors.grey.shade900], ), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade700, width: 1), ), child: Row( mainAxisSize: MainAxisSize.min, children: [ _buildPlayerScore(localName, localScore, Colors.cyan, true), Padding( padding: const EdgeInsets.symmetric(horizontal: 8), child: Container( padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration( color: Colors.black, borderRadius: BorderRadius.circular(6), border: Border.all(color: timerColor.withOpacity(0.5), width: 1.5), boxShadow: [ BoxShadow( color: timerColor.withOpacity(0.4), blurRadius: isUrgent ? 12 : 6, ), ], ), child: Text( timeStr, style: TextStyle( fontFamily: 'monospace', fontSize: 16, fontWeight: FontWeight.bold, color: timerColor, shadows: [ Shadow(color: timerColor, blurRadius: 8), ], ), ), ), ), _buildPlayerScore(opponentName, opponentScore, Colors.orange, false), ], ), );
```

### Column

```dart
return Column( mainAxisSize: MainAxisSize.min, children: [ Row( mainAxisSize: MainAxisSize.min, children: [ if (isLocal) Padding( padding: const EdgeInsets.only(right: 2), child: Icon(Icons.person, size: 10, color: Colors.green), ), Text( name.length > 6 ? '${name.substring(0, 5)}.' : name,
```

### SizedBox

```dart
const SizedBox(height: 2), Container( constraints: const BoxConstraints(minWidth: 32), padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration( color: Colors.black, borderRadius: BorderRadius.circular(4), border: Border.all(color: color.withOpacity(0.4), width: 1), boxShadow: [ BoxShadow(color: color.withOpacity(0.3), blurRadius: 4), ], ), child: Text( '$score', textAlign: TextAlign.center, style: TextStyle( fontFamily: 'monospace', fontSize: 18, fontWeight: FontWeight.bold, color: color, shadows: [ Shadow(color: color, blurRadius: 6), ], ), ), ), ], );
```

### LayoutBuilder

```dart
return LayoutBuilder( builder: (context, constraints) {
```

### Center

```dart
return Center( child: Container( width: cellSize * visualCols, height: cellSize * visualRows, decoration: BoxDecoration( color: Colors.black, // Fond noir pour les contours boxShadow: [ BoxShadow( color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 4), ), ], borderRadius: BorderRadius.circular(8), ), child: ClipRRect( borderRadius: BorderRadius.circular(8), child: DragTarget<Pento>( onWillAcceptWithDetails: (details) => true, onMove: (details) {
```

### GestureDetector

```dart
return GestureDetector( onTap: () {
```

### Padding

```dart
return Padding( padding: const EdgeInsets.symmetric(horizontal: 6), child: LongPressDraggable<Pento>( data: piece, delay: const Duration(milliseconds: 150), hapticFeedbackOnStart: true, onDragStarted: () {
```

### SizedBox

Widget pièce dans le slider - COULEURS VIVES + CONTOURS NOIRS


```dart
return SizedBox( width: width * cellSize, height: height * cellSize, child: Stack( children: position.map((cellNum) {
```

### Positioned

```dart
return Positioned( left: x * cellSize, top: y * cellSize, child: Container( width: cellSize, height: cellSize, decoration: BoxDecoration( color: isDragging ? color.withOpacity(0.9) : color, border: Border.all( color: Colors.black,  // ← CONTOUR NOIR width: 1.5, ), borderRadius: BorderRadius.circular(2), ), ), );
```

### paint

Hachures pour distinguer les pièces
- Diagonales (/) pour l'adversaire
- Horizontales (═) pour le joueur


```dart
void paint(Canvas canvas, Size size) {
```

### shouldRepaint

```dart
bool shouldRepaint(covariant HatchPainter oldDelegate) {
```

