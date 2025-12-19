# 🎵 FlutterVibe Mobile

FlutterVibe est un lecteur de musique local moderne pour Android, construit avec Flutter et inspiré du Material Design 3.

## ✨ Fonctionnalités

- 🎵 **Lecture de musique locale** : Scanne et lit tous les fichiers audio de votre téléphone
- 🎨 **Interface Material 3** : Design moderne avec thème sombre élégant
- 🎛️ **Contrôles complets** :
  - Lecture/Pause
  - Suivant/Précédent
  - Barre de progression avec recherche
  - Contrôle du volume
  - Mode Shuffle (aléatoire)
  - Mode Repeat (répétition : Off / All / One)
- 🖼️ **Affichage des pochettes** : Affiche les artworks des albums quand disponibles
- 📱 **Mini-player** : Contrôle rapide en bas de l'écran d'accueil
- 🎵 **Player plein écran** : Interface immersive pour la lecture

## 🚀 Installation et Lancement

### Prérequis

- Flutter SDK installé (version 3.2.0 ou supérieure)
- Android SDK configuré
- Un appareil Android ou un émulateur

### Étapes

1. **Installer les dépendances** :
   ```bash
   flutter pub get
   ```

2. **Connecter un appareil ou lancer un émulateur**

3. **Lancer l'application** :
   ```bash
   flutter run
   ```

   Ou pour une version release optimisée :
   ```bash
   flutter run --release
   ```

## 📱 Utilisation

1. **Au premier lancement** :
   - L'application va demander la permission d'accéder à vos fichiers audio
   - Acceptez la permission pour voir vos chansons

2. **Écran d'accueil** :
   - Toutes vos chansons sont listées
   - Appuyez sur une chanson pour la lire
   - Un mini-player apparaît en bas

3. **Player plein écran** :
   - Appuyez sur le mini-player pour ouvrir le lecteur complet
   - Contrôlez la lecture, le volume, shuffle et repeat
   - Balayez vers le bas pour revenir à la liste

## 🏗️ Architecture du Projet

```
lib/
├── main.dart                      # Point d'entrée de l'application
├── services/
│   └── audio_manager.dart         # Gestion de la lecture audio 
├── viewmodels/
│   └── player_viewmodel.dart      # État global du lecteur (Provider)
└── views/
    ├── home_screen.dart           # Écran d'accueil avec liste de chansons
    └── player_screen.dart         # Écran de lecture plein écran
```

### Pattern utilisé : MVVM avec Provider

- **View** : Écrans Flutter (HomeScreen, PlayerScreen)
- **ViewModel** : PlayerViewModel (gestion d'état avec Provider)
- **Model** : AudioManager (logique métier audio)

## 🔧 Technologies et Packages

| Package | Usage |
|---------|-------|
| `just_audio` | Lecteur audio haute qualité |
| `on_audio_query` | Scanner les fichiers audio du téléphone |
| `provider` | Gestion d'état réactive |
| `permission_handler` | Gestion des permissions Android |
| `audio_service` | Service audio en arrière-plan |

## 🎨 Design Tokens (Material 3)

```dart
Primary: #6750A4 (violet)
Surface: #1C1B1F (noir foncé)
On Surface: #E6E1E5 (blanc cassé)
Secondary: #625B71 (violet grisé)
```

## ⚙️ Configuration Android

### Permissions requises (déjà configurées)

- `READ_EXTERNAL_STORAGE` : Lire les fichiers audio
- `READ_MEDIA_AUDIO` : Android 13+ 
- `WAKE_LOCK` : Lecture en arrière-plan
- `FOREGROUND_SERVICE` : Service de lecture

### SDK minimum

- **minSdk** : 21 (Android 5.0 Lollipop)
- **targetSdk** : Dernière version stable

## 🐛 Résolution des problèmes

### L'application ne trouve pas de chansons

1. Vérifiez que vous avez des fichiers audio sur votre téléphone
2. Assurez-vous que les permissions sont accordées
3. Appuyez sur le bouton "Actualiser" (icône refresh)

### Erreur de permission

Si les permissions sont refusées :
1. Allez dans Paramètres > Applications > FlutterVibe
2. Activez les permissions de stockage/médias

### L'application ne se lance pas

```bash
# Nettoyer le cache
flutter clean
flutter pub get

# Réinstaller
flutter run
```

## 🎯 Prochaines fonctionnalités

- [ ] Playlists personnalisées
- [ ] Recherche de chansons
- [ ] Égaliseur
- [ ] Thèmes personnalisables
- [ ] Widget pour l'écran d'accueil
- [ ] Notification de lecture
- [ ] Gestion des favoris
- [ ] Lecture Bluetooth optimisée

## 📄 Licence

Ce projet est un exemple éducatif pour démontrer les capacités de Flutter pour la création d'applications musicales.

## 🤝 Contribution

N'hésitez pas à ouvrir des issues ou des pull requests pour améliorer l'application !

---

**Développé avec ❤️ et Flutter**
