import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:playit/cubit/album_cubit.dart';
import 'package:playit/cubit/songs_cubit.dart';
import 'package:playit/pages/root_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final Directory directory = await getApplicationDocumentsDirectory();
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: HydratedStorageDirectory(directory.path),
  );
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<SongsCubit>(create: (context) => SongsCubit()),
        BlocProvider<SongsListCubit>(create: (context) => SongsListCubit()),
        BlocProvider<AlbumCubit>(
          create: (context) =>
              AlbumCubit(songsListCubit: context.read<SongsListCubit>()),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColorDark: Colors.deepOrange.shade600,
      ),
      home: RootPage(),
    );
  }
}
