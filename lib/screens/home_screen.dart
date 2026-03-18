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
        // ✅ HEURISTIC #8: Help & Documentation - Add info button
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            tooltip: 'About APOD & Help',
            onPressed: () => _showAboutApodDialog(),
          ),
        ],
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

  // ✅ HEURISTIC #7: Flexibility - Pull-to-refresh
  Widget _buildHomeTab() {
    return RefreshIndicator(
      onRefresh: () async {
        final apodProvider = context.read<ApodProvider>();
        await apodProvider.fetchTodayApod();
        await apodProvider.fetchRecentPhotos(days: 60);
      },
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
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
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (_) => setState(() {}),
                onSubmitted: (query) {
                  if (query.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please enter a search term'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                    return;
                  }
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
                  // ✅ HEURISTIC #1: Visibility - Show errors to user
                  if (apodProvider.error != null) {
                    return Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        border: Border.all(color: Colors.red[300]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red, size: 32),
                          SizedBox(height: 8),
                          Text(
                            apodProvider.error!,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.red[700]),
                          ),
                          SizedBox(height: 12),
                          ElevatedButton.icon(
                            icon: Icon(Icons.refresh),
                            label: Text('Try Again'),
                            onPressed: () {
                              apodProvider.fetchTodayApod();
                            },
                          ),
                        ],
                      ),
                    );
                  }

                  if (apodProvider.isLoading) {
                    return Center(
                      child: Column(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Loading today\'s image...'),
                        ],
                      ),
                    );
                  }

                  if (apodProvider.todayApod == null) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('No data available'),
                      ),
                    );
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
                      final isGrid =
                          settingsProvider.settings.viewPreference ==
                              ViewPreference.grid;
                      return Tooltip(
                        message:
                            isGrid ? 'Switch to list view' : 'Switch to grid view',
                        child: IconButton(
                          icon: Icon(isGrid ? Icons.list : Icons.grid_3x3),
                          tooltip: isGrid ? 'Switch to List' : 'Switch to Grid',
                          onPressed: () {
                            final newPref = isGrid
                                ? ViewPreference.list
                                : ViewPreference.grid;
                            settingsProvider.setViewPreference(newPref);
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            Consumer<ApodProvider>(
              builder: (context, apodProvider, _) {
                // ✅ HEURISTIC #1: Visibility - Show loading state
                if (apodProvider.isLoading && apodProvider.recentPhotos.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Column(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Loading photos... (may take a moment)'),
                        ],
                      ),
                    ),
                  );
                }

                if (apodProvider.recentPhotos.isEmpty &&
                    apodProvider.error == null) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('No photos available'),
                    ),
                  );
                }

                return Consumer<SettingsProvider>(
                  builder: (context, settingsProvider, _) {
                    final isGrid = settingsProvider.settings.viewPreference ==
                        ViewPreference.grid;

                    return Column(
                      children: [
                        // GRID VIEW
                        if (isGrid)
                          Padding(
                            padding: EdgeInsets.all(16),
                            child: GridView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                childAspectRatio: 0.75,
                              ),
                              itemCount: apodProvider.recentPhotos.length,
                              itemBuilder: (context, index) {
                                final photo =
                                    apodProvider.recentPhotos[index];
                                return ImageCard(
                                  image: photo,
                                  fontSize:
                                      settingsProvider.getFontSizeValue(),
                                  isGridView: true,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            DetailScreen(image: photo),
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
                              final photo =
                                  apodProvider.recentPhotos[index];
                              return ImageCard(
                                image: photo,
                                fontSize:
                                    settingsProvider.getFontSizeValue(),
                                isGridView: false,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          DetailScreen(image: photo),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        // LOAD MORE BUTTON
                        if (apodProvider.hasMorePhotos)
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                icon: Icon(Icons.add),
                                label: Text(
                                  'Load More (${apodProvider.recentPhotos.length}/${apodProvider.allRecentPhotos.length})',
                                ),
                                onPressed: () {
                                  apodProvider.loadMorePhotos();
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Loaded ${apodProvider.recentPhotos.length} photos'),
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                },
                              ),
                            ),
                          )
                        else if (apodProvider.allRecentPhotos.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              '✅ All ${apodProvider.allRecentPhotos.length} photos loaded!',
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
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
              Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(16)),
                    child: Image.network(
                      apod.url,
                      height: 250,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 250,
                          color: Colors.grey[300],
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.image_not_supported),
                              SizedBox(height: 8),
                              Text('Image failed to load'),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  // ✅ HEURISTIC #8: Help - "Today's Pick" label
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "Today's Pick",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      apod.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildFavoriteButton(apod)),
                        SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: Icon(Icons.share),
                            label: Text('Share'),
                            onPressed: () {
                              Share.share(
                                'Check out this amazing NASA image: ${apod.title}\n${apod.url}',
                              );
                            },
                          ),
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
                    SnackBar(
                      content: Text('Removed from favorites'),
                      action: SnackBarAction(
                        label: 'Undo',
                        onPressed: () {
                          favoritesProvider.addFavorite(apod);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Added back to favorites'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                      duration: Duration(seconds: 5),
                    ),
                  );
                } else {
                  favoritesProvider.addFavorite(apod);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Added to favorites'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
            );
          },
        );
      },
    );
  }

  // ✅ HEURISTIC #8: Help & Documentation
  void _showAboutApodDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('📚 About APOD'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'What is APOD?',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                'Astronomy Picture of the Day is a NASA service that features a different image of the universe each day with a detailed explanation.',
              ),
              SizedBox(height: 16),
              Text(
                'Tips:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text('• Tap ❤️ to save your favorite images'),
              Text('• Swipe down to refresh the content'),
              Text('• Use the view toggle to switch between list & grid'),
              Text('• Search by title or description'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Got it!'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}