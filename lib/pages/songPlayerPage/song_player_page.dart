import 'dart:ui';
import 'package:audio_metadata_reader/audio_metadata_reader.dart' as amr;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:playit/cubit/player_cubit.dart';
import 'package:playit/helpers/dynamic_color_generator_helper.dart';
import 'package:playit/helpers/time_formater.dart';
import 'package:playit/models/song_model.dart';
import 'package:playit/pages/songPlayerPage/lyric_page.dart';
import 'package:playit/pages/songPlayerPage/queue_music_page.dart';
import 'package:playit/utils/screen_detector.dart';
import 'package:squiggly_slider/slider.dart';

class SongPlayerPage extends StatefulWidget {
  const SongPlayerPage({
    super.key,
    required this.songs,
    required this.songIndex,
  });
  final List<SongModel> songs;
  final int songIndex;
  @override
  State<SongPlayerPage> createState() => _SongPlayerPageState();
}

class _SongPlayerPageState extends State<SongPlayerPage> {
  @override
  void initState() {
    context.read<PlayerCubit>().playSong(widget.songs, widget.songIndex);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyActions: true,
        backgroundColor: Colors.transparent,
      ),
      body: Stack(
        fit: StackFit.loose,
        children: [
          BlocBuilder<PlayerCubit, PlayerState>(
            buildWhen: (c, p) =>
                c.isPlaying != p.isPlaying || c.recentSong != p.recentSong,
            builder: (BuildContext context, state) {
              return ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaY: 100, sigmaX: 1000),
                child: Image.memory(state.recentSong.cover.bytes),
              );
            },
          ),
          BlocBuilder<PlayerCubit, PlayerState>(
            buildWhen: (p, c) =>
                p.isPlaying != c.isPlaying ||
                p.recentSong != c.recentSong ||
                p.position != c.position ||
                p.shuffleThisPlaylist != c.shuffleThisPlaylist,
            builder: (BuildContext context, state) {
              final duration = state.duration;
              final currentPosition = state.position;
              return Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: Container(
                      clipBehavior: Clip.antiAlias,
                      width: context.screenSize.width * 0.8,
                      height: context.screenSize.width * 0.8,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            spreadRadius: 2,
                            blurRadius: 20,
                            color: Colors.black54,
                          ),
                        ],
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          image: MemoryImage(state.recentSong.cover.bytes),
                        ),
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        state.recentSong.title,
                        style: TextStyle(
                          fontSize: context.screenSize.width * 0.07,
                        ),
                      ),
                      SizedBox(height: 30),
                      Text(
                        state.recentSong.artis,
                        style: TextStyle(
                          fontSize: context.screenSize.width * 0.04,
                          color: Colors.white54,
                        ),
                      ),
                      Text(
                        state.recentSong.album,
                        style: TextStyle(
                          fontSize: context.screenSize.width * 0.04,
                          color: Colors.blueGrey.shade100.withAlpha(90),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(formatDuration(state.position)),
                            Expanded(
                              child: SquigglySlider(
                                activeColor: Colors.white,
                                inactiveColor: Colors.white54.withAlpha(20),
                                thumbColor: Colors.blueGrey,
                                squiggleAmplitude: 2.0,
                                squiggleWavelength: 5.0,
                                squiggleSpeed: 0.1,
                                value: currentPosition.inMilliseconds
                                    .clamp(0, duration.inMilliseconds)
                                    .toDouble(),
                                max: duration.inMilliseconds
                                    .clamp(0, duration.inMilliseconds)
                                    .toDouble(),
                                onChanged: (double value) {
                                  context.read<PlayerCubit>().seekTo(
                                    Duration(milliseconds: value.toInt()),
                                  );
                                },
                              ),
                            ),

                            Text(formatDuration(state.duration)),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LyricPage(),
                                  ),
                                );
                              },
                              icon: Icon(Icons.queue_music),
                            ),
                            Spacer(),
                            IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => QueueMusicPage(
                                      songIndex:
                                          context
                                              .read<PlayerCubit>()
                                              .playerControl
                                              .songIndex ??
                                          0,
                                    ),
                                  ),
                                );
                              },
                              icon: Icon(Icons.list_outlined),
                            ),
                            IconButton(
                              onPressed: () {
                                context.read<PlayerCubit>().repeatThisSong(
                                  !state.repeatThisSong,
                                );
                              },
                              icon: Icon(
                                Icons.repeat_one,
                                color: state.repeatThisSong
                                    ? Colors.white
                                    : Colors.white54.withAlpha(30),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                context.read<PlayerCubit>().shuffleThisPlaylist(
                                  !state.shuffleThisPlaylist,
                                );
                              },
                              icon: Icon(
                                Icons.shuffle,
                                color: state.shuffleThisPlaylist
                                    ? Colors.white
                                    : Colors.white54.withAlpha(30),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        onPressed: () =>
                            context.read<PlayerCubit>().previousSong(),
                        icon: Icon(Icons.skip_previous),
                      ),
                      IconButton(
                        onPressed: () {
                          context.read<PlayerCubit>().goTo(
                            Duration(
                              seconds: (state.position - Duration(seconds: 10))
                                  .inSeconds,
                            ),
                          );
                        },
                        icon: Icon(Icons.settings_backup_restore_outlined),
                      ),
                      IconButton(
                        onPressed: () {
                          context.read<PlayerCubit>().resumeOrPause();
                        },
                        icon: Icon(
                          state.isPlaying ? Icons.pause : Icons.play_arrow,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          context.read<PlayerCubit>().goTo(
                            Duration(
                              seconds: (state.position + Duration(seconds: 10))
                                  .inSeconds,
                            ),
                          );
                        },
                        icon: Transform.flip(
                          flipX: true,
                          child: Icon(Icons.settings_backup_restore_outlined),
                        ),
                      ),

                      IconButton(
                        onPressed: () => context.read<PlayerCubit>().nextSong(),
                        icon: Icon(Icons.skip_next),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
