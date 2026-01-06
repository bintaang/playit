import 'dart:typed_data';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:playit/helpers/player_helper.dart';
import 'package:playit/models/song_model.dart';

class PlayerState {
  final List<SongModel> activePlaylist;
  final bool isPlaying;
  final bool isMinimized;
  final SongModel recentSong;
  final Duration position;
  final Duration duration;
  final bool shuffleThisPlaylist;
  final bool repeatThisSong;

  PlayerState({
    required this.isPlaying,
    required this.isMinimized,
    required this.recentSong,
    required this.position,
    required this.duration,
    required this.activePlaylist,
    required this.shuffleThisPlaylist,
    required this.repeatThisSong,
  });

  PlayerState copyWith({
    bool? isPlaying,
    bool? isMinimized,
    SongModel? recentSong,
    Duration? position,
    Duration? duration,
    List<SongModel>? activePlaylist,
    bool? shuffleThisPlaylist,
    bool? repeatThisSong,
  }) {
    return PlayerState(
      isPlaying: isPlaying ?? this.isPlaying,
      isMinimized: isMinimized ?? this.isMinimized,
      recentSong: recentSong ?? this.recentSong,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      activePlaylist: activePlaylist ?? this.activePlaylist,
      shuffleThisPlaylist: shuffleThisPlaylist ?? this.shuffleThisPlaylist,
      repeatThisSong: repeatThisSong ?? this.repeatThisSong,
    );
  }
}

class PlayerCubit extends Cubit<PlayerState> {
  final PlayerControl playerControl = PlayerControl();

  PlayerCubit()
    : super(
        PlayerState(
          isPlaying: false,
          isMinimized: false,
          recentSong: SongModel(
            title: "",
            album: "",
            artis: "",
            genre: "",
            cover: Picture(Uint8List(0), "", PictureType.leadArtist),
            path: "",
          ),
          position: Duration.zero,
          duration: Duration.zero,
          activePlaylist: [],
          shuffleThisPlaylist: false,
          repeatThisSong: false,
        ),
      ) {
    playerControl.currentIndex.listen((index) {
      if (index != null) {
        if (index >= state.activePlaylist.length) return;
        final recentSong = state.activePlaylist[index];
        emit(state.copyWith(recentSong: recentSong));
      }
    });
    playerControl.isPlaying.listen((playing) {
      emit(state.copyWith(isPlaying: playing));
    });
    playerControl.durationSong.listen((duration) {
      if (duration != null) {
        emit(state.copyWith(duration: duration));
      }
    });
    playerControl.recentPosition.listen((position) {
      if (position != null) {
        emit(state.copyWith(position: position));
      }
    });
  }

  void playSong(List<SongModel> songs, int songIndex) {
    if (playerControl.songIndex == songIndex || state.activePlaylist == songs) return;
    playerControl.playAudio(songs, songIndex);
    emit(state.copyWith(recentSong: songs[songIndex], activePlaylist: songs));
  }

  void resumeOrPause() {
    if (state.isPlaying) {
      playerControl.pause();
    } else {
      playerControl.resumeAudio();
    }
  }

  void seekTo(Duration position) {
    playerControl.seekAudio(position);
  }

  void nextSong() {
    playerControl.playNext();
  }

  void previousSong() {
    playerControl.playPrevious();
  }

  void goTo(Duration position) {
    playerControl.seekAudio(position);
  }

  void shuffleThisPlaylist(bool shuffleThisSong) {
    playerControl.shufflePlaylist(shuffleThisSong: shuffleThisSong);
    if (shuffleThisSong) playerControl.repeatThisSong(repeatThisSong: false);
    emit(
      state.copyWith(
        shuffleThisPlaylist: shuffleThisSong ? true : false,
        repeatThisSong: shuffleThisSong ? false : state.repeatThisSong,
      ),
    );
  }

  void repeatThisSong(bool repeatThisSong) {
    playerControl.repeatThisSong(repeatThisSong: repeatThisSong);
    if (repeatThisSong) playerControl.shufflePlaylist(shuffleThisSong: false);
    emit(
      state.copyWith(
        repeatThisSong: repeatThisSong ? true : false,
        shuffleThisPlaylist: repeatThisSong ? false : state.shuffleThisPlaylist,
      ),
    );
  }
}
