import 'package:flutter/material.dart';
import 'package:anime_mobile/models.dart';
import 'package:http/http.dart' as http;
import 'anime_screen.dart';
import 'search_screen.dart';



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
        MaterialPageRoute(builder: (context) => AnimeScreen(anime: _anime!, user: widget.user)),
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

  // Placeholder for API call (replace with your actual API logic)
  Future<List<Anime>> _fetchAlerts() async {
    // ... (Your API call logic) ...
    return []; // Placeholder
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Anime Alerts page'),
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
                            MaterialPageRoute(builder: (context) => AnimeScreen(anime: anime, user: widget.user)),
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
    );
  }
}