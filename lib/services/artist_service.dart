import 'dart:convert';
import 'package:http/http.dart' as http;
import 'storage_service.dart';

/// Model for artist information with extended data
class ArtistInfo {
  final String? biography;
  final String? genre;
  final String? website;
  final String? facebook;
  final String? twitter;
  final String? instagram; // NEW
  final String? thumbUrl;
  final String? bannerUrl;
  final String? country;
  final String? formedYear;
  final String? mbid; // MusicBrainz ID
  final List<AlbumInfo>? albums;

  ArtistInfo({
    this.biography,
    this.genre,
    this.website,
    this.facebook,
    this.twitter,
    this.instagram,
    this.thumbUrl,
    this.bannerUrl,
    this.country,
    this.formedYear,
    this.mbid,
    this.albums,
  });

  factory ArtistInfo.fromAudioDB(Map<String, dynamic> json) {
    return ArtistInfo(
      biography: json['strBiographyFR'] ?? json['strBiographyEN'],
      genre: json['strGenre'],
      website: json['strWebsite'],
      facebook: json['strFacebook'],
      twitter: json['strTwitter'],
      instagram: json['strInstagram'],
      thumbUrl: json['strArtistThumb'],
      bannerUrl: json['strArtistBanner'],
      country: json['strCountry'],
      formedYear: json['intFormedYear']?.toString(),
      mbid: json['strMusicBrainzID'],
    );
  }

  factory ArtistInfo.fromMusicBrainz(Map<String, dynamic> json) {
    String? bio;
    if (json['annotation'] != null) {
      bio = json['annotation'];
    }

    return ArtistInfo(
      biography: bio,
      country: json['country'] ?? json['area']?['name'],
      formedYear: json['life-span']?['begin']?.toString().substring(0, 4),
      mbid: json['id'],
      genre: (json['tags'] as List?)?.isNotEmpty == true
          ? (json['tags'] as List).first['name']
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'strBiographyEN': biography,
      'strGenre': genre,
      'strWebsite': website,
      'strFacebook': facebook,
      'strTwitter': twitter,
      'strInstagram': instagram,
      'strArtistThumb': thumbUrl,
      'strArtistBanner': bannerUrl,
      'strCountry': country,
      'intFormedYear': formedYear,
      'strMusicBrainzID': mbid,
    };
  }
}

/// Model for album information
class AlbumInfo {
  final String title;
  final String? year;
  final String? thumbUrl;
  final String? mbid;

  AlbumInfo({
    required this.title,
    this.year,
    this.thumbUrl,
    this.mbid,
  });

  factory AlbumInfo.fromAudioDB(Map<String, dynamic> json) {
    return AlbumInfo(
      title: json['strAlbum'] ?? 'Unknown',
      year: json['intYearReleased']?.toString(),
      thumbUrl: json['strAlbumThumb'],
      mbid: json['strMusicBrainzID'],
    );
  }

  factory AlbumInfo.fromMusicBrainz(Map<String, dynamic> json) {
    return AlbumInfo(
      title: json['title'] ?? 'Unknown',
      year: json['first-release-date']?.toString().substring(0, 4),
      mbid: json['id'],
    );
  }
}

/// Service to fetch artist information from multiple APIs with fallback support.
/// Primary: TheAudioDB (rich data, images)
/// Fallback: MusicBrainz (broader coverage)
class ArtistService {
  static const String _audioDBUrl = 'https://www.theaudiodb.com/api/v1/json/2';
  static const String _musicBrainzUrl = 'https://musicbrainz.org/ws/2';

  final StorageService _storage = StorageService();

  /// Fetch artist info. Tries TheAudioDB first, then MusicBrainz fallback.
  Future<ArtistInfo?> getArtistInfo(String artistName) async {
    // 1. Check cache
    await _storage.init();
    final cached = _storage.getArtistInfoCache(artistName);
    if (cached != null) {
      try {
        final Map<String, dynamic> jsonMap = json.decode(cached);
        return ArtistInfo.fromAudioDB(jsonMap);
      } catch (e) {
        print('Cache parse error for $artistName: $e');
      }
    }

    // 2. Try TheAudioDB (primary)
    ArtistInfo? info = await _fetchFromAudioDB(artistName);

    // 3. Try MusicBrainz as fallback
    if (info == null) {
      info = await _fetchFromMusicBrainz(artistName);
    }

    // Cache result if found
    if (info != null) {
      await _storage.saveArtistInfoCache(
          artistName, json.encode(info.toJson()));
    }

    return info;
  }

  /// Fetch artist albums/discography
  Future<List<AlbumInfo>> getArtistAlbums(String artistName) async {
    List<AlbumInfo> albums = [];

    // Try TheAudioDB first
    albums = await _fetchAlbumsFromAudioDB(artistName);

    // Fallback to MusicBrainz if empty
    if (albums.isEmpty) {
      albums = await _fetchAlbumsFromMusicBrainz(artistName);
    }

    return albums;
  }

  /// Fetch from TheAudioDB API
  Future<ArtistInfo?> _fetchFromAudioDB(String artistName) async {
    try {
      final url = Uri.parse(
          '$_audioDBUrl/search.php?s=${Uri.encodeComponent(artistName)}');
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['artists'] != null && (data['artists'] as List).isNotEmpty) {
          return ArtistInfo.fromAudioDB(data['artists'][0]);
        }
      }
      return null;
    } catch (e) {
      print('TheAudioDB error: $e');
      return null;
    }
  }

  /// Fetch from MusicBrainz API (fallback)
  Future<ArtistInfo?> _fetchFromMusicBrainz(String artistName) async {
    try {
      final url = Uri.parse(
          '$_musicBrainzUrl/artist?query=artist:${Uri.encodeComponent(artistName)}&fmt=json&limit=1');

      final response = await http.get(
        url,
        headers: {'User-Agent': 'WayneMusic/1.0 (contact@example.com)'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['artists'] != null && (data['artists'] as List).isNotEmpty) {
          return ArtistInfo.fromMusicBrainz(data['artists'][0]);
        }
      }
      return null;
    } catch (e) {
      print('MusicBrainz error: $e');
      return null;
    }
  }

  /// Fetch albums from TheAudioDB
  Future<List<AlbumInfo>> _fetchAlbumsFromAudioDB(String artistName) async {
    try {
      final url = Uri.parse(
          '$_audioDBUrl/searchalbum.php?s=${Uri.encodeComponent(artistName)}');
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['album'] != null) {
          return (data['album'] as List)
              .map((a) => AlbumInfo.fromAudioDB(a))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('TheAudioDB albums error: $e');
      return [];
    }
  }

  /// Fetch albums from MusicBrainz
  Future<List<AlbumInfo>> _fetchAlbumsFromMusicBrainz(String artistName) async {
    try {
      // First find artist ID
      final searchUrl = Uri.parse(
          '$_musicBrainzUrl/artist?query=artist:${Uri.encodeComponent(artistName)}&fmt=json&limit=1');

      final searchResponse = await http.get(
        searchUrl,
        headers: {'User-Agent': 'WayneMusic/1.0 (contact@example.com)'},
      ).timeout(const Duration(seconds: 10));

      if (searchResponse.statusCode != 200) return [];

      final searchData = json.decode(searchResponse.body);
      if (searchData['artists'] == null ||
          (searchData['artists'] as List).isEmpty) {
        return [];
      }

      final artistId = searchData['artists'][0]['id'];

      // Now fetch release groups (albums)
      final albumsUrl = Uri.parse(
          '$_musicBrainzUrl/release-group?artist=$artistId&type=album&fmt=json&limit=10');

      final albumsResponse = await http.get(
        albumsUrl,
        headers: {'User-Agent': 'WayneMusic/1.0 (contact@example.com)'},
      ).timeout(const Duration(seconds: 10));

      if (albumsResponse.statusCode == 200) {
        final data = json.decode(albumsResponse.body);
        if (data['release-groups'] != null) {
          return (data['release-groups'] as List)
              .map((a) => AlbumInfo.fromMusicBrainz(a))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('MusicBrainz albums error: $e');
      return [];
    }
  }
}
