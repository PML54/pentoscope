# config/ui_layout_manager.dart

**Module:** config

## Fonctions

### calculate

Gestionnaire centralisé pour calculer toutes les dimensions UI

Utilisation:
```dart
final layout = UILayoutManager.calculate(
screenWidth: MediaQuery.of(context).size.width,
screenHeight: MediaQuery.of(context).size.height,
boardCols: 6,
boardRows: 10,
);
```
Taille de base d'une icône (téléphone)
Taille de base d'une cellule de pièce dans le slider
Hauteur de base du slider en portrait
Largeur de base de la colonne d'actions
Épaisseur de bordure du plateau
Rayon des coins du plateau
Marge horizontale du plateau en portrait
Calcule toutes les dimensions UI en fonction de l'écran et du plateau

[screenWidth] - Largeur de l'écran disponible
[screenHeight] - Hauteur de l'écran disponible
[boardCols] - Nombre de colonnes logiques du plateau (ex: 6)
[boardRows] - Nombre de lignes logiques du plateau (ex: 10)
[safeAreaTop] - Hauteur de la safe area en haut (optionnel)
[safeAreaBottom] - Hauteur de la safe area en bas (optionnel)


```dart
static UILayout calculate({
```

### UILayout

```dart
return UILayout( deviceType: deviceType, orientation: orientation, scaleFactor: scaleFactor, board: board, slider: slider, actionBar: actionBar, text: text, screenWidth: screenWidth, screenHeight: screenHeight, );
```

### ActionBarDimensions

Détecte le type d'appareil selon la plus petite dimension
Retourne le facteur d'échelle selon le type d'appareil
Calcule les dimensions de la barre d'actions


```dart
return ActionBarDimensions( width: width, iconSize: iconSize, iconPadding: EdgeInsets.all(iconSize * 0.25), iconSpacing: iconSpacing, buttonMinSize: buttonMinSize, );
```

### SliderDimensions

Calcule les dimensions du slider de pièces


```dart
return SliderDimensions( width: width, height: height, itemSize: itemSize, pieceCellSize: pieceCellSize, itemPadding: itemPadding, sliderPadding: sliderPadding, );
```

### BoardDimensions

Calcule les dimensions du plateau


```dart
return BoardDimensions( cellSize: cellSize, width: boardWidth.toDouble(), height: boardHeight.toDouble(), horizontalMargin: horizontalMargin, borderWidth: _boardBorderWidth, borderRadius: _boardBorderRadius, visualCols: visualCols, visualRows: visualRows, );
```

### TextDimensions

Calcule les dimensions typographiques


```dart
return TextDimensions( timerFontSize: (14 * scaleFactor).clamp(12.0, 20.0), scoreFontSize: (18 * scaleFactor).clamp(14.0, 28.0), labelFontSize: (12 * scaleFactor).clamp(10.0, 18.0), pieceNumberFontSize: (14 * scaleFactor).clamp(12.0, 20.0), );
```

### fromContext

Calcule le layout à partir d'un BuildContext

Pratique pour un usage direct dans un widget :
```dart
final layout = UILayoutManager.fromContext(context);
```


```dart
static UILayout fromContext( BuildContext context, {
```

### calculate

```dart
return calculate( screenWidth: mediaQuery.size.width, screenHeight: mediaQuery.size.height, boardCols: boardCols, boardRows: boardRows, safeAreaTop: mediaQuery.padding.top, safeAreaBottom: mediaQuery.padding.bottom, );
```

### fromConstraints

Calcule le layout à partir de BoxConstraints (LayoutBuilder)

Pratique dans un LayoutBuilder :
```dart
LayoutBuilder(
builder: (context, constraints) {
final layout = UILayoutManager.fromConstraints(constraints);
return ...;
},
)
```


```dart
static UILayout fromConstraints( BoxConstraints constraints, {
```

### calculate

```dart
return calculate( screenWidth: constraints.maxWidth, screenHeight: constraints.maxHeight, boardCols: boardCols, boardRows: boardRows, );
```

