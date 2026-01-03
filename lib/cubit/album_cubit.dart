import 'dart:typed_data';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:playit/cubit/songs_cubit.dart';
import 'package:playit/models/album_model.dart';

class AlbumSate {
  final List<AlbumModel> listAlbum;
  AlbumSate({required this.listAlbum});
  AlbumSate copyWith(List<AlbumModel>? listAlbum) {
    return AlbumSate(listAlbum: listAlbum ?? this.listAlbum);
  }
}

class AlbumCubit extends Cubit<AlbumSate> {
  final SongsListCubit songsListCubit;

  AlbumCubit({required this.songsListCubit}) : super(AlbumSate(listAlbum: []));

  void getAlbums() {
    final songs = songsListCubit.state.songs;
    final List<AlbumModel> listAlbum = [];

    for (var song in songs) {
      bool alreadyExists = listAlbum.any(
        (album) => album.albumName == song.album,
      );

      if (!alreadyExists) {
        listAlbum.add(
          AlbumModel(albumCover: song.cover, albumName: song.album),
        );
      }
    }

    emit(state.copyWith(listAlbum));
  }
}
