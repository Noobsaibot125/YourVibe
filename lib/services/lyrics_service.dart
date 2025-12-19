import 'dart:convert';
import 'package:http/http.dart' as http;

class LyricsService {
  static const String _baseUrl = 'https://api.lyrics.ovh/v1';

  Future<String?> getLyrics(String artist, String title) async {
    try {
      // Clean up strings to improve matching chances
      final cleanArtist = _cleanString(artist);
      final cleanTitle = _cleanString(title);

      final url = Uri.parse('$_baseUrl/$cleanArtist/$cleanTitle');
      final response = await http.get(url).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['lyrics'] as String?;
      } else {
        print('Lyrics error: ${response.statusCode}');
        return null; // Not found or error
      }
    } catch (e) {
      print('Error fetching lyrics: $e');
      return null;
    }
  }

  String _cleanString(String input) {
    // Remove "feat.", "(Remix)", etc. simplistic approach
    return input.replaceAll(RegExp(r'\(.*?\)|\[.*?\]'), '').trim();
  }
}
