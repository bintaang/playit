import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:playit/cubit/album_cubit.dart';
import 'package:playit/cubit/songs_cubit.dart';
import 'package:playit/models/album_model.dart';
import 'package:playit/models/song_model.dart';
import 'package:playit/pages/songPlayerPage/song_player_page.dart';
import 'package:playit/utils/screen_detector.dart';

class PlaylistLibraryPage extends StatelessWidget {
  const PlaylistLibraryPage({
    super.key,
    required this.albumName,
    required this.albumSinger,
  });
  final String albumName;
  final String albumSinger;
  @override
  Widget build(BuildContext context) {
    final AlbumModel album = context
        .read<AlbumCubit>()
        .state
        .listAlbum
        .firstWhere(
          (a) => a.albumSinger == albumSinger && a.albumName == albumName,
        );
    final List<SongModel> songList = context
        .read<SongsListCubit>()
        .state
        .songs
        .where((song) => song.album == albumName && song.artis.contains(albumSinger))
        .toList();
    return Scaffold(
      body: Stack(
        alignment: AlignmentGeometry.topCenter,
        fit: StackFit.loose,
        children: [
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 200, sigmaY: 200),
            child: Image.memory(album.albumCover.bytes, fit: BoxFit.cover),
          ),
          Container(
            decoration: BoxDecoration(color: Colors.black87.withAlpha(50)),
          ),
          SingleChildScrollView(
            padding: EdgeInsets.only(top: 50, left: 10, right: 10),
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                Center(
                  child: Column(
                    spacing: 20,
                    children: [
                      Container(
                        width: context.screenSize.width * 0.5,
                        height: context.screenSize.width * 0.5,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: MemoryImage(album.albumCover.bytes),
                          ),
                        ),
                      ),
                      Text(
                        album.albumName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        album.albumSinger,
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Text(
                        "${songList.length} Songs",
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            style: IconButton.styleFrom(
                              iconSize: 35,
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black87,
                            ),
                            onPressed: () {},
                            icon: Icon(Icons.play_arrow),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: songList.length,
                  itemBuilder: (context, index) {
                    final song = songList[index];
                    return ListTile(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SongPlayerPage(
                              songs: songList,
                              songIndex: index,
                            ),
                          ),
                        );
                      },
                      trailing: IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.play_arrow),
                      ),
                      title: Text(song.title),
                      subtitle: Text(song.artis),
                    );
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20.0, left: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.arrow_back_ios),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
