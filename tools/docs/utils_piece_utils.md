# utils/piece_utils.dart

**Module:** utils

## Fonctions

### getPieceName

Noms des pièces selon leur ID (nomenclature standard des pentominos)
Obtenir le nom d'une pièce selon son ID


```dart
String getPieceName(int pieceId) {
```

### getDefaultPieceColor

Couleurs par défaut des pièces (schéma classique)
Obtenir la couleur par défaut d'une pièce


```dart
Color getDefaultPieceColor(int pieceId) {
```

### PiecePreview

Widget pour afficher l'aperçu d'une pièce


```dart
const PiecePreview({
```

### build

```dart
Widget build(BuildContext context) {
```

### SizedBox

```dart
return SizedBox( width: width * cellSize, height: height * cellSize, child: Stack( children: baseShape.map((cellNum) {
```

### Positioned

```dart
return Positioned( left: (x - minX) * cellSize, top: (y - minY) * cellSize, child: Container( width: cellSize, height: cellSize, decoration: BoxDecoration( color: color.withValues(alpha: 0.7), border: showBorder ? Border.all(color: Colors.white, width: 1) : null, borderRadius: BorderRadius.circular(2), ), ), );
```

### PieceIcon

Widget pour afficher une pièce avec sa lettre


```dart
const PieceIcon({
```

### build

```dart
Widget build(BuildContext context) {
```

### Container

```dart
return Container( width: size, height: size, decoration: BoxDecoration( color: color, borderRadius: BorderRadius.circular(8), border: showBorder ? Border.all(color: Colors.grey.shade400, width: 2) : null, ), child: Center( child: Text( pieceName, style: TextStyle( color: color.computeLuminance() > 0.5 ? Colors.black : Colors.white, fontWeight: FontWeight.bold, fontSize: size * 0.5, ), ), ), );
```

### getColorHex

Obtenir le code couleur hexadécimal d'une couleur


```dart
String getColorHex(Color color) {
```

### getPredefinedColors

Palette de couleurs prédéfinies pour le sélecteur


```dart
List<Color> getPredefinedColors() {
```

