import 'package:flutter/material.dart';
import '../models/apod_model.dart';
import '../services/database_service.dart';

class FavoritesProvider extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  List<ApodImage> _favorites = [];
  bool _isLoading = false;

  List<ApodImage> get favorites => _favorites;
  bool get isLoading => _isLoading;

  Future<void> loadFavorites() async {
    _isLoading = true;
    notifyListeners();

    try {
      _favorites = await _dbService.getFavorites();
      print('Loaded ${_favorites.length} favorites');
    } catch (e) {
      print('Error loading favorites: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addFavorite(ApodImage image) async {
    try {
      await _dbService.addFavorite(image);
      print('Added favorite: ${image.title}');
      await loadFavorites();
    } catch (e) {
      print('Error adding favorite: $e');
    }
  }

  Future<void> removeFavorite(String date) async {
    try {
      await _dbService.removeFavorite(date);
      print('Removed favorite: $date');
      await loadFavorites();
    } catch (e) {
      print('Error removing favorite: $e');
    }
  }

  Future<bool> isFavorite(String date) async {
    try {
      bool result = await _dbService.isFavorite(date);
      return result;
    } catch (e) {
      print('Error checking favorite: $e');
      return false;
    }
  }
}