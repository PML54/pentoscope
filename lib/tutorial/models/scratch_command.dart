// lib/tutorial/models/scratch_command.dart
// Classe abstraite de base pour toutes les commandes Scratch-Pentapol

import  'package:pentapol/tutorial/models/tutorial_context.dart';

/// Classe abstraite pour toutes les commandes Scratch
abstract class ScratchCommand {
  const ScratchCommand();

  /// Exécute la commande dans le contexte donné
  Future<void> execute(TutorialContext context);

  /// Nom de la commande (pour debug/logs)
  String get name => runtimeType.toString();

  /// Validation de la commande (optionnel)
  bool validate() => true;

  /// Description de la commande (pour aide/documentation)
  String get description => 'Commande $name';
}

/// Commande composée (bloc de commandes)
class CompositeCommand extends ScratchCommand {
  final List<ScratchCommand> commands;

  const CompositeCommand(this.commands);

  @override
  Future<void> execute(TutorialContext context) async {
    for (final command in commands) {
      if (context.isCancelled) break;
      await command.execute(context);
    }
  }

  @override
  String get name => 'BLOCK';
}

/// Commande conditionnelle
class ConditionalCommand extends ScratchCommand {
  final bool Function(TutorialContext) condition;
  final List<ScratchCommand> thenCommands;
  final List<ScratchCommand> elseCommands;

  const ConditionalCommand({
    required this.condition,
    required this.thenCommands,
    this.elseCommands = const [],
  });

  @override
  Future<void> execute(TutorialContext context) async {
    if (condition(context)) {
      for (final cmd in thenCommands) {
        await cmd.execute(context);
      }
    } else {
      for (final cmd in elseCommands) {
        await cmd.execute(context);
      }
    }
  }

  @override
  String get name => 'IF';
}
