import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';
import '../viewmodels/player_viewmodel.dart';
import 'artist_actu_screen.dart';

class ArtistDetailScreen extends StatefulWidget {
  final ArtistModel artist;

  const ArtistDetailScreen({super.key, required this.artist});

  @override
  State<ArtistDetailScreen> createState() => _ArtistDetailScreenState();
}

class _ArtistDetailScreenState extends State<ArtistDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch artist info when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<PlayerViewModel>();
      viewModel.fetchArtistInfoByName(widget.artist.artist);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.artist.artist),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ArtistActuScreen(
                    artistName: widget.artist.artist,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<PlayerViewModel>(
        builder: (context, viewModel, child) {
          final artistSongs = viewModel.songs
              .where((s) => s.artistId == widget.artist.id)
              .toList();
          final info = viewModel.artistInfo;

          return Column(
            children: [
              // Header with network image
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
                        child: _buildArtistImage(viewModel, widget.artist.id),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.artist.artist,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Genre and country info
                    if (info?.genre != null || info?.country != null)
                      Text(
                        [info?.genre, info?.country]
                            .where((e) => e != null)
                            .join(' • '),
                        style:
                            TextStyle(color: Colors.purple[200], fontSize: 14),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      "${artistSongs.length} Chansons",
                      style: const TextStyle(color: Colors.grey),
                    ),
                    // Biography snippet
                    if (info?.biography != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          info!.biography!,
                          style:
                              const TextStyle(color: Colors.grey, fontSize: 13),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
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

  Widget _buildArtistImage(PlayerViewModel viewModel, int artistId) {
    if (viewModel.artistInfo?.thumbUrl != null) {
      return Image.network(
        viewModel.artistInfo!.thumbUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildLocalArtistImage(artistId),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
              color: Colors.purple,
            ),
          );
        },
      );
    }
    return _buildLocalArtistImage(artistId);
  }

  Widget _buildLocalArtistImage(int artistId) {
    return QueryArtworkWidget(
      id: artistId,
      type: ArtworkType.ARTIST,
      nullArtworkWidget:
          const Icon(Icons.person, size: 80, color: Colors.white54),
    );
  }
}
