import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
                                 value: loadingProgress.expectedTotalBytes != null
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

                _buildSectionTitle("Dernières News (Demo)"),
                const SizedBox(height: 16),
                _buildNewsSection(context),
                const SizedBox(height: 32),

                _buildSectionTitle("Concerts & Événements (Demo)"),
                const SizedBox(height: 16),
                _buildConcertsSection(context),
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

  Widget _buildNewsSection(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildNewsCard(
              context,
              "$artistName annonce une nouvelle tournée mondiale",
              Colors.blueGrey),
          _buildNewsCard(context, "Nouvel album en préparation", Colors.brown),
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

  Widget _buildConcertsSection(BuildContext context) {
    return Column(
      children: [
        _buildConcertItem(
            "Lot", "20", "déc", artistName, "Line Delue • Ortrania"),
        const SizedBox(height: 12),
        _buildConcertItem("Let", "23", "NOV", artistName, "North Arena • USA"),
      ],
    );
  }

  Widget _buildConcertItem(
      String day, String date, String month, String artist, String location) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(day,
                    style: const TextStyle(color: Colors.purple, fontSize: 12)),
                Text(date,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                Text(month,
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(artist,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
                Text(location,
                    style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purpleAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            ),
            child: const Text("Tickets"),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialsSection(BuildContext context, dynamic info) {
    return Column(
      children: [
        if (info.website != null && info.website!.isNotEmpty)
          _buildSocialItem(Icons.language, "Website", info.website!),
        const SizedBox(height: 12),
        if (info.facebook != null && info.facebook!.isNotEmpty)
          _buildSocialItem(Icons.facebook, "Facebook", info.facebook!),
        const SizedBox(height: 12),
        if (info.twitter != null && info.twitter!.isNotEmpty)
          _buildSocialItem(Icons.close, "X (Twitter)", info.twitter!),
      ],
    );
  }

  Widget _buildSocialItem(IconData icon, String title, String content) {
    return Container(
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
                Text(content,
                    style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                        decoration: TextDecoration.underline)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
