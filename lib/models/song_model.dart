class SongModel {
  final String title;
  final String album;
  final String artis;
  final String genre;
  final Uri cover;
  SongModel({
    required this.title,
    required this.album,
    required this.artis,
    required this.genre,
    required this.cover,
  });

  SongModel copyWith({
    String? title,
    String? album,
    String? artis,
    String? genre,
    Uri? cover,
  }) {
    return SongModel(
      title: title ?? this.title,
      album: album ?? this.album,
      artis: artis ?? this.artis,
      genre: genre ?? this.genre,
      cover: cover ?? this.cover,
    );
  }
}
