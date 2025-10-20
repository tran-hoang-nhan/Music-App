import 'package:flutter/material.dart';
import '../../../models/song.dart';
import '../../song_tile.dart';

class SearchResults extends StatelessWidget {
  final List<Song> results;

  const SearchResults({super.key, required this.results});

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Không tìm thấy kết quả', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: SongTile(song: results[index], playlist: results),
        );
      },
    );
  }
}

