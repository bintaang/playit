class ArtisModel {
  final String artist;
  ArtisModel({required this.artist});
  ArtisModel copyWith({String? artist}) {
    return ArtisModel(artist: artist ?? this.artist);
  }
}
