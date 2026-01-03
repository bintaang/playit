
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:playit/cubit/songs_cubit.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    fetchSong();
  }

  Future<void> fetchSong() async {
    final path = context.read<SongsCubit>().state.baseUrl;
    if (path.isEmpty) return;
    context.read<SongsListCubit>().fetchNewSong(path);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: BlocBuilder<SongsListCubit, SongsListState>(
          builder: (context, state) {
            return ListView.builder(
              padding: EdgeInsets.all(5),
              itemCount: state.songs.length,
              itemBuilder: (context, index) {
                final song = state.songs[index];
                return ListTile(
                  key: Key(index.toString()),
                  contentPadding: EdgeInsets.all(5),
                  title: Text(song.title),
                  subtitle: Text(song.artis),
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(100)),
                    ),
                    child: Image.memory(song.cover.bytes, fit: BoxFit.cover),
                  ),
                  trailing: IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.play_arrow),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
