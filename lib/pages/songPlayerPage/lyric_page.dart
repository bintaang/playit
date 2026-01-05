import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:playit/cubit/lyrics_cubit.dart';
import 'package:playit/cubit/player_cubit.dart';
import 'package:playit/models/lyrics_model.dart';
import 'package:playit/services/synced_lyric_service.dart';
import 'package:playit/utils/screen_detector.dart';

import '../../helpers/active_lyrics_helper.dart';
import '../../helpers/lrc_parser.dart';

class LyricPage extends StatefulWidget {
  const LyricPage({super.key});

  @override
  State<LyricPage> createState() => _LyricPageState();
}

class _LyricPageState extends State<LyricPage> {
  @override
  void initState() {
    super.initState();
    context.read<LyricsCubit>().fetchLyrics();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            children: [
              SingleChildScrollView(
                child: SafeArea(
                  child: BlocListener<PlayerCubit, PlayerState>(
                    listenWhen: (p, c) => p.recentSong != c.recentSong,
                    listener: (BuildContext context, state) {
                      context.read<LyricsCubit>().fetchLyrics();
                    },
                    child: BlocBuilder<LyricsCubit, LyricsState>(
                      builder: (context, state) {
                        if (state.isLoading) {
                          return Center(child: CircularProgressIndicator());
                        }
                        return Padding(
                          padding: const EdgeInsets.all(30.0),
                          child: Text(
                            state.plainLyrics,
                            style: TextStyle(
                              fontSize: context.screenSize.width * 0.06,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              BlocListener<PlayerCubit, PlayerState>(
                listenWhen: (p, c) => p.recentSong != c.recentSong,
                listener: (BuildContext context, state) {
                  context.read<LyricsCubit>().fetchLyrics();
                },
                child: StreamBuilder<Duration?>(
                  stream: context
                      .read<PlayerCubit>()
                      .playerControl
                      .recentPosition,
                  builder: (context, snapshot) {
                    final position = snapshot.data ?? Duration.zero;
                    final lyrics = context
                        .read<LyricsCubit>()
                        .state
                        .syncedLyrics;

                    final currentIndex = findCurrentLyricIndex(
                      position,
                      lyrics,
                    );
                    if (context.read<LyricsCubit>().state.isLoading) {
                      CircularNotchedRectangle();
                    }
                    return Padding(
                      padding: const EdgeInsets.all(50.0),
                      child: ListView.builder(
                        itemCount: lyrics.length,
                        itemBuilder: (context, index) {
                          final isActive = index == currentIndex;
                          return AnimatedDefaultTextStyle(
                            textAlign: TextAlign.center,
                            curve: Curves.easeInOut,
                            duration: const Duration(milliseconds: 800),
                            style: TextStyle(
                              fontSize: isActive ? 20 : 16,
                              color: isActive ? Colors.white : Colors.white54,
                              fontWeight: isActive
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Text(lyrics[index].text),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
