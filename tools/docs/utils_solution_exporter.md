# utils/solution_exporter.dart

**Module:** utils

## Fonctions

### empty

Représente une solution de pentomino comme une grille 6x10
Chaque cellule contient le numéro de la pièce (1-12) qui l'occupe
Crée une grille vide 6x10


```dart
static PentominoSolution empty() {
```

### PentominoSolution

```dart
return PentominoSolution( List.generate(10, (_) => List<int>.filled(6, 0)) );
```

### toString

Convertit en string pour affichage


```dart
String toString() {
```

### addSolution

Classe pour exporter les solutions vers un fichier
Ajoute une solution à la collection


```dart
void addSolution(PentominoSolution solution) {
```

### saveToFile

Sauvegarde toutes les solutions dans le fichier


```dart
Future<void> saveToFile() async {
```

### saveCompact

Sauvegarde avec format compact (une solution par ligne)


```dart
Future<void> saveCompact() async {
```

### saveDartCode

Sauvegarde au format Dart (tableau constant)


```dart
Future<void> saveDartCode() async {
```

### placementsToGrid

Fonction utilitaire pour convertir une List<PlacementInfo> en grille
Cette fonction doit être adaptée selon ta structure PlacementInfo


```dart
PentominoSolution placementsToGrid(List<dynamic> placements, int width, int height) {
```

### PentominoSolution

```dart
return PentominoSolution(grid);
```

### main

```dart
void main() async {
```

