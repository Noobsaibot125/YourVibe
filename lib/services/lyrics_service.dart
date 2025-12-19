import 'dart:convert';
import 'package:http/http.dart' as http;
import 'storage_service.dart';

/// Model for a single line of synced lyrics
class LyricsLine {
  final Duration time;
  final String text;

  LyricsLine({required this.time, required this.text});
}

/// Container for lyrics result (synced or plain)
class LyricsData {
  final List<LyricsLine> lines;
  final String? plainLyrics;
  final bool isSynced;

  LyricsData({
    this.lines = const [],
    this.plainLyrics,
    this.isSynced = false,
  });
}

/// Service to fetch song lyrics from multiple APIs with fallback support.
class LyricsService {
  // Primary API: LRCLIB - excellent coverage for international songs
  static const String _lrclibUrl = 'https://lrclib.net/api/get';

  // Fallback API: lyrics.ovh
  static const String _fallbackUrl = 'https://api.lyrics.ovh/v1';

  final StorageService _storage = StorageService();

  /// Fetch lyrics for a song. Tries multiple sources.
  Future<LyricsData?> getLyrics(String artist, String title) async {
    // 1. Check cache first
    await _storage.init();
    final cached = _storage.getLyricsCache(artist, title);
    if (cached != null &&
        cached.isNotEmpty &&
        cached != "No lyrics found" &&
        !cached.contains("Error")) {
      // If cached is LRC format, parse it
      if (cached.contains('[00:')) {
        return LyricsData(
          lines: _parseLrc(cached),
          plainLyrics: _stripLrcTimestamps(cached),
          isSynced: true,
        );
      }
      return LyricsData(plainLyrics: cached, isSynced: false);
    }

    // Clean up strings to improve matching
    final cleanArtist = _cleanString(artist);
    final cleanTitle = _cleanString(title);

    if (cleanArtist.isEmpty || cleanTitle.isEmpty) return null;

    String? lyrics;

    // 2. Try multiple sources with cleaned strings
    lyrics = await _tryAllSources(cleanArtist, cleanTitle);

    // 3. Try with original (unclean) strings if still no result
    if (lyrics == null || lyrics.isEmpty) {
      lyrics = await _tryAllSources(artist, title);
    }

    // 4. Try without "The" in artist name if relevant
    if ((lyrics == null || lyrics.isEmpty) &&
        artist.toLowerCase().startsWith("the ")) {
      lyrics = await _tryAllSources(artist.substring(4), title);
    }

    // 5. Cache and return if found
    if (lyrics != null && lyrics.isNotEmpty) {
      await _storage.saveLyricsCache(artist, title, lyrics);

      if (lyrics.contains('[00:')) {
        return LyricsData(
          lines: _parseLrc(lyrics),
          plainLyrics: _stripLrcTimestamps(lyrics),
          isSynced: true,
        );
      }
      return LyricsData(plainLyrics: lyrics, isSynced: false);
    }

    return null;
  }

  Future<String?> _tryAllSources(String artist, String title) async {
    String? lyrics;

    // Try LRCLIB
    try {
      lyrics = await _fetchFromLRCLIB(artist, title);
    } catch (e) {
      print('LRCLIB failed: $e');
    }

    // Try lyrics.ovh as fallback
    if (lyrics == null || lyrics.isEmpty) {
      try {
        lyrics = await _fetchFromLyricsOvh(artist, title);
      } catch (e) {
        print('lyrics.ovh failed: $e');
      }
    }

    return lyrics;
  }

  /// Fetch from LRCLIB API - supports synced and plain lyrics
  Future<String?> _fetchFromLRCLIB(String artist, String title) async {
    final url = Uri.parse(
        '$_lrclibUrl?artist_name=${Uri.encodeComponent(artist)}&track_name=${Uri.encodeComponent(title)}');

    final response = await http.get(
      url,
      headers: {'User-Agent': 'WayneMusic/1.0'},
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      // Prefer synced lyrics for parsing, but keep plain as backup
      final syncedLyrics = data['syncedLyrics'] as String?;
      final plainLyrics = data['plainLyrics'] as String?;

      if (syncedLyrics != null && syncedLyrics.isNotEmpty) {
        return syncedLyrics;
      }

      if (plainLyrics != null && plainLyrics.isNotEmpty) {
        return plainLyrics;
      }
    }
    return null;
  }

  /// Fetch from lyrics.ovh API (fallback)
  Future<String?> _fetchFromLyricsOvh(String artist, String title) async {
    final url = Uri.parse(
        '$_fallbackUrl/${Uri.encodeComponent(artist)}/${Uri.encodeComponent(title)}');
    final response = await http.get(url).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final lyrics = data['lyrics'] as String?;

      if (lyrics != null && lyrics.isNotEmpty) {
        return lyrics;
      }
    }
    return null;
  }

  /// Strip LRC timestamps from synced lyrics (e.g., "[00:12.34] Line" -> "Line")
  String _stripLrcTimestamps(String lrc) {
    final lines = lrc.split('\n');
    final strippedLines = lines
        .map((line) {
          // Remove timestamps like [00:12.34]
          return line.replaceAll(RegExp(r'\[\d{2}:\d{2}\.\d{2,3}\]\s*'), '');
        })
        .where((line) => line.trim().isNotEmpty)
        .toList();

    return strippedLines.join('\n');
  }

  /// Parse LRC format into LyricsLine list
  List<LyricsLine> _parseLrc(String lrc) {
    final lines = lrc.split('\n');
    final List<LyricsLine> list = [];
    final regex = RegExp(r'\[(\d{2}):(\d{2})\.(\d{2,3})\]');

    for (var line in lines) {
      final match = regex.firstMatch(line);
      if (match != null) {
        final minutes = int.parse(match.group(1)!);
        final seconds = int.parse(match.group(2)!);
        final ms = int.parse(match.group(3)!);

        final duration = Duration(
          minutes: minutes,
          seconds: seconds,
          milliseconds: ms,
        );

        final text = line.replaceAll(regex, '').trim();
        if (text.isNotEmpty) {
          list.add(LyricsLine(time: duration, text: text));
        }
      }
    }
    return list;
  }

  /// Clean string for better API matching
  String _cleanString(String input) {
    // 1. Convert to lowercase for consistent regex matching
    String s = input;

    // 2. Remove "(feat. Artist)", "(Remix)", "[Explicit]" etc.
    s = s.replaceAll(RegExp(r'\(.*?\)|\[.*?\]'), '');

    // 3. Remove common "ft.", "feat.", "with" patterns
    s = s.replaceAll(
        RegExp(r'\s*(feat\.?|ft\.?|with|presents|pres\.?|prod\.?|by)\s+.*$',
            caseSensitive: false),
        '');

    // 4. Remove anything after " - " which often contains extra info
    if (s.contains(' - ')) {
      s = s.split(' - ')[0];
    }

    // 5. Keep accented letters and basic punctuation, but be careful with special chars
    s = s.replaceAll(RegExp(r"[^\w\s\u00C0-\u017F'-]"), ' ');

    // 6. Collapse multiple spaces
    s = s.replaceAll(RegExp(r'\s+'), ' ');

    return s.trim();
  }

  /// Get a search URL for lyrics (for web browser fallback)
  String getLyricsSearchUrl(String artist, String title) {
    final query = Uri.encodeComponent('$artist $title paroles lyrics');
    return 'https://www.google.com/search?q=$query';
  }
}
