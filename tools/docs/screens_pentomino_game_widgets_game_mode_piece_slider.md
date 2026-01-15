# screens/pentomino_game/widgets/game_mode/piece_slider.dart

**Module:** screens

## Fonctions

### PieceSlider

Slider de pièces disponibles

Affiche les pièces non encore placées dans un slider infini.
- Portrait: horizontal en bas
- Paysage: vertical à droite


```dart
const PieceSlider({
```

### createState

```dart
ConsumerState<PieceSlider> createState() => _PieceSliderState();
```

### dispose

```dart
void dispose() {
```

### build

```dart
Widget build(BuildContext context) {
```

### SizedBox

Construit une pièce draggable


```dart
return SizedBox( width: fixedSize, height: fixedSize, child: Center( child: Container( decoration: BoxDecoration( boxShadow: isSelected ? [ BoxShadow( color: Colors.amber.withOpacity(0.7), blurRadius: 14, spreadRadius: 2, ), ] : null, ), child: DraggablePieceWidget( piece: piece, positionIndex: positionIndex, isSelected: isSelected, selectedPositionIndex: state.selectedPositionIndex, longPressDuration: Duration(milliseconds: settings.game.longPressDuration), onSelect: () {
```

