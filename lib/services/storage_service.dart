import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _keyLastSongId = 'last_song_id';
  static const String _keyLastPosition = 'last_position';
  static const String _keyRecentlyPlayed = 'recently_played_ids';
  static const String _keyPlayCounts = 'play_counts';
  static const String _keyLikedSongs = 'liked_songs_ids';
  static const String _keyPlaylists = 'playlists_data';

  // Profile Keys
  static const String _keyProfileName = 'profile_name';
  static const String _keyProfileBio = 'profile_bio';

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // --- Last Played Song ---
  Future<void> saveLastSong(dynamic songId) async {
    await _prefs?.setString(_keyLastSongId, songId.toString());
  }

  String? getLastSongId() {
    return _prefs?.getString(_keyLastSongId);
  }

  // --- Last Position ---
  Future<void> saveLastPosition(int positionMs) async {
    await _prefs?.setInt(_keyLastPosition, positionMs);
  }

  int getLastPosition() {
    return _prefs?.getInt(_keyLastPosition) ?? 0;
  }

  // --- Recently Played ---
  Future<void> addToRecentlyPlayed(dynamic songId) async {
    List<String> recent = getRecentlyPlayedIds();
    final idStr = songId.toString();

    // Remove if exists to move to top
    recent.remove(idStr);
    // Add to front
    recent.insert(0, idStr);
    // Limit to 20
    if (recent.length > 20) {
      recent = recent.sublist(0, 20);
    }

    await _prefs?.setStringList(_keyRecentlyPlayed, recent);
  }

  List<String> getRecentlyPlayedIds() {
    return _prefs?.getStringList(_keyRecentlyPlayed) ?? [];
  }

  // --- Play Counts for "Made For You" ---
  Future<void> incrementPlayCount(String artist) async {
    Map<String, int> counts = getPlayCounts();
    counts[artist] = (counts[artist] ?? 0) + 1;
    await _prefs?.setString(_keyPlayCounts, json.encode(counts));
  }

  Map<String, int> getPlayCounts() {
    final String? jsonStr = _prefs?.getString(_keyPlayCounts);
    if (jsonStr == null) return {};
    try {
      final Map<String, dynamic> decoded = json.decode(jsonStr);
      return decoded.map((key, value) => MapEntry(key, value as int));
    } catch (e) {
      return {};
    }
  }

  // --- Liked Songs ---
  Future<void> saveLikedSongs(List<String> songIds) async {
    await _prefs?.setStringList(_keyLikedSongs, songIds);
  }

  List<String> getLikedSongs() {
    return _prefs?.getStringList(_keyLikedSongs) ?? [];
  }

  // --- Playlists ---
  Future<void> savePlaylists(Map<String, List<String>> playlists) async {
    await _prefs?.setString(_keyPlaylists, json.encode(playlists));
  }

  Map<String, List<String>> getPlaylists() {
    final String? jsonStr = _prefs?.getString(_keyPlaylists);
    if (jsonStr == null) return {};
    try {
      final Map<String, dynamic> decoded = json.decode(jsonStr);
      // Convert List<dynamic> to List<String>
      return decoded.map((key, value) =>
          MapEntry(key, (value as List).map((e) => e.toString()).toList()));
    } catch (e) {
      return {};
    }
  }

  // --- Profile Data ---
  Future<void> saveProfile(String name, String bio) async {
    await _prefs?.setString(_keyProfileName, name);
    await _prefs?.setString(_keyProfileBio, bio);
  }

  String getProfileName() {
    return _prefs?.getString(_keyProfileName) ?? "User";
  }

  String getProfileBio() {
    return _prefs?.getString(_keyProfileBio) ?? "No bio yet.";
  }

  // --- Cache: Artist Info ---
  Future<void> saveArtistInfoCache(String artistName, String jsonString) async {
    await _prefs?.setString('artist_$artistName', jsonString);
  }

  String? getArtistInfoCache(String artistName) {
    return _prefs?.getString('artist_$artistName');
  }

  // --- Cache: Lyrics ---
  Future<void> saveLyricsCache(String artist, String title, String lyrics) async {
    final key = 'lyrics_${artist}_$title';
    await _prefs?.setString(key, lyrics);
  }

  String? getLyricsCache(String artist, String title) {
    final key = 'lyrics_${artist}_$title';
    return _prefs?.getString(key);
  }
}
