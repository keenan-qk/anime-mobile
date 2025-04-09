import 'package:flutter/material.dart';
import 'package:anime_mobile/models.dart';
import 'package:http/http.dart' as http;
import 'anime_screen.dart';
import 'search_screen.dart';
import 'dart:convert';
import 'background_container.dart';
import 'anime_summary_screen.dart'; // Import AnimeSummaryScreen

class AlertsScreen extends StatefulWidget {
  final User user;
  AlertsScreen({required this.user});

  @override
  _AlertsScreenState createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  int _selectedIndex = 2;

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
      // Stay on the AlertsScreen
    }
  }

  Future<List<Anime>> _fetchAlerts() async {
    final String getAlertsURL = 'http://194.195.211.99:5000/api/getAnimeAlerts';
    try {
      final response = await http.post(
        Uri.parse(getAlertsURL),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, dynamic>{
          'id': widget.user.id,
        }),
      );

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200 && responseData['anime'] != null) {
        return (responseData['anime'] as List)
            .map((item) => Anime(
          animeId: item['animeId'] as int? ?? 0,
          title: item['title'] as String? ?? 'No Title',
          synopsis: item['synopsis'] as String? ?? 'No Synopsis',
          imageURL: item['imageURL'] as String? ?? '',
          alert: true, // All items here are alerts initially
        ))
            .toList();
      } else {
        print('Failed to fetch alerts: ${response.statusCode}, body: ${response.body}');
        return []; // Return an empty list on failure
      }
    } catch (e) {
      print('Error fetching alerts: $e');
      return []; // Return an empty list on error
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
          setState(() {}); // Trigger a rebuild to reflect the removal
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

  Future<void> _showConfirmationDialog(Anime anime) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Removal'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to remove "${anime.title}" from your alerts?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Remove'),
              onPressed: () {
                _removeAlert(anime.animeId);
                Navigator.of(context).pop(); // Dismiss the dialog after removal
              },
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return BackgroundContainer(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Anime Alerts'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Column(
          children: [
            Expanded(
              child: FutureBuilder<List<Anime>>(
                future: _fetchAlerts(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    final alertList = snapshot.data!;
                    return ListView.builder(
                      itemCount: alertList.length,
                      itemBuilder: (context, index) {
                        final anime = alertList[index];
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
                                if (value != null && !value) {
                                  _showConfirmationDialog(anime); // Show confirmation dialog
                                  // Optimistically remove from the list immediately
                                  setState(() {
                                    if (_fetchAlerts() is List<Anime>) {
                                      (_fetchAlerts() as List<Anime>).removeWhere((a) => a.animeId == anime.animeId);
                                    }
                                  });
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
                    );
                  } else {
                    return Center(child: Text('No anime alerts found.'));
                  }
                },
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