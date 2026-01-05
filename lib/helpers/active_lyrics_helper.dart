import '../models/lyrics_model.dart';

int findCurrentLyricIndex(Duration position, List<LyricLine> lyrics) {
  for (int i = lyrics.length - 1; i >= 0; i--) {
    if (position >= lyrics[i].time) return i;
  }
  return 0;
}
