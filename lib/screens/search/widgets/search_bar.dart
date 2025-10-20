import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSearch;
  final Function(String)? onChanged;

  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.onSearch,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Tìm kiếm bài hát, nghệ sĩ...',
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    controller.clear();
                    onChanged?.call('');
                  },
                )
              : null,
          filled: true,
          fillColor: const Color(0xFF1E1E1E),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: onChanged,
        onSubmitted: onSearch,
      ),
    );
  }
}

