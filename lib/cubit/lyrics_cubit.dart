import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:playit/cubit/player_cubit.dart';
import 'package:playit/helpers/lrc_parser.dart';
import 'package:playit/models/lyrics_model.dart';
import 'package:playit/services/synced_lyric_service.dart';

class LyricsState {
  final bool isLoading;
  final bool isError;
  final String errorMessage;
  final String plainLyrics;
  final List<LyricLine> syncedLyrics;
  final int currentSongIndex;

  LyricsState({
    required this.isLoading,
    required this.isError,
    required this.errorMessage,
    required this.plainLyrics,
    required this.syncedLyrics,
    required this.currentSongIndex,
  });
  LyricsState copyWith({
    bool? isLoading,
    bool? isError,
    String? errorMessage,
    String? plainLyrics,
    List<LyricLine>? syncedLyrics,
    int? currentSongIndex,
  }) {
    return LyricsState(
      currentSongIndex: currentSongIndex ?? this.currentSongIndex,
      isLoading: isLoading ?? this.isLoading,
      isError: isError ?? this.isError,
      errorMessage: errorMessage ?? this.errorMessage,
      plainLyrics: plainLyrics ?? this.plainLyrics,
      syncedLyrics: syncedLyrics ?? this.syncedLyrics,
    );
  }
}

class LyricsCubit extends Cubit<LyricsState> {
  final PlayerCubit _playerCubit;
  LyricsCubit(this._playerCubit)
    : super(
        LyricsState(
          isLoading: false,
          isError: false,
          errorMessage: "",
          syncedLyrics: [],
          plainLyrics: "",
          currentSongIndex: -1,
        ),
      );

  Future<void> fetchLyrics() async {
    final recentSong = _playerCubit.state.recentSong;
    final duration = _playerCubit.state.duration;
    final indexSong = _playerCubit.playerControl.songIndex;
    final LyricsModel body = LyricsModel(
      track_name: recentSong.title,
      artist_name: recentSong.artis,
      album_name: recentSong.album,
      duration: duration.inSeconds,
    );
    try {
      emit(state.copyWith(isLoading: true, isError: false));
      LyricsResponseModel result = await getLyrics(body: body);
      List<LyricLine> syncLyric = parseLrc(result.syncedLyrics!);
      emit(
        state.copyWith(
          plainLyrics: result.plainLyrics,
          syncedLyrics: syncLyric,
          isError: false,
          isLoading: false,
          errorMessage: "",
          currentSongIndex: indexSong,
        ),
      );
    } catch (e) {
      state.copyWith(
        plainLyrics: "Lyrics Not Found",
        syncedLyrics: [LyricLine(time: Duration.zero, text: "")],
        isError: true,
        isLoading: false,
        errorMessage: e.toString(),
        currentSongIndex: -1
      );
    }
  }
}
