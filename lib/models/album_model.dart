import 'dart:core';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';

class AlbumModel {
  final String albumName;
  final Picture albumCover;
  AlbumModel({required this.albumCover, required this.albumName});

  AlbumModel copyWith(String? albumName, Picture? albumCover) {
    return AlbumModel(
      albumName: albumName ?? this.albumName,
      albumCover: albumCover ?? this.albumCover,
    );
  }
}
