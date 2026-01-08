# tutorial/models/tutorial_state.dart

**Module:** tutorial

## Fonctions

### TutorialState

État d'un tutoriel
Script actuellement chargé
Interpréteur en cours
Contexte d'exécution
Le tutoriel est-il en cours d'exécution ?
Le tutoriel est-il en pause ?
Index de l'étape courante
Message actuel affiché
Script chargé mais pas encore démarré
Nom du script (pour affichage)
💾 État du jeu sauvegardé avant le tutorial (pour restauration au quit)


```dart
const TutorialState({
```

### copyWith

État initial
Le tutoriel est-il terminé ?
Calcule le progrès (0.0 à 1.0)
Nombre total d'étapes
Copie avec modifications


```dart
TutorialState copyWith({
```

### TutorialState

```dart
return TutorialState( currentScript: clearCurrentScript ? null : (currentScript ?? this.currentScript), interpreter: clearInterpreter ? null : (interpreter ?? this.interpreter), context: clearContext ? null : (context ?? this.context), isRunning: isRunning ?? this.isRunning, isPaused: isPaused ?? this.isPaused, currentStep: currentStep ?? this.currentStep, currentMessage: clearCurrentMessage ? null : (currentMessage ?? this.currentMessage), isLoaded: isLoaded ?? this.isLoaded, scriptName: clearScriptName ? null : (scriptName ?? this.scriptName), savedGameState: clearSavedGameState ? null : (savedGameState ?? this.savedGameState), );
```

