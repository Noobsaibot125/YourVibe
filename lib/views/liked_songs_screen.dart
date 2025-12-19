import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../viewmodels/player_viewmodel.dart';

class LikedSongsScreen extends StatelessWidget {
  const LikedSongsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Liked Songs'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<PlayerViewModel>(
        builder: (context, viewModel, child) {
          final likedSongs = viewModel.likedSongs;

          if (likedSongs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text("No liked songs yet.",
                      style: TextStyle(color: Colors.grey)),
                  Text("Tap the heart icon to add songs.",
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: likedSongs.length,
            itemBuilder: (context, index) {
              final song = likedSongs[index];
              return ListTile(
                leading: QueryArtworkWidget(
                  id: song.id,
                  type: ArtworkType.AUDIO,
                  nullArtworkWidget:
                      const Icon(Icons.music_note, color: Colors.white54),
                ),
                title: Text(song.title,
                    style: const TextStyle(color: Colors.white)),
                subtitle: Text(song.artist ?? '<unknown>',
                    style: const TextStyle(color: Colors.grey)),
                trailing: IconButton(
                  icon: const Icon(Icons.favorite, color: Colors.purple),
                  onPressed: () => viewModel.toggleLike(song),
                ),
                onTap: () {
                  // Logic to play song
                  viewModel.playSong(song);
                },
              );
            },
          );
        },
      ),
    );
  }
}
