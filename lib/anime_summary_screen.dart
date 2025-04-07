import 'package:anime_mobile/anime_screen.dart';
import 'package:flutter/material.dart';
import 'package:anime_mobile/models.dart';

class HomeCall extends StatefulWidget {
  final User user;

  HomeCall({required this.user});

  @override
  _HomeCallState createState() => _HomeCallState();
}

class _HomeCallState extends State<HomeCall> {
  Anime? _anime; // Nullable Anime object

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    await Future.delayed(const Duration(seconds: 1));
    // Simulate fetching anime data (replace with actual API call)
    Anime fetchedAnime = Anime(
      animeId: 1,
      title: 'Cowboy Bebop',
      imageURL: 'https://cdn.myanimelist.net/images/anime/4/19644.jpg',
      synopsis: 'example_synopsis',
      alert: false,
    );
    setState(() {
      _anime = fetchedAnime;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'), // Or whatever title you want
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_anime != null) ...[
              Text('Anime Title: ${_anime!.title}'),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AnimeScreen(user: widget.user),
                    ),
                  );
                },
                child: Text('View Anime Details'),
              ),
            ] else ...[
              Text('Loading Anime...'),
            ],
          ],
        ),
      ),
    );
  }
}