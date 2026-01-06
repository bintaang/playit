import 'dart:io';
import 'dart:typed_data'; //
import 'package:path_provider/path_provider.dart';

Future<Uri> getArtUri(Uint8List bytes, String songId) async {
  final tempDir = await getTemporaryDirectory();
  final safeFileName = songId.hashCode.toString();
  final file = File('${tempDir.path}/$safeFileName.jpg');

  if (await file.exists()) {
    return file.uri;
  }

  await file.writeAsBytes(bytes.toList());
  return file.uri;
}
