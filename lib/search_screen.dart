import 'package:flutter/material.dart';
import 'package:anime_mobile/models.dart'; // Ensure this import exists and is correct
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'anime_screen.dart';
import 'background_container.dart'; // ✅ Ensure this file exists and works

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
      // Stay on the SearchScreen
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AnimeScreen(user: widget.user)),
      );
    }
  }

  Future<void> _performSearch(String query) async {
    final Uri url = Uri.parse('http://your_server_ip:your_server_port/api/searchAnime'); // Replace with your server URL and port

    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'searchParams': {
            'q': query, // You can add other search parameters here if needed
          },
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['error'].isEmpty) {
          final List<dynamic> data = responseData['data'];
          setState(() {
            _searchResults = data.map((item) => Anime.fromJson(item)).toList();
          });
          // You can also handle the pagination data if needed (responseData['pagination'])
        } else {
          // Handle the error from the server
          setState(() {
            _searchResults = [];
          });
          print('Search Error: ${responseData['error']}');
          // Optionally show an error message to the user
        }
      } else {
        // Handle HTTP errors
        setState(() {
          _searchResults = [];
        });
        print('HTTP Error: ${response.statusCode}');
        // Optionally show an error message to the user
      }
    } catch (e) {
      // Handle network or other exceptions
      setState(() {
        _searchResults = [];
      });
      print('Error during search: $e');
      // Optionally show an error message to the user
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundContainer( // Wrap the entire Scaffold with BackgroundContainer
      child: Scaffold(
        appBar: AppBar(
          title: Text('Search for your anime'),
          backgroundColor: Colors.transparent, // Make AppBar transparent
          elevation: 0, // Remove AppBar shadow
        ),
        body: Stack(
          children: [
            // You are already using Image.asset here for a background.
            // If BackgroundContainer provides the main background,
            // you might want to remove or adjust this Image.asset.
            // If you want a secondary background for just the search screen's content, keep it.
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      suffixIcon: Icon(Icons.search),
                    ),
                    onChanged: (text) {
                      setState(() {
                        _searchText = text;
                      });
                      _performSearch(text); // Call your API search function
                    },
                  ),
                ),
                Expanded(
                  child: _searchResults.isNotEmpty
                      ? ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final anime = _searchResults[index];
                      return ListTile(
                        leading: Image.network(anime.imageURL, width: 50, height: 75),
                        title: Text(anime.title),
                        onTap: () {
                          // You need to pass the correct anime object here
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AnimeScreen(user: widget.user)),
                          );
                        },
                      );
                    },
                  )
                      : Center(
                    child: Text(
                      _searchText.isNotEmpty ? 'No results found' : 'Search',
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                ),
              ],
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