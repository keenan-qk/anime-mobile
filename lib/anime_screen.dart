import 'package:anime_mobile/anime_summary_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:anime_mobile/models.dart';
import 'alerts_screen.dart';
import 'search_screen.dart';
import 'background_container.dart';

class AnimeScreen extends StatefulWidget {
  final User user;
  const AnimeScreen({super.key, required this.user});

  @override
  _AnimeScreenState createState() => _AnimeScreenState();
}

class _AnimeScreenState extends State<AnimeScreen> {
  List<Anime> animeList = [];
  String message = '';
  int _selectedIndex = 0;
  bool _loading = true;
  int _currentPage = 1;
  int _itemsPerPage = 25;
  List<int> _userAlertedAnimeIds = [];

  @override
  void initState() {
    super.initState();
    _fetchTopAnime();
    _fetchUserAlerts();
  }

  Future<void> _fetchUserAlerts() async {
    final url = Uri.parse('http://194.195.211.99:5000/api/getAnimeAlerts');
    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'id': widget.user.id.toString(), // Convert BigInt to String
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data.containsKey('alerts') && data['alerts'] is List) {
          setState(() {
            _userAlertedAnimeIds = (data['alerts'] as List).cast<int>();
            animeList = animeList.map((anime) {
              return anime.copyWith(alert: _userAlertedAnimeIds.contains(anime.animeId));
            }).toList();
          });
        } else {
          print('Failed to fetch user alerts: ${response.statusCode}');
        }
      } else {
        print('Error fetching user alerts: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching user alerts: $error');
    }
  }

  Future<void> _addAlert(int animeId) async {
    final url = Uri.parse('http://194.195.211.99:5000/api/addAlert');
    print('Adding alert for animeId: $animeId, userId: ${widget.user.id}');
    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'id': widget.user.id.toString(), // Convert BigInt to String
          'animeId': animeId,
        }),
      );
      print('Add alert response status: ${response.statusCode}');
      print('Add alert response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['error'] == null || data['error'].isEmpty) {
          setState(() {
            _userAlertedAnimeIds.add(animeId);
            animeList = animeList.map((anime) {
              return anime.animeId == animeId ? anime.copyWith(alert: true) : anime;
            }).toList();
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
    final url = Uri.parse('http://194.195.211.99:5000/api/removeAlert');
    print('Removing alert for animeId: $animeId, userId: ${widget.user.id}');
    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'id': widget.user.id.toString(), // Convert BigInt to String
          'animeId': animeId,
        }),
      );
      print('Remove alert response status: ${response.statusCode}');
      print('Remove alert response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['error'] == null || data['error'].isEmpty) {
          setState(() {
            _userAlertedAnimeIds.remove(animeId);
            animeList = animeList.map((anime) {
              return anime.animeId == animeId ? anime.copyWith(alert: false) : anime;
            }).toList();
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

  Future<void> _fetchTopAnime() async {
    setState(() {
      _loading = true;
      message = '';
    });
    final url = Uri.parse(
        'https://api.jikan.moe/v4/top/anime?page=$_currentPage&limit=$_itemsPerPage');
    print('Fetching top anime - URL: $url');
    try {
      final response = await http.get(url);
      print('Fetch top anime response status: ${response.statusCode}');
      print('Fetch top anime response body: ${response.body}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] != null && data['data'] is List) {
          setState(() {
            animeList = (data['data'] as List)
                .map((item) => Anime(
              animeId: item['mal_id'] as int? ?? 0,
              title: item['title'] as String? ?? 'No Title',
              imageURL: item['images']['jpg']['image_url'] as String? ?? '',
              synopsis: item['synopsis'] as String? ?? 'No Synopsis',
              alert: _userAlertedAnimeIds.contains(item['mal_id']),
            ))
                .toList();
            _loading = false;
          });
        } else {
          setState(() {
            message = 'Failed to load anime data.';
            _loading = false;
          });
        }
      } else {
        setState(() {
          message =
          'Failed to connect to the API. Status code: ${response.statusCode}';
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

  void _onPageChanged(int page) {
    if (page > 0 && page != _currentPage) {
      setState(() {
        _currentPage = page;
      });
      _fetchTopAnime();
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
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
          title: Text('Top Anime'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: _loading
            ? Center(child: CircularProgressIndicator())
            : animeList.isEmpty
            ? Center(child: Text(message.isNotEmpty ? message : 'No anime data available.'))
            : Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: animeList.length,
                itemBuilder: (context, index) {
                  final anime = animeList[index];
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
                              animeList[index] = animeList[index].copyWith(alert: value);
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
                            builder: (context) => AnimeSummaryScreen(
                                user: widget.user, anime: anime),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: _currentPage > 1
                        ? () => _onPageChanged(_currentPage - 1)
                        : null,
                    child: Text('Previous'),
                  ),
                  Text('Page $_currentPage'),
                  ElevatedButton(
                    onPressed: () => _onPageChanged(_currentPage + 1),
                    child: Text('Next'),
                  ),
                ],
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