import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:anime_mobile/models.dart';

class AnimeScreen extends StatefulWidget {
  final Anime anime;
  final User user;
  const AnimeScreen({super.key, required this.anime, required this.user});

  @override
  _AnimeScreenState createState() => _AnimeScreenState();
}

class _AnimeScreenState extends State<AnimeScreen> {
  String message = '';
  @override
  void dispose() {
    super.dispose();
  }

  _animeAlert() async {
    if(widget.anime.alert) {
      final String removeAlertURL = 'http://194.195.211.99:5000/api/removeAlert';
      try {
        final response = await http.post(
          Uri.parse(removeAlertURL),
          headers: <String, String>{
            'Content-Type': 'application/json',
          },
          body: jsonEncode(<String, dynamic>{
            'id': widget.user.id,
            'animeId': widget.anime.animeId,
          }),
        );

        final responseData = jsonDecode(response.body);
        if (response.statusCode == 200) {
          setState(() {
            widget.anime.alert = false;
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
    else {
      final String addAlertURL = 'http://194.195.211.99:5000/api/addAlert';
      try {
        final response = await http.post(
          Uri.parse(addAlertURL),
          headers: <String, String>{
            'Content-Type': 'application/json',
          },
          body: jsonEncode(<String, dynamic>{
            'id': widget.user.id,
            'animeId': widget.anime.animeId,
          }),
        );

        final responseData = jsonDecode(response.body);
        if (response.statusCode == 200) {
          setState(() {
            widget.anime.alert = true;
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
  }
  

  @override
  Widget build(BuildContext context) {
    Color getColor(Set<WidgetState> states) {
      const Set<WidgetState> interactiveStates = <WidgetState>{
        WidgetState.pressed,
        WidgetState.hovered,
        WidgetState.focused,
      };
      if(states.any(interactiveStates.contains)) {
        return Colors.blue;
      }
      return Colors.white;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Anime Information'),
      ),
      body: Container(
        padding: EdgeInsets.all(12.0),
        alignment: Alignment.center,
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(12.0),
            ),
            Image.network(widget.anime.imageURL),
            Text(widget.anime.title),
            Text(widget.anime.synopsis),
            Row(
              children: [
                Text('Set as Alert'),
                Checkbox(
                  checkColor: Colors.black,
                  fillColor: WidgetStateProperty.resolveWith(getColor),
                  value: widget.anime.alert, 
                  onChanged: (bool? value) {
                    setState(() {
                      _animeAlert();
                    });
                  }             
                )
              ],
            ),
          ]
        )
      )
    );
  }
}

