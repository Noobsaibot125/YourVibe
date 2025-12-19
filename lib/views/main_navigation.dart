import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../viewmodels/player_viewmodel.dart';
import 'home_screen.dart';
import 'Search_screen.dart';
import 'library_screen.dart';
import 'player_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const SearchScreen(),
    const LibraryScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Charger les chansons au démarrage si ce n'est pas déjà fait
    Future.microtask(() {
      final viewModel = context.read<PlayerViewModel>();
      if (viewModel.songs.isEmpty) {
        viewModel.loadSongs();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Contenu principal
          Padding(
            padding: const EdgeInsets.only(
                bottom: 140), // Espace pour le mini player + nav bar
            child: IndexedStack(
              index: _currentIndex,
              children: _screens,
            ),
          ),

          // Mini Player et Navigation en bas
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Mini Player
                Consumer<PlayerViewModel>(
                  builder: (context, viewModel, child) {
                    if (viewModel.currentSong == null) {
                      return const SizedBox.shrink();
                    }
                    return _buildMiniPlayer(context, viewModel);
                  },
                ),

                // Bottom Navigation Bar
                NavigationBar(
                  selectedIndex: _currentIndex,
                  onDestinationSelected: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.home_outlined),
                      selectedIcon: Icon(Icons.home),
                      label: 'Accueil',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.search_outlined),
                      selectedIcon: Icon(Icons.search),
                      label: 'Rechercher',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.library_music_outlined),
                      selectedIcon: Icon(Icons.library_music),
                      label: 'Bibliothèque',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniPlayer(BuildContext context, PlayerViewModel viewModel) {
    final song = viewModel.currentSong!;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PlayerScreen(),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Barre de progression
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: LinearProgressIndicator(
                value: viewModel.duration.inMilliseconds > 0
                    ? viewModel.position.inMilliseconds /
                        viewModel.duration.inMilliseconds
                    : 0,
                backgroundColor:
                    Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
                minHeight: 2,
              ),
            ),

            // Contenu
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  // Artwork
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Theme.of(context).colorScheme.surface,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: QueryArtworkWidget(
                        key: Key(
                            song.id.toString()), // Force rebuild on song change
                        id: song.id,
                        type: ArtworkType.AUDIO,
                        nullArtworkWidget: Icon(
                          Icons.music_note,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Infos
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          song.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        Text(
                          song.artist ?? 'Artiste inconnu',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                        ),
                      ],
                    ),
                  ),

                  // Contrôles
                  IconButton(
                    icon: Icon(
                      viewModel.isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      size: 32,
                    ),
                    onPressed: () => viewModel.togglePlayPause(),
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_next_rounded, size: 32),
                    onPressed: () => viewModel.playNext(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
