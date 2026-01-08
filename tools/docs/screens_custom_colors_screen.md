# screens/custom_colors_screen.dart

**Module:** screens

## Fonctions

### CustomColorsScreen

```dart
const CustomColorsScreen({super.key});
```

### createState

```dart
ConsumerState<CustomColorsScreen> createState() => _CustomColorsScreenState();
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
return Scaffold( appBar: AppBar( title: const Text('Couleurs personnalisées'), actions: [ IconButton( icon: const Icon(Icons.check), tooltip: 'Enregistrer', onPressed: () async {
```

### Card

```dart
return Card( margin: const EdgeInsets.only(bottom: 12), child: ListTile( leading: PieceIcon( pieceId: pieceId, color: _colors[index], ), title: Text('Pièce $pieceName (#$pieceId)'), subtitle: Column( crossAxisAlignment: CrossAxisAlignment.start, children: [ Text(getColorHex(_colors[index])), const SizedBox(height: 4), PiecePreview( piece: piece, color: _colors[index], ), ], ), trailing: const Icon(Icons.edit), onTap: () => _showColorPicker(index, pieceName), ), );
```

### SizedBox

```dart
const SizedBox(height: 4), PiecePreview( piece: piece, color: _colors[index], ), ], ), trailing: const Icon(Icons.edit), onTap: () => _showColorPicker(index, pieceName), ), );
```

### GestureDetector

```dart
return GestureDetector( onTap: () {
```

