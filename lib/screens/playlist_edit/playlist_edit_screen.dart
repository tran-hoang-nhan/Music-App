import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/firebase/firebase_controller.dart';
import 'widgets/playlist_edit_form.dart';

class PlaylistEditScreen extends StatefulWidget {
  final String playlistId;
  final String playlistName;
  final String? playlistDescription;
  final String? currentImageUrl;

  const PlaylistEditScreen({
    super.key,
    required this.playlistId,
    required this.playlistName,
    this.playlistDescription,
    this.currentImageUrl,
  });

  @override
  State<PlaylistEditScreen> createState() => _PlaylistEditScreenState();
}

class _PlaylistEditScreenState extends State<PlaylistEditScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.playlistName);
    _descriptionController = TextEditingController(text: widget.playlistDescription ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Chỉnh sửa playlist'),
        backgroundColor: const Color(0xFF121212),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _savePlaylist,
            child: const Text(
              'Lưu',
              style: TextStyle(color: Color(0xFFE53E3E), fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            PlaylistEditForm(
              nameController: _nameController,
              descriptionController: _descriptionController,
              onSave: _savePlaylist,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }



  Future<void> _savePlaylist() async {
    if (!mounted) return;
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    
    if (_nameController.text.trim().isEmpty) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tên playlist')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final firebaseController = Provider.of<FirebaseController>(context, listen: false);
      await firebaseController.playlist.updatePlaylist(
        widget.playlistId,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
      );
      
      if (!mounted) return;
      navigator.pop(true);
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Đã cập nhật playlist thành công')),
      );
    } catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Lỗi cập nhật playlist: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

