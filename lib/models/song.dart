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

class Artist {
  final String id;
  final String name;
  final String image;
  final String website;
  final String joinDate;

  Artist({
    required this.id,
    required this.name,
    required this.image,
    required this.website,
    required this.joinDate,
  });

  factory Artist.fromJson(Map<String, dynamic> json) {
    return Artist(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      website: json['website'] ?? '',
      joinDate: json['joindate'] ?? '',
    );
  }
}

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