import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/food_model.dart';

class ApiService {
  static const _baseUrl = 'https://www.themealdb.com/api/json/v1/1/search.php?f=a';

  Future<List<Food>> fetchFoods() async {
    try {
      final uri = Uri.parse(_baseUrl);
      final response =
          await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonMap = json.decode(response.body);
        final meals = jsonMap['meals'] as List<dynamic>?;
        if (meals == null) {
          return [];
        }
        var items = meals
            .map((e) => Food.fromJson(e as Map<String, dynamic>))
            .toList();
        // assign one of our four categories in round‑robin fashion
        const cats = ['Khai vị', 'Món chính', 'Đồ uống', 'Tráng miệng'];
        final n = items.length;
        for (var i = 0; i < n; i++) {
          final idx = (i * cats.length ~/ n).clamp(0, cats.length - 1);
          items[i] = items[i].copyWith(category: cats[idx]);
        }
        return items;
      } else {
        throw Exception('Server returned ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}