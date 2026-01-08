# Guide des Propriétés UI Flutter - Pentapol

Ce document résume les propriétés Flutter utilisées pour gérer l'interface utilisateur dans le projet Pentapol.

---

## 📐 AppBar

### `leadingWidth`
Largeur maximale allouée au widget `leading` de l'AppBar.

```dart
AppBar(
  leadingWidth: 100,  // Par défaut: 56 (kToolbarHeight)
  leading: Row(...), // Le widget ne peut pas dépasser cette largeur
)
```

**Quand l'utiliser :** Si le `leading` contient plus qu'un simple IconButton (ex: Row avec plusieurs widgets).

### `toolbarHeight`
Hauteur de la barre d'outils de l'AppBar.

```dart
AppBar(
  toolbarHeight: 56.0,  // Par défaut: kToolbarHeight (56)
)
```

### `PreferredSize`
Wrapper pour personnaliser la taille préférée d'un widget dans l'AppBar.

```dart
appBar: PreferredSize(
  preferredSize: const Size.fromHeight(56.0),
  child: AppBar(...),
)
```

---

## 📦 Contraintes et Tailles

### `BoxConstraints`
Définit les contraintes min/max pour un widget.

```dart
IconButton(
  constraints: const BoxConstraints(minWidth: 36, minHeight: 40),
  // Empêche le bouton d'être plus petit que ces dimensions
)
```

### `minimumSize` (ElevatedButton)
Taille minimale d'un bouton.

```dart
ElevatedButton.styleFrom(
  minimumSize: const Size(45, 30),
)
```

### `tapTargetSize`
Contrôle la zone de tap pour les boutons Material.

```dart
ElevatedButton.styleFrom(
  tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Réduit au minimum
  // Autres valeurs: padded (défaut, ajoute du padding)
)
```

---

## 🎯 Layout Flex (Row/Column)

### `mainAxisSize`
Contrôle l'espace occupé sur l'axe principal.

```dart
Row(
  mainAxisSize: MainAxisSize.min,  // Prend le minimum d'espace nécessaire
  // MainAxisSize.max = prend tout l'espace disponible (défaut)
)
```

### `mainAxisAlignment`
Alignement des enfants sur l'axe principal.

```dart
Column(
  mainAxisAlignment: MainAxisAlignment.center,
  // start, end, center, spaceBetween, spaceAround, spaceEvenly
)
```

### `crossAxisAlignment`
Alignement des enfants sur l'axe secondaire.

```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  // start, end, center, stretch, baseline
)
```

### `Expanded` / `Flexible`
Force un enfant à occuper l'espace restant.

```dart
Row(
  children: [
    Expanded(
      flex: 3,  // Ratio d'espace (défaut: 1)
      child: GameBoard(),
    ),
    Expanded(
      flex: 1,
      child: PieceSlider(),
    ),
  ],
)
```

---

## 📱 Responsive Design

### `MediaQuery`
Accès aux dimensions et propriétés de l'écran.

```dart
final screenWidth = MediaQuery.of(context).size.width;
final screenHeight = MediaQuery.of(context).size.height;
final isLandscape = screenWidth > screenHeight;
```

### `LayoutBuilder`
Accès aux contraintes du parent.

```dart
LayoutBuilder(
  builder: (context, constraints) {
    final cellSize = (constraints.maxWidth / visualCols)
        .clamp(0.0, constraints.maxHeight / visualRows);
    return ...;
  },
)
```

### `FittedBox`
Adapte le contenu pour qu'il tienne dans l'espace disponible.

```dart
FittedBox(
  fit: BoxFit.scaleDown,  // Réduit si trop grand, ne grossit pas
  child: Text('Long text...'),
)
```

---

## 🎨 Décoration et Style

### `BoxDecoration`
Décoration complète d'un Container.

```dart
Container(
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: Colors.amber, width: 3),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 20,
        offset: const Offset(0, 4),
        spreadRadius: 2,
      ),
    ],
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Colors.grey.shade50, Colors.grey.shade100],
    ),
  ),
)
```

### `EdgeInsets` (Padding/Margin)
Espacement intérieur ou extérieur.

```dart
Padding(
  padding: const EdgeInsets.all(16),              // Tous les côtés
  padding: const EdgeInsets.symmetric(
    horizontal: 16, 
    vertical: 12,
  ),
  padding: const EdgeInsets.only(bottom: 8),      // Un seul côté
)
```

---

## 🔧 Widgets de Dimensionnement

### `SizedBox`
Boîte de taille fixe ou comme spacer.

```dart
SizedBox(width: 100, height: 50, child: ...),
const SizedBox(height: 8),       // Spacer vertical
const SizedBox.shrink(),         // Widget invisible de taille 0
```

### `Container`
Widget polyvalent avec taille, décoration, padding, etc.

```dart
Container(
  width: 44,
  height: 44,
  padding: const EdgeInsets.all(12),
  decoration: BoxDecoration(...),
  child: ...,
)
```

### `ClipRRect`
Découpe le contenu avec des coins arrondis.

```dart
ClipRRect(
  borderRadius: BorderRadius.circular(16),
  child: Image.asset('...'),
)
```

---

## 📜 Scroll et Listes

### `ListView.builder`
Liste optimisée avec construction à la demande.

```dart
ListView.builder(
  controller: _scrollController,
  scrollDirection: Axis.horizontal,  // ou Axis.vertical (défaut)
  padding: const EdgeInsets.all(16),
  physics: const NeverScrollableScrollPhysics(),  // Désactive le scroll
  itemCount: items.length,
  itemBuilder: (context, index) => ...,
)
```

### `GridView.builder`
Grille optimisée.

```dart
GridView.builder(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 6,        // Nombre de colonnes
    childAspectRatio: 1.0,    // Ratio largeur/hauteur
    crossAxisSpacing: 0,      // Espacement horizontal
    mainAxisSpacing: 0,       // Espacement vertical
  ),
  itemCount: 60,
  itemBuilder: (context, index) => ...,
)
```

### `SingleChildScrollView`
Rend scrollable un enfant unique.

```dart
SingleChildScrollView(
  child: Column(children: [...]),
)
```

---

## 🎭 Animations

### `AnimatedContainer`
Container avec animations automatiques sur changement de propriétés.

```dart
AnimatedContainer(
  duration: const Duration(milliseconds: 150),
  curve: Curves.easeOut,
  height: isExpanded ? 200 : 100,
  color: isActive ? Colors.blue : Colors.grey,
)
```

### `TweenAnimationBuilder`
Animation personnalisée avec valeur interpolée.

```dart
TweenAnimationBuilder<double>(
  tween: Tween(begin: 0.8, end: 1.0),
  duration: const Duration(milliseconds: 200),
  curve: Curves.elasticOut,
  builder: (context, scale, child) {
    return Transform.scale(scale: scale, child: child);
  },
  child: Icon(Icons.star),
)
```

---

## 🖱️ Gestes et Interactions

### `GestureDetector`
Détection de gestes complexes.

```dart
GestureDetector(
  onTap: () => ...,
  onDoubleTap: () => ...,
  onLongPress: () => ...,
  child: ...,
)
```

### `Draggable` / `DragTarget`
Drag & Drop.

```dart
// Source
Draggable<MyData>(
  data: myData,
  feedback: Widget(...),           // Widget affiché pendant le drag
  childWhenDragging: Widget(...),  // Widget affiché à l'emplacement d'origine
  child: Widget(...),
)

// Cible
DragTarget<MyData>(
  onWillAcceptWithDetails: (details) => true,
  onAcceptWithDetails: (details) => handleDrop(details.data),
  onMove: (details) => updatePreview(details.offset),
  onLeave: (data) => clearPreview(),
  builder: (context, candidateData, rejectedData) => ...,
)
```

### `InkWell`
Effet d'ondulation Material au tap.

```dart
Material(
  color: Colors.transparent,
  child: InkWell(
    borderRadius: BorderRadius.circular(20),
    onTap: () => ...,
    child: ...,
  ),
)
```

---

## ⚡ Feedback Haptique

```dart
import 'package:flutter/services.dart';

HapticFeedback.selectionClick();  // Léger (sélection)
HapticFeedback.lightImpact();     // Impact léger
HapticFeedback.mediumImpact();    // Impact moyen
HapticFeedback.heavyImpact();     // Impact fort
```

---

## 📊 Constantes du Projet (GameConstants)

```dart
class GameConstants {
  // Dimensions plateau
  static const int boardWidth = 6;
  static const int boardHeight = 10;
  
  // Bordures
  static const double masterCellBorderWidth = 4.0;
  static const double selectedPieceBorderWidth = 3.0;
  static const double cellBorderWidth = 1.0;
  
  // Slider
  static const double sliderItemSize = 140.0;
  
  // Ombres
  static const double shadowBlurRadius = 10.0;
  static const double shadowOpacity = 0.3;
}
```

---

## 🎨 Paramètres UI Personnalisables (UISettings)

| Propriété | Type | Défaut | Description |
|-----------|------|--------|-------------|
| `colorScheme` | `PieceColorScheme` | `classic` | Palette de couleurs |
| `showPieceNumbers` | `bool` | `true` | Afficher numéros sur pièces |
| `showGridLines` | `bool` | `false` | Afficher grille |
| `enableAnimations` | `bool` | `true` | Activer animations |
| `pieceOpacity` | `double` | `1.0` | Opacité des pièces |
| `iconSize` | `double` | `48.0` | Taille des icônes |

---

## 🔗 Références

- [Flutter Layout Cheat Sheet](https://medium.com/flutter-community/flutter-layout-cheat-sheet-5363348d037e)
- [Material Design Guidelines](https://m3.material.io/)
- [Flutter Widget Catalog](https://flutter.dev/docs/development/ui/widgets)

