import 'package:flutter/material.dart';

import '../models/food_model.dart';
import '../services/api_service.dart';
import '../widgets/food_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();

  bool _loading = true;
  String? _error;
  List<Food> _foods = [];

  static const _categories = ['Khai vị', 'Món chính', 'Đồ uống', 'Tráng miệng'];

  @override
  void initState() {
    super.initState();
    _loadFoods();
  }

  Future<void> _loadFoods() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await _apiService.fetchFoods();
      setState(() {
        _foods = items;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _categories.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'TH3 - [Thân Đức Minh] - [2351060467]',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          bottom: TabBar(
            isScrollable: true,
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Theme.of(context).primaryColor,
            indicatorWeight: 3,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            tabs: _categories.map((c) => Tab(text: c)).toList(),
          ),
        ),
        body: TabBarView(
          children: _categories.map((cat) {
            return _buildCategoryView(cat);
          }).toList(),
        ),
      ),
    );
  }



  Widget _buildCategoryView(String category) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
            const SizedBox(height: 16),
            const Text(
              'Đã xảy ra lỗi khi tải dữ liệu',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _loadFoods,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }
    final filtered = _foods.where((f) => f.category == category).toList();
    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.fastfood_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Không có món trong chuyên mục này',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      );
    }
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.75, // Adjust for nicer cards
      ),
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      itemBuilder: (context, index) => FoodCard(food: filtered[index]),
    );
  }}