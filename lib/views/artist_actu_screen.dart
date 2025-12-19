import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../viewmodels/player_viewmodel.dart';

class ArtistActuScreen extends StatelessWidget {
  final String artistName;

  const ArtistActuScreen({super.key, required this.artistName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text("Actualités de $artistName",
            style: const TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down,
              color: Colors.white, size: 30),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<PlayerViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoadingArtist) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.purple));
          }

          final info = viewModel.artistInfo;

          if (info == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.info_outline, color: Colors.grey, size: 60),
                  const SizedBox(height: 16),
                  const Text("Informations non disponibles",
                      style: TextStyle(color: Colors.white)),
                  const SizedBox(height: 8),
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Retour"))
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (info.thumbUrl != null)
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      height: 200,
                      width: double.infinity,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          info.thumbUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[900],
                              child: const Icon(Icons.broken_image,
                                  color: Colors.white54, size: 50),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                                color: Colors.purple,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                _buildSectionTitle("Biographie"),
                const SizedBox(height: 16),
                Text(
                  info.biography ?? "Aucune biographie disponible.",
                  style: const TextStyle(
                      color: Colors.grey, fontSize: 14, height: 1.5),
                ),
                const SizedBox(height: 32),

                _buildSectionTitle("Dernières News"),
                const SizedBox(height: 16),
                _buildNewsSection(context, artistName),
                const SizedBox(height: 32),

                // Discography Section - Real data
                _buildSectionTitle("Discographie"),
                const SizedBox(height: 16),
                _buildDiscographySection(context, viewModel, artistName),
                const SizedBox(height: 32),

                _buildSectionTitle("Réseaux Sociaux"),
                const SizedBox(height: 16),
                _buildSocialsSection(context, info),
                const SizedBox(height: 48),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.purpleAccent,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildNewsSection(BuildContext context, String artistName) {
    return SizedBox(
      height: 200,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildNewsCard(
              context,
              "$artistName annonce une nouvelle tournée mondiale",
              Colors.blueGrey),
          _buildNewsCard(context, "Nouvel album de $artistName en préparation",
              Colors.brown),
          _buildNewsCard(context, "Interview exclusive : Les secrets du succès",
              Colors.indigo),
        ],
      ),
    );
  }

  Widget _buildNewsCard(BuildContext context, String title, Color color) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSocialsSection(BuildContext context, dynamic info) {
    return Column(
      children: [
        if (info.website != null && info.website!.isNotEmpty)
          _buildSocialItem(Icons.language, "Site Web", info.website!),
        const SizedBox(height: 12),
        if (info.facebook != null && info.facebook!.isNotEmpty)
          _buildSocialItem(Icons.facebook, "Facebook", info.facebook!),
        const SizedBox(height: 12),
        if (info.twitter != null && info.twitter!.isNotEmpty)
          _buildSocialItem(Icons.close, "X (Twitter)", info.twitter!),
        const SizedBox(height: 12),
        if (info.instagram != null && info.instagram!.isNotEmpty)
          _buildSocialItem(Icons.camera_alt, "Instagram", info.instagram!),
      ],
    );
  }

  Widget _buildSocialItem(IconData icon, String title, String content) {
    return GestureDetector(
      onTap: () => _launchUrl(content),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey[800],
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: Colors.blue, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(content,
                            style: const TextStyle(
                                color: Colors.purple,
                                fontSize: 13,
                                decoration: TextDecoration.underline)),
                      ),
                      const Icon(Icons.open_in_new,
                          color: Colors.purple, size: 16),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    String finalUrl = url;
    if (!url.startsWith('http')) {
      finalUrl = 'https://$url';
    }
    final uri = Uri.parse(finalUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _openSpotifySearch(String artistName, String albumTitle) async {
    final query = Uri.encodeComponent('$artistName $albumTitle');
    final spotifyUrl = 'https://open.spotify.com/search/$query';
    final uri = Uri.parse(spotifyUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildDiscographySection(
      BuildContext context, PlayerViewModel viewModel, String artistName) {
    if (viewModel.isLoadingAlbums) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(color: Colors.purple),
        ),
      );
    }

    final albums = viewModel.artistAlbums;

    if (albums.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          "Aucun album trouvé pour cet artiste.",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: albums.length,
        itemBuilder: (context, index) {
          final album = albums[index];
          return GestureDetector(
            onTap: () => _openSpotifySearch(artistName, album.title),
            child: Container(
              width: 140,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Album artwork
                  Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.3),
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(12)),
                    ),
                    child: album.thumbUrl != null
                        ? ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12)),
                            child: Image.network(
                              album.thumbUrl!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (_, __, ___) => const Center(
                                child: Icon(Icons.album,
                                    color: Colors.white54, size: 40),
                              ),
                            ),
                          )
                        : const Center(
                            child: Icon(Icons.album,
                                color: Colors.white54, size: 40),
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          album.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (album.year != null)
                          Text(
                            album.year!,
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 11),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
