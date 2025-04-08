import 'package:anime_mobile/alerts_screen.dart';
import 'package:flutter/material.dart';
import 'package:anime_mobile/models.dart'; // Ensure this import exists and is correct
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'anime_screen.dart';
import 'background_container.dart'; // ✅ Ensure this file exists and works
import 'anime_summary_screen.dart'; // Import AnimeSummaryScreen

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
  List<int> _userAlertedAnimeIds = []; // Store user's alerted anime IDs

  @override
  void initState() {
    super.initState();
    _fetchUserAlerts();
  }

  Future<void> _fetchUserAlerts() async {
    final url = Uri.parse('http://194.195.211.99:5000/api/getAnimeAlerts'); // Replace with your actual endpoint
    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'id': widget.user.id.toString(),
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data.containsKey('alerts') && data['alerts'] is List) {
          setState(() {
            _userAlertedAnimeIds = (data['alerts'] as List).cast<int>();
          });
        }
      } else {
        print('Failed to fetch user alerts: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching user alerts: $error');
    }
  }

  Future<void> _addAlert(int animeId) async {
    final url = Uri.parse('http://194.195.211.99:5000/api/addAlert'); // Replace with your actual endpoint
    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'id': widget.user.id.toString(),
          'animeId': animeId,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['error'] == null || data['error'].isEmpty) {
          setState(() {
            _userAlertedAnimeIds.add(animeId);
            // Update the local _searchResults if needed for immediate UI feedback
            _searchResults = _searchResults.map((anime) =>
            anime.animeId == animeId ? anime.copyWith(alert: true) : anime).toList();
          });
          print('Alert added for anime ID: $animeId');
        } else {
          print('Failed to add alert: ${data['error']}');
        }
      } else {
        print('HTTP error adding alert: ${response.statusCode}');
      }
    } catch (error) {
      print('Error adding alert: $error');
    }
  }

  Future<void> _removeAlert(int animeId) async {
    final url = Uri.parse('http://194.195.211.99:5000/api/removeAlert'); // Replace with your actual endpoint
    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'id': widget.user.id.toString(),
          'animeId': animeId,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['error'] == null || data['error'].isEmpty) {
          setState(() {
            _userAlertedAnimeIds.remove(animeId);
            // Update the local _searchResults if needed for immediate UI feedback
            _searchResults = _searchResults.map((anime) =>
            anime.animeId == animeId ? anime.copyWith(alert: false) : anime).toList();
          });
          print('Alert removed for anime ID: $animeId');
        } else {
          print('Failed to remove alert: ${data['error']}');
        }
      } else {
        print('HTTP error removing alert: ${response.statusCode}');
      }
    } catch (error) {
      print('Error removing alert: $error');
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
              alert: _userAlertedAnimeIds.contains(item['mal_id']), // Set initial alert state
            ))
                .toList();
          });
        } else {
          setState(() {
            _searchResults = [];
          });
          print('Invalid search response format');
        }
      } else {
        setState(() {
          _searchResults = [];
        });
        print('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _searchResults = [];
      });
      print('Error during search: $e');
    }
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
      // Stay on the SearchScreen
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
                      trailing: Checkbox(
                        value: anime.alert,
                        onChanged: (bool? value) {
                          if (value != null) {
                            setState(() {
                              _searchResults[index] = _searchResults[index].copyWith(alert: value);
                            });
                            if (value) {
                              _addAlert(anime.animeId);
                            } else {
                              _removeAlert(anime.animeId);
                            }
                          }
                        },
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