# 🎨 Génération des Icônes - Pentapol

**Date de génération** : 1er décembre 2025  
**Source** : `assets/pentopol.png`  
**Outil** : flutter_launcher_icons v0.14.4

---

## ✅ Icônes générées

### Android
- ✅ **Icônes standard** : Toutes les résolutions (mdpi, hdpi, xhdpi, xxhdpi, xxxhdpi)
- ✅ **Icônes adaptatives** : Foreground + Background (Android 8.0+)
- ✅ **Fichiers générés** :
  - `android/app/src/main/res/mipmap-*/ic_launcher.png`
  - `android/app/src/main/res/mipmap-*/ic_launcher_foreground.png`
  - `android/app/src/main/res/drawable/ic_launcher_background.xml`
  - `android/app/src/main/res/values/colors.xml`
  - `android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml`

### iOS
- ✅ **Icônes AppIcon** : Toutes les tailles requises
- ✅ **Canal alpha retiré** : Conforme aux exigences Apple
- ✅ **Fichiers générés** :
  - `ios/Runner/Assets.xcassets/AppIcon.appiconset/`
  - Toutes les résolutions (20pt à 1024pt)

### Web
- ✅ **Icônes PWA** : Différentes tailles
- ✅ **Fichiers générés** :
  - `web/icons/Icon-192.png`
  - `web/icons/Icon-512.png`
  - `web/icons/Icon-maskable-192.png`
  - `web/icons/Icon-maskable-512.png`
  - `web/favicon.png`

### Windows
- ✅ **Icône Windows** : Format .ico
- ✅ **Fichiers générés** :
  - `windows/runner/resources/app_icon.ico`

### macOS
- ✅ **Icône macOS** : Format .icns
- ✅ **Fichiers générés** :
  - `macos/Runner/Assets.xcassets/AppIcon.appiconset/`

---

## 📋 Configuration utilisée

### Fichier : `flutter_launcher_icons.yaml`

```yaml
flutter_launcher_icons:
  # Plateformes activées
  android: true
  ios: true
  
  # Image source
  image_path: "assets/pentopol.png"
  
  # Android - Icônes adaptatives
  adaptive_icon_background: "#FFFFFF"  # Fond blanc
  adaptive_icon_foreground: "assets/pentopol.png"
  
  # iOS - Retirer canal alpha
  remove_alpha_ios: true
  
  # Web
  web:
    generate: true
    image_path: "assets/pentopol.png"
    background_color: "#FFFFFF"
    theme_color: "#2196F3"
  
  # Windows
  windows:
    generate: true
    image_path: "assets/pentopol.png"
    icon_size: 48
  
  # macOS
  macos:
    generate: true
    image_path: "assets/pentopol.png"
```

---

## 🔄 Regénérer les icônes

Si vous modifiez `assets/pentopol.png` et souhaitez regénérer les icônes :

```bash
# Méthode 1 : Commande directe
dart run flutter_launcher_icons

# Méthode 2 : Via flutter pub
flutter pub run flutter_launcher_icons
```

---

## 📱 Vérification

### Android
1. Ouvrir le projet dans Android Studio
2. Vérifier `android/app/src/main/res/mipmap-*/`
3. Build et installer sur device/émulateur
4. Vérifier l'icône dans le launcher

### iOS
1. Ouvrir `ios/Runner.xcworkspace` dans Xcode
2. Vérifier `Assets.xcassets/AppIcon.appiconset/`
3. Build et installer sur device/simulateur
4. Vérifier l'icône sur l'écran d'accueil

### Web
1. Lancer `flutter run -d chrome`
2. Vérifier le favicon dans l'onglet
3. Installer comme PWA et vérifier l'icône

---

## 🎨 Recommandations pour l'image source

### Taille optimale
- **Minimum** : 512x512 px
- **Recommandé** : 1024x1024 px
- **Idéal** : 2048x2048 px

### Format
- **PNG** avec transparence
- **Fond transparent** pour icônes adaptatives Android
- **Pas de texte petit** (illisible en petite taille)

### Design
- ✅ **Simple et reconnaissable**
- ✅ **Contraste élevé**
- ✅ **Fonctionne en petit (20x20 px)**
- ❌ Éviter détails fins
- ❌ Éviter texte < 12pt

---

## 🔧 Personnalisation avancée

### Changer la couleur de fond (Android)

Modifier dans `flutter_launcher_icons.yaml` :

```yaml
adaptive_icon_background: "#2196F3"  # Bleu au lieu de blanc
```

Puis regénérer :

```bash
dart run flutter_launcher_icons
```

### Icônes différentes par plateforme

```yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path_android: "assets/icon_android.png"
  image_path_ios: "assets/icon_ios.png"
```

### Icône de notification Android (séparée)

Créer manuellement dans :
- `android/app/src/main/res/drawable/notification_icon.png`

---

## 📦 Fichiers modifiés

### Ajoutés
- ✅ `flutter_launcher_icons.yaml` (configuration)
- ✅ `android/app/src/main/res/values/colors.xml`
- ✅ `android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml`

### Modifiés
- ✅ `pubspec.yaml` (ajout dépendance dev)
- ✅ Tous les fichiers d'icônes existants (remplacés)

### Aucun impact sur
- ✅ Code source Dart
- ✅ Logique métier
- ✅ Données utilisateur

---

## 🚨 Attention

### Commit Git
Les icônes générées doivent être commitées :

```bash
git add android/app/src/main/res/mipmap-*
git add ios/Runner/Assets.xcassets/AppIcon.appiconset/
git add web/icons/
git add windows/runner/resources/
git add macos/Runner/Assets.xcassets/AppIcon.appiconset/
git commit -m "feat: Génération des icônes de l'application"
```

### Build Release
Vérifier les icônes dans les builds release :

```bash
# Android
flutter build apk --release

# iOS (nécessite Mac + Xcode)
flutter build ios --release

# Web
flutter build web --release
```

---

## 📚 Ressources

### Documentation
- **flutter_launcher_icons** : https://pub.dev/packages/flutter_launcher_icons
- **Android Adaptive Icons** : https://developer.android.com/guide/practices/ui_guidelines/icon_design_adaptive
- **iOS App Icons** : https://developer.apple.com/design/human-interface-guidelines/app-icons

### Outils de design
- **Figma** : Design d'icônes
- **GIMP** : Édition PNG gratuite
- **ImageMagick** : Conversion en ligne de commande

---

## ✅ Checklist de validation

- [x] Icônes Android générées
- [x] Icônes iOS générées
- [x] Icônes Web générées
- [x] Icônes Windows générées
- [x] Icônes macOS générées
- [ ] Testé sur device Android
- [ ] Testé sur device iOS
- [ ] Testé sur navigateur Web
- [ ] Vérifié dans build release

---

**Dernière mise à jour** : 1er décembre 2025  
**Statut** : ✅ Icônes générées avec succès




