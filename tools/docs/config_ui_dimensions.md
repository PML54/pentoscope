# config/ui_dimensions.dart

**Module:** config

## Fonctions

### BoardDimensions

Type d'appareil détecté
Orientation de l'écran
Dimensions du plateau de jeu
Taille d'une cellule du plateau (en pixels)
Largeur totale du plateau (cellSize × colonnes)
Hauteur totale du plateau (cellSize × lignes)
Marge horizontale autour du plateau
Épaisseur de la bordure
Rayon des coins arrondis
Nombre de colonnes visuelles
Nombre de lignes visuelles


```dart
const BoardDimensions({
```

### SliderDimensions

Dimensions par défaut (fallback)
Dimensions du slider de pièces
Largeur du slider (en paysage) ou null
Hauteur du slider (en portrait) ou null
Taille fixe d'un item (carré 5×5 pour contenir toute pièce)
Taille d'une cellule de pièce dans le slider
Padding entre les pièces
Padding global du slider


```dart
const SliderDimensions({
```

### ActionBarDimensions

Dimensions par défaut
Dimensions des barres d'actions (isométries, fonctionnement)
Largeur de la colonne d'actions (en paysage)
Taille des icônes
Padding autour de chaque icône
Espacement vertical entre les icônes
Taille minimale de la zone cliquable
Contraintes pour les IconButton


```dart
const ActionBarDimensions({
```

### TextDimensions

Dimensions par défaut
Dimensions typographiques
Taille police du chronomètre
Taille police du score
Taille police des labels généraux
Taille police des numéros de pièces (sur le plateau)


```dart
const TextDimensions({
```

### UILayout

Dimensions par défaut
Container principal regroupant toutes les dimensions UI
Type d'appareil détecté
Orientation actuelle
Facteur d'échelle global (1.0 = phone, 1.2 = tablet, 1.4 = largeTablet)
Dimensions du plateau
Dimensions du slider
Dimensions de la barre d'actions
Dimensions typographiques
Largeur de l'écran
Hauteur de l'écran


```dart
const UILayout({
```

