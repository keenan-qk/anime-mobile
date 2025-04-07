import 'package:anime_mobile/anime_screen.dart';
import 'package:flutter/material.dart';
import 'package:anime_mobile/models.dart';
import 'background_container.dart'; // ✅ Import background wrapper

class HomeCall extends StatefulWidget {
  final User user;

  HomeCall({required this.user});

  @override
  _HomeCallState createState() => _HomeCallState();
}

class _HomeCallState extends State<HomeCall> {
  Anime? _anime;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _anime = Anime(
        animeId: 1,
        title: 'Naruto',
        synopsis: 'A young ninja...',
        imageURL: 'https://example.com/naruto.jpg',
        alert: true,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black87,
        title: Text('Home'),
      ),
      body: BackgroundContainer(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Welcome to',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'AniLert',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  if (_anime != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AnimeScreen(anime: _anime!, user: widget.user),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('Go to Anime Screen'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
