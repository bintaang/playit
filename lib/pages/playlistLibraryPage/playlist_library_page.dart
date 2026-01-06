import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:playit/cubit/album_cubit.dart';
import 'package:playit/cubit/player_cubit.dart';
import 'package:playit/cubit/songs_cubit.dart';
import 'package:playit/models/album_model.dart';
import 'package:playit/models/song_model.dart';
import 'package:playit/pages/songPlayerPage/song_player_page.dart';
import 'package:playit/utils/screen_detector.dart';
import 'package:rive_animated_icon/rive_animated_icon.dart';

class PlaylistLibraryPage extends StatefulWidget {
  const PlaylistLibraryPage({
    super.key,
    required this.albumName,
    required this.albumSinger,
  });

  final String albumName;
  final String albumSinger;

  @override
  State<PlaylistLibraryPage> createState() => _PlaylistLibraryPageState();
}

class _PlaylistLibraryPageState extends State<PlaylistLibraryPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool isPlay = false;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final AlbumModel album = context
        .read<AlbumCubit>()
        .state
        .listAlbum
        .firstWhere(
          (a) =>
              a.albumSinger == widget.albumSinger &&
              a.albumName == widget.albumName,
        );
    final List<SongModel> songList = context
        .read<SongsListCubit>()
        .state
        .songs
        .where(
          (song) =>
              song.album == widget.albumName &&
              song.artis.contains(widget.albumSinger),
        )
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
                          BlocListener<PlayerCubit, PlayerState>(
                            listenWhen: (p, c) => p.isPlaying != c.isPlaying,
                            listener: (context, state) {
                              if (state.isPlaying) {
                                _animationController.forward();
                              } else {
                                _animationController.reverse();
                              }
                            },
                            child: IconButton(
                              style: ButtonStyle(
                                iconSize:
                                    WidgetStateProperty.resolveWith<double?>((
                                      states,
                                    ) {
                                      if (states.contains(
                                        WidgetState.pressed,
                                      )) {
                                        return 40;
                                      } else {
                                        return 40;
                                      }
                                    }),
                                backgroundColor:
                                    WidgetStateProperty.resolveWith<Color?>((
                                      states,
                                    ) {
                                      if (states.contains(
                                        WidgetState.pressed,
                                      )) {
                                        return Colors.white;
                                      } else {
                                        return Colors.white;
                                      }
                                    }),
                                foregroundColor:
                                    WidgetStateProperty.resolveWith<Color?>((
                                      states,
                                    ) {
                                      if (states.contains(
                                        WidgetState.pressed,
                                      )) {
                                        return Colors.black;
                                      } else {
                                        return Colors.black;
                                      }
                                    }),
                              ),
                              icon: AnimatedIcon(
                                icon: AnimatedIcons.play_pause,
                                progress: _animationController,
                              ),
                              onPressed: () {
                                final playerCubit = context.read<PlayerCubit>();
                                final isCurrentlyPlaying =
                                    playerCubit.state.isPlaying;
                                final currentSongIndex =
                                    playerCubit.playerControl.songIndex;

                                if (isCurrentlyPlaying) {
                                  playerCubit.playerControl.pause();
                                } else if (currentSongIndex == null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SongPlayerPage(
                                        songs: songList,
                                        songIndex: 0,
                                      ),
                                    ),
                                  );
                                } else {
                                  playerCubit.playerControl.resumeAudio();
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                BlocBuilder<PlayerCubit, PlayerState>(
                  buildWhen: (p, c) => p.recentSong != c.recentSong,
                  builder: (BuildContext context, state) {
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: songList.length,
                      itemBuilder: (context, index) {
                        final song = songList[index];
                        final isPlaying =
                            context
                                    .read<PlayerCubit>()
                                    .playerControl
                                    .songIndex ==
                                index &&
                            state.recentSong.title == song.title;
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
                            icon: isPlaying
                                ? RiveAnimatedIcon(
                                    riveIcon: RiveIcon.sound,
                                    loopAnimation: true,
                                    width: context.screenSize.width * 0.08,
                                    height: context.screenSize.width * 0.08,
                                    color: Colors.deepOrange,
                                  )
                                : Icon(Icons.play_arrow),
                          ),
                          title: Text(song.title),
                          subtitle: Text(song.artis),
                        );
                      },
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
