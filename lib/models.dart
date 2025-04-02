// lib/models.dart
import 'dart:math';
class Anime {
  int animeId;
  String title;
  String synopsis;
  String imageURL;
  bool alert;

  Anime({
    required this.animeId,
    required this.title,
    required this.synopsis,
    required this.imageURL,
    required this.alert,
  });
}

class User {
  BigInt id;
  String name;
  String emailAddress;
  var alerts;

  User({required this.id, required this.name, required this.emailAddress, required this.alerts});
}