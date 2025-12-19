import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../viewmodels/player_viewmodel.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          controller: _searchController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Rechercher une musique, un artiste...',
            hintStyle: TextStyle(color: Colors.white54),
            border: InputBorder.none,
          ),
          onChanged: (value) {
            setState(() {
              _query = value.toLowerCase();
            });
          },
          autofocus: true,
        ),
      ),
      body: Consumer<PlayerViewModel>(
        builder: (context, viewModel, child) {
          if (_query.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search, size: 80, color: Colors.white24),
                  SizedBox(height: 16),
                  Text(
                    'Recherchez vos musiques préférées',
                    style: TextStyle(color: Colors.white54),
                  ),
                ],
              ),
            );
          }

          final songs = viewModel.songs
              .where((s) =>
                  s.title.toLowerCase().contains(_query) ||
                  (s.artist?.toLowerCase().contains(_query) ?? false))
              .toList();

          final artists = viewModel.artists
              .where((a) => a.artist.toLowerCase().contains(_query))
              .toList();

          final albums = viewModel.albums
              .where((a) => a.album.toLowerCase().contains(_query))
              .toList();

          if (songs.isEmpty && artists.isEmpty && albums.isEmpty) {
            return const Center(
              child: Text(
                'Aucun résultat trouvé',
                style: TextStyle(color: Colors.white54),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.only(bottom: 100),
            children: [
              if (songs.isNotEmpty) ...[
                _buildSectionTitle('Musiques'),
                ...songs.map((song) => ListTile(
                      leading: QueryArtworkWidget(
                        id: song.id,
                        type: ArtworkType.AUDIO,
                        nullArtworkWidget:
                            const Icon(Icons.music_note, color: Colors.white54),
                      ),
                      title: Text(song.title,
                          style: const TextStyle(color: Colors.white),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      subtitle: Text(song.artist ?? 'Inconnu',
                          style: const TextStyle(color: Colors.grey),
                          maxLines: 1),
                      onTap: () => viewModel.playSong(song),
                    )),
              ],
              if (artists.isNotEmpty) ...[
                _buildSectionTitle('Artistes'),
                ...artists.map((artist) => ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.grey,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      title: Text(artist.artist,
                          style: const TextStyle(color: Colors.white)),
                      subtitle: Text('${artist.numberOfTracks} titres',
                          style: const TextStyle(color: Colors.grey)),
                    )),
              ],
              if (albums.isNotEmpty) ...[
                _buildSectionTitle('Albums'),
                ...albums.map((album) => ListTile(
                      leading: QueryArtworkWidget(
                        id: album.id,
                        type: ArtworkType.ALBUM,
                        nullArtworkWidget:
                            const Icon(Icons.album, color: Colors.white54),
                      ),
                      title: Text(album.album,
                          style: const TextStyle(color: Colors.white)),
                      subtitle: Text(album.artist ?? 'Inconnu',
                          style: const TextStyle(color: Colors.grey)),
                    )),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
