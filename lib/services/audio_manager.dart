import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:audio_session/audio_session.dart';

/// Service de gestion audio utilisant just_audio et audio_service
class AudioManager {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final OnAudioQuery _audioQuery = OnAudioQuery();

  AudioPlayer get player => _audioPlayer;
  OnAudioQuery get audioQuery => _audioQuery;

  // État du lecteur
  Stream<PlayerState> get playerStateStream => _audioPlayer.playerStateStream;
  Stream<Duration?> get positionStream => _audioPlayer.positionStream;
  Stream<Duration?> get durationStream => _audioPlayer.durationStream;
  Stream<double> get volumeStream => _audioPlayer.volumeStream;

  // Mode de lecture
  Stream<LoopMode> get loopModeStream => _audioPlayer.loopModeStream;
  Stream<bool> get shuffleModeEnabledStream =>
      _audioPlayer.shuffleModeEnabledStream;

  /// Initialiser l'AudioManager
  Future<void> initialize() async {
    try {
      // Configuration de la session audio
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());

      // Explicitly activate session
      if (await session.setActive(true)) {
        debugPrint('✅ Audio Session Activated');
      } else {
        debugPrint('⚠️ Audio Session Activation Failed');
      }

      // Force volume reset
      await _audioPlayer.setVolume(1.0);
      await _audioPlayer.setLoopMode(LoopMode.off);

      // Gestion de la fin de lecture
      _audioPlayer.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          // Auto-play next handled by viewModel usually
        }
      });
    } catch (e) {
      print('Erreur lors de l\'initialisation de l\'AudioManager: $e');
    }
  }

  /// Charger une chanson depuis son URI
  Future<void> loadSong(String uri) async {
    try {
      debugPrint('🎵 Loading song from URI: $uri');

      // Sur Android, on_audio_query retourne déjà un URI valide
      // Il faut juste s'assurer qu'il est correct
      Uri audioUri;
      if (uri.startsWith('content://') || uri.startsWith('file://')) {
        audioUri = Uri.parse(uri);
      } else {
        // Si c'est un chemin de fichier, le convertir en URI
        audioUri = Uri.file(uri);
      }

      debugPrint('🎵 Parsed URI: $audioUri');

      await _audioPlayer.setAudioSource(
        AudioSource.uri(audioUri),
      );

      debugPrint('✅ Audio source set successfully');
    } catch (e) {
      debugPrint('❌ Erreur lors du chargement de la chanson: $e');
      rethrow;
    }
  }

  /// Lire la musique
  Future<void> play() async {
    try {
      debugPrint('▶️ Playing audio...');
      await _audioPlayer.play();
      debugPrint('✅ Play command sent');
    } catch (e) {
      debugPrint('❌ Erreur lors de la lecture: $e');
    }
  }

  /// Mettre en pause
  Future<void> pause() async {
    try {
      debugPrint('⏸️ Pausing audio...');
      await _audioPlayer.pause();
    } catch (e) {
      debugPrint('❌ Erreur lors de la pause: $e');
    }
  }

  /// Stop
  Future<void> stop() async {
    try {
      await _audioPlayer.stop();
    } catch (e) {
      print('Erreur lors de l\'arrêt: $e');
    }
  }

  /// Chercher une position dans la chanson
  Future<void> seek(Duration position) async {
    try {
      await _audioPlayer.seek(position);
    } catch (e) {
      print('Erreur lors de la recherche de position: $e');
    }
  }

  /// Modifier le volume (0.0 - 1.0)
  Future<void> setVolume(double volume) async {
    try {
      await _audioPlayer.setVolume(volume.clamp(0.0, 1.0));
    } catch (e) {
      print('Erreur lors du changement de volume: $e');
    }
  }

  /// Activer/désactiver le mode shuffle
  Future<void> setShuffleModeEnabled(bool enabled) async {
    try {
      await _audioPlayer.setShuffleModeEnabled(enabled);
    } catch (e) {
      print('Erreur lors du changement de shuffle: $e');
    }
  }

  /// Définir le mode de répétition
  Future<void> setLoopMode(LoopMode mode) async {
    try {
      await _audioPlayer.setLoopMode(mode);
    } catch (e) {
      print('Erreur lors du changement de loop mode: $e');
    }
  }

  /// Récupérer toutes les chansons du téléphone
  Future<List<SongModel>> querySongs() async {
    try {
      // Vérifier les permissions
      bool hasPermission = await _audioQuery.checkAndRequest();
      if (!hasPermission) {
        print('Permission refusée pour accéder aux fichiers audio');
        return [];
      }

      // Récupérer les chansons
      List<SongModel> songs = await _audioQuery.querySongs(
        sortType: SongSortType.TITLE,
        orderType: OrderType.ASC_OR_SMALLER,
        uriType: UriType.EXTERNAL,
        ignoreCase: true,
      );

      return songs;
    } catch (e) {
      print('Erreur lors de la récupération des chansons: $e');
      return [];
    }
  }

  /// Récupérer l'artwork d'une chanson
  Future<Uint8List?> getArtwork(int songId) async {
    try {
      return await _audioQuery.queryArtwork(
        songId,
        ArtworkType.AUDIO,
      );
    } catch (e) {
      print('Erreur lors de la récupération de l\'artwork: $e');
      return null;
    }
  }

  /// Nettoyer les ressources
  Future<void> dispose() async {
    await _audioPlayer.dispose();
  }

  /// Récupérer les albums
  Future<List<AlbumModel>> queryAlbums() async {
    try {
      if (!await _audioQuery.permissionsStatus()) {
        return [];
      }
      return await _audioQuery.queryAlbums(
        sortType: null,
        orderType: OrderType.ASC_OR_SMALLER,
        uriType: UriType.EXTERNAL,
        ignoreCase: true,
      );
    } catch (e) {
      print("Error querying albums: $e");
      return [];
    }
  }

  /// Récupérer les artistes
  Future<List<ArtistModel>> queryArtists() async {
    try {
      if (!await _audioQuery.permissionsStatus()) {
        return [];
      }
      return await _audioQuery.queryArtists(
        sortType: null,
        orderType: OrderType.ASC_OR_SMALLER,
        uriType: UriType.EXTERNAL,
        ignoreCase: true,
      );
    } catch (e) {
      print("Error querying artists: $e");
      return [];
    }
  }
}
