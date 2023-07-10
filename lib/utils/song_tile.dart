// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

class SongTile extends StatelessWidget {
  final String title;
  final String artist;
  final String data;
  bool isPlaying;
  final VoidCallback onTap;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final int duration;

  SongTile(
      {super.key,
      required this.title,
      required this.artist,
      required this.data,
      required this.onTap,
      required this.onNext,
      required this.onPrevious,
      required this.duration,
      this.isPlaying = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey[800],
              ),
              child: const Icon(Icons.music_note_rounded),
            ),

            const SizedBox(width: 10),
            
            Flexible(
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
