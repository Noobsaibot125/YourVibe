import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../viewmodels/player_viewmodel.dart';
import 'artist_actu_screen.dart';
import 'full_lyrics_screen.dart';
import 'package:just_audio/just_audio.dart'; // <--- AJOUTE CECI

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.5),
              Theme.of(context).scaffoldBackgroundColor,
            ],
          ),
        ),
        child: Consumer<PlayerViewModel>(
          builder: (context, viewModel, child) {
            final song = viewModel.currentSong;
            if (song == null) {
              return const Center(
                child: Text(
                  'Aucune chanson en lecture',
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            return SafeArea(
              child: Column(
                children: [
                  // AppBar simplifiée
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.keyboard_arrow_down,
                              color: Colors.white, size: 30),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Column(
                          children: [
                            const Text(
                              "Now Playing",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                            // Bluetooth/Device Indicator
                            Row(
                              children: [
                                Icon(Icons.speaker,
                                    size: 12, color: Colors.purple[200]),
                                const SizedBox(width: 4),
                                Text("Haut-parleur",
                                    style: TextStyle(
                                        color: Colors.purple[200],
                                        fontSize: 10)),
                              ],
                            )
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.more_horiz,
                              color: Colors.white, size: 30),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),

                  // Contenu scrollable (Artwork + Player + Lyrics + Artist Info)
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          // Artwork
                          Center(
                            child: Container(
                              width: 300,
                              height: 300,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.5),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: QueryArtworkWidget(
                                  id: song.id,
                                  type: ArtworkType.AUDIO,
                                  nullArtworkWidget: Container(
                                    color: Colors.grey[800],
                                    child: const Icon(
                                      Icons.music_note,
                                      color: Colors.white,
                                      size: 100,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 40),

                          // Titre et Artiste
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      // Trigger search options
                                      showModalBottomSheet(
                                        context: context,
                                        backgroundColor: const Color(0xFF2A2A2A),
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                        ),
                                        builder: (context) => Container(
                                          padding: const EdgeInsets.all(16),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              ListTile(
                                                leading: const Icon(Icons.search, color: Colors.white),
                                                title: const Text("Rechercher les paroles sur le web", style: TextStyle(color: Colors.white)),
                                                onTap: () {
                                                  Navigator.pop(context);
                                                  // Trigger manual lyrics fetch or web search
                                                   Navigator.push(
                                                    context,
                                                    MaterialPageRoute(builder: (context) => const FullLyricsScreen()),
                                                  );
                                                },
                                              ),
                                              ListTile(
                                                leading: const Icon(Icons.info, color: Colors.white),
                                                title: const Text("Rechercher infos artiste", style: TextStyle(color: Colors.white)),
                                                onTap: () {
                                                  Navigator.pop(context);
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => ArtistActuScreen(
                                                        artistName: song.artist ?? "Artiste",
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          song.title,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          song.artist ?? "Artiste inconnu",
                                          style: TextStyle(
                                            color: Colors.grey[400],
                                            fontSize: 18,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        const Text(
                                          "Tap for options",
                                          style: TextStyle(
                                            color: Colors.purple,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    viewModel.isLiked(song)
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: viewModel.isLiked(song)
                                        ? Colors.pink
                                        : Colors.white,
                                    size: 30,
                                  ),
                                  onPressed: () => viewModel.toggleLike(song),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Barre de progression
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              children: [
                                SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    trackHeight: 4,
                                    thumbShape: const RoundSliderThumbShape(
                                        enabledThumbRadius: 8),
                                    activeTrackColor: Colors.purple,
                                    inactiveTrackColor: Colors.grey[800],
                                    thumbColor: Colors.purple,
                                    overlayColor:
                                        Colors.purple.withOpacity(0.2),
                                  ),
                                  child: Slider(
                                    value: viewModel.position.inMilliseconds
                                        .toDouble()
                                        .clamp(0.0, viewModel.duration.inMilliseconds.toDouble()),
                                    max: viewModel.duration.inMilliseconds
                                        .toDouble(),
                                    onChanged: (value) {
                                      viewModel.seek(Duration(
                                          milliseconds: value.toInt()));
                                    },
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _formatDuration(viewModel.position),
                                        style: const TextStyle(
                                            color: Colors.grey, fontSize: 12),
                                      ),
                                      Text(
                                        _formatDuration(viewModel.duration),
                                        style: const TextStyle(
                                            color: Colors.grey, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Contrôles de lecture (Sans Volume)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.shuffle,
                                      color: viewModel.isShuffle ? Colors.purple : Colors.grey),
                                  onPressed: () => viewModel.toggleShuffle(),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.skip_previous,
                                      color: Colors.white, size: 40),
                                  onPressed: () => viewModel.playPrevious(),
                                ),
                                Container(
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.purple,
                                  ),
                                  child: IconButton(
                                    icon: Icon(
                                      viewModel.isPlaying
                                          ? Icons.pause
                                          : Icons.play_arrow,
                                      color: Colors.white,
                                      size: 40,
                                    ),
                                    onPressed: () =>
                                        viewModel.togglePlayPause(),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.skip_next,
                                      color: Colors.white, size: 40),
                                  onPressed: () => viewModel.playNext(),
                                ),
                                IconButton(
                                  icon: Icon(Icons.repeat,
                                      color: viewModel.loopMode != LoopMode.off ? Colors.purple : Colors.grey),
                                  onPressed: () => viewModel.toggleLoopMode(),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 40),

                          // Section Lyrics
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      "Lyrics",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.open_in_full,
                                          color: Colors.white54, size: 20),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const FullLyricsScreen()),
                                        );
                                      },
                                    )
                                  ],
                                ),
                                const SizedBox(height: 8),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const FullLyricsScreen()),
                                    );
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.all(16),
                                    child: viewModel.isLoadingLyrics
                                        ? const Center(
                                            child: SizedBox(
                                                height: 20,
                                                width: 20,
                                                child: CircularProgressIndicator(
                                                    color: Colors.purple, strokeWidth: 2)))
                                        : Text(
                                            viewModel.lyrics ??
                                                "No lyrics available",
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 16,
                                              height: 1.5,
                                            ),
                                            maxLines:
                                                5,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 40),

                          // Section À propos de l'artiste
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ArtistActuScreen(
                                      artistName: song.artist ?? "Artiste",
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2A2A2A),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "A propos de l'artiste",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Container(
                                          width: 60,
                                          height: 60,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.rectangle,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: _buildArtistImage(viewModel, song.artistId),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: viewModel.isLoadingArtist
                                            ? const Text("Chargement...", style: TextStyle(color: Colors.grey))
                                            : Text(
                                            viewModel.artistInfo?.biography ??
                                                "Pas d'informations disponibles pour le moment.",
                                            style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 13),
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 40), // Espace en bas
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildArtistImage(PlayerViewModel viewModel, int? artistId) {
    if (viewModel.artistInfo?.thumbUrl != null) {
      return Image.network(
        viewModel.artistInfo!.thumbUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildLocalArtistImage(artistId),
      );
    }
    return _buildLocalArtistImage(artistId);
  }

  Widget _buildLocalArtistImage(int? artistId) {
      return QueryArtworkWidget(
        id: artistId ?? 0,
        type: ArtworkType.ARTIST,
        nullArtworkWidget: Container(
            color: Colors.grey,
            child: const Icon(
                Icons.person,
                color: Colors.white)),
      );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
