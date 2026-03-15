import 'package:flutter/material.dart';
import '../models/apod_model.dart';
import '../services/nasa_service.dart';

class ApodProvider extends ChangeNotifier {
  ApodImage? _todayApod;
  List<ApodImage> _recentPhotos = [];
  List<ApodImage> _searchResults = [];
  bool _isLoading = false;
  String? _error;

  ApodImage? get todayApod => _todayApod;
  List<ApodImage> get recentPhotos => _recentPhotos;
  List<ApodImage> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  String? get error => _error;

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
      _recentPhotos = await NasaService.getRecentPhotos(days: days);
      print('Recent photos fetched: ${_recentPhotos.length} photos');
    } catch (e) {
      _error = e.toString();
      print('Error fetching recent photos: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
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