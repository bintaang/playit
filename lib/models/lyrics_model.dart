class LyricsModel {
  final String track_name;
  final String artist_name;
  final String album_name;
  final int duration;
  LyricsModel({
    required this.track_name,
    required this.artist_name,
    required this.album_name,
    required this.duration,
  });
  Map<String, dynamic> toJson() => {
    'track_name': track_name,
    'artist_name': artist_name,
    'album_name': album_name,
    'duration': duration,
  };
}

class LyricsResponseModel {
  final String? plainLyrics;
  final String? syncedLyrics;

  LyricsResponseModel({required this.plainLyrics, required this.syncedLyrics});
  factory LyricsResponseModel.fromJson(Map<String, dynamic> json) {
    return LyricsResponseModel(
      plainLyrics: json['plainLyrics'],
      syncedLyrics: json['syncedLyrics'],
    );
  }
}

class LyricLine {
  final Duration time;
  final String text;

  LyricLine({required this.time, required this.text});
}
