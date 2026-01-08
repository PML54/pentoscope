# services/pentomino_solver.dart

**Module:** services

## Fonctions

### hasSolution

```dart
bool hasSolution(Plateau plateau, List<Pento> pieces) {
```

### findSolution

```dart
return findSolution(plateau, pieces) != null;
```

### ArgumentError

Constructeur permettant de spécifier l'ordre des pièces par leurs IDs (1-12)


```dart
throw ArgumentError('Pièce avec id=$id introuvable');
```

### areIsolatedRegionsValid

```dart
bool areIsolatedRegionsValid() {
```

### backtrack

```dart
bool backtrack() {
```

### backtrackFromPosition

```dart
bool backtrackFromPosition( int skipPieceIndex, int skipOrientation, int skipTargetCell, ) {
```

### backtrack

```dart
return backtrack();
```

### canAnyAvailablePieceFitRegion

```dart
bool canAnyAvailablePieceFitRegion(List<Point> region) {
```

### canPlaceWithOffset

```dart
bool canPlaceWithOffset( List<int> shape, int offsetX, int offsetY, List<int> occupiedCells, ) {
```

### countAllSolutions

```dart
Future<int> countAllSolutions({
```

### countRecursive

```dart
Future<void> countRecursive() async {
```

### countRecursive

```dart
await countRecursive();
```

### countRecursive

```dart
await countRecursive();
```

### Function

Trouve toutes les solutions et les retourne
Utile pour la normalisation


```dart
void Function(int count, int elapsedSeconds)? onProgress, int? maxSolutions, }) async {
```

### searchRecursive

```dart
Future<void> searchRecursive() async {
```

### searchRecursive

```dart
await searchRecursive();
```

### searchRecursive

```dart
await searchRecursive();
```

### findSmallestFreeCell

```dart
int findSmallestFreeCell() {
```

### floodFillAndCollect

```dart
int floodFillAndCollect( int x, int y, List<List<bool>> visited, List<Point> region, ) {
```

### placeWithOffset

```dart
void placeWithOffset(List<int> shape, int offsetX, int offsetY) {
```

### removeWithOffset

```dart
void removeWithOffset(List<int> shape, int offsetX, int offsetY) {
```

### stopCounting

Demande l'arrêt du comptage en cours


```dart
void stopCounting() {
```

### tryNextPlacements

```dart
bool tryNextPlacements( int pieceIndex, int startTargetCell, int startOrientation, ) {
```

### toString

```dart
String toString() {
```

