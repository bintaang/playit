import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:playit/cubit/album_cubit.dart';

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
            return GridView.builder(
              padding: EdgeInsets.all(10),
              itemCount: state.listAlbum.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10
              ),
              itemBuilder: (context, index) {
                final album = state.listAlbum[index];
                return Image.memory(album.albumCover.bytes);
              },
            );
          },
        ),
      ),
    );
  }
}
