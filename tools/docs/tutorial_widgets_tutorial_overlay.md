# tutorial/widgets/tutorial_overlay.dart

**Module:** tutorial

## Fonctions

### TutorialOverlay

Overlay qui s'affiche par-dessus le jeu pendant les tutoriels


```dart
const TutorialOverlay({super.key});
```

### build

```dart
Widget build(BuildContext context, WidgetRef ref) {
```

### Stack

```dart
return Stack( children: [ // Message en haut (seulement pendant l'exécution, PAS à la fin) if (tutorialState.currentMessage != null && !tutorialState.isCompleted) Positioned( top: 16, left: 16, right: 16, child: _MessageBox(message: tutorialState.currentMessage!), ), ], );
```

### build

Message de fin de tutorial


```dart
Widget build(BuildContext context) {
```

### Material

```dart
return Material( elevation: 8, borderRadius: BorderRadius.circular(12), color: Colors.green[700], child: Container( padding: const EdgeInsets.all(16), child: Row( children: [ const Icon(Icons.check_circle, color: Colors.white, size: 36), const SizedBox(width: 16), Expanded( child: Column( crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [ const Text( 'Félicitations ! 🎉', style: TextStyle( color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, ), ), const SizedBox(height: 4), Text( 'Tutorial "$scriptName" terminé avec succès !', style: const TextStyle( color: Colors.white, fontSize: 14, ), ), ], ), ), ], ), ), );
```

### Icon

```dart
const Icon(Icons.check_circle, color: Colors.white, size: 36), const SizedBox(width: 16), Expanded( child: Column( crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [ const Text( 'Félicitations ! 🎉', style: TextStyle( color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, ), ), const SizedBox(height: 4), Text( 'Tutorial "$scriptName" terminé avec succès !', style: const TextStyle( color: Colors.white, fontSize: 14, ), ), ], ), ), ], ), ), );
```

### SizedBox

```dart
const SizedBox(width: 16), Expanded( child: Column( crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [ const Text( 'Félicitations ! 🎉', style: TextStyle( color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, ), ), const SizedBox(height: 4), Text( 'Tutorial "$scriptName" terminé avec succès !', style: const TextStyle( color: Colors.white, fontSize: 14, ), ), ], ), ), ], ), ), );
```

### Text

```dart
const Text( 'Félicitations ! 🎉', style: TextStyle( color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, ), ), const SizedBox(height: 4), Text( 'Tutorial "$scriptName" terminé avec succès !', style: const TextStyle( color: Colors.white, fontSize: 14, ), ), ], ), ), ], ), ), );
```

### SizedBox

```dart
const SizedBox(height: 4), Text( 'Tutorial "$scriptName" terminé avec succès !', style: const TextStyle( color: Colors.white, fontSize: 14, ), ), ], ), ), ], ), ), );
```

### build

Boîte de message


```dart
Widget build(BuildContext context) {
```

### Material

```dart
return Material( elevation: 8, borderRadius: BorderRadius.circular(12), color: Colors.blue[700], child: Container( padding: const EdgeInsets.all(16), child: Row( children: [ const Icon(Icons.lightbulb_outline, color: Colors.white, size: 32), const SizedBox(width: 16), Expanded( child: Text( message, style: const TextStyle( color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500, ), ), ), ], ), ), );
```

### Icon

```dart
const Icon(Icons.lightbulb_outline, color: Colors.white, size: 32), const SizedBox(width: 16), Expanded( child: Text( message, style: const TextStyle( color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500, ), ), ), ], ), ), );
```

### SizedBox

```dart
const SizedBox(width: 16), Expanded( child: Text( message, style: const TextStyle( color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500, ), ), ), ], ), ), );
```

### build

Barre de progression


```dart
Widget build(BuildContext context) {
```

### Material

```dart
return Material( elevation: 4, borderRadius: BorderRadius.circular(8), color: Colors.white, child: Padding( padding: const EdgeInsets.all(12), child: Column( mainAxisSize: MainAxisSize.min, children: [ // Texte étape courante Text( 'Étape $currentStep / $totalSteps', style: TextStyle( color: Colors.grey[700], fontSize: 14, fontWeight: FontWeight.w500, ), ), const SizedBox(height: 8),  // Barre de progression ClipRRect( borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator( value: progress, minHeight: 8, backgroundColor: Colors.grey[300], valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[700]!), ), ), ], ), ), );
```

### SizedBox

```dart
const SizedBox(height: 8),  // Barre de progression ClipRRect( borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator( value: progress, minHeight: 8, backgroundColor: Colors.grey[300], valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[700]!), ), ), ], ), ), );
```

