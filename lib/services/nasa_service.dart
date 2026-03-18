import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/apod_model.dart';

class NasaService {
  static const String apiKey = 'vPNpZu338bWCecteqaI3jPGAvPden2hZyGrd752o';
  static const String baseUrl = 'https://api.nasa.gov/planetary/apod';

  static Future<ApodImage> getTodayApod() async {
    try {
      final url = '$baseUrl?api_key=$apiKey';
      print('📡 Fetching today APOD from: $url');

      final response = await http.get(Uri.parse(url)).timeout(
        Duration(seconds: 10),
        onTimeout: () => throw Exception('Request timeout'),
      );

      print('📡 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final apod = ApodImage.fromJson(jsonDecode(response.body));
        print('✅ Today APOD fetched: ${apod.title}');
        return apod;
      } else {
        // ✅ HEURISTIC #9: Error Messaging
        throw Exception('Failed: HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching today APOD: $e');
      throw Exception('Error: $e');
    }
  }

  static Future<List<ApodImage>> getApodRange(String startDate, String endDate) async {
    try {
      final url = '$baseUrl?api_key=$apiKey&start_date=$startDate&end_date=$endDate';
      print('📡 Fetching range from $startDate to $endDate');

      final response = await http.get(Uri.parse(url)).timeout(
        Duration(seconds: 30),
        onTimeout: () => throw Exception('Request timeout'),
      );

      print('📡 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        print('✅ API returned ${data.length} photos');

        final photos = data
            .map((item) {
              try {
                return ApodImage.fromJson(item);
              } catch (e) {
                print('⚠️ Error parsing photo: $e');
                return null;
              }
            })
            .whereType<ApodImage>()
            .toList()
            .reversed
            .toList();

        print('✅ Processed ${photos.length} photos');
        return photos;
      } else {
        print('❌ API error: ${response.statusCode}');
        throw Exception('Failed to load photos: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching APOD range: $e');
      throw Exception('Error: $e');
    }
  }

  static Future<List<ApodImage>> getRecentPhotos({int days = 60}) async {
    try {
      final now = DateTime.now();
      final endDate = now.subtract(Duration(days: 1));
      final endDateOnly = DateTime(endDate.year, endDate.month, endDate.day);
      final startDate = endDateOnly.subtract(Duration(days: days));

      final start = startDate.toString().split(' ')[0];
      final end = endDateOnly.toString().split(' ')[0];

      print('📡 Getting recent photos for last $days days');
      print('📡 Date range: $start to $end');

      final photos = await getApodRange(start, end);
      print('✅ Got ${photos.length} recent photos');
      return photos;
    } catch (e) {
      print('❌ Error in getRecentPhotos: $e');
      throw Exception('Error: $e');
    }
  }
}