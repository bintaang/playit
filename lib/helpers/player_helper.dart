import 'package:just_audio/just_audio.dart';
import 'package:playit/models/song_model.dart';

class PlayerControl {
  final control = AudioPlayer();
  Stream<int?> get currentIndex => control.currentIndexStream;
  int? get songIndex => control.currentIndex;
  Stream<bool> get isPlaying => control.playingStream;
  Stream<Duration?> get durationSong => control.durationStream;
  Stream<Duration?> get recentPosition => control.positionStream;
  List<AudioSource> playlist = [];
  Future<void> playAudio(List<SongModel> songs, int currentIndex) async {
    final newPlaylist = <AudioSource>[];

    for (var song in songs) {
      newPlaylist.add(AudioSource.uri(Uri.parse(song.path)));
    }

    await control.setAudioSources(
      newPlaylist,
      initialIndex: currentIndex,
      initialPosition: Duration.zero,
      preload: true,
      shuffleOrder: DefaultShuffleOrder(),
    );

    await control.setLoopMode(LoopMode.all);
    await control.play();
  }

  Future<void> seekAudio(Duration position) async {
    await control.seek(position);
  }

  Future<void> pause() async {
    await control.pause();
  }

  Future<void> resumeAudio() async {
    await control.play();
  }

  Future<void> playNext() async {
    await control.seekToNext();
  }

  Future<void> playPrevious() async {
    await control.seekToPrevious();
  }

  Future<void> shufflePlaylist({required bool shuffleThisSong}) async {
    await control.setShuffleModeEnabled(shuffleThisSong);
    if (shuffleThisSong) {
      await control.shuffle();
    }
  }

  Future<void> repeatThisSong({required bool repeatThisSong}) async {
    await control.setLoopMode(repeatThisSong ? LoopMode.one : LoopMode.off);
  }
}
