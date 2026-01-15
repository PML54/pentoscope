# pentoscope/widgets/pentoscope_board.dart

**Module:** pentoscope

## Fonctions

### PentoscopeBoard

```dart
const PentoscopeBoard({super.key, required this.isLandscape});
```

### createState

```dart
ConsumerState<PentoscopeBoard> createState() => _PentoscopeBoardState();
```

### highlightCell

```dart
void highlightCell(int x, int y, Color color) {
```

### clearHighlights

```dart
void clearHighlights() {
```

### placeSelectedPiece

```dart
void placeSelectedPiece(int gridX, int gridY) {
```

### selectPieceOnBoard

```dart
void selectPieceOnBoard(int x, int y) {
```

### build

```dart
Widget build(BuildContext context) {
```

### LayoutBuilder

```dart
return LayoutBuilder( builder: (context, constraints) {
```

### Align

```dart
return Align( // En paysage: aligner en haut pour éviter l'espace // En portrait: centrer alignment: widget.isLandscape ? Alignment.topCenter : Alignment.center, child: Container( width: gridWidth, height: gridHeight, decoration: BoxDecoration( gradient: LinearGradient( begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.grey.shade50, Colors.grey.shade100], ), border: Border.all( color: Colors.grey.shade700, width: 3, ), boxShadow: [ BoxShadow( color: Colors.black.withValues(alpha: 0.2), blurRadius: 12, offset: const Offset(0, 4), spreadRadius: 2, ), ], borderRadius: BorderRadius.circular(16), ), child: ClipRRect( borderRadius: BorderRadius.circular(16), child: GridView.builder( padding: EdgeInsets.zero, physics: const NeverScrollableScrollPhysics(), shrinkWrap: true, gridDelegate: SliverGridDelegateWithFixedCrossAxisCount( crossAxisCount: visualCols, childAspectRatio: 1.0, crossAxisSpacing: 0, mainAxisSpacing: 0, ), itemCount: boardWidth * boardHeight, itemBuilder: (context, index) {
```

### SizedBox

Détermine la bordure à afficher
Détecte si une preview est à cette cellule
Détecte si une pièce placée est sélectionnée à cette cellule
Détermine la couleur de base de la cellule
Texte à afficher dans la cellule
Calcule le décalage minimum pour normaliser une forme
Récupère le numéro de pièce solution à une cellule donnée
Couleur du texte selon le contexte
Taille du texte
Épaisseur du texte
Détecte si cette cellule est une pièce solution


```dart
const SizedBox(height: 8),  Row( mainAxisSize: MainAxisSize.min, children: [ TextButton( onPressed: () {
```

### SizedBox

```dart
const SizedBox(width: 8), ElevatedButton( onPressed: () {
```

### SizedBox

```dart
const SizedBox(height: 8), ], ), ), ), ), ), );
```

