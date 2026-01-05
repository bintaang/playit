import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:playit/components/album_card.dart';
import 'package:playit/cubit/album_cubit.dart';
import 'package:playit/pages/playlistLibraryPage/playlist_library_page.dart';
import 'package:playit/utils/screen_detector.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  @override
  void initState() {
    super.initState();
    context.read<AlbumCubit>().getAlbums();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: BlocBuilder<AlbumCubit, AlbumSate>(
          builder: (BuildContext context, state) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  "Album Collections",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: context.isMobile
                        ? context.screenSize.width * 0.05
                        : context.screenSize.width * 0.08,
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: EdgeInsets.all(10),
                    itemCount: state.listAlbum.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                    ),
                    itemBuilder: (context, index) {
                      final album = state.listAlbum[index];
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PlaylistLibraryPage(
                                  albumName: album.albumName,
                                  albumSinger: album.albumSinger,
                                ),
                              ),
                            );
                          },
                          child: AlbumCard(
                            albumName: album.albumName,
                            albumPhoto: album.albumCover.bytes,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
