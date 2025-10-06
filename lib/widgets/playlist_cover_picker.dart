import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import '../services/cloudinary_service.dart';

class PlaylistCoverPicker extends StatefulWidget {
  final String playlistId;
  final String? currentImageUrl;
  final VoidCallback? onImageChanged;

  const PlaylistCoverPicker({
    Key? key,
    required this.playlistId,
    this.currentImageUrl,
    this.onImageChanged,
  }) : super(key: key);

  @override
  _PlaylistCoverPickerState createState() => _PlaylistCoverPickerState();
}

class _PlaylistCoverPickerState extends State<PlaylistCoverPicker> {
  bool _isUploading = false;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _imageUrl = widget.currentImageUrl;
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() => _isUploading = true);

      try {
        final imageFile = File(pickedFile.path);
        
        // Upload lên Cloudinary với resize
        final uploadedUrl = await CloudinaryService.uploadImageWithTransform(
          imageFile,
          folder: 'playlists',
          width: 400,
          height: 400,
          crop: 'fill',
        );

        if (uploadedUrl != null) {
          // Cập nhật Firebase
          await FirebaseDatabase.instance
              .ref('playlists/${widget.playlistId}')
              .update({
            'imageUrl': uploadedUrl,
            'updatedAt': DateTime.now().millisecondsSinceEpoch,
          });

          setState(() => _imageUrl = uploadedUrl);
          widget.onImageChanged?.call();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Đã cập nhật ảnh bìa playlist')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi upload ảnh')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      } finally {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _isUploading ? null : _pickAndUploadImage,
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey[800],
          border: Border.all(color: Colors.grey[600]!, width: 1),
        ),
        child: _isUploading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.blue),
                    SizedBox(height: 8),
                    Text('Đang tải...', style: TextStyle(color: Colors.white70)),
                  ],
                ),
              )
            : _imageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      children: [
                        Image.network(
                          _imageUrl!,
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildPlaceholder();
                          },
                        ),
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : _buildPlaceholder(),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_photo_alternate,
          size: 50,
          color: Colors.grey[400],
        ),
        SizedBox(height: 8),
        Text(
          'Thêm ảnh bìa',
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}