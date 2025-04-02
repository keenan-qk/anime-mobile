import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:anime_mobile/models.dart';
import 'search_screen.dart';


class AnimeScreen extends StatefulWidget {
  final Anime anime;
  final User user;
  const AnimeScreen({super.key, required this.anime, required this.user});

  @override
  _AnimeScreenState createState() => _AnimeScreenState();
}

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
        MaterialPageRoute(builder: (context) => AnimeListScreen(user: widget.user)),
      );
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SearchScreen(user: widget.user)), // Replace with your SearchScreen
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AlertsScreen(user: widget.user)), // Replace with your AlertsScreen
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

    return Scaffold(
      appBar: AppBar(
        title: Text('Anime Information'),
      ),
      body: Container(
        padding: EdgeInsets.all(12.0),
        alignment: Alignment.center,
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(12.0),
            ),
            Image.network(widget.anime.imageURL),
            Text(widget.anime.title),
            Text(widget.anime.synopsis),
            Row(
              children: [
                Text('Set as Alert'),
                Checkbox(
                  checkColor: Colors.black,
                  fillColor: MaterialStateProperty.resolveWith(getColor),
                  value: widget.anime.alert,
                  onChanged: (bool? value) {
                    setState(() {
                      _animeAlert();
                    });
                  },
                )
              ],
            ),
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
    );
  }
}

class AnimeListScreen extends StatelessWidget {
  final User user;
  AnimeListScreen({required this.user});

  // Replace with your actual anime list data (fetch from API or database)
  final List<Anime> animeList = [
    Anime(animeId: 1, title: 'Sousou no Frieren', imageURL: 'URL_TO_SOUSOU_IMAGE', synopsis: '...', alert: false),
    Anime(animeId: 2, title: 'Fullmetal Alchemist: Brotherhood', imageURL: 'URL_TO_FMA_IMAGE', synopsis: '...', alert: false),
    Anime(animeId: 3, title: 'Hunter x Hunter (2011)', imageURL: 'URL_TO_HUNTER_IMAGE', synopsis: '...', alert: false),
    Anime(animeId: 4, title: 'Mob Psycho 100 II', imageURL: 'URL_TO_MOB_IMAGE', synopsis: '...', alert: false),
    Anime(animeId: 5, title: 'Cowboy Bebop', imageURL: 'URL_TO_COWBOY_IMAGE', synopsis: '...', alert: false),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Anime List'),
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
                MaterialPageRoute(builder: (context) => AnimeScreen(anime: anime, user: user)),
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
          // Handle navigation here (same logic as in AnimeScreen)
          if (index == 0) {
            // Stay on the AnimeListScreen
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SearchScreen(user: user)), // Replace with your SearchScreen
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AlertsScreen(user: user)), // Replace with your AlertsScreen
            );
          }
        },
      ),
    );
  }
}


class AlertsScreen extends StatelessWidget {
  final User user;
  AlertsScreen({required this.user});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Alerts')),
      body: Center(child: Text('Alerts Screen')),
    );
  }
}