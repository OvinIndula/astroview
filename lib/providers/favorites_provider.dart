import 'package:flutter/material.dart';
import '../models/apod_model.dart';
import '../services/database_service.dart';

class FavoritesProvider extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  List<ApodImage> _favorites = [];
  bool _isLoading = false;
  String? _error;

  List<ApodImage> get favorites => _favorites;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadFavorites() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _favorites = await _dbService.getFavorites();
      print('✅ Loaded ${_favorites.length} favorites');
    } catch (e) {
      _error = 'Error loading favorites: $e';
      print('❌ Error loading favorites: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addFavorite(ApodImage image) async {
    try {
      await _dbService.addFavorite(image);
      print('✅ Added favorite: ${image.title}');
      await loadFavorites();
    } catch (e) {
      _error = 'Error adding favorite: $e';
      print('❌ Error adding favorite: $e');
      notifyListeners();
    }
  }

  Future<void> removeFavorite(String date) async {
    try {
      await _dbService.removeFavorite(date);
      print('✅ Removed favorite: $date');
      // ✅ HEURISTIC #3: User Control - Don't reload immediately for better UX
      // Just remove from local list for instant feedback
      _favorites.removeWhere((fav) => fav.date == date);
      notifyListeners();
    } catch (e) {
      _error = 'Error removing favorite: $e';
      print('❌ Error removing favorite: $e');
      notifyListeners();
    }
  }

  Future<bool> isFavorite(String date) async {
    try {
      bool result = await _dbService.isFavorite(date);
      return result;
    } catch (e) {
      print('❌ Error checking favorite: $e');
      return false;
    }
  }
}