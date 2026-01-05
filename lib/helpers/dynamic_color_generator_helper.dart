import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:palette_generator_master/palette_generator_master.dart';

class DynamicColorGeneratorHelper {
  final Color? lightessColor;
  final Color? darkestColor;
  DynamicColorGeneratorHelper(this.lightessColor, this.darkestColor);
  static Future<DynamicColorGeneratorHelper> generatePallete(
    Picture image,
  ) async {
    final targetImage = MemoryImage(image.bytes);
    final PaletteGeneratorMaster palleteGenerator =
        await PaletteGeneratorMaster.fromImageProvider(
          targetImage,
          maximumColorCount: 5,
          colorSpace: ColorSpace.lab,
          generateHarmony: true,
        );
    final lightessColor = palleteGenerator.lightMutedColor?.color;
    final darkestColor = palleteGenerator.darkMutedColor?.color;
    return DynamicColorGeneratorHelper(
      lightessColor,
      darkestColor,
    );
  }
}
