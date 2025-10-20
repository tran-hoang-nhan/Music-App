import 'package:flutter/material.dart';

class PlaylistEditForm extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final VoidCallback onSave;
  final bool isLoading;

  const PlaylistEditForm({
    super.key,
    required this.nameController,
    required this.descriptionController,
    required this.onSave,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextFormField(
            controller: nameController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Tên playlist',
              labelStyle: const TextStyle(color: Colors.grey),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Color(0xFFE53E3E)),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: descriptionController,
            style: const TextStyle(color: Colors.white),
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Mô tả (tùy chọn)',
              labelStyle: const TextStyle(color: Colors.grey),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Color(0xFFE53E3E)),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoading ? null : onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53E3E),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Lưu thay đổi',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

