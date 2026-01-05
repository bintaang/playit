import 'dart:core';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';

class AlbumModel {
  final String albumName;
  final Picture albumCover;
  final String albumSinger;
  AlbumModel({
    required this.albumCover,
    required this.albumName,
    required this.albumSinger,
  });

  AlbumModel copyWith(
    String? albumName,
    Picture? albumCover,
    String? albumSinger,
  ) {
    return AlbumModel(
      albumName: albumName ?? this.albumName,
      albumCover: albumCover ?? this.albumCover,
      albumSinger: albumSinger ?? this.albumSinger,
    );
  }
}
