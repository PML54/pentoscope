// lib/tutorial/commands/highlight_isometry_icon.dart
// Commande pour surligner une icône d'isométrie (rotation, symétrie)

import 'package:pentapol/tutorial/models/scratch_command.dart';
import 'package:pentapol/tutorial/models/tutorial_context.dart';

/// Commande : Surligne une icône d'isométrie
///
/// Syntaxe YAML :
/// ```yaml
/// - type: highlight_isometry_icon
///   icon: rotation  # rotation, rotation_cw, symmetry_h, symmetry_v
/// ```
///
/// Valeurs possibles pour `icon` :
/// - `rotation` : Rotation 90° anti-horaire (🔄 `Icons.rotate_right`)
/// - `rotation_cw` : Rotation 90° horaire (🔃 `Icons.rotate_left`)
/// - `symmetry_h` : Symétrie horizontale (↔️ `Icons.swap_horiz`)
/// - `symmetry_v` : Symétrie verticale (↕️ `Icons.swap_vert`)
class HighlightIsometryIconCommand extends ScratchCommand {
  final String icon;

  const HighlightIsometryIconCommand({required this.icon});

  factory HighlightIsometryIconCommand.fromYaml(Map<String, dynamic> yaml) {
    final icon = yaml['icon'] as String?;

    if (icon == null) {
      throw FormatException(
        'highlight_isometry_icon: le paramètre "icon" est obligatoire',
      );
    }

    // Valider le nom de l'icône
    const validIcons = ['rotation', 'rotation_cw', 'symmetry_h', 'symmetry_v'];
    if (!validIcons.contains(icon)) {
      throw FormatException(
        'highlight_isometry_icon: icône invalide "$icon". '
            'Valeurs possibles : ${validIcons.join(", ")}',
      );
    }

    return HighlightIsometryIconCommand(icon: icon);
  }

  @override
  String get name => 'highlight_isometry_icon';

  @override
  String get description => 'Surligne l\'icône d\'isométrie: $icon';

  @override
  bool validate() {
    const validIcons = ['rotation', 'rotation_cw', 'symmetry_h', 'symmetry_v'];
    return validIcons.contains(icon);
  }

  @override
  Future<void> execute(TutorialContext context) async {
    print('[TUTORIAL] 🔆 Highlight icône isométrie: $icon');
    context.gameNotifier.highlightIsometryIcon(icon);
  }
}

/// Commande : Efface la surbrillance des icônes d'isométrie
///
/// Syntaxe YAML :
/// ```yaml
/// - type: clear_isometry_icon_highlight
/// ```
class ClearIsometryIconHighlightCommand extends ScratchCommand {
  const ClearIsometryIconHighlightCommand();

  factory ClearIsometryIconHighlightCommand.fromYaml(
      Map<String, dynamic> yaml,
      ) {
    return const ClearIsometryIconHighlightCommand();
  }

  @override
  String get name => 'clear_isometry_icon_highlight';

  @override
  String get description => 'Efface la surbrillance des icônes d\'isométrie';

  @override
  Future<void> execute(TutorialContext context) async {
    print('[TUTORIAL] Effacement highlight icône isométrie');
    context.gameNotifier.clearIsometryIconHighlight();
  }
}