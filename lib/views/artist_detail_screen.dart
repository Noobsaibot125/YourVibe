import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';
import '../viewmodels/player_viewmodel.dart';

class ArtistDetailScreen extends StatelessWidget {
  final ArtistModel artist;

  const ArtistDetailScreen({super.key, required this.artist});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(artist.artist),
        backgroundColor: Colors.transparent,
      ),
      body: Consumer<PlayerViewModel>(
        builder: (context, viewModel, child) {
          final artistSongs =
              viewModel.songs.where((s) => s.artistId == artist.id).toList();

          return Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[800],
                      ),
                      child: ClipOval(
                        child: QueryArtworkWidget(
                          id: artist.id,
                          type: ArtworkType.ARTIST,
                          nullArtworkWidget: const Icon(Icons.person,
                              size: 80, color: Colors.white54),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      artist.artist,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "${artistSongs.length} Chansons",
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),

              // Song List
              Expanded(
                child: ListView.builder(
                  itemCount: artistSongs.length,
                  itemBuilder: (context, index) {
                    final song = artistSongs[index];
                    return ListTile(
                      leading: QueryArtworkWidget(
                        id: song.id,
                        type: ArtworkType.AUDIO,
                        nullArtworkWidget:
                            const Icon(Icons.music_note, color: Colors.white54),
                      ),
                      title: Text(song.title,
                          style: const TextStyle(color: Colors.white)),
                      subtitle: Text(song.artist ?? '',
                          style: const TextStyle(color: Colors.grey)),
                      onTap: () {
                        viewModel.playSong(song);
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
