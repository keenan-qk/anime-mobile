import 'package:anime_mobile/anime_screen.dart';
import 'package:flutter/material.dart';
import 'package:anime_mobile/models.dart';
import 'search_screen.dart'; // Import SearchScreen
import 'alerts_screen.dart'; // Import AlertsScreen
import 'background_container.dart'; // Ensure this file exists and works

class AnimeSummaryScreen extends StatefulWidget {
  final User? user;
  const AnimeSummaryScreen({Key? key, this.user}) : super(key: key);

  @override
  _AnimeSummaryScreenState createState() => _AnimeSummaryScreenState();
}

class _AnimeSummaryScreenState extends State<AnimeSummaryScreen> {
  Anime? _anime;
  int _selectedIndex = 0; // For bottom navigation

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    await Future.delayed(const Duration(seconds: 1));
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      // Stay on the AnimeSummaryScreen (or navigate to your main AnimeListScreen if that's the home)
      // If this is the main home, you might not need to navigate again.
      print("Anime Summary");
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SearchScreen(user: widget.user!)),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AlertsScreen(user: widget.user!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundContainer( // Wrap with BackgroundContainer
      child: Scaffold(
        appBar: AppBar(
          title: Text('Anime Information'),
          backgroundColor: Colors.transparent,
          elevation: 0,
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
                        builder: (context) => AnimeScreen(user: widget.user!),
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
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.movie_filter),
              label: 'Anime',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications),
              label: 'Alerts',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.blue,
          onTap: _onItemTapped,
        ),
        backgroundColor: Colors.transparent, // Make Scaffold background transparent
      ),
    );
  }
}