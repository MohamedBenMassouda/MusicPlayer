import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_app/functions/convert_duration.dart';
import 'package:on_audio_query/on_audio_query.dart';

class SongPage extends StatefulWidget {
  final AudioPlayer player;
  final List<SongModel> songs;
  bool isPlaying = false;

  SongPage({
    super.key,
    required this.songs,
    required this.player,
    required this.isPlaying,
  });

  @override
  State<SongPage> createState() => _SongPageState();
}

class _SongPageState extends State<SongPage> {
  double sliderValue = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if (mounted) {
      setState(() {
        duration = widget.player.duration;
      });
    }

    widget.player.positionStream.listen((event) {
      if (event == duration) {
        if (widget.player.currentIndex! + 1 == widget.songs.length) {
          widget.player.pause();
          setState(() {
            widget.isPlaying = false;
          });
        } else {
          widget.player.seek(Duration.zero);
          widget.player.seekToNext();
          widget.player.play();
        }
      }

      if (mounted) {
        setState(() {
          position = event;
        });
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  Duration position = Duration.zero;
  Duration? duration = Duration.zero;

  bool isOnRepeat = false;
  bool isOnShuffle = false;

  @override
  Widget build(BuildContext context) {
    List<List<dynamic>> bottomButtons = [
      [
        CupertinoIcons.backward_fill,
        () async {
          if (position.inSeconds < 10) {
            await widget.player.seek(Duration.zero);
          } else {
            await widget.player.seek(Duration(seconds: (position.inSeconds - 10)));
          }
        }
      ],
      [
        isOnRepeat ? CupertinoIcons.repeat_1 : CupertinoIcons.repeat,
        () {
          if (isOnRepeat) {
            widget.player.setLoopMode(LoopMode.off);
          } else {
            widget.player.setLoopMode(LoopMode.one);
          }

          setState(() {
            isOnRepeat = !isOnRepeat;
          });
        }
      ],
      [
        isOnShuffle ? Icons.shuffle_on_rounded : CupertinoIcons.shuffle_medium,  
        () {
          widget.player.setShuffleModeEnabled(!isOnShuffle);

          setState(() {
            isOnShuffle = !isOnShuffle;
          });
        }
      ],
      [
        CupertinoIcons.forward_fill,
        () async {
          if (position.inSeconds + 10 > duration!.inSeconds) {
            await widget.player.seek(duration!);
          } else {
            await widget.player.seek(Duration(seconds: (position.inSeconds + 10)));
          }
        }
      ]
    ];

    String title = widget.songs[widget.player.currentIndex!].title;
    String artist =
        widget.songs[widget.player.currentIndex!].artist ?? "Unknown";

    return Scaffold(
      appBar: AppBar(
        title: const Text('Now Playing'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Center(
            child: Container(
              padding: const EdgeInsets.all(70),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey[800],
              ),
              child: const Icon(
                Icons.music_note_rounded,
                size: 40,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              height: 50,
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            artist == "<unknown>" ? "Unknown Artist" : artist,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
          const Spacer(),
          Slider(
            value: position.inSeconds.toDouble(),
            onChanged: (value) async {
              position = Duration(seconds: value.toInt());
              await widget.player.seek(Duration(seconds: value.toInt()));
            },
            min: 0,
            max: duration!.inSeconds.toDouble(),
          ),
          Row(
            children: [
              const SizedBox(width: 20),
              Text(
                position.toString().substring(2, 7),
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              Text(
                widget.player.duration.toString().substring(2, 7),
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 20),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: () {
                  if (widget.player.currentIndex! == 0) {
                    widget.player.seek(Duration.zero);
                  } else {
                    widget.player.seekToPrevious();

                    setState(() {
                      widget.isPlaying = true;
                    });
                  }
                },
                icon: const Icon(Icons.skip_previous_rounded),
                iconSize: 40,
              ),
              IconButton(
                onPressed: () {
                  if (widget.isPlaying) {
                    widget.player.pause();
                  } else {
                    widget.player.play();
                  }

                  setState(() {
                    widget.isPlaying = !widget.isPlaying;
                  });
                },
                icon: widget.isPlaying
                    ? const Icon(Icons.pause_rounded)
                    : const Icon(Icons.play_arrow_rounded),
                iconSize: 40,
              ),
              IconButton(
                onPressed: () {
                  if (widget.player.currentIndex! + 1 == widget.songs.length) {
                    widget.player.seek(Duration.zero, index: 0);
                  } else {
                    widget.player.seekToNext();
                    widget.player.play();
                  }
                },
                icon: const Icon(Icons.skip_next_rounded),
                iconSize: 40,
              ),
            ],
          ),
          
          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (var item in bottomButtons)
                IconButton(
                  onPressed: item[1],
                  icon: Icon(
                    item[0],
                  ),
                )
            ],
          )
        ],
      ),
    );
  }
}
