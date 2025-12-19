import 'dart:convert';
import 'package:http/http.dart' as http;
import 'storage_service.dart';

class LyricsService {
  static const String _baseUrl = 'https://api.lyrics.ovh/v1';
  final StorageService _storage = StorageService();

  Future<String?> getLyrics(String artist, String title) async {
    // 1. Check cache
    await _storage.init();
    final cached = _storage.getLyricsCache(artist, title);
    if (cached != null) {
      return cached;
    }

    try {
      // Clean up strings to improve matching chances
      final cleanArtist = _cleanString(artist);
      final cleanTitle = _cleanString(title);

      if (cleanArtist.isEmpty || cleanTitle.isEmpty) return null;

      final url = Uri.parse('$_baseUrl/${Uri.encodeComponent(cleanArtist)}/${Uri.encodeComponent(cleanTitle)}');
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final lyrics = data['lyrics'] as String?;

        if (lyrics != null && lyrics.isNotEmpty) {
           await _storage.saveLyricsCache(artist, title, lyrics);
           return lyrics;
        }
      }
      return null; // Not found or error
    } catch (e) {
      print('Error fetching lyrics: $e');
      return null;
    }
  }

  String _cleanString(String input) {
    // Remove "feat.", "(Remix)", parens, brackets, etc.
    String s = input.replaceAll(RegExp(r'\(.*?\)|\[.*?\]'), '');
    // Remove "ft.", "feat."
    s = s.replaceAll(RegExp(r'(?i)\b(feat\.?|ft\.?|with)\b.*'), '');
    return s.trim();
  }
}
