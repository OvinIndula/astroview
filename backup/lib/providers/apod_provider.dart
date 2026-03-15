import 'package:flutter/material.dart';
import '../models/apod_model.dart';
import '../services/nasa_service.dart';

class ApodProvider extends ChangeNotifier {
  ApodImage? _todayApod;
  List<ApodImage> _allRecentPhotos = [];
  List<ApodImage> _displayedPhotos = [];
  List<ApodImage> _searchResults = [];
  bool _isLoading = false;
  String? _error;
  int _itemsToDisplay = 10;

  ApodImage? get todayApod => _todayApod;
  List<ApodImage> get recentPhotos => _displayedPhotos;
  List<ApodImage> get allRecentPhotos => _allRecentPhotos;
  List<ApodImage> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMorePhotos => _displayedPhotos.length < _allRecentPhotos.length;

  Future<void> fetchTodayApod() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _todayApod = await NasaService.getTodayApod();
      print('Today APOD fetched: ${_todayApod?.title}');
    } catch (e) {
      _error = e.toString();
      print('Error fetching today APOD: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchRecentPhotos({int days = 30}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allRecentPhotos = await NasaService.getRecentPhotos(days: days);
      print('Total photos fetched: ${_allRecentPhotos.length}');
      
      _itemsToDisplay = 10;
      _updateDisplayedPhotos();
    } catch (e) {
      _error = e.toString();
      print('Error fetching recent photos: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _updateDisplayedPhotos() {
    _displayedPhotos = _allRecentPhotos.take(_itemsToDisplay).toList();
    print('📸 Now showing ${_displayedPhotos.length}/${_allRecentPhotos.length} photos');
    notifyListeners();
  }

  void loadMorePhotos() {
    if (hasMorePhotos) {
      if (_itemsToDisplay == 10) {
        _itemsToDisplay = 20;
      } else if (_itemsToDisplay == 20) {
        _itemsToDisplay = 40;
      } else {
        _itemsToDisplay += 20;
      }
      
      _updateDisplayedPhotos();
      print('✅ Load More clicked! Showing ${_displayedPhotos.length} items');
    }
  }

  Future<void> searchPhotos(String query, {int days = 60}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final allPhotos = await NasaService.getRecentPhotos(days: days);
      _searchResults = allPhotos
          .where((photo) =>
              photo.title.toLowerCase().contains(query.toLowerCase()) ||
              photo.explanation.toLowerCase().contains(query.toLowerCase()))
          .toList();
      print('Search results: ${_searchResults.length} photos');
    } catch (e) {
      _error = e.toString();
      print('Error searching photos: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearSearch() {
    _searchResults = [];
    notifyListeners();
  }
}