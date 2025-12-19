# 🔧 Guide de Dépannage - FlutterVibe Mobile

## ❌ Problème : "Aucun appareil Android détecté"

Si `flutter run` ou `flutter devices` ne montre pas d'appareil Android, suivez ces étapes :

---

## ✅ Solution 1 : Créer et lancer un émulateur Android

### Étape 1 : Vérifier Android Studio

1. **Ouvrir Android Studio**
2. Aller dans **Tools > Device Manager** (ou AVD Manager)

### Étape 2 : Créer un émulateur

Si vous n'avez pas d'émulateur :

1. Cliquez sur **"Create Virtual Device"**
2. Choisissez un modèle (recommandé : **Pixel 6**)
3. Sélectionnez une image système (recommandé : **Android 13 ou 14**)
4. Donnez un nom à votre émulateur
5. Cliquez sur **Finish**

### Étape 3 : Lancer l'émulateur

1. Dans Device Manager, trouvez votre émulateur
2. Cliquez sur le bouton **Play ▶️**
3. Attendez que l'émulateur démarre complètement (environ 30-60 secondes)

### Étape 4 : Vérifier la détection

```bash
flutter devices
```

Vous devriez voir quelque chose comme :
```
Android SDK built for x86_64 (mobile) • emulator-5554 • android-x64 • Android 13 (API 33)
```

### Étape 5 : Lancer l'application

```bash
flutter run
```

---

## ✅ Solution 2 : Connecter un téléphone Android physique

### Étape 1 : Activer le mode développeur sur votre téléphone

1. Allez dans **Paramètres > À propos du téléphone**
2. Appuyez **7 fois** sur **"Numéro de build"**
3. Un message confirmera l'activation du mode développeur

### Étape 2 : Activer le débogage USB

1. Retournez dans **Paramètres**
2. Allez dans **Options pour les développeurs**
3. Activez **"Débogage USB"**

### Étape 3 : Connecter via USB

1. Branchez votre téléphone à l'ordinateur avec un câble USB
2. Sur votre téléphone, acceptez **"Autoriser le débogage USB"**
3. Cochez **"Toujours autoriser depuis cet ordinateur"**

### Étape 4 : Vérifier la connexion

```bash
flutter devices
```

Vous devriez voir votre téléphone listé.

### Étape 5 : Lancer l'application

```bash
flutter run
```

---

## ✅ Solution 3 : Utiliser la version Web (temporaire)

En attendant de configurer un émulateur ou un appareil, vous pouvez tester la version web :

```bash
flutter run -d edge
```

⚠️ **Note** : La version web ne pourra pas accéder aux fichiers audio locaux du système. C'est juste pour tester l'interface.

---

## 🛠️ Dépannage avancé

### Problème : "Android licenses not accepted"

```bash
flutter doctor --android-licenses
```

Acceptez toutes les licences en tapant `y`.

### Problème : "Android SDK not found"

1. Ouvrez Android Studio
2. Allez dans **File > Settings > Appearance & Behavior > System Settings > Android SDK**
3. Vérifiez le chemin du SDK
4. Si nécessaire, configurez la variable d'environnement :
   ```
   ANDROID_HOME=C:\Users\VotreNom\AppData\Local\Android\Sdk
   ```

### Vérifier l'état de Flutter

```bash
flutter doctor -v
```

Cela vous montrera tous les problèmes potentiels à résoudre.

---

## 📱 Commandes utiles

| Commande | Description |
|----------|-------------|
| `flutter devices` | Liste tous les appareils disponibles |
| `flutter run` | Lance l'app sur l'appareil par défaut |
| `flutter run -d <device-id>` | Lance l'app sur un appareil spécifique |
| `flutter run --release` | Lance en mode release (optimisé) |
| `flutter clean` | Nettoie le projet |
| `flutter pub get` | Installe les dépendances |
| `flutter doctor` | Vérifie la configuration Flutter |

---

## 🎯 Étapes recommandées pour démarrer

1. **Ouvrir Android Studio**
2. **Créer/Lancer un émulateur Android** (AVD Manager)
3. **Attendre que l'émulateur démarre complètement**
4. **Dans le terminal** :
   ```bash
   cd D:\fluttervibe-web
   flutter devices  # Vérifier que l'émulateur est détecté
   flutter run      # Lancer l'application
   ```

---

## ✅ Si tout fonctionne

Vous devriez voir :

1. L'application se compiler (première fois : 2-5 minutes)
2. L'application s'installer sur l'émulateur
3. L'application se lancer automatiquement
4. Les logs s'afficher dans le terminal

**Hot Reload** : Pendant le développement, appuyez sur `r` pour recharger rapidement vos changements !

---

## 🆘 Besoin d'aide ?

Si vous rencontrez toujours des problèmes :

1. Vérifiez `flutter doctor -v`
2. Assurez-vous qu'Android Studio est bien installé
3. Redémarrez votre ordinateur si nécessaire
4. Consultez la documentation officielle : [flutter.dev/docs/get-started/install/windows](https://flutter.dev/docs/get-started/install/windows)

---

**Bon développement ! 🚀**
