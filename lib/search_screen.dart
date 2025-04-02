import 'package:flutter/material.dart';
import 'package:anime_mobile/models.dart'; // Assuming your Anime and User models are here
import 'package:http/http.dart' as http;
import 'anime_screen.dart'; // Import for API calls (replace with your package)

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
      if (_anime != null) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AnimeScreen(anime: _anime!, user: widget.user)),
        );
      } else {
        print("Error: _anime is null."); // Handle null case
      }
    } else if (index == 1) {
      // Stay on the SearchScreen
    } else if (index == 2) {
      if (_anime != null) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AnimeScreen(anime: _anime!, user: widget.user)),
        );
      } else {
        print("Error: _anime is null."); // Handle null case
      }
    }
  }

  // Placeholder for API call (replace with your actual API logic)
  Future<void> _performSearch(String query) async {
    // Example API call using http (replace with your API)
    // final response = await http.get(Uri.parse('your_api_url?q=$query'));
    // if (response.statusCode == 200) {
    //   // Parse the response and update the UI
    //   setState(() {
    //     // _searchResults = parsedResults;
    //   });
    // } else {
    //   // Handle error
    // }
    setState(() {
      _searchResults = [
        Anime(animeId: 1, title: 'Spirited Away', imageURL: 'https://cdn.myanimelist.net/images/anime/6/79597.jpg', synopsis: '...', alert: false),
        Anime(animeId: 2, title: 'Fullmetal Alchemist: Brotherhood', imageURL: 'https://cdn.myanimelist.net/images/anime/1208/94745.jpg', synopsis: '...', alert: false),
        Anime(animeId: 3, title: 'Hunter x Hunter (2011)', imageURL: 'https://cdn.myanimelist.net/images/anime/1337/99013.jpg', synopsis: '...', alert: false),
        Anime(animeId: 4, title: 'Mob Psycho 100 II', imageURL: 'https://cdn.myanimelist.net/images/anime/1918/96303.jpg', synopsis: '...', alert: false),
        Anime(animeId: 5, title: 'Cowboy Bebop', imageURL: 'https://cdn.myanimelist.net/images/anime/4/19644.jpg', synopsis: '...', alert: false),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Anime List page'),
      ),
      body: Stack(
        children: [
          // Background Image
          Image.asset(
            'assets/search_background.png', // Replace with your image path
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),

          // Search Bar and Results (using a Column)
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search...',
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

              // Search Results (will be populated from the API)
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
                        setState(() {
                          _anime = anime;
                        });
                        if (_anime != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => AnimeScreen(anime: _anime!, user: widget.user)),
                          );
                        }
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
    );
  }
}