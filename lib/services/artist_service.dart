import 'dart:convert';
import 'package:http/http.dart' as http;
import 'storage_service.dart';

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

  Map<String, dynamic> toJson() {
    return {
      'strBiographyEN': biography,
      'strGenre': genre,
      'strWebsite': website,
      'strFacebook': facebook,
      'strTwitter': twitter,
      'strArtistThumb': thumbUrl,
    };
  }
}

class ArtistService {
  static const String _baseUrl = 'https://www.theaudiodb.com/api/v1/json/1';
  final StorageService _storage = StorageService();

  Future<ArtistInfo?> getArtistInfo(String artistName) async {
    // 1. Check cache
    await _storage.init(); // Ensure storage is ready
    final cached = _storage.getArtistInfoCache(artistName);
    if (cached != null) {
      try {
        final Map<String, dynamic> jsonMap = json.decode(cached);
        return ArtistInfo.fromJson(jsonMap);
      } catch (e) {
        print('Cache error for $artistName: $e');
      }
    }

    // 2. Network call
    try {
      final url = Uri.parse(
          '$_baseUrl/search.php?s=${Uri.encodeComponent(artistName)}');
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['artists'] != null && (data['artists'] as List).isNotEmpty) {
          final artistData = data['artists'][0];

          // Save to cache
          await _storage.saveArtistInfoCache(artistName, json.encode(artistData));

          return ArtistInfo.fromJson(artistData);
        }
      }
      return null;
    } catch (e) {
      print('Error fetching artist info: $e');
      return null;
    }
  }
}
