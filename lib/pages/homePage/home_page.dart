import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:playit/cubit/player_cubit.dart';
import 'package:playit/cubit/songs_cubit.dart';
import 'package:playit/helpers/song_finder.dart';
import 'package:playit/models/song_model.dart';
import 'package:playit/pages/songPlayerPage/song_player_page.dart';
import 'package:playit/utils/screen_detector.dart';
import 'package:rive_animated_icon/rive_animated_icon.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _textEditingController = TextEditingController();
  String searchSong = "";
  @override
  void initState() {
    super.initState();
    fetchSong();
  }

  Future<void> fetchSong() async {
    final path = context.read<SongsCubit>().state.baseUrl;
    if (path.isEmpty) return;
    if (context.read<SongsListCubit>().state.baseUrl == path) return;
    context.read<SongsListCubit>().fetchNewSong(path);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: BlocBuilder<SongsListCubit, SongsListState>(
          builder: (context, state) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SearchBar(
                    controller: _textEditingController,
                    onChanged: (String value) {
                      setState(() {
                        searchSong = value;
                      });
                    },
                    padding: WidgetStateProperty.resolveWith<EdgeInsets?>((
                      states,
                    ) {
                      if (states.contains(WidgetState.focused)) {
                        EdgeInsets.symmetric(horizontal: 20);
                      } else {
                        return EdgeInsets.symmetric(horizontal: 30);
                      }
                    }),
                    trailing: [Icon(Icons.search)],
                    hintText: "Find any song from your library",
                    hintStyle: WidgetStateProperty.resolveWith<TextStyle?>((
                      states,
                    ) {
                      if (states.contains(WidgetState.focused)) {
                        return TextStyle(color: Colors.black12);
                      }
                      return TextStyle(color: Colors.white54.withAlpha(30));
                    }),
                  ),
                ),
                searchSong.isNotEmpty
                    ? Expanded(child: SongFinder(songTitle: searchSong))
                    : Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.all(5),
                          itemCount: state.songs.length,
                          itemBuilder: (context, index) {
                            final song = state.songs[index];
                            return ListTile(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SongPlayerPage(
                                      songs: context
                                          .read<SongsListCubit>()
                                          .state
                                          .songs,
                                      songIndex: index,
                                    ),
                                  ),
                                );
                              },
                              key: Key(index.toString()),
                              contentPadding: EdgeInsets.all(5),
                              title: Text(song.title),
                              subtitle: Text(song.artis),
                              leading: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(100),
                                  ),
                                ),
                                child: Image.memory(
                                  song.cover.bytes,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              trailing: BlocBuilder<PlayerCubit, PlayerState>(
                                buildWhen: (p, c) =>
                                    p.recentSong != c.recentSong,
                                builder: (BuildContext context, state) {
                                  final isSongPlayed =
                                      state.recentSong.artis == song.artis &&
                                      state.recentSong.title == song.title;
                                  return IconButton(
                                    onPressed: () {},
                                    icon: isSongPlayed
                                        ? RiveAnimatedIcon(
                                            riveIcon: RiveIcon.sound,
                                            loopAnimation: true,
                                            width:
                                                context.screenSize.width * 0.08,
                                            height:
                                                context.screenSize.width * 0.08,
                                            color: Colors.deepOrange,
                                          )
                                        : Icon(Icons.play_arrow),
                                  );
                                },
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
