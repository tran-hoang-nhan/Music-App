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

