class GenreModel {
  final String genre;
  GenreModel({required this.genre});
  GenreModel copyWith({String? genre}) {
    return GenreModel(genre: genre ?? this.genre);
  }
}
