import 'song.dart';

class Album {
  final String id;
  final String name;
  final String artistName;
  final String image;
  final String releaseDate;
  final List<Song> tracks;

  Album({
    required this.id,
    required this.name,
    required this.artistName,
    required this.image,
    required this.releaseDate,
    required this.tracks,
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      artistName: json['artist_name'] ?? '',
      image: json['image'] ?? '',
      releaseDate: json['releasedate'] ?? '',
      tracks: [],
    );
  }
}