import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:playit/cubit/player_cubit.dart';
import 'package:playit/helpers/queue_finder.dart';
import 'package:playit/models/song_model.dart';
import 'package:playit/utils/screen_detector.dart';

class QueueMusicPage extends StatefulWidget {
  const QueueMusicPage({super.key, required this.songIndex});
  final int songIndex;
  @override
  State<QueueMusicPage> createState() => _QueueMusicPageState();
}

class _QueueMusicPageState extends State<QueueMusicPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shadowColor: Colors.transparent,
        title: Text(context.read<PlayerCubit>().state.recentSong.album),
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: true,
        backgroundColor: Colors.transparent,
      ),
      body: Stack(
        fit: StackFit.loose,
        children: [
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaY: 50, sigmaX: 50),
            child: Image.memory(
              context.read<PlayerCubit>().state.recentSong.cover.bytes,
            ),
          ),
          Container(color: Colors.black.withAlpha(80)),
          BlocBuilder<PlayerCubit, PlayerState>(
            builder: (context, state) {
              final List<SongModel> queueSongs = queueFinder(
                currentIndexSong: widget.songIndex,
                state: state,
              );
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15.0,
                      vertical: 10,
                    ),
                    child: Text(
                      "Next Songs",
                      style: TextStyle(
                        fontSize: context.screenSize.width * 0.05,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.all(5),
                      itemCount: queueSongs.length,
                      itemBuilder: (context, index) {
                        final song = queueSongs[index];
                        return ListTile(
                          contentPadding: EdgeInsets.all(10),
                          title: Text(song.title),
                          leading: Container(
                            width: 50,
                            height: 50,
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              image: DecorationImage(
                                image: MemoryImage(song.cover.bytes),
                              ),
                            ),
                          ),
                          subtitle: Text(song.artis),
                        );
                      },
                    ),
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
