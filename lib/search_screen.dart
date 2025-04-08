import 'package:anime_mobile/alerts_screen.dart';
import 'package:flutter/material.dart';
import 'package:anime_mobile/models.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'anime_screen.dart';
import 'background_container.dart';
import 'anime_summary_screen.dart';

class SearchScreen extends StatefulWidget {
  final User user;
  SearchScreen({required this.user});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  int _selectedIndex = 1;
  String _searchText = '';
  List<Anime> _searchResults = []; // List to store search results

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
      // Stay on the SearchScreen
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AlertsScreen(user: widget.user)),
      );
    }
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    final Uri url = Uri.parse('https://api.jikan.moe/v4/anime?q=$query');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData.containsKey('data') && responseData['data'] is List) {
          final List<dynamic> data = responseData['data'];
          setState(() {
            _searchResults = data
                .map((item) => Anime(
              animeId: item['mal_id'] as int? ?? 0,
              title: item['title'] as String? ?? 'No Title',
              imageURL: item['images']['jpg']['image_url'] as String? ?? '',
              synopsis: item['synopsis'] as String? ?? 'No Synopsis',
              alert: false,
            ))
                .toList();
          });
        } else {
          setState(() {
            _searchResults = [];
          });
          print('Invalid search response format');
          // Optionally show an error message to the user
        }
      } else {
        setState(() {
          _searchResults = [];
        });
        print('HTTP Error: ${response.statusCode}');
        // Optionally show an error message to the user
      }
    } catch (e) {
      setState(() {
        _searchResults = [];
      });
      print('Error during search: $e');
      // Optionally show an error message to the user
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundContainer(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Search for your anime'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  suffixIcon: Icon(Icons.search),
                  hintText: 'Enter anime title',
                ),
                onChanged: (text) {
                  setState(() {
                    _searchText = text;
                  });
                  _performSearch(text); // Call the API search function
                },
              ),
            ),
            Expanded(
              child: _searchResults.isNotEmpty
                  ? ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final anime = _searchResults[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: ListTile(
                      leading: Image.network(
                        anime.imageURL,
                        width: 50,
                        height: 75,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return SizedBox(
                            width: 50,
                            height: 75,
                            child: Icon(Icons.image_not_supported),
                          );
                        },
                      ),
                      title: Text(
                        anime.title,
                        style: TextStyle(color: Colors.black),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AnimeSummaryScreen(user: widget.user, anime: anime),
                          ),
                        );
                      },
                    ),
                  );
                },
              )
                  : Center(
                child: Text(
                  _searchText.isNotEmpty ? 'No results found' : 'Search for anime by title',
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
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