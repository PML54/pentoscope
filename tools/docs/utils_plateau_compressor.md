# utils/plateau_compressor.dart

**Module:** utils

## Fonctions

### encode

Utilitaire pour compresser et canoniser les plateaux de pentomino.

Permet de:
- Encoder un plateau en 8 int32 (240 bits, 4 bits par cellule)
- Générer les 8 variantes (rotations + miroirs)
- Trouver la forme canonique (la plus petite numériquement)
- Détecter les doublons
Compresseur de plateau avec détection de forme canonique.
Encode un plateau en List<int> compact (8 int32 = 240 bits).

Chaque cellule utilise 4 bits (0-15):
- 0: vide
- 1-12: numéro de pièce
- 13: cellule cachée


```dart
static List<int> encode(Plateau plateau) {
```

### decode

Décode un List<int> compact en Plateau.


```dart
static Plateau decode(List<int> encoded) {
```

### rotate90

Rotation 90° horaire.
Transformation: (x, y) → (9-y, x)
où x ∈ [0,5] et y ∈ [0,9]


```dart
static List<int> rotate90(List<int> encoded) {
```

### encode

```dart
return encode(rotated);
```

### rotate180

Rotation 180°.


```dart
static List<int> rotate180(List<int> encoded) {
```

### rotate90

```dart
return rotate90(rotate90(encoded));
```

### rotate270

Rotation 270° horaire.


```dart
static List<int> rotate270(List<int> encoded) {
```

### rotate90

```dart
return rotate90(rotate180(encoded));
```

### mirrorH

Miroir horizontal.
Transformation: (x, y) → (5-x, y)


```dart
static List<int> mirrorH(List<int> encoded) {
```

### encode

```dart
return encode(mirrored);
```

### compare

Génère les 8 variantes équivalentes (4 rotations × 2 miroirs).
Compare deux encodages (ordre lexicographique).

Retourne:
- < 0 si a < b
- 0 si a == b
- > 0 si a > b


```dart
static int compare(List<int> a, List<int> b) {
```

### findCanonical

Trouve la forme canonique (la plus petite numériquement) parmi les 8 variantes.


```dart
static List<int> findCanonical(List<int> encoded) {
```

### toDebugString

Convertit un List<int> en String pour débogage.


```dart
static String toDebugString(List<int> encoded) {
```

### areEquivalent

Vérifie si deux encodages sont équivalents (même forme canonique).


```dart
static bool areEquivalent(List<int> a, List<int> b) {
```

### compare

```dart
return compare(canonicalA, canonicalB) == 0;
```

