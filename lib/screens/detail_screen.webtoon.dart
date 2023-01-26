import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toonflix/models/webtoon_apisode.model.dart';
import 'package:toonflix/models/webtoon_detail.model.dart';
import 'package:toonflix/services/api_service.dart';
import 'package:toonflix/widgets/webtoon_widget.dart';

import '../widgets/webtoon_episode.dart';

class WebtoonDetailScreen extends StatefulWidget {
  final String title, thumb, id;
  const WebtoonDetailScreen({
    super.key,
    required this.title,
    required this.thumb,
    required this.id,
  });

  @override
  State<WebtoonDetailScreen> createState() => _WebtoonDetailScreenState();
}

class _WebtoonDetailScreenState extends State<WebtoonDetailScreen> {
  late Future<WebtoonDetailModel> webtoon;
  late Future<List<WebtoonEpisodeModel>> episodes;
  late SharedPreferences prefs;
  bool isLiked = false;
  Future initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    final likedToons = prefs.getStringList('likedToons');
    if (likedToons != null) {
      if (likedToons.contains(widget.id) == true) {
        setState(() {
          isLiked = true;
        });
      }
    } else {
      prefs.setStringList('likedToons', []);
    }
  }

  @override
  void initState() {
    super.initState();
    webtoon = ApiService.getToonById(widget.id);
    episodes = ApiService.getLatestEpisodesById(widget.id);
    initPrefs();
  }

  void onToggleLiked() async {
    final likedToons = prefs.getStringList('likedToons');
    if (likedToons != null) {
      if (isLiked) {
        likedToons.remove(widget.id);
      } else {
        likedToons.add(widget.id);
      }
      await prefs.setStringList('likedToons', likedToons);
      setState(() {
        isLiked = !isLiked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 2,
        foregroundColor: Colors.green,
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: onToggleLiked,
            icon: Icon(
                isLiked ? Icons.favorite_outlined : Icons.favorite_outline),
          )
        ],
        title: Text(
          widget.title,
          style: const TextStyle(
            fontSize: 24,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 50),
        child: ListView(children: [
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Webtoon(
                title: widget.title,
                thumb: widget.thumb,
                id: widget.id,
              ),
            ],
          ),
          const SizedBox(
            height: 25,
          ),
          FutureBuilder(
              future: webtoon,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        snapshot.data!.about,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        '${snapshot.data!.genre} / ${snapshot.data!.age}',
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      )
                    ],
                  );
                }
                return const Text('...');
              }),
          const SizedBox(
            height: 20,
          ),
          FutureBuilder(
              future: episodes,
              builder: ((context, snapshot) {
                if (snapshot.hasData) {
                  return Column(children: [
                    for (var episode in snapshot.data!)
                      Episode(
                        webtoonId: widget.id,
                        episode: episode,
                      )
                  ]);
                }
                return Container();
              }))
        ]),
      ),
    );
  }
}
