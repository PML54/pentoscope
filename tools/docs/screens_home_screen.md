# screens/home_screen.dart

**Module:** screens

## Fonctions

### HomeScreen

```dart
const HomeScreen({super.key});
```

### build

```dart
Widget build(BuildContext context, WidgetRef ref) {
```

### Scaffold

```dart
return Scaffold( body: Container( decoration: BoxDecoration( gradient: LinearGradient( begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [ colorScheme.primaryContainer.withOpacity(0.9), colorScheme.surface, ], ), ), child: SafeArea( child: Padding( padding: const EdgeInsets.all(16), child: Column( crossAxisAlignment: CrossAxisAlignment.start, children: [ // HEADER Row( children: [ _AppLogo(color: colorScheme.primary), const SizedBox(width: 12), Expanded( child: Column( crossAxisAlignment: CrossAxisAlignment.start, children: [ Text( 'Pentapolis', style: theme.textTheme.headlineMedium?.copyWith( fontWeight: FontWeight.bold, color: colorScheme.onPrimaryContainer, ), ), const SizedBox(height: 4), Text( 'La cité des pentominos', style: theme.textTheme.bodyMedium?.copyWith( color: colorScheme.onPrimaryContainer.withOpacity( 0.8, ), ), ), ], ), ), ], ),  const SizedBox(height: 24),  // CONTENU PRINCIPAL : CARTES DE MENU Expanded( child: SingleChildScrollView( child: Column( children: [ const SizedBox(height: 12), _MenuCard( icon: Icons.search, title: 'Pentominos Speed', subtitle: 'Placer de 3 à 6 pieces', color: colorScheme.secondary, onTap: () {
```

### SizedBox

```dart
const SizedBox(width: 12), Expanded( child: Column( crossAxisAlignment: CrossAxisAlignment.start, children: [ Text( 'Pentapolis', style: theme.textTheme.headlineMedium?.copyWith( fontWeight: FontWeight.bold, color: colorScheme.onPrimaryContainer, ), ), const SizedBox(height: 4), Text( 'La cité des pentominos', style: theme.textTheme.bodyMedium?.copyWith( color: colorScheme.onPrimaryContainer.withOpacity( 0.8, ), ), ), ], ), ), ], ),  const SizedBox(height: 24),  // CONTENU PRINCIPAL : CARTES DE MENU Expanded( child: SingleChildScrollView( child: Column( children: [ const SizedBox(height: 12), _MenuCard( icon: Icons.search, title: 'Pentominos Speed', subtitle: 'Placer de 3 à 6 pieces', color: colorScheme.secondary, onTap: () {
```

### SizedBox

```dart
const SizedBox(height: 4), Text( 'La cité des pentominos', style: theme.textTheme.bodyMedium?.copyWith( color: colorScheme.onPrimaryContainer.withOpacity( 0.8, ), ), ), ], ), ), ], ),  const SizedBox(height: 24),  // CONTENU PRINCIPAL : CARTES DE MENU Expanded( child: SingleChildScrollView( child: Column( children: [ const SizedBox(height: 12), _MenuCard( icon: Icons.search, title: 'Pentominos Speed', subtitle: 'Placer de 3 à 6 pieces', color: colorScheme.secondary, onTap: () {
```

### SizedBox

```dart
const SizedBox(height: 24),  // CONTENU PRINCIPAL : CARTES DE MENU Expanded( child: SingleChildScrollView( child: Column( children: [ const SizedBox(height: 12), _MenuCard( icon: Icons.search, title: 'Pentominos Speed', subtitle: 'Placer de 3 à 6 pieces', color: colorScheme.secondary, onTap: () {
```

### SizedBox

```dart
const SizedBox(height: 12), _MenuCard( icon: Icons.search, title: 'Pentominos Speed', subtitle: 'Placer de 3 à 6 pieces', color: colorScheme.secondary, onTap: () {
```

### SizedBox

```dart
const SizedBox(height: 12), _MenuCard( icon: Icons.extension, title: 'Pentominos Classique', subtitle: '9356 Solutions', color: colorScheme.primary, onTap: () {
```

### SizedBox

```dart
const SizedBox(height: 12), _MenuCard( icon: Icons.sports_kabaddi, title: 'Duel Isométries', subtitle: 'Affronte un autre joueur ', color: colorScheme.tertiary, onTap: () {
```

### SizedBox

```dart
const SizedBox(height: 12), _MenuCard( icon: Icons.settings, title: 'Réglages', subtitle: 'Thème, options, préférences', color: colorScheme.surfaceVariant, foregroundOnColor: colorScheme.onSurfaceVariant, onTap: () {
```

### SizedBox

```dart
const SizedBox(height: 8), FloatingActionButton( onPressed: () {
```

### build

Petit logo abstrait en forme de pentomino stylisé


```dart
Widget build(BuildContext context) {
```

### Material

```dart
return Material( elevation: 4, shape: const CircleBorder(), child: Container( width: 52, height: 52, decoration: BoxDecoration(color: color, shape: BoxShape.circle), child: Center(child: Icon(Icons.grid_view, color: Colors.white)), ), );
```

### build

Carte de menu réutilisable


```dart
Widget build(BuildContext context) {
```

### Material

```dart
return Material( color: Colors.transparent, child: InkWell( borderRadius: BorderRadius.circular(20), onTap: onTap, child: Ink( decoration: BoxDecoration( color: color, borderRadius: BorderRadius.circular(20), boxShadow: [ BoxShadow( blurRadius: 8, offset: const Offset(0, 4), color: Colors.black.withOpacity(0.12), ), ], ), child: Padding( padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16), child: Row( children: [ Container( width: 44, height: 44, decoration: BoxDecoration( color: fg.withOpacity(0.12), borderRadius: BorderRadius.circular(14), ), child: Icon(icon, color: fg, size: 26), ), const SizedBox(width: 16), Expanded( child: Column( crossAxisAlignment: CrossAxisAlignment.start, children: [ Text( title, style: theme.textTheme.titleMedium?.copyWith( fontWeight: FontWeight.w700, color: fg, ), ), const SizedBox(height: 4), Text( subtitle, style: theme.textTheme.bodySmall?.copyWith( color: fg.withOpacity(0.85), ), ), ], ), ), const Icon(Icons.chevron_right, size: 24), ], ), ), ), ), );
```

### SizedBox

```dart
const SizedBox(width: 16), Expanded( child: Column( crossAxisAlignment: CrossAxisAlignment.start, children: [ Text( title, style: theme.textTheme.titleMedium?.copyWith( fontWeight: FontWeight.w700, color: fg, ), ), const SizedBox(height: 4), Text( subtitle, style: theme.textTheme.bodySmall?.copyWith( color: fg.withOpacity(0.85), ), ), ], ), ), const Icon(Icons.chevron_right, size: 24), ], ), ), ), ), );
```

### SizedBox

```dart
const SizedBox(height: 4), Text( subtitle, style: theme.textTheme.bodySmall?.copyWith( color: fg.withOpacity(0.85), ), ), ], ), ), const Icon(Icons.chevron_right, size: 24), ], ), ), ), ), );
```

### Icon

```dart
const Icon(Icons.chevron_right, size: 24), ], ), ), ), ), );
```

