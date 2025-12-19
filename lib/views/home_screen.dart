import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../viewmodels/player_viewmodel.dart';
import 'artist_detail_screen.dart';
import 'album_detail_screen.dart';
import 'profile_screen.dart';
import 'search_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Theme.of(context).scaffoldBackgroundColor, // Use theme background
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context),

            // Contenu scrollable
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(
                      bottom:
                          120.0), // Increased padding for mini player + bottom nav
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section Recently Played
                      _buildSectionTitle(context, 'Recently Played'),
                      _buildRecentlyPlayedList(context),

                      // Section Made For You
                      const SizedBox(height: 24),
                      _buildSectionTitle(context, 'Made For You (Local)'),
                      _buildMadeForYouList(context),

                      // Section Contenu que vous aimez (Spotify)
                      const SizedBox(height: 24),
                      _buildSectionTitle(
                          context, 'Contenu que vous aimez (Spotify)'),
                      _buildSpotifyRecommendationsList(context),

                      // Section Mix prefere
                      const SizedBox(height: 24),
                      _buildSectionTitle(context, 'Mix préféré'),
                      _buildMixPrefereList(context),

                      // Section Selection du jour
                      const SizedBox(height: 24),
                      _buildSectionTitle(context, 'Sélection du jour'),
                      _buildSelectionJourList(context),

                      // Section Albums
                      const SizedBox(height: 24),
                      _buildSectionTitle(context, 'Album'),
                      _buildAlbumList(context),

                      // Section Artistes
                      const SizedBox(height: 24),
                      _buildSectionTitle(context, 'Artistes'),
                      _buildArtistList(context),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ProfileScreen()),
                  );
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey,
                  ),
                  child: const Icon(Icons.person, color: Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              // Optionnel: Ajouter un message de bienvenue
            ],
          ),
          const Text(
            'Home',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildRecentlyPlayedList(BuildContext context) {
    return Consumer<PlayerViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.recentlyPlayed.isEmpty) {
          // Afficher quelques chansons normales si recently played est vide
          if (viewModel.songs.isEmpty) return const SizedBox.shrink();
          // Placeholder: utiliser les 5 premières
          return _buildHorizontalSongList(
              context, viewModel.songs.take(5).toList());
        }
        return _buildHorizontalSongList(context, viewModel.recentlyPlayed);
      },
    );
  }

  Widget _buildMadeForYouList(BuildContext context) {
    return Consumer<PlayerViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.madeForYou.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text("Écoutez de la musique pour voir vos recommandations",
                style: TextStyle(color: Colors.white54)),
          );
        }
        return _buildHorizontalSongList(context, viewModel.madeForYou);
      },
    );
  }

  Widget _buildMixPrefereList(BuildContext context) {
    return Consumer<PlayerViewModel>(
      builder: (context, viewModel, child) {
        // Logic: Top played songs from storage (we can use madeForYou logic as proxy or simple random for now if play counts not high enough yet)
        // Ideally viewModel should expose a specific `topPlayed` list.
        // For now, let's use a shuffled mix of songs to simulate "Mix Preféré" but dynamic.

        if (viewModel.songs.isEmpty) return const SizedBox.shrink();

        // Use a deterministic shuffle based on day to simulate "Daily Mix"
        final seed = DateTime.now().day;
        final mixedSongs = List<SongModel>.from(viewModel.songs)
          ..shuffle(Random(seed));
        final displaySongs = mixedSongs.take(5).toList();

        return _buildHorizontalSongList(context, displaySongs);
      },
    );
  }

  Widget _buildSpotifyRecommendationsList(BuildContext context) {
    return Consumer<PlayerViewModel>(
      builder: (context, viewModel, child) {
        // Logic: Suggest content based on Genre or Artist Similarity
        // Instead of just linking to the specific song, we link to a search for "Genre" or "Artist Mix"

        final songs = viewModel.madeForYou.take(5).toList();
        if (songs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
                "Écoutez de la musique pour débloquer ces recommandations.",
                style: TextStyle(color: Colors.white54)),
          );
        }

        return SizedBox(
          height: 160,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: songs.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final song = songs[index];
              final artist = song.artist ?? "Music";

              // We try to infer a "style" or "mood" if genre is missing (common in local files)
              // For now, we search for "Artist Mix" or "Songs similar to Artist"
              final String searchTerm = "$artist mix";

              return GestureDetector(
                onTap: () async {
                  final Uri url = Uri.parse(
                      "https://open.spotify.com/search/${Uri.encodeComponent(searchTerm)}");
                  if (!await launchUrl(url,
                      mode: LaunchMode.externalApplication)) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Impossible d'ouvrir Spotify")));
                  }
                },
                child: Container(
                  width: 120,
                  margin: const EdgeInsets.only(right: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: const Color(0xFF1DB954), // Spotify Green
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Try to show artist artwork if possible, else Icon
                            Expanded(
                              child: QueryArtworkWidget(
                                id: song.id,
                                type: ArtworkType
                                    .AUDIO, // Use song art as proxy for "Style"
                                nullArtworkWidget: const Icon(Icons.podcasts,
                                    color: Colors.white, size: 40),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Mix $artist",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Ouvrir dans Spotify",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSelectionJourList(BuildContext context) {
    return Consumer<PlayerViewModel>(builder: (context, viewModel, child) {
      final randomSongs =
          (viewModel.songs.toList()..shuffle()).take(15).toList();
      return _buildHorizontalSongList(context, randomSongs);
    });
  }

  Widget _buildHorizontalSongList(BuildContext context, List<SongModel> songs) {
    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: songs.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final song = songs[index];
          return GestureDetector(
            onTap: () => context.read<PlayerViewModel>().playSong(song),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                      id: song.id,
                      type: ArtworkType.AUDIO,
                      nullArtworkWidget: const Icon(Icons.music_note,
                          size: 50, color: Colors.white54),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: 120,
                  child: Text(
                    song.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(
                  width: 120,
                  child: Text(
                    song.artist ?? 'Unknown Artist',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAlbumList(BuildContext context) {
    return Consumer<PlayerViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.albums.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text("Aucun album trouvé",
                style: TextStyle(color: Colors.white54)),
          );
        }

        return SizedBox(
          height: 180,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: viewModel.albums.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final album = viewModel.albums[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AlbumDetailScreen(album: album),
                    ),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                              size: 50, color: Colors.white54),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 120,
                      child: Text(
                        album.album,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 120,
                      child: Text(
                        "${album.numOfSongs} chansons",
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildArtistList(BuildContext context) {
    return Consumer<PlayerViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.artists.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text("Aucun artiste trouvé",
                style: TextStyle(color: Colors.white54)),
          );
        }

        return SizedBox(
          height: 150,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: viewModel.artists.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final artist = viewModel.artists[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ArtistDetailScreen(artist: artist),
                    ),
                  );
                },
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[800],
                      ),
                      child: ClipOval(
                        child: QueryArtworkWidget(
                          id: artist.id,
                          type: ArtworkType.ARTIST,
                          nullArtworkWidget: const Icon(Icons.person,
                              size: 50, color: Colors.white54),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 100,
                      child: Text(
                        artist.artist,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
