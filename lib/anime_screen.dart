import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AnimeInfo {
  String title;
  String imageURL;
  String synopsis;

  AnimeInfo({required this.title, required this.imageURL, required this.synopsis});
}

class AnimeScreen extends StatelessWidget {
  final int animeId;

  AnimeScreen({super.key, required this.animeId});

  final String infoURL = 'http://194.195.211.99:5000/api/getAnimeInfo';
  String title = '';
  String imageURL = '';
  String synopsis = '';

  _AnimeInfo() async {
    try {
      final response = await http.post(
      Uri.parse(infoURL),
        headers: <String, String>{
          'Content-Type': 'application/json',
      } ,
        body: jsonEncode(<String, dynamic>{
          'animeId': animeId,
        }),
      );

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200) {
          title = responseData['data']['title'];
          imageURL = responseData['data']['images']['jpg']['image_url'];
          synopsis = responseData['data']['synopsis'];
      } else {
        throw Exception('${responseData['error']}');
      }   
    } catch (e) {
      return AnimeInfo(title: '', imageURL: '', synopsis: '');
    }
  }

  @override
  Widget build(BuildContext context) {
    _AnimeInfo();
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
            Image.network(imageURL),
            Text(title),
            Text(synopsis),   
          ]
        )
      )
    );
  }
}

