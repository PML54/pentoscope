# duel/widgets/opponent_piece_overlay.dart

**Module:** duel

## Fonctions

### OpponentPieceOverlay

Widget qui affiche des hachures sur une pièce adverse


```dart
const OpponentPieceOverlay({
```

### build

```dart
Widget build(BuildContext context) {
```

### Stack

```dart
return Stack( children: [ child, Positioned.fill( child: CustomPaint( painter: _HatchPainter( color: hatchColor.withOpacity(0.3), strokeWidth: hatchWidth, spacing: hatchSpacing, ), ), ), ], );
```

### paint

Painter pour dessiner des hachures diagonales


```dart
void paint(Canvas canvas, Size size) {
```

### shouldRepaint

```dart
bool shouldRepaint(covariant _HatchPainter oldDelegate) {
```

