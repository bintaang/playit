import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:playit/models/lyrics_model.dart';

Future<LyricsResponseModel> getLyrics({required LyricsModel body}) async {
  final uri = Uri.https('lrclib.net', '/api/get', {
    'artist_name': body.artist_name,
    'track_name': body.track_name,
    'album_name': body.album_name,
    'duration': body.duration.toString(),
  });

  final res = await http.get(uri);

  if (res.statusCode == 200) {
    return LyricsResponseModel.fromJson(jsonDecode(res.body));
  } else {
    throw Exception('Failed to load lyrics (${res.statusCode})');
  }
}
