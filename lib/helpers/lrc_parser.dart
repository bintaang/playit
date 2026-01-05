import '../models/lyrics_model.dart';

List<LyricLine> parseLrc(String lrc) {
  final regex = RegExp(r'\[(\d+):(\d+\.\d+)\](.*)');
  final List<LyricLine> result = [];

  for (final line in lrc.split('\n')) {
    final match = regex.firstMatch(line);
    if (match == null) continue;

    final minutes = int.parse(match.group(1)!);
    final seconds = double.parse(match.group(2)!);
    final text = match.group(3)!.trim();

    final time = Duration(
      milliseconds: ((minutes * 60 + seconds) * 1000).toInt(),
    );

    result.add(LyricLine(time: time, text: text));
  }

  result.sort((a, b) => a.time.compareTo(b.time));
  return result;
}
