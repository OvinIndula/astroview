import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/settings_model.dart';
import '../providers/apod_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/image_card.dart';
import 'detail_screen.dart';

class SearchResultsScreen extends StatefulWidget {
  final String query;

  const SearchResultsScreen({Key? key, required this.query}) : super(key: key);

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ApodProvider>().searchPhotos(widget.query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search: ${widget.query}'),
        leading: BackButton(),
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
      body: Consumer2<ApodProvider, SettingsProvider>(
        builder: (context, apodProvider, settingsProvider, _) {
          if (apodProvider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (apodProvider.searchResults.isEmpty) {
            return Center(child: Text('No results found'));
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
                  itemCount: apodProvider.searchResults.length,
                  itemBuilder: (context, index) {
                    final photo = apodProvider.searchResults[index];
                    return ImageCard(
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
                    );
                  },
                )
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: apodProvider.searchResults.length,
                  itemBuilder: (context, index) {
                    final photo = apodProvider.searchResults[index];
                    return ImageCard(
                      image: photo,
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
                );
        },
      ),
    );
  }
}