import 'dart:convert';
import 'package:anime_mobile/anime_screen.dart';
import 'package:flutter/material.dart';
import 'package:anime_mobile/models.dart';
import 'package:http/http.dart' as http;
import 'search_screen.dart';
import 'alerts_screen.dart';
import 'background_container.dart';

class AnimeSummaryScreen extends StatefulWidget {
  final User user;
  final Anime? anime;
  const AnimeSummaryScreen({Key? key, this.anime, required this.user}) : super(key: key);

  @override
  _AnimeSummaryScreenState createState() => _AnimeSummaryScreenState();
}

class _AnimeSummaryScreenState extends State<AnimeSummaryScreen> {
  int _selectedIndex = 0;
  bool _isAlerted = false; // Track if the current anime is alerted
  List<int> _userAlertedAnimeIds = []; // Store user's alerted anime IDs

  @override
  void initState() {
    super.initState();
    _fetchUserAlerts();
    // Initialize _isAlerted based on whether the current anime is in the user's alerts
    if (widget.anime != null) {
      _isAlerted = _userAlertedAnimeIds.contains(widget.anime!.animeId);
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
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SearchScreen(user: widget.user)),
      );
    } else if (index == 2) {
      Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AlertsScreen(user: widget.user))
      );
    }
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
          'id': widget.user.id.toString(),
        }),
      );


      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data.containsKey('anime') && data['anime'] is List) {
          List<int> alertedIds = [];
          for (var animeData in data['anime']) {
            if (animeData.containsKey('alerts') && animeData['alerts'] is List) {
              if (animeData['alerts'].contains(widget.user.id.toString())) {
                alertedIds.add(animeData['animeId'] as int);
              }
            }
          }
          setState(() {
            _userAlertedAnimeIds = alertedIds;
          });
        }
      } else {
        print('Failed to fetch user alerts: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching user alerts: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundContainer(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Anime Information'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        backgroundColor: Colors.transparent,
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                if (widget.anime != null) ...[
                  Image.network(
                    widget.anime!.imageURL,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return SizedBox(
                        height: 200,
                        width: double.infinity,
                        child: Icon(Icons.image_not_supported),
                      );
                    },
                  ),
                  SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(
                      widget.anime!.title,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8), // Opaque white background for synopsis
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.anime!.synopsis,
                          style: TextStyle(color: Colors.black),
                          textAlign: TextAlign.start,
                        ),
                        SizedBox(height: 16),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Go back to the previous screen
                    },
                    child: Text('Back'),
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(
                      'No anime details available.',
                      style: TextStyle(color: Colors.black),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.movie_filter_outlined), // Use an outlined version for a simpler look
              label: 'Anime',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search_outlined), // Use an outlined search icon
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications_outlined), // Use an outlined notifications icon
              label: 'Alerts',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.blue, // Color for the active item
          unselectedItemColor: Colors.black54, // Color for inactive items (adjust as needed)
          showSelectedLabels: true, // Ensure labels are always shown for selected item
          showUnselectedLabels: true, // Ensure labels are always shown for unselected items
          type: BottomNavigationBarType.fixed, // To keep icons and labels visible
          backgroundColor: Colors.white.withOpacity(0.8), // Match the background style if needed
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}