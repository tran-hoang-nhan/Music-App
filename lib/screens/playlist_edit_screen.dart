import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../widgets/playlist_cover_picker.dart';

class PlaylistEditScreen extends StatefulWidget {
  final String playlistId;
  final String playlistName;
  final String? playlistDescription;
  final String? currentImageUrl;

  const PlaylistEditScreen({
    Key? key,
    required this.playlistId,
    required this.playlistName,
    this.playlistDescription,
    this.currentImageUrl,
  }) : super(key: key);

  @override
  _PlaylistEditScreenState createState() => _PlaylistEditScreenState();
}

class _PlaylistEditScreenState extends State<PlaylistEditScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.playlistName;
    _descriptionController.text = widget.playlistDescription ?? '';
  }

  Future<void> _savePlaylist() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tên playlist không được để trống')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseDatabase.instance
          .ref('playlists/${widget.playlistId}')
          .update({
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });

      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã cập nhật playlist')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Chỉnh sửa playlist'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _savePlaylist,
            child: Text(
              'Lưu',
              style: TextStyle(
                color: _isLoading ? Colors.grey : Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Ảnh bìa playlist
            Center(
              child: PlaylistCoverPicker(
                playlistId: widget.playlistId,
                currentImageUrl: widget.currentImageUrl,
              ),
            ),
            
            SizedBox(height: 32),
            
            // Tên playlist
            TextField(
              controller: _nameController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Tên playlist',
                labelStyle: TextStyle(color: Colors.grey[400]),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[600]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            // Mô tả playlist
            TextField(
              controller: _descriptionController,
              style: TextStyle(color: Colors.white),
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Mô tả (tùy chọn)',
                labelStyle: TextStyle(color: Colors.grey[400]),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[600]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            
            SizedBox(height: 32),
            
            // Nút lưu
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _savePlaylist,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        'Lưu thay đổi',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}