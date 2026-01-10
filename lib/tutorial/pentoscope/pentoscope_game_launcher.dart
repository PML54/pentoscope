import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pentapol/pentoscope/screens/pentoscope_game_screen.dart';
import 'package:pentapol/tutorial/pentoscope/screens/pentoscope_game_with_tutorial_screen.dart';

import 'package:pentapol/providers/settings_provider.dart';

class PentoscopeGameLauncher extends ConsumerWidget {
  const PentoscopeGameLauncher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    // ✅ Adapte ce getter à TON settings model.
    // Idée: afficher le tuto si l’utilisateur n’a pas encore validé "tuto vu".
    //
    // Exemple attendu (à créer si besoin) :
    // final bool showTutorial = settings.tutorials.showPentoscopeTutorial;
    //
    // Fallback: si tu n’as rien encore, mets false (jeu direct).
    final bool showTutorial = _tryGetShowTutorial(settings) ?? false;

    return showTutorial
        ? const PentoscopeGameWithTutorialScreen()
        : const PentoscopeGameScreen();
  }

  /// Petit helper safe: évite de casser le build si ton modèle settings évolue.
  bool? _tryGetShowTutorial(dynamic settings) {
    try {
      // ⚠️ Change cette ligne quand tu auras le vrai champ.
      // return settings.tutorials.showPentoscopeTutorial as bool?;
      return null;
    } catch (_) {
      return null;
    }
  }
}
