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

class _AnimeScreenState extends State<AnimeScreen> {
  List<Anime> animeList = []; // Initialize as an empty list
  String message = '';
  int _selectedIndex = 0; // For bottom navigation
  bool _loading = true; // Add a loading state

  @override
  void initState() {
    super.initState();
    _fetchTopAnime(); // Call the function to fetch data when the widget is created
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _fetchTopAnime() async {
    final url = Uri.parse('https://api.jikan.moe/v4/top/anime?&limit=25');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] != null && data['data'] is List) {
          setState(() {
            animeList = (data['data'] as List)
                .take(100) // Take only the top 100
                .map((item) => Anime(
              animeId: item['mal_id'] as int? ?? 0,
              title: item['title'] as String? ?? 'No Title',
              imageURL: item['images']['jpg']['image_url'] as String? ?? '',
              synopsis: item['synopsis'] as String? ?? 'No Synopsis',
              alert: false, // Default alert value
            ))
                .toList();
            _loading = false; // Data loaded
          });
        } else {
          setState(() {
            message = 'Failed to load anime data.';
            _loading = false;
          });
        }
      } else {
        setState(() {
          message = 'Failed to connect to the API. Status code: ${response.statusCode}';
          _loading = false;
        });
      }
    } catch (error) {
      setState(() {
        message = 'An error occurred: $error';
        _loading = false;
      });
    }
  }

  _animeAlert() async {
    // ... (Your _animeAlert logic remains the same) ...
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      // No need to push to AnimeScreen again if already there
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
    return BackgroundContainer(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Top 100 Anime'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: _loading
            ? Center(child: CircularProgressIndicator()) // Show loading indicator
            : animeList.isEmpty
            ? Center(child: Text(message.isNotEmpty ? message : 'No anime data available.'))
            : ListView.builder(
          itemCount: animeList.length,
          itemBuilder: (context, index) {
            final anime = animeList[index];
            return ListTile(
              leading: Image.network(
                anime.imageURL,
                width: 50,
                height: 75,
                errorBuilder: (context, error, stackTrace) {
                  return SizedBox(
                    width: 50,
                    height: 75,
                    child: Icon(Icons.image_not_supported),
                  );
                },
              ),
              title: Text(anime.title),
              trailing: Checkbox(
                value: anime.alert,
                onChanged: (bool? value) {
                  // Implement alert toggle logic here, likely involving updating the state
                  // of the specific anime in the list.
                  setState(() {
                    animeList[index].alert = value ?? false;
                  });
                  // You might want to call _animeAlert() here if it's meant to interact
                  // with an external service based on this change.
                },
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AnimeSummaryScreen(
                        user: widget.user, anime: anime), // Pass the anime object
                  ),
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
        backgroundColor: Colors.transparent,
      ),
    );
  }
}

class AnimeListScreen extends StatelessWidget {
  final User user;
  AnimeListScreen({required this.user});

  @override
  Widget build(BuildContext context) {
    return BackgroundContainer(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Anime List'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Center(
          child: Text('This screen is no longer the primary anime list display.'),
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
          currentIndex: 0,
          selectedItemColor: Colors.blue,
          onTap: (index) {
            if (index == 0) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => AnimeScreen(user: user)),
              );
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
        backgroundColor: Colors.transparent,
      ),
    );
  }
}