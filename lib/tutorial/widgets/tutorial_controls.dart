// lib/tutorial/widgets/tutorial_controls.dart
// Contrôles pour gérer l'exécution du tutoriel

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pentapol/tutorial/providers/tutorial_provider.dart';

/// Contrôles flottants pour le tutoriel
class TutorialControls extends ConsumerWidget {
  const TutorialControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tutorialState = ref.watch(tutorialProvider);
    final notifier = ref.read(tutorialProvider.notifier);

    // Ne rien afficher si pas de tutoriel chargé
    if (!tutorialState.isLoaded) {
      return const SizedBox.shrink();
    }

    return Positioned(
      bottom: 16,
      right: 16,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: tutorialState.isRunning
              ? _RunningControls(
            isPaused: tutorialState.isPaused,
            onPause: () => notifier.pause(),
            onResume: () => notifier.resume(),
            onStop: () => notifier.stop(),
            onRestart: () => notifier.restart(),
            onQuit: () => notifier.quit(),
          )
              : tutorialState.isCompleted
              ? _CompletedControls(
            onRestart: () => notifier.restart(),
            onQuit: () => notifier.quit(),
          )
              : _LoadedControls(
            onStart: () => notifier.start(),
            onCancel: () => notifier.unloadScript(),
          ),
        ),
      ),
    );
  }
}

/// Contrôles quand le tutoriel est chargé mais pas démarré
class _LoadedControls extends StatelessWidget {
  final VoidCallback onStart;
  final VoidCallback onCancel;

  const _LoadedControls({required this.onStart, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Bouton Démarrer
        IconButton(
          icon: const Icon(Icons.play_arrow, size: 32),
          color: Colors.green[700],
          tooltip: 'Démarrer le tutoriel',
          onPressed: onStart,
        ),

        const SizedBox(width: 4),

        // Bouton Annuler
        IconButton(
          icon: const Icon(Icons.close, size: 28),
          color: Colors.red[700],
          tooltip: 'Annuler',
          onPressed: onCancel,
        ),
      ],
    );
  }
}

/// Contrôles quand le tutoriel est terminé
class _CompletedControls extends StatelessWidget {
  final VoidCallback onRestart;
  final VoidCallback onQuit;

  const _CompletedControls({
    required this.onRestart,
    required this.onQuit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Message de confirmation
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: Colors.green[700], size: 20),
              const SizedBox(width: 8),
              Text(
                'Tutorial terminé !',
                style: TextStyle(
                  color: Colors.green[700],
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Boutons d'actions
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Bouton Recommencer
            IconButton(
              icon: const Icon(Icons.replay, size: 32),
              color: Colors.blue[700],
              tooltip: 'Recommencer le tutoriel',
              onPressed: onRestart,
            ),

            const SizedBox(width: 8),

            // Bouton Fermer/Quitter
            IconButton(
              icon: const Icon(Icons.close, size: 32),
              color: Colors.red[700],
              tooltip: 'Fermer le tutoriel',
              onPressed: onQuit,
            ),
          ],
        ),
      ],
    );
  }
}

/// Contrôles quand le tutoriel est en cours
class _RunningControls extends StatelessWidget {
  final bool isPaused;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onStop;
  final VoidCallback onRestart;
  final VoidCallback onQuit; // 🆕 Callback Quit

  const _RunningControls({
    required this.isPaused,
    required this.onPause,
    required this.onResume,
    required this.onStop,
    required this.onRestart,
    required this.onQuit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Bouton Play/Pause
        IconButton(
          icon: Icon(isPaused ? Icons.play_arrow : Icons.pause, size: 28),
          color: Colors.blue[700],
          tooltip: isPaused ? 'Reprendre' : 'Pause',
          onPressed: isPaused ? onResume : onPause,
        ),

        const SizedBox(width: 4),

        // Bouton Redémarrer
        IconButton(
          icon: const Icon(Icons.restart_alt, size: 28),
          color: Colors.orange[700],
          tooltip: 'Redémarrer',
          onPressed: onRestart,
        ),

        const SizedBox(width: 4),

        // Bouton Stop
        IconButton(
          icon: const Icon(Icons.stop, size: 28),
          color: Colors.red[700],
          tooltip: 'Arrêter',
          onPressed: onStop,
        ),

        const SizedBox(width: 4),

        // 🆕 Bouton Quit (Quitter le tutoriel)
        IconButton(
          icon: const Icon(Icons.exit_to_app, size: 28),
          color: Colors.grey[700],
          tooltip: 'Quitter le tutoriel',
          onPressed: onQuit,
        ),
      ],
    );
  }
}