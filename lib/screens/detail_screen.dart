import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/apod_model.dart';
import '../providers/favorites_provider.dart';

class DetailScreen extends StatelessWidget {
  final ApodImage image;

  const DetailScreen({Key? key, required this.image}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Details'),
        leading: BackButton(),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
              child: Image.network(
                image.url,
                height: 300,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 300,
                    color: Colors.grey[200],
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 300,
                    color: Colors.grey[300],
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image_not_supported, size: 48),
                        SizedBox(height: 8),
                        Text('Failed to load image'),
                      ],
                    ),
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
                    image.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Date: ${image.date}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (image.copyright != null && image.copyright!.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        'Copyright: ${image.copyright}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  SizedBox(height: 16),
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    image.explanation,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _buildFavoriteButton(image, context),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: Icon(Icons.share),
                          label: Text('Share'),
                          onPressed: () {
                            Share.share(
                              'Check out this amazing NASA image: ${image.title}\n${image.url}',
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Explore More'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ HEURISTIC #3: User Control - Confirmation + Undo
  Widget _buildFavoriteButton(ApodImage apod, BuildContext context) {
    return Consumer<FavoritesProvider>(
      builder: (context, favoritesProvider, _) {
        return FutureBuilder<bool>(
          future: favoritesProvider.isFavorite(apod.date),
          builder: (context, snapshot) {
            final isFavorite = snapshot.data ?? false;
            return ElevatedButton.icon(
              icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
              label: Text(isFavorite ? 'Favorited' : 'Favorite'),
              onPressed: () {
                if (isFavorite) {
                  // ✅ HEURISTIC #5: Error Prevention - Confirmation dialog
                  showDialog(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: Text('Remove Favorite?'),
                      content: Text(
                        'This image will be removed from your saved favorites.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: Text('CANCEL'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(dialogContext);
                            favoritesProvider.removeFavorite(apod.date);

                            // ✅ HEURISTIC #3: User Control - Undo option
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Removed from favorites'),
                                action: SnackBarAction(
                                  label: 'UNDO',
                                  onPressed: () {
                                    favoritesProvider.addFavorite(apod);
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      SnackBar(
                                        content:
                                            Text('Added back to favorites'),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  },
                                ),
                                duration: Duration(seconds: 5),
                              ),
                            );
                          },
                          child: Text(
                            'DELETE',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
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
}