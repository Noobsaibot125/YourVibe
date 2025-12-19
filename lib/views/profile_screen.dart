import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/profile_viewmodel.dart';
import '../viewmodels/player_viewmodel.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showEditProfileDialog(BuildContext context, ProfileViewModel viewModel) {
    final nameController = TextEditingController(text: viewModel.name);
    final bioController = TextEditingController(text: viewModel.bio);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Text("Edit Profile", style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Name",
                labelStyle: TextStyle(color: Colors.purpleAccent),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.purpleAccent)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: bioController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Bio",
                labelStyle: TextStyle(color: Colors.purpleAccent),
                 enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.purpleAccent)),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              viewModel.saveProfile(nameController.text, bioController.text);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
            child: const Text("Save", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Access PlayerViewModel for stats
    final playerViewModel = Provider.of<PlayerViewModel>(context);
    final playlistCount = playerViewModel.playlists.length;
    final likedCount = playerViewModel.likedSongs.length;

    return Scaffold(
      backgroundColor: Colors.black, // Dark theme background
      body: SafeArea(
        child: Consumer<ProfileViewModel>(
          builder: (context, profileViewModel, child) {
            if (profileViewModel.isLoading) {
              return const Center(child: CircularProgressIndicator(color: Colors.purple));
            }

            return NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        // App Bar custom
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.arrow_back,
                                      color: Colors.white),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ),
                              const Spacer(),
                              const Icon(Icons.more_horiz, color: Colors.white),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Avatar
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.purple, width: 2),
                            // Mock placeholder
                            color: Colors.grey[800],
                          ),
                          child: const Icon(Icons.person,
                              size: 60, color: Colors.white),
                        ),
                        const SizedBox(height: 12),

                        // Name
                        Text(
                          profileViewModel.name,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold),
                        ),
                         const SizedBox(height: 4),
                         Text(
                          profileViewModel.bio,
                          style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14),
                              textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),

                        // Edit Profile Button
                        ElevatedButton(
                          onPressed: () => _showEditProfileDialog(context, profileViewModel),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6A1B9A), // Purple
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                          ),
                          child: const Text("Edit Profile"),
                        ),
                        const SizedBox(height: 24),

                        // Stats
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatItem("$likedCount", "Liked Songs"),
                            _buildStatItem("$playlistCount", "Playlists"),
                            _buildStatItem("0", "Following"), // Mock
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),

                  // Tab Bar stuck at top
                  SliverPersistentHeader(
                    delegate: _SliverAppBarDelegate(
                      TabBar(
                        controller: _tabController,
                        indicatorColor: Colors.purple,
                        indicatorWeight: 3,
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.grey,
                        tabs: const [
                          Tab(text: "Overview"),
                          Tab(text: "Public Playlists"),
                          Tab(text: "Liked Songs"),
                        ],
                      ),
                    ),
                    pinned: true,
                  ),
                ];
              },
              body: TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(),
                  _buildPlaceholderTab("Public Playlists"),
                  _buildPlaceholderTab("Liked Songs"),
                ],
              ),
            );
          }
        ),
      ),
    );
  }

  Widget _buildStatItem(String count, String label) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Recently Played Artists",
            style: TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildArtistAvatar("Drake", Colors.blueGrey),
                _buildArtistAvatar("Billie Eilish", Colors.amber),
                _buildArtistAvatar("Rochloe", Colors.redAccent),
                _buildArtistAvatar("Maelys", Colors.green),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "Top Genres",
            style: TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildGenreChip("Genres", isSelected: true),
              _buildGenreChip("Top-mush"),
              _buildGenreChip("Music", isSelected: true),
              _buildGenreChip("Lop mush"),
              _buildGenreChip("Media"),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            "My Playlists",
            style: TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 140,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildPlaylistCard("Chill Vibes", "Chill Vibes", Colors.teal),
                _buildPlaylistCard("Workout Mix", "Workout Mix", Colors.orange),
                _buildPlaylistCard("Wno Drot", "Wno Drot", Colors.deepOrange),
                _buildPlaylistCard("Bora Pla", "Mencap", Colors.blue),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArtistAvatar(String name, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: color,
            // Mock image placeholder
            child: Text(name[0],
                style: const TextStyle(color: Colors.white, fontSize: 24)),
          ),
          const SizedBox(height: 8),
          Text(name, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildGenreChip(String label, {bool isSelected = false}) {
    return Chip(
      label: Text(label),
      backgroundColor: isSelected ? Colors.purple : Colors.grey[800],
      labelStyle: const TextStyle(color: Colors.white),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), side: BorderSide.none),
    );
  }

  Widget _buildPlaylistCard(String title, String subtitle, Color color) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            // Placeholder content
            child: const Center(
                child: Icon(Icons.music_note, color: Colors.white, size: 40)),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderTab(String title) {
    return Center(
      child: Text(title, style: const TextStyle(color: Colors.white)),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.black,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
