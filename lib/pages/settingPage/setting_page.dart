import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../cubit/songs_cubit.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  Future<void> getPermission() async {
    final permission = await Permission.audio.request();
    if (permission.isGranted) {
      final String? directory = await FilePicker.platform.getDirectoryPath();
      print(directory);
      if (mounted) {
        print(directory);
        context.read<SongsCubit>().updateBaseUrl(directory!);
      }
    }
    if (permission.isPermanentlyDenied) {
      openAppSettings();
    }
    if (permission.isDenied) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ListTile(
          onTap: () => {getPermission()},
          title: Text("Add Directory"),
          leading: Icon(Icons.folder),
        ),
      ),
    );
  }
}
