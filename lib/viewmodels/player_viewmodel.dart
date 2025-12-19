import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../services/lyrics_service.dart';
import '../services/artist_service.dart';
import '../services/audio_manager.dart';
import '../services/storage_service.dart';

/// ViewModel pour gérer l'état du lecteur de musique
class PlayerViewModel extends ChangeNotifier {
  final AudioManager _audioManager = AudioManager();

  // Liste des chansons
  List<SongModel> _songs = [];
  List<AlbumModel> _albums = [];
  List<ArtistModel> _artists = [];
  List<SongModel> _recentlyPlayed = [];

  List<SongModel> get songs => _songs;
  List<AlbumModel> get albums => _albums;
  List<ArtistModel> get artists => _artists;
  List<SongModel> get recentlyPlayed => _recentlyPlayed;

  // Chanson actuelle
  SongModel? _currentSong;
  SongModel? get currentSong => _currentSong;

  // Index de la chanson actuelle
  int _currentIndex = -1;
  int get currentIndex => _currentIndex;

  // État de lecture
  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;

  // Position et durée
  Duration _position = Duration.zero;
  Duration get position => _position;

  Duration _duration = Duration.zero;
  Duration get duration => _duration;

  // Volume
  double _volume = 1.0;
  double get volume => _volume;

  // Modes
  bool _isShuffle = false;
  bool get isShuffle => _isShuffle;

  LoopMode _loopMode = LoopMode.off;
  LoopMode get loopMode => _loopMode;

  // État de chargement
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  AudioManager get audioManager => _audioManager;

  // Lyrics
  String? _lyrics;
  String? get lyrics => _lyrics;
  bool _isLoadingLyrics = false;
  bool get isLoadingLyrics => _isLoadingLyrics;

  final LyricsService _lyricsService = LyricsService();

  // Artist Info
  ArtistInfo? _artistInfo;
  ArtistInfo? get artistInfo => _artistInfo;
  bool _isLoadingArtist = false;
  bool get isLoadingArtist => _isLoadingArtist;

  final ArtistService _artistService = ArtistService();

  // Storage & Persistence
  final StorageService _storage = StorageService();

  // Likes & Playlists
  List<SongModel> _likedSongs = [];
  List<SongModel> get likedSongs => _likedSongs;

  Map<String, List<SongModel>> _playlists = {};
  Map<String, List<SongModel>> get playlists => _playlists;

  // Made For You
  List<SongModel> _madeForYou = [];
  List<SongModel> get madeForYou => _madeForYou;

  PlayerViewModel() {
    _initialize();
  }

  /// Initialiser le player
  Future<void> _initialize() async {
    await _audioManager.initialize();
    await _storage.init();

    // Écouter les changements d'état
    _audioManager.playerStateStream.listen((state) {
      _isPlaying = state.playing;
      notifyListeners();

      // Auto-play next si completed
      if (state.processingState == ProcessingState.completed) {
        playNext();
      }
    });

    _audioManager.positionStream.listen((position) {
      _position = position ?? Duration.zero;
      notifyListeners();
    });

    _audioManager.durationStream.listen((duration) {
      _duration = duration ?? Duration.zero;
      notifyListeners();
    });

    _audioManager.volumeStream.listen((volume) {
      _volume = volume;
      notifyListeners();
    });

    _audioManager.shuffleModeEnabledStream.listen((enabled) {
      _isShuffle = enabled;
      notifyListeners();
    });

    _audioManager.loopModeStream.listen((mode) {
      _loopMode = mode;
      notifyListeners();
    });

    // Charger les chansons d'abord
    await loadSongs();

    // Restaurer l'état
    await _restoreState();

    // Charger Likes et Playlists
    await _loadUserData();

    _generateMadeForYou();
  }

  Future<void> _loadUserData() async {
    // Likes
    final likedIds = _storage.getLikedSongs();
    _likedSongs =
        _songs.where((s) => likedIds.contains(s.id.toString())).toList();

    // Playlists
    final playlistData = _storage.getPlaylists();
    _playlists = {};
    playlistData.forEach((name, ids) {
      _playlists[name] =
          _songs.where((s) => ids.contains(s.id.toString())).toList();
    });
    notifyListeners();
  }

  bool isLiked(SongModel song) {
    return _likedSongs.any((s) => s.id == song.id);
  }

  Future<void> toggleLike(SongModel song) async {
    if (isLiked(song)) {
      _likedSongs.removeWhere((s) => s.id == song.id);
    } else {
      _likedSongs.add(song);
    }
    notifyListeners();

    // Persist
    final ids = _likedSongs.map((s) => s.id.toString()).toList();
    await _storage.saveLikedSongs(ids);
  }

  Future<void> createPlaylist(String name) async {
    if (_playlists.containsKey(name)) return;
    _playlists[name] = [];
    notifyListeners();
    await _savePlaylists();
  }

  Future<void> addToPlaylist(String playlistName, SongModel song) async {
    if (!_playlists.containsKey(playlistName)) return;
    if (_playlists[playlistName]!.any((s) => s.id == song.id)) return;

    _playlists[playlistName]!.add(song);
    notifyListeners();
    await _savePlaylists();
  }

  Future<void> _savePlaylists() async {
    final Map<String, List<String>> data = {};
    _playlists.forEach((name, songs) {
      data[name] = songs.map((s) => s.id.toString()).toList();
    });
    await _storage.savePlaylists(data);
  }

  Future<void> _restoreState() async {
    // 1. Restore Recently Played
    final recentIds = _storage.getRecentlyPlayedIds();
    _recentlyPlayed = [];
    for (var idStr in recentIds) {
      // Find song with this ID
      try {
        final song = _songs.firstWhere((s) => s.id.toString() == idStr);
        if (!_recentlyPlayed.contains(song)) {
          _recentlyPlayed.add(song);
        }
      } catch (_) {}
    }

    // 2. Restore Last Played Song
    final lastSongId = _storage.getLastSongId();
    if (lastSongId != null) {
      try {
        final song = _songs.firstWhere((s) => s.id.toString() == lastSongId);
        _currentSong = song;
        _currentIndex = _songs.indexOf(song);

        // Load metadata but DON'T play
        await _audioManager.loadSong(song.uri ?? '');

        // Fetch info for UI
        _fetchLyrics(song);
        _fetchArtistInfo(song);

        notifyListeners();
      } catch (e) {
        debugPrint("Error restoring last song: $e");
      }
    }
  }

  void _generateMadeForYou() {
    // Simple algo: Top artists + random mix
    final counts = _storage.getPlayCounts();
    if (counts.isEmpty && _songs.isNotEmpty) {
      // Fallback: Random
      _madeForYou = List.from(_songs)..shuffle();
      _madeForYou = _madeForYou.take(10).toList();
      notifyListeners();
      return;
    }

    // Sort artists by count
    final sortedArtists = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topArtists = sortedArtists.take(3).map((e) => e.key).toList();

    _madeForYou = _songs.where((s) {
      return topArtists.contains(s.artist);
    }).toList();

    // Fill with random if too result
    if (_madeForYou.length < 10 && _songs.isNotEmpty) {
      final remaining = _songs.where((s) => !_madeForYou.contains(s)).toList();
      remaining.shuffle();
      _madeForYou.addAll(remaining.take(10 - _madeForYou.length));
    }

    _madeForYou.shuffle(); // Shuffle result
    notifyListeners();
  }

  /// Charger toutes les chansons du téléphone
  Future<void> loadSongs() async {
    _isLoading = true;
    notifyListeners();

    try {
      _songs = await _audioManager.querySongs();

      // Filtrer les chansons invalides (moins de 10 secondes)
      _songs = _songs.where((song) {
        return (song.duration ?? 0) > 10000; // 10 secondes en millisecondes
      }).toList();

      _albums = await _audioManager.queryAlbums();
      _artists = await _audioManager.queryArtists();

      debugPrint('${_songs.length} chansons chargées');
      debugPrint('${_albums.length} albums chargés');
      debugPrint('${_artists.length} artistes chargés');
    } catch (e) {
      debugPrint('Erreur lors du chargement des données: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Lire une chanson spécifique
  Future<void> playSong(SongModel song) async {
    try {
      final index = _songs.indexWhere((s) => s.id == song.id);
      if (index == -1) return;

      _currentIndex = index;
      _currentSong = song;
      _lyrics = null; // Reset lyrics
      _artistInfo = null; // Reset artist info
      notifyListeners();

      // Fetch lyrics and artist info in background
      _fetchLyrics(song);
      _fetchArtistInfo(song);

      // Persistence
      _storage.saveLastSong(song.id);
      _storage.addToRecentlyPlayed(song.id);
      if (song.artist != null) {
        _storage.incrementPlayCount(song.artist!);
      }

      // Update local lists
      if (!_recentlyPlayed.contains(song)) {
        _recentlyPlayed.insert(0, song);
        if (_recentlyPlayed.length > 20) _recentlyPlayed.removeLast();
      } else {
        // Move to top
        _recentlyPlayed.remove(song);
        _recentlyPlayed.insert(0, song);
      }

      // Charger et lire la chanson
      await _audioManager.loadSong(song.uri ?? '');
      await _audioManager.play();

      notifyListeners();
    } catch (e) {
      print('Erreur lors de la lecture de la chanson: $e');
    }
  }

  Future<void> _fetchLyrics(SongModel song) async {
    String artist = song.artist ?? "";
    if (artist == '<unknown>' || artist.isEmpty) {
      _lyrics = "Lyrics not available.";
      notifyListeners();
      return;
    }

    _isLoadingLyrics = true;
    notifyListeners();

    try {
      final fetchedLyrics = await _lyricsService.getLyrics(artist, song.title);
      _lyrics = fetchedLyrics ?? "No lyrics found";
    } catch (_) {
      _lyrics = "Error loading lyrics";
    } finally {
      _isLoadingLyrics = false;
      notifyListeners();
    }
  }

  Future<void> _fetchArtistInfo(SongModel song) async {
    String artist = song.artist ?? "";
    if (artist == '<unknown>' || artist.isEmpty) {
      _artistInfo = null;
      notifyListeners();
      return;
    }

    _isLoadingArtist = true;
    notifyListeners();

    try {
      _artistInfo = await _artistService.getArtistInfo(artist);
    } catch (_) {
       _artistInfo = null;
    } finally {
      _isLoadingArtist = false;
      notifyListeners();
    }
  }

  /// Lire une chanson par index
  Future<void> playSongAtIndex(int index) async {
    if (index < 0 || index >= _songs.length) return;
    await playSong(_songs[index]);
  }

  /// Toggle play/pause
  Future<void> togglePlayPause() async {
    if (_isPlaying) {
      await _audioManager.pause();
    } else {
      if (_currentSong == null && _songs.isNotEmpty) {
        await playSongAtIndex(0);
      } else {
        await _audioManager.play();
      }
    }
  }

  /// Chanson suivante
  Future<void> playNext() async {
    if (_songs.isEmpty) return;

    int nextIndex;

    if (_isShuffle) {
      // Mode shuffle : chanson aléatoire
      nextIndex = DateTime.now().millisecondsSinceEpoch % _songs.length;
    } else {
      // Mode normal
      nextIndex = _currentIndex + 1;

      if (nextIndex >= _songs.length) {
        if (_loopMode == LoopMode.all) {
          nextIndex = 0;
        } else {
          // Arrêter si pas de loop
          await _audioManager.stop();
          return;
        }
      }
    }

    await playSongAtIndex(nextIndex);
  }

  /// Chanson précédente
  Future<void> playPrevious() async {
    if (_songs.isEmpty) return;

    // Si la chanson a joué plus de 3 secondes, revenir au début
    if (_position.inSeconds > 3) {
      await seek(Duration.zero);
      return;
    }

    int prevIndex = _currentIndex - 1;

    if (prevIndex < 0) {
      prevIndex = _songs.length - 1;
    }

    await playSongAtIndex(prevIndex);
  }

  /// Chercher une position
  Future<void> seek(Duration position) async {
    await _audioManager.seek(position);
  }

  /// Changer le volume
  Future<void> setVolume(double volume) async {
    await _audioManager.setVolume(volume);
  }

  /// Toggle shuffle
  Future<void> toggleShuffle() async {
    await _audioManager.setShuffleModeEnabled(!_isShuffle);
  }

  /// Toggle loop mode
  Future<void> toggleLoopMode() async {
    LoopMode newMode;
    switch (_loopMode) {
      case LoopMode.off:
        newMode = LoopMode.all;
        break;
      case LoopMode.all:
        newMode = LoopMode.one;
        break;
      case LoopMode.one:
        newMode = LoopMode.off;
        break;
    }
    await _audioManager.setLoopMode(newMode);
  }

  /// Obtenir l'icône de loop mode
  String getLoopModeText() {
    switch (_loopMode) {
      case LoopMode.off:
        return 'Off';
      case LoopMode.all:
        return 'All';
      case LoopMode.one:
        return 'One';
    }
  }

  @override
  void dispose() {
    _audioManager.dispose();
    super.dispose();
  }
}
