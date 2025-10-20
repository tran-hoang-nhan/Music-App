import 'song.dart';

class Playlist {
  final String id;
  final String name;
  final String description;
  final String userId;
  final List<Song> songs;
  final DateTime createdAt;
  final DateTime updatedAt;

  Playlist({
    required this.id,
    required this.name,
    required this.description,
    required this.userId,
    required this.songs,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Playlist.fromFirestore(Map<String, dynamic> data, String id) {
    return Playlist(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      userId: data['userId'] ?? '',
      songs: [],
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: data['updatedAt']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'userId': userId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

