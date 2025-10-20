import 'package:flutter/material.dart';

class SearchSuggestions extends StatelessWidget {
  const SearchSuggestions({super.key});

  @override
  Widget build(BuildContext context) {
    final suggestions = ['Pop', 'Rock', 'Jazz', 'Electronic', 'Hip Hop', 'Classical'];
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Thể loại phổ biến', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: suggestions.map((suggestion) => Chip(
              label: Text(suggestion),
              backgroundColor: const Color(0xFF1E1E1E),
              labelStyle: const TextStyle(color: Colors.white),
            )).toList(),
          ),
          const SizedBox(height: 32),
          const Text('Gần đây', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          const Center(
            child: Text('Chưa có lịch sử tìm kiếm', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }
}

