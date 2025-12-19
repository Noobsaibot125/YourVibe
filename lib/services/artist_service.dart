import 'dart:convert';
import 'package:http/http.dart' as http;

class ArtistInfo {
  final String? biography;
  final String? genre;
  final String? website;
  final String? facebook;
  final String? twitter;
  final String? thumbUrl;

  ArtistInfo({
    this.biography,
    this.genre,
    this.website,
    this.facebook,
    this.twitter,
    this.thumbUrl,
  });

  factory ArtistInfo.fromJson(Map<String, dynamic> json) {
    return ArtistInfo(
      biography: json['strBiographyEN'] ?? json['strBiographyFR'],
      genre: json['strGenre'],
      website: json['strWebsite'],
      facebook: json['strFacebook'],
      twitter: json['strTwitter'],
      thumbUrl: json['strArtistThumb'],
    );
  }
}

class ArtistService {
  static const String _baseUrl = 'https://www.theaudiodb.com/api/v1/json/1';

  Future<ArtistInfo?> getArtistInfo(String artistName) async {
    try {
      final url = Uri.parse(
          '$_baseUrl/search.php?s=${Uri.encodeComponent(artistName)}');
      final response = await http.get(url).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['artists'] != null && (data['artists'] as List).isNotEmpty) {
          return ArtistInfo.fromJson(data['artists'][0]);
        }
      }
      return null;
    } catch (e) {
      print('Error fetching artist info: $e');
      return null;
    }
  }
}
