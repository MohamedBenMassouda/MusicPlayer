import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_app/pages/song_page.dart';
import 'package:music_app/utils/song_tile.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final OnAudioQuery audioQuery = OnAudioQuery();
  List<SongModel> songs = [];
  final AudioPlayer player = AudioPlayer();
  bool isPlaying = false;

  void getFiles() async {
    var permission = await Permission.audio.status;

    if (!permission.isGranted) {
      permission = await Permission.audio.request();
    }

    if (permission.isGranted) {
      var song = await audioQuery.querySongs();
      setState(() {
        songs = song;
      });
    }
  }

  List<AudioSource> getAudioSource() {
    return songs
        .map(
          (e) => AudioSource.uri(
            Uri.parse(e.data),
          ),
        )
        .toList();
  }

  @override
  void initState() {
    super.initState();
    getFiles();

    player.playerStateStream.listen((event) {
      if (event.playing) {
        setState(() {
          isPlaying = true;
        });
      } else {
        setState(() {
          isPlaying = false;
        });
      }

      if (event.processingState == ProcessingState.completed) {
        goToNextSong();
      }
    });
  }

  void goToNextSong() async {
    if (player.hasNext){
      await player.seekToNext();
    }
  }

  void goToPreviousSong() async {
    if (player.hasPrevious){
      await player.seekToPrevious();
    }
  }

  bool isSearching = false;
  TextEditingController controller = TextEditingController();
  List<SongModel> searchResults = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          isSearching ? Expanded(
            child: TextField(
              maxLines: 1,
              controller: controller,

              decoration: const InputDecoration(
                hintText: "Search",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                )
              ),
              onChanged: (value) {
                searchResults.clear();
                if (value.isNotEmpty) {
                  for (var name in songs) {
                    if (name.title.contains(value)) {
                      searchResults.add(name);
                    } 
                  }

                  setState(() {
                    isSearching = true;
                  });
                } else {
                  setState(() {
                    isSearching = false;
                  });
                }
              },
            ),
          ) : const SizedBox(),

          IconButton(
            onPressed: () {
              setState(() {
                isSearching = !isSearching;
              });
            },
            icon: const Icon(Icons.search_rounded),
          ),
        ],
      ),

      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: songs.length,
              itemBuilder: (context, index) {
                return SongTile(
                  title: songs[index].title,
                  artist: songs[index].artist ?? "Unknown",
                  data: songs[index].data,
                  onTap: () async {
                    if (isPlaying) {
                      await player.pause();
                    } else {
                      if (player.audioSource == null) {
                        await player.setAudioSource(
                          ConcatenatingAudioSource(
                            children: getAudioSource(),
                          ),
                          initialIndex: index,
                        );
                      } else {
                        await player.seek(Duration.zero, index: index);
                      }
                      player.play();
                    }
                  },
                  onNext: () {
                    goToNextSong();
                  },
                  onPrevious: () {
                    goToPreviousSong();
                  },
                  duration: songs[index].duration ?? 0,
                );
              },
            ),
          ),

          player.audioSource != null ? 
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SongPage(
                        player: player,
                        songs: songs,
                        isPlaying: isPlaying,
                      ),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color.fromARGB(255, 63, 49, 86),
                        Color.fromARGB(255, 64, 44, 99),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
              
                  padding: const EdgeInsets.all(5),
                  margin: const EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const CircleAvatar(
                        child: Icon(
                          Icons.music_note_rounded,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          songs[player.currentIndex!].title,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          goToPreviousSong();
                        },
                        icon: const Icon(Icons.skip_previous),
                      ),
                      isPlaying
                          ? IconButton(
                              onPressed: () async {
                                await player.pause();
                              },
                              icon: const Icon(Icons.pause),
                            )
                          : IconButton(
                              onPressed: () async {
                                await player.play();
                              },
                              icon: const Icon(Icons.play_arrow),
                            ),
                      IconButton(
                        onPressed: () {
                          goToNextSong();
                        },
                        icon: const Icon(Icons.skip_next),
                      ),
                    ],
                  ),
                        ),
              ) : const SizedBox(),
        ],
      ),
    );
  }
}
