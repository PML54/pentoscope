# tutorial/models/tutorial_context.dart

**Module:** tutorial

## Fonctions

### setMessage

Contexte d'exécution d'un tutoriel
Notifier du jeu (accès aux méthodes de manipulation)
Ref Riverpod (pour accéder à d'autres providers si besoin)
Variables du script (pour stocker des valeurs temporaires)
Message actuel affiché
État de pause
État d'annulation
Affiche un message


```dart
void setMessage(String text) {
```

### clearMessage

Efface le message


```dart
void clearMessage() {
```

### setVariable

Définit une variable


```dart
void setVariable(String name, dynamic value) {
```

### getVariable

Récupère une variable


```dart
dynamic getVariable(String name) {
```

### incrementVariable

Incrémente une variable numérique


```dart
void incrementVariable(String name) {
```

### pause

Met en pause l'exécution


```dart
void pause() {
```

### resume

Reprend l'exécution


```dart
void resume() {
```

### cancel

Annule l'exécution


```dart
void cancel() {
```

### waitIfPaused

Attend que le tutoriel ne soit plus en pause


```dart
Future<void> waitIfPaused() async {
```

