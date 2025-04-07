import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:anime_mobile/models.dart';
import 'background_container.dart'; // ✅ Import background wrapper

class AnimeScreen extends StatefulWidget {
  final Anime anime;
  final User user;

  const AnimeScreen({super.key, required this.anime, required this.user});

  @override
  _AnimeScreenState createState() => _AnimeScreenState();
}

class _AnimeScreenState extends State<AnimeScreen> {
  String message = '';

  _animeAlert() async {
    final bool isAlertSet = widget.anime.alert;
    final String url = isAlertSet
        ? 'http://194.195.211.99:5000/api/removeAlert'
        : 'http://194.195.211.99:5000/api/addAlert';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': widget.user.id,
          'animeId': widget.anime.animeId,
        }),
      );

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          widget.anime.alert = !isAlertSet;
        });
      } else {
        throw Exception('${responseData['error']}');
      }
    } catch (e) {
      setState(() {
        message = 'Error $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Color getColor(Set<WidgetState> states) {
      const Set<WidgetState> interactiveStates = {
        WidgetState.pressed,
        WidgetState.hovered,
        WidgetState.focused,
      };
      if (states.any(interactiveStates.contains)) {
        return Colors.blue;
      }
      return Colors.white;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Anime Information'),
        backgroundColor: Colors.black87,
      ),
      body: BackgroundContainer(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.network(widget.anime.imageURL),
              SizedBox(height: 10),
              Text(
                widget.anime.title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 10),
              Text(
                widget.anime.synopsis,
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Set as Alert',
                    style: TextStyle(color: Colors.white),
                  ),
                  Checkbox(
                    checkColor: Colors.black,
                    fillColor: WidgetStateProperty.resolveWith(getColor),
                    value: widget.anime.alert,
                    onChanged: (bool? value) {
                      _animeAlert();
                    },
                  ),
                ],
              ),
              if (message.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    message,
                    style: TextStyle(color: Colors.redAccent),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
