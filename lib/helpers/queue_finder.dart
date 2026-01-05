import 'package:playit/models/song_model.dart';
import 'package:playit/cubit/player_cubit.dart' as cp;

List<SongModel> queueFinder({
  required int currentIndexSong,
  required cp.PlayerState state,
}) {
  final playlist = state.activePlaylist;
  final totalSong = playlist.length;
  const maxNextSong = 3;

  final isRepeatOne = state.repeatThisSong;
  final isShuffle = state.shuffleThisPlaylist;

  final List<SongModel> queueSong = [];

  if (isShuffle) {
    return [];
  }

  if (isRepeatOne) {
    for (int i = 0; i < maxNextSong; i++) {
      queueSong.add(playlist[currentIndexSong]);
    }
    return queueSong;
  }

  for (int i = 1; i <= maxNextSong; i++) {
    final nextIndex = (currentIndexSong + i) % totalSong;
    queueSong.add(playlist[nextIndex]);
  }

  return queueSong;
}
