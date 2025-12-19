import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';
import '../viewmodels/player_viewmodel.dart';

class AlbumDetailScreen extends StatelessWidget {
  final AlbumModel album;

  const AlbumDetailScreen({super.key, required this.album});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(album.album),
        backgroundColor: Colors.transparent,
      ),
      body: Consumer<PlayerViewModel>(
        builder: (context, viewModel, child) {
          // Note: OnAudioQuery songs usually have albumId, ensuring correct filtering
          final albumSongs =
              viewModel.songs.where((s) => s.albumId == album.id).toList();

          return Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey[800],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: QueryArtworkWidget(
                          id: album.id,
                          type: ArtworkType.ALBUM,
                          nullArtworkWidget: const Icon(Icons.album,
                              size: 60, color: Colors.white54),
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            album.album,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            album.artist ?? 'Artiste Inconnu',
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "${albumSongs.length} Chansons",
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),

              // Song List
              Expanded(
                child: ListView.builder(
                  itemCount: albumSongs.length,
                  itemBuilder: (context, index) {
                    final song = albumSongs[index];
                    return ListTile(
                      leading: Text(
                        "${index + 1}",
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      title: Text(song.title,
                          style: const TextStyle(color: Colors.white)),
                      // subtitle: Text(song.artist ?? '', style: const TextStyle(color: Colors.grey)),
                      // Album usually means same artist, so subtitle might be redundant or could show duration
                      trailing:
                          const Icon(Icons.play_arrow, color: Colors.white54),
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
