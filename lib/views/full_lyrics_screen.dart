import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/player_viewmodel.dart';
import 'package:on_audio_query/on_audio_query.dart';

class FullLyricsScreen extends StatefulWidget {
  const FullLyricsScreen({super.key});

  @override
  State<FullLyricsScreen> createState() => _FullLyricsScreenState();
}

class _FullLyricsScreenState extends State<FullLyricsScreen> {
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _lineKeys = {};

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToCurrentLine(int index) {
    if (_lineKeys.containsKey(index)) {
      final key = _lineKeys[index];
      if (key?.currentContext != null) {
        Scrollable.ensureVisible(
          key!.currentContext!,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
          alignment: 0.5, // Center the line
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
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
          final currentSong = viewModel.currentSong;

          if (viewModel.isLoadingLyrics) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.purple),
            );
          }

          if (viewModel.syncedLyrics.isNotEmpty) {
            // Re-scroll if index changed
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _scrollToCurrentLine(viewModel.currentLyricsIndex);
            });

            return ListView.builder(
              controller: _scrollController,
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 100),
              itemCount: viewModel.syncedLyrics.length,
              itemBuilder: (context, index) {
                final line = viewModel.syncedLyrics[index];
                final isCurrent = index == viewModel.currentLyricsIndex;

                // Assign key if not present
                _lineKeys[index] ??= GlobalKey();

                return GestureDetector(
                  onTap: () {
                    // Optionnel: seek to this line
                    viewModel.audioManager.seek(line.time);
                  },
                  child: Padding(
                    key: _lineKeys[index],
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      line.text,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isCurrent ? Colors.white : Colors.white24,
                        fontSize: 24,
                        fontWeight:
                            isCurrent ? FontWeight.bold : FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                  ),
                );
              },
            );
          }

          final lyrics = viewModel.lyrics;
          if (lyrics == null || lyrics == "No lyrics found") {
            return const Center(
              child: Text(
                "Paroles non disponibles",
                style: TextStyle(color: Colors.white54, fontSize: 18),
              ),
            );
          }

          // Plain lyrics fallback
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                if (currentSong != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: QueryArtworkWidget(
                      id: currentSong.id,
                      type: ArtworkType.AUDIO,
                      nullArtworkWidget:
                          const Icon(Icons.music_note, color: Colors.white),
                    ),
                  ),
                Text(
                  lyrics,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
