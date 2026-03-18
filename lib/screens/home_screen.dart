import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/settings_model.dart';
import '../providers/apod_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/platform_bottom_nav.dart';
import '../widgets/image_card.dart';
import 'detail_screen.dart';
import 'search_results_screen.dart';
import 'favorites_screen.dart';
import 'settings_screen.dart';


class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AstroView'),
        centerTitle: true,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeTab(),
          FavoritesScreen(),
          SettingsScreen(),
        ],
      ),
      bottomNavigationBar: PlatformBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
      ),
    );
  }

  Widget _buildHomeTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search images...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onSubmitted: (query) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SearchResultsScreen(query: query),
                  ),
                );
                _searchController.clear();
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Consumer<ApodProvider>(
              builder: (context, apodProvider, _) {
                if (apodProvider.isLoading) {
                  return Center(child: CircularProgressIndicator());
                }

                if (apodProvider.todayApod == null) {
                  return Center(child: Text('No data available'));
                }

                final apod = apodProvider.todayApod!;
                return _buildFeaturedCard(apod);
              },
            ),
          ),
          // Recent Photos Header with View Toggle
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Consumer<SettingsProvider>(
                  builder: (context, settingsProvider, _) {
                    return Text(
                      'Recent Photos',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: settingsProvider.getHeadlineFontSize(),
                      ),
                    );
                  },
                ),
                // Toggle Button
                Consumer<SettingsProvider>(
                  builder: (context, settingsProvider, _) {
                    final isGrid = settingsProvider.settings.viewPreference == ViewPreference.grid;
                    return IconButton(
                      icon: Icon(isGrid ? Icons.list : Icons.grid_3x3),
                      tooltip: isGrid ? 'Switch to List' : 'Switch to Grid',
                      onPressed: () {
                        final newPref = isGrid ? ViewPreference.list : ViewPreference.grid;
                        settingsProvider.setViewPreference(newPref);
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          Consumer<ApodProvider>(
            builder: (context, apodProvider, _) {
              if (apodProvider.recentPhotos.isEmpty) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Loading photos...'),
                  ),
                );
              }

              return Consumer<SettingsProvider>(
                builder: (context, settingsProvider, _) {
                  final isGrid = settingsProvider.settings.viewPreference == ViewPreference.grid;
                  
                  return Column(
                    children: [
                      // GRID VIEW
                      if (isGrid)
                        Padding(
                          padding: EdgeInsets.all(16),
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 0.75,
                            ),
                            itemCount: apodProvider.recentPhotos.length,
                            itemBuilder: (context, index) {
                              final photo = apodProvider.recentPhotos[index];
                              return ImageCard(
                                image: photo,
                                fontSize: settingsProvider.getFontSizeValue(),
                                isGridView: true,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => DetailScreen(image: photo),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        )
                      // LIST VIEW
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.all(16),
                          itemCount: apodProvider.recentPhotos.length,
                          itemBuilder: (context, index) {
                            final photo = apodProvider.recentPhotos[index];
                            return ImageCard(
                              image: photo,
                              fontSize: settingsProvider.getFontSizeValue(),
                              isGridView: false,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => DetailScreen(image: photo),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      // LOAD MORE BUTTON
                      if (apodProvider.hasMorePhotos)
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: Icon(Icons.add),
                              label: Text(
                                'Load More (${apodProvider.recentPhotos.length}/${apodProvider.allRecentPhotos.length})',
                              ),
                              onPressed: () {
                                print('🔄 Load More clicked!');
                                apodProvider.loadMorePhotos();
                              },
                            ),
                          ),
                        )
                      else
                        Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            '✅ All ${apodProvider.allRecentPhotos.length} photos loaded!',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              );
            },
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildFeaturedCard(dynamic apod) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, _) {
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  apod.url,
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 250,
                      color: Colors.grey[300],
                      child: Icon(Icons.image_not_supported),
                    );
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      apod.title,
                      style: TextStyle(
                        fontSize: settingsProvider.getHeadlineFontSize(),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      apod.date,
                      style: TextStyle(
                        fontSize: settingsProvider.getFontSizeValue(),
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        _buildFavoriteButton(apod),
                        SizedBox(width: 8),
                        ElevatedButton.icon(
                          icon: Icon(Icons.share),
                          label: Text('Share'),
                          onPressed: () {
                            Share.share(
                              'Check out this amazing NASA image: ${apod.title}\n${apod.url}',
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFavoriteButton(dynamic apod) {
    return Consumer<FavoritesProvider>(
      builder: (context, favoritesProvider, _) {
        return FutureBuilder<bool>(
          future: favoritesProvider.isFavorite(apod.date),
          builder: (context, snapshot) {
            final isFavorite = snapshot.data ?? false;
            return ElevatedButton.icon(
              icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
              label: Text('Favorite'),
              onPressed: () {
                if (isFavorite) {
                  favoritesProvider.removeFavorite(apod.date);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Removed from favorites')),
                  );
                } else {
                  favoritesProvider.addFavorite(apod);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Added to favorites')),
                  );
                }
              },
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}