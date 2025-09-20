class Song {
  final String id;
  final String name;
  final String artistName;
  final String artistId;
  final String albumName;
  final String albumImage;
  final String audioUrl;
  final String audioDownload;
  final int duration;
  final List<String> tags;
  final String releaseDate;
  final int position;

  Song({
    required this.id,
    required this.name,
    required this.artistName,
    required this.artistId,
    required this.albumName,
    required this.albumImage,
    required this.audioUrl,
    required this.audioDownload,
    required this.duration,
    required this.tags,
    required this.releaseDate,
    required this.position,
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      artistName: json['artist_name'] ?? '',
      artistId: json['artist_id'].toString(),
      albumName: json['album_name'] ?? '',
      albumImage: json['album_image'] ?? '',
      audioUrl: json['audio'] ?? '',
      audioDownload: json['audiodownload'] ?? '',
      duration: json['duration'] ?? 0,
      tags: List<String>.from(json['musicinfo']?['tags']?['genres'] ?? []),
      releaseDate: json['releasedate'] ?? '',
      position: json['position'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'artist_name': artistName,
      'artist_id': artistId,
      'album_name': albumName,
      'album_image': albumImage,
      'audio': audioUrl,
      'audiodownload': audioDownload,
      'duration': duration,
      'musicinfo': {'tags': {'genres': tags}},
      'releasedate': releaseDate,
      'position': position,
    };
  }

  String get formattedDuration {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}