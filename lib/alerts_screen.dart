import 'package:flutter/material.dart';
import 'package:anime_mobile/models.dart';
import 'package:http/http.dart' as http;
import 'anime_screen.dart';
import 'search_screen.dart';
import 'dart:convert';
import 'background_container.dart';

class AlertsScreen extends StatefulWidget {
  final User user;
  AlertsScreen({required this.user});

  @override
  _AlertsScreenState createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  int _selectedIndex = 2;
  Anime? _anime; // Nullable Anime object

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
    List<Anime> responseArray = [];
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
      if (response.statusCode == 200) {
        for (int i = 0; i < responseData['anime'].length; i += 1) {
          responseArray.add(
            Anime(
              animeId: responseData['anime'][i]['animeId'],
              title: responseData['anime'][i]['title'],
              synopsis: responseData['anime'][i]['synopsis'],
              imageURL: responseData['anime'][i]['imageURL'],
              alert: true,
            ),
          );
        }
      } else {
        print('Failed to fetch alerts: ${response.statusCode}');
        // Consider showing an error message to the user
      }
    } catch (e) {
      print('Error fetching alerts: $e');
      // Consider showing an error message to the user
    }
    return responseArray;
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundContainer( // Wrap the entire Scaffold with BackgroundContainer
      child: Scaffold(
        appBar: AppBar(
          title: Text('Anime Alerts page'),
          backgroundColor: Colors.transparent, // Make AppBar transparent
          elevation: 0, // Remove AppBar shadow
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
                        return ListTile(
                          leading: Image.network(anime.imageURL, width: 50, height: 75),
                          title: Text(anime.title),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AnimeScreen(user: widget.user)),
                            );
                          },
                        );
                      },
                    );
                  } else {
                    return Center(child: Text('No alerts found.'));
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
        backgroundColor: Colors.transparent, // Make Scaffold background transparent
      ),
    );
  }
}