# pentoscope/widgets/pentoscope_piece_slider.dart

**Module:** pentoscope

## Fonctions

### PentoscopePieceSlider

```dart
const PentoscopePieceSlider({
```

### createState

```dart
ConsumerState<PentoscopePieceSlider> createState() => _PentoscopePieceSliderState();
```

### highlightPiece

```dart
void highlightPiece(int index) {
```

### clearHighlight

```dart
void clearHighlight() {
```

### scrollToPiece

```dart
void scrollToPiece(int pieceIndex) {
```

### selectPiece

```dart
void selectPiece(int pieceIndex) {
```

### build

```dart
Widget build(BuildContext context) {
```

### Container

```dart
return Container( decoration: isHighlighted ? BoxDecoration( border: Border.all(color: Colors.yellow, width: 3), borderRadius: BorderRadius.circular(8), boxShadow: [ BoxShadow( color: Colors.yellow.withOpacity(0.5), blurRadius: 8, spreadRadius: 2, ), ], ) : null, child: _buildDraggablePiece(piece, notifier, state, settings, widget.isLandscape), );
```

### SizedBox

Convertit positionIndex interne en displayPositionIndex pour l'affichage


```dart
return SizedBox( width: fixedSize, height: fixedSize, child: Center( child: Transform.rotate( angle: isLandscape ? -math.pi / 2 : 0.0, child: Container( decoration: BoxDecoration( boxShadow: isSelected ? [ BoxShadow( color: Colors.amber.withOpacity(0.7), blurRadius: 14, spreadRadius: 2, ), ] : null, ), child: DraggablePieceWidget( piece: piece, positionIndex: displayPositionIndex, isSelected: isSelected, selectedPositionIndex: isSelected ? displayPositionIndex : state.selectedPositionIndex, longPressDuration: Duration(milliseconds: settings.game.longPressDuration), onSelect: () {
```

### dispose

```dart
void dispose() {
```

