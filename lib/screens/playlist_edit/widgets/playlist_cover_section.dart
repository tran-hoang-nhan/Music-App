import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PlaylistCoverSection extends StatelessWidget {
  final String? currentImageUrl;
  final VoidCallback onChangeImage;

  const PlaylistCoverSection({
    super.key,
    required this.currentImageUrl,
    required this.onChangeImage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          GestureDetector(
            onTap: onChangeImage,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[700]!),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: currentImageUrl != null && currentImageUrl!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: currentImageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, _) => Container(
                          color: const Color(0xFF2E2E2E),
                          child: const Icon(Icons.queue_music, color: Colors.grey, size: 50),
                        ),
                        errorWidget: (_, _, _) => Container(
                          color: const Color(0xFF2E2E2E),
                          child: const Icon(Icons.queue_music, color: Colors.grey, size: 50),
                        ),
                      )
                    : Container(
                        color: const Color(0xFF2E2E2E),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate, color: Colors.grey, size: 40),
                            SizedBox(height: 8),
                            Text(
                              'Thêm ảnh bìa',
                              style: TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: onChangeImage,
            icon: const Icon(Icons.camera_alt, color: Color(0xFFE53E3E)),
            label: const Text(
              'Thay đổi ảnh bìa',
              style: TextStyle(color: Color(0xFFE53E3E)),
            ),
          ),
        ],
      ),
    );
  }
}

