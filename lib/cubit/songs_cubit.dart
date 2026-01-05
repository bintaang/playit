import 'dart:io';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:playit/models/song_model.dart';

class SongsState {
  final String baseUrl;
  SongsState({required this.baseUrl});
  SongsState copyWith({String? baseUrl}) {
    return SongsState(baseUrl: baseUrl ?? this.baseUrl);
  }

  Map<String, dynamic> toMap() {
    return {'baseUrl': baseUrl};
  }

  factory SongsState.fromMap(Map<String, dynamic> map) {
    return SongsState(baseUrl: map['baseUrl'] ?? '');
  }
}

class SongsCubit extends HydratedCubit<SongsState> {
  SongsCubit() : super(SongsState(baseUrl: ""));

  @override
  fromJson(Map<String, dynamic> json) {
    return SongsState.fromMap(json);
  }

  @override
  Map<String, dynamic>? toJson(SongsState state) {
    return state.toMap();
  }

  void updateBaseUrl(String newUrl) {
    emit(state.copyWith(baseUrl: newUrl));
  }
}

class SongsListState {
  final List<SongModel> songs;
  SongsListState({required this.songs});
  SongsListState copyWith(List<SongModel>? songs) {
    return SongsListState(songs: songs ?? this.songs);
  }
}

class SongsListCubit extends Cubit<SongsListState> {
  SongsListCubit() : super(SongsListState(songs: []));
  void fetchNewSong(String songPath) {
    List<SongModel> songs = [];
    final List<File> rawSong = Directory(songPath)
        .listSync(recursive: true, followLinks: false)
        .whereType<File>()
        .where(
          (file) =>
              file.path.endsWith(".mp3") ||
              file.path.endsWith(".flac") ||
              file.path.endsWith(".m4a"),
        )
        .toList();

    for (var song in rawSong) {
      try {
        final songData = readMetadata(song, getImage: true);

        songs.add(
          SongModel(
            title: songData.title ?? "Unknown Title",
            album: songData.album ?? "Unkown Album",
            artis: songData.artist ?? "Unkown Artist",
            genre: songData.genres.first,
            cover: songData.pictures.first,
            path: songData.file.path,
          ),
        );
      } catch (e) {
        print("something is wrong: $e");
      }
    }
    emit(state.copyWith(songs));
  }
}
