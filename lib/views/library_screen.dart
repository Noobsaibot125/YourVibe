import 'liked_songs_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../viewmodels/player_viewmodel.dart';
import 'artist_detail_screen.dart';
import 'album_detail_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  int _selectedTabIndex = 0; // 0: Pistes, 1: Playlists, 2: Artists, 3: Albums

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildFilterChips(context),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildSortRow(),
                    _buildLikedSongsItem(context),
                    _buildContentList(context),
                  ],
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
        children: [
          Container(
            width: 35,
            height: 35,
            decoration: const BoxDecoration(
              color: Colors.purple, // Avatar placeholder color
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 16),
          const Text(
            'Your Library',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          const Icon(Icons.search, color: Colors.white, size: 28),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white, size: 30),
            onPressed: () => _showCreatePlaylistDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    final filters = ["Piste", "Playlists", "Artists", "Albums"];
    return SizedBox(
      height: 50,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = _selectedTabIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedTabIndex = index;
              });
            },
            child: Chip(
              label: Text(
                filters[index],
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.white,
                  fontSize: 13,
                ),
              ),
              backgroundColor: isSelected ? Colors.white : Colors.grey[900],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                    color: isSelected ? Colors.white : Colors.grey[800]!),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSortRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: const [
              Icon(Icons.import_export, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text(
                "Recently Played",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const Icon(Icons.grid_view, color: Colors.white, size: 18),
        ],
      ),
    );
  }

  Widget _buildLikedSongsItem(BuildContext context) {
    return ListTile(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LikedSongsScreen()),
        );
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        width: 55,
        height: 55,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4A148C), Color(0xFF880E4F)], // Purple gradient
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Center(
          child: Icon(Icons.favorite, color: Colors.white, size: 24),
        ),
      ),
      title: const Text(
        "Liked Songs",
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      subtitle: Row(
        children: [
          const Icon(Icons.push_pin,
              color: Colors.green, size: 12), // Pinned icon
          const SizedBox(width: 4),
          Consumer<PlayerViewModel>(builder: (context, vm, child) {
            return Text(
              "Playlist • ${vm.likedSongs.length} songs",
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildContentList(BuildContext context) {
    return Consumer<PlayerViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Padding(
            padding: EdgeInsets.all(32.0),
            child:
                Center(child: CircularProgressIndicator(color: Colors.white)),
          );
        }

        switch (_selectedTabIndex) {
          case 0: // Piste (Songs)
            return _buildSongList(viewModel.songs);
          case 1: // Playlists
            return _buildPlaylistList(viewModel.playlists);
          case 2: // Artists
            return _buildArtistList(viewModel.artists);
          case 3: //Albums
            return _buildAlbumList(viewModel.albums);
          default:
            return const SizedBox();
        }
      },
    );
  }

  Widget _buildSongList(List<SongModel> songs) {
    if (songs.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32.0),
        child: Text("No songs found", style: TextStyle(color: Colors.grey)),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: songs.length,
      itemBuilder: (context, index) {
        final song = songs[index];
        return _buildListItem(
          context,
          title: song.title,
          subtitle: song.artist ?? "Unknown Artist",
          id: song.id,
          type: ArtworkType.AUDIO,
          isRound: false,
          onTap: () => context.read<PlayerViewModel>().playSong(song),
        );
      },
    );
  }

  Widget _buildArtistList(List<ArtistModel> artists) {
    if (artists.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32.0),
        child: Text("No artists found", style: TextStyle(color: Colors.grey)),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: artists.length,
      itemBuilder: (context, index) {
        final artist = artists[index];
        return _buildListItem(
          context,
          title: artist.artist,
          subtitle: "${artist.numberOfTracks} tracks",
          id: artist.id,
          type: ArtworkType.ARTIST,
          isRound: true,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ArtistDetailScreen(artist: artist),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAlbumList(List<AlbumModel> albums) {
    if (albums.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32.0),
        child: Text("No albums found", style: TextStyle(color: Colors.grey)),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: albums.length,
      itemBuilder: (context, index) {
        final album = albums[index];
        return _buildListItem(
          context,
          title: album.album,
          subtitle: "${album.numOfSongs} songs",
          id: album.id,
          type: ArtworkType.ALBUM,
          isRound: false,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AlbumDetailScreen(album: album),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildListItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required int id,
    required ArtworkType type,
    required bool isRound,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        width: 55,
        height: 55,
        decoration: BoxDecoration(
          color: Colors.grey[850],
          shape: isRound ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: isRound ? null : BorderRadius.circular(4),
        ),
        child: ClipRRect(
          borderRadius:
              isRound ? BorderRadius.circular(100) : BorderRadius.circular(4),
          child: QueryArtworkWidget(
            id: id,
            type: type,
            nullArtworkWidget: Icon(
              type == ArtworkType.ARTIST ? Icons.person : Icons.album,
              color: Colors.white54,
            ),
          ),
        ),
      ),
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        subtitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: Colors.grey, fontSize: 12),
      ),
    );
  }

  Widget _buildPlaylistList(Map<String, List<SongModel>> playlists) {
    if (playlists.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              const Text("No playlists yet",
                  style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _showCreatePlaylistDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                ),
                child: const Text("Create Playlist"),
              )
            ],
          ),
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: playlists.length,
      itemBuilder: (context, index) {
        final name = playlists.keys.elementAt(index);
        final count = playlists[name]?.length ?? 0;
        return ListTile(
          leading: Container(
              width: 55,
              height: 55,
              color: Colors.grey[900],
              child: const Icon(Icons.queue_music, color: Colors.white)),
          title: Text(name, style: const TextStyle(color: Colors.white)),
          subtitle:
              Text("$count songs", style: const TextStyle(color: Colors.grey)),
          onTap: () {
            // Navigate to playlist detail (Placeholder)
          },
        );
      },
    );
  }

  void _showCreatePlaylistDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text("Create Playlist",
              style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: "Playlist Name",
              hintStyle: TextStyle(color: Colors.grey),
              enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.purple)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  context
                      .read<PlayerViewModel>()
                      .createPlaylist(controller.text);
                  Navigator.pop(context);
                }
              },
              child:
                  const Text("Create", style: TextStyle(color: Colors.purple)),
            ),
          ],
        );
      },
    );
  }
}
