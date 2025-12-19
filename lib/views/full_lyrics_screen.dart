import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/player_viewmodel.dart';
import 'package:on_audio_query/on_audio_query.dart';

class FullLyricsScreen extends StatelessWidget {
  const FullLyricsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark theme
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down,
              color: Colors.white, size: 30),
          onPressed: () => Navigator.pop(context),
        ),
        title: Consumer<PlayerViewModel>(
          builder: (context, viewModel, child) {
            return Column(
              children: [
                const Text(
                  "Paroles",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                Text(
                  viewModel.currentSong?.title ?? "",
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            );
          },
        ),
        centerTitle: true,
      ),
      body: Consumer<PlayerViewModel>(
        builder: (context, viewModel, child) {
          final lyrics = viewModel.lyrics;
          final currentSong = viewModel.currentSong;

          if (lyrics == null ||
              lyrics == "Loading..." ||
              lyrics == "No lyrics found") {
            return Center(
              child: Text(
                lyrics ?? "Chargement...",
                style: const TextStyle(color: Colors.white54, fontSize: 18),
              ),
            );
          }

          return Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // Optional: Small artwork at top
                  if (currentSong != null)
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 24),
                        height: 100,
                        width: 100,
                        child: QueryArtworkWidget(
                          id: currentSong.id,
                          type: ArtworkType.AUDIO,
                          nullArtworkWidget: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[800],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.music_note,
                                color: Colors.white),
                          ),
                        ),
                      ),
                    ),

                  Text(
                    lyrics,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22, // Larger font for full screen reading
                      height: 1.6,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
