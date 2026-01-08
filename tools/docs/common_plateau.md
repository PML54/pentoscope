# common/plateau.dart

**Module:** common

## Fonctions

### Plateau

```dart
const Plateau({
```

### Plateau

```dart
return Plateau( width: width, height: height, grid: List.generate( height, (_) => List.filled(width, -1), ), );
```

### Plateau

```dart
return Plateau( width: width, height: height, grid: List.generate( height, (_) => List.filled(width, 0), ), );
```

### isInBounds

```dart
bool isInBounds(int x, int y) {
```

### getCell

```dart
int getCell(int x, int y) {
```

### setCell

```dart
void setCell(int x, int y, int value) {
```

### copy

```dart
Plateau copy() {
```

### Plateau

```dart
return Plateau( width: width, height: height, grid: grid.map((row) => List<int>.from(row)).toList(), );
```

