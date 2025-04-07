import 'package:anime_mobile/anime_summary_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:anime_mobile/models.dart';
import 'alerts_screen.dart';
import 'search_screen.dart';
import 'background_container.dart'; // ✅ Ensure this file exists and works

class AnimeScreen extends StatefulWidget {
  final User user;
  const AnimeScreen({super.key, required this.user});

  @override
  _AnimeScreenState createState() => _AnimeScreenState();
}

final List<Anime> animeList = [
  Anime(animeId: 1, title: 'Sousou no Frieren', imageURL: 'https://cdn.myanimelist.net/images/anime/1015/138006.jpg', synopsis: '...', alert: false),
  Anime(animeId: 2, title: 'Fullmetal Alchemist: Brotherhood', imageURL: 'https://cdn.myanimelist.net/images/anime/1208/94745.jpg', synopsis: '...', alert: false),
  Anime(animeId: 3, title: 'Hunter x Hunter (2011)', imageURL: 'https://cdn.myanimelist.net/images/anime/1337/99013.jpg', synopsis: '...', alert: false),
  Anime(animeId: 4, title: 'Mob Psycho 100 II', imageURL: 'https://cdn.myanimelist.net/images/anime/1918/96303.jpg', synopsis: '...', alert: false),
  Anime(animeId: 5, title: 'Cowboy Bebop', imageURL: 'https://cdn.myanimelist.net/images/anime/4/19644.jpg', synopsis: '...', alert: false),
];

class _AnimeScreenState extends State<AnimeScreen> {
  String message = '';
  int _selectedIndex = 0; // For bottom navigation

  @override
  void dispose() {
    super.dispose();
  }

  _animeAlert() async {
    // ... (Your _animeAlert logic remains the same) ...
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AnimeScreen(user: widget.user)),
      );
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SearchScreen(user: widget.user)),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AlertsScreen(user: widget.user)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Color getColor(Set<MaterialState> states) {
      const Set<MaterialState> interactiveStates = <MaterialState>{
        MaterialState.pressed,
        MaterialState.hovered,
        MaterialState.focused,
      };
      if (states.any(interactiveStates.contains)) {
        return Colors.blue;
      }
      return Colors.white;
    }

    return BackgroundContainer( // Wrap with BackgroundContainer
      child: Scaffold(
        appBar: AppBar(
          title: Text('Anime List'),
          backgroundColor: Colors.transparent, // Make AppBar transparent
          elevation: 0, // Remove AppBar shadow
        ),
        body: ListView.builder(
          itemCount: animeList.length,
          itemBuilder: (context, index) {
            final anime = animeList[index];
            return ListTile(
              leading: Image.network(anime.imageURL, width: 50, height: 75),
              title: Text(anime.title),
              trailing: Checkbox(
                value: anime.alert,
                onChanged: (bool? value) {
                  // Implement alert toggle logic here
                  // Update the anime's alert status and make 1API call.
                },
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AnimeSummaryScreen(user: widget.user)),
                );
              },
            );
          },
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

class AnimeListScreen extends StatelessWidget {
  final User user;
  AnimeListScreen({required this.user});

  @override
  Widget build(BuildContext context) {
    return BackgroundContainer( // Wrap with BackgroundContainer
      child: Scaffold(
        appBar: AppBar(
          title: Text('Anime List'),
          backgroundColor: Colors.transparent, // Make AppBar transparent
          elevation: 0, // Remove AppBar shadow
        ),
        body: ListView.builder(
          itemCount: animeList.length,
          itemBuilder: (context, index) {
            final anime = animeList[index];
            return ListTile(
              leading: Image.network(anime.imageURL, width: 50, height: 75),
              title: Text(anime.title),
              trailing: Checkbox(
                value: anime.alert,
                onChanged: (bool? value) {
                  // Implement alert toggle logic here
                  // Update the anime's alert status and make API call.
                },
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AnimeScreen(user: user)),
                );
              },
            );
          },
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
          currentIndex: 0, // Set initial index for this screen
          selectedItemColor: Colors.blue,
          onTap: (index) {
            if (index == 0) {
              // Stay on the AnimeListScreen
            } else if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SearchScreen(user: user)),
              );
            } else if (index == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AlertsScreen(user: user)),
              );
            }
          },
        ),
        backgroundColor: Colors.transparent, // Make Scaffold background transparent
      ),
    );
  }
}