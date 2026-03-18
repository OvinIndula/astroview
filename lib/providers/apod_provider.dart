import 'package:flutter/material.dart';
import 'dart:async';  // ✅ ADD THIS (for TimeoutException)
import 'dart:io';     // ✅ ADD THIS (for SocketException)
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
  DateTime? _lastFetchTime;

  ApodImage? get todayApod => _todayApod;
  List<ApodImage> get recentPhotos => _displayedPhotos;
  List<ApodImage> get allRecentPhotos => _allRecentPhotos;
  List<ApodImage> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMorePhotos => _displayedPhotos.length < _allRecentPhotos.length;
  DateTime? get lastFetchTime => _lastFetchTime;

  Future<void> fetchTodayApod() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _todayApod = await NasaService.getTodayApod()
          .timeout(Duration(seconds: 10));
      _lastFetchTime = DateTime.now();
      print('Today APOD fetched: ${_todayApod?.title}');
    } on TimeoutException {
      _error = 'Connection is slow. Please try again in a moment.';
    } on SocketException {
      _error = 'No internet connection. Please check your WiFi.';
    } catch (e) {
      if (e.toString().contains('429')) {
        _error = 'Too many requests. Please try again in 5 minutes.';
      } else if (e.toString().contains('500')) {
        _error = 'NASA servers are temporarily down. Try again later.';
      } else if (e.toString().contains('404')) {
        _error = 'Image not found. Please try another date.';
      } else {
        _error = 'Unable to load. Please check your connection and try again.';
      }
      print('Error fetching today APOD: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchRecentPhotos({int days = 60}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allRecentPhotos = await NasaService.getRecentPhotos(days: days)
          .timeout(Duration(seconds: 15));
      _lastFetchTime = DateTime.now();
      print('Total photos fetched: ${_allRecentPhotos.length}');

      _itemsToDisplay = 10;
      _updateDisplayedPhotos();
    } on TimeoutException {
      _error = 'Connection slow. Try again in a moment.';
    } catch (e) {
      _error = 'Unable to load photos. Please check your connection.';
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
      final allPhotos = await NasaService.getRecentPhotos(days: days)
          .timeout(Duration(seconds: 15));
      _searchResults = allPhotos
          .where((photo) =>
              photo.title.toLowerCase().contains(query.toLowerCase()) ||
              photo.explanation.toLowerCase().contains(query.toLowerCase()))
          .toList();
      print('Search results: ${_searchResults.length} photos');
    } on TimeoutException {
      _error = 'Search timed out. Please try again.';
    } catch (e) {
      _error = 'Error searching. Please try again.';
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