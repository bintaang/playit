import 'dart:typed_data';

import 'package:flutter/material.dart';

class AlbumCard extends StatelessWidget {
  const AlbumCard({
    super.key,
    required this.albumName,
    required this.albumPhoto,
  });

  final Uint8List albumPhoto;
  final String albumName;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: AspectRatio(
            aspectRatio: 1,
            child: Container(
              padding: const EdgeInsets.all(8),
              alignment: Alignment.bottomLeft,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: MemoryImage(albumPhoto),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          albumName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade400
          ),
        ),
      ],
    );
  }
}
