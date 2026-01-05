import 'dart:ffi';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:playit/cubit/lyrics_cubit.dart';
import 'package:playit/cubit/player_cubit.dart';
import 'package:playit/models/lyrics_model.dart';
import 'package:playit/services/synced_lyric_service.dart';
import 'package:playit/utils/screen_detector.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../helpers/active_lyrics_helper.dart';
import '../../helpers/lrc_parser.dart';

class LyricPage extends StatefulWidget {
  const LyricPage({super.key});

  @override
  State<LyricPage> createState() => _LyricPageState();
}

class _LyricPageState extends State<LyricPage> {
  int currentPage = 0;
  final PageController _pageController = PageController(initialPage: 0);
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();
  int _lastIndex = -1;
  void scrollToIndex(int index) {
    itemScrollController.scrollTo(
      index: index,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      alignment: 0.5,
    );
  }

  @override
  void initState() {
    super.initState();
    final playerState = context.read<PlayerCubit>();
    final lyricsState = context.read<LyricsCubit>().state;

    if (lyricsState.syncedLyrics.isEmpty ||
        lyricsState.currentSongIndex != playerState.playerControl.songIndex) {
      context.read<LyricsCubit>().fetchLyrics();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: AlignmentGeometry.bottomCenter,
        fit: StackFit.loose,
        children: [
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
            child: Image.memory(
              fit: BoxFit.fill,
              context.read<PlayerCubit>().state.recentSong.cover.bytes,
            ),
          ),
          BlocListener<PlayerCubit, PlayerState>(
            listenWhen: (p, c) => p.recentSong != c.recentSong,
            listener: (BuildContext context, state) {
              context.read<LyricsCubit>().fetchLyrics();
            },
            child: PageView(
              onPageChanged: (page) {
                setState(() {
                  currentPage = page;
                });
              },
              controller: _pageController,
              children: [
                SingleChildScrollView(
                  child: SafeArea(
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
                StreamBuilder<Duration?>(
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
                    if (currentIndex != _lastIndex && currentIndex != -1) {
                      _lastIndex = currentIndex;
                      Future.microtask(() => scrollToIndex(currentIndex));
                    }
                    if (context.read<LyricsCubit>().state.isLoading) {
                      return Center(child: CircularProgressIndicator());
                    }
                    return Padding(
                      padding: const EdgeInsets.all(50.0),
                      child: ScrollablePositionedList.builder(
                        itemCount: lyrics.length,
                        itemScrollController: itemScrollController,
                        itemBuilder: (context, index) {
                          final lyric = lyrics[index];
                          final isActive = index == currentIndex;
                          return AnimatedDefaultTextStyle(
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              shadows: isActive
                                  ? [
                                      Shadow(
                                        color: Colors.white,
                                        blurRadius: 20,
                                      ),
                                    ]
                                  : null,
                              color: isActive
                                  ? Colors.white
                                  : Colors.white24.withAlpha(30),
                              fontSize: isActive
                                  ? context.screenSize.width * 0.07
                                  : context.screenSize.width * 0.05,
                            ),
                            duration: Duration(milliseconds: 500),
                            child: GestureDetector(
                              onTap: () {
                                context.read<PlayerCubit>().seekTo(lyric.time);
                              },
                              child: Text(lyric.text),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: BlocBuilder<PlayerCubit, PlayerState>(
                buildWhen: (p, c) => p.recentSong != c.recentSong,
                builder: (BuildContext context, state) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12.withAlpha(20),
                              blurRadius: 40,
                              spreadRadius: 20,
                            ),
                          ],
                          color: Colors.white.withAlpha(10),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        width: double.infinity,
                        height: context.screenSize.height * 0.06,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              style: TextStyle(
                                fontSize: context.screenSize.width * 0.04,
                              ),
                              state.recentSong.title,
                            ),
                            Text(state.recentSong.artis),
                          ],
                        ),
                      ),
                      Container(
                        width: context.screenSize.width * 0.6,
                        height: context.screenSize.height * 0.06,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 10,
                              color: Colors.black12.withAlpha(20),
                            ),
                          ],
                          color: Colors.white.withAlpha(20),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              TextButton(
                                style: ButtonStyle(
                                  backgroundColor:
                                      WidgetStateProperty.resolveWith<Color?>((
                                        states,
                                      ) {
                                        if (states.contains(
                                          WidgetState.pressed,
                                        )) {
                                          return Colors.white;
                                        }

                                        return currentPage == 0
                                            ? Colors.blueGrey
                                            : Colors.transparent;
                                      }),
                                  foregroundColor:
                                      WidgetStateProperty.resolveWith<Color?>((
                                        states,
                                      ) {
                                        if (states.contains(
                                          WidgetState.pressed,
                                        )) {
                                          return currentPage == 0
                                              ? Colors.blueGrey
                                              : Colors.transparent;
                                        }

                                        return currentPage == 0
                                            ? Colors.white
                                            : Colors.grey;
                                      }),
                                ),
                                onPressed: () {
                                  setState(() {
                                    currentPage = 0;
                                  });
                                  _pageController.animateToPage(
                                    0,
                                    duration: Duration(milliseconds: 500),
                                    curve: Curves.easeInOut,
                                  );
                                },
                                child: Text("Static"),
                              ),

                              TextButton(
                                style: ButtonStyle(
                                  backgroundColor:
                                      WidgetStateProperty.resolveWith<Color?>((
                                        states,
                                      ) {
                                        if (states.contains(
                                          WidgetState.pressed,
                                        )) {
                                          return Colors.white;
                                        }

                                        return currentPage == 1
                                            ? Colors.blueGrey
                                            : Colors.transparent;
                                      }),
                                  foregroundColor:
                                      WidgetStateProperty.resolveWith<Color?>((
                                        states,
                                      ) {
                                        if (states.contains(
                                          WidgetState.pressed,
                                        )) {
                                          return currentPage == 1
                                              ? Colors.blueGrey
                                              : Colors.white;
                                        }

                                        return currentPage == 1
                                            ? Colors.white
                                            : Colors.grey;
                                      }),
                                ),
                                onPressed: () {
                                  setState(() {
                                    currentPage = 1;
                                  });
                                  _pageController.animateToPage(
                                    1,
                                    duration: Duration(milliseconds: 500),
                                    curve: Curves.easeInOut,
                                  );
                                },
                                child: Text("Synced"),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
