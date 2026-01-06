import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:playit/cubit/player_cubit.dart';
import 'package:playit/cubit/songs_cubit.dart';
import 'package:rive_animated_icon/rive_animated_icon.dart';

import '../pages/songPlayerPage/song_player_page.dart';
import '../utils/screen_detector.dart';

class SongFinder extends StatefulWidget {
  const SongFinder({super.key, required this.songTitle});
  final String songTitle;
  @override
  State<SongFinder> createState() => _SongFinderState();
}

class _SongFinderState extends State<SongFinder> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SongsListCubit, SongsListState>(
      builder: (BuildContext context, state) {
        final result = state.songs
            .where(
              (song) => song.title.toLowerCase().contains(
                widget.songTitle.toLowerCase(),
              ),
            )
            .toList();
        return ListView.builder(
          itemCount: result.length,
          itemBuilder: (context, index) {
            final resultSong = result[index];
            return ListTile(
              onTap: () {
                final index = state.songs.indexWhere(
                  (song) =>
                      song.title == resultSong.title &&
                      song.artis == resultSong.artis,
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SongPlayerPage(
                      songs: context.read<SongsListCubit>().state.songs,
                      songIndex: index,
                    ),
                  ),
                );
              },
              leading: Image.memory(resultSong.cover.bytes),
              title: Text(resultSong.title),
              subtitle: Text(resultSong.artis),
              trailing: BlocBuilder<PlayerCubit, PlayerState>(
                buildWhen: (p, c) => p.recentSong != c.recentSong,
                builder: (context, state) {
                  final isPlaying =
                      state.recentSong.artis == resultSong.artis &&
                      state.recentSong.title == resultSong.title;
                  return isPlaying
                      ? RiveAnimatedIcon(
                          riveIcon: RiveIcon.sound,
                          loopAnimation: true,
                          width: context.screenSize.width * 0.08,
                          height: context.screenSize.width * 0.08,
                          color: Colors.deepOrange,
                        )
                      : Icon(Icons.play_arrow);
                },
              ),
            ).animate().fadeIn(duration: Duration(milliseconds: 300));
          },
        );
      },
    );
  }
}
