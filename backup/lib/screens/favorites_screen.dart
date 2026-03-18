import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/settings_model.dart';
import '../providers/favorites_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/image_card.dart';
import 'detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Favorites'),
          centerTitle: true,
          automaticallyImplyLeading: false,
          actions: [
            Consumer<SettingsProvider>(
              builder: (context, settingsProvider, _) {
                final isGrid = settingsProvider.settings.viewPreference == ViewPreference.grid;
                return IconButton(
                  icon: Icon(isGrid ? Icons.list : Icons.grid_3x3),
                  onPressed: () {
                    final newPreference = isGrid ? ViewPreference.list : ViewPreference.grid;
                    settingsProvider.setViewPreference(newPreference);
                  },
                );
              },
            ),
          ],
        ),
        body: Consumer2<FavoritesProvider, SettingsProvider>(
          builder: (context, favoritesProvider, settingsProvider, _) {
            if (favoritesProvider.isLoading) {
              return Center(child: CircularProgressIndicator());
            }

            if (favoritesProvider.favorites.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('No favorites yet'),
                  ],
                ),
              );
            }

            final isGrid = settingsProvider.settings.viewPreference == ViewPreference.grid;

            return isGrid
                ? GridView.builder(
                    padding: EdgeInsets.all(8),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: favoritesProvider.favorites.length,
                    itemBuilder: (context, index) {
                      final photo = favoritesProvider.favorites[index];
                      return Stack(
                        children: [
                          ImageCard(
                            image: photo,
                            isGridView: true,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DetailScreen(image: photo),
                                ),
                              );
                            },
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: IconButton(
                              icon: Icon(Icons.close, color: Colors.red),
                              onPressed: () {
                                favoritesProvider.removeFavorite(photo.date);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Removed from favorites')),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: favoritesProvider.favorites.length,
                    itemBuilder: (context, index) {
                      final photo = favoritesProvider.favorites[index];
                      return Dismissible(
                        key: Key(photo.date),
                        onDismissed: (_) {
                          favoritesProvider.removeFavorite(photo.date);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Removed from favorites')),
                          );
                        },
                        child: ImageCard(
                          image: photo,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DetailScreen(image: photo),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
          },
        ),
      ),
    );
  }
}