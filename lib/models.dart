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
    this.alert = false, // may have to change this part later?
  });

  Anime copyWith({
    int? animeId,
    String? title,
    String? synopsis,
    String? imageURL,
    bool? alert,
  }) {
    return Anime(
      animeId: animeId ?? this.animeId,
      title: title ?? this.title,
      synopsis: synopsis ?? this.synopsis,
      imageURL: imageURL ?? this.imageURL,
      alert: alert ?? this.alert,
    );
  }

  factory Anime.fromJson(Map<String, dynamic> json) {
    return Anime(
      animeId: json['animeId'] as int,
      title: json['title'] as String,
      imageURL: json['imageURL'] as String,
      synopsis: json['synopsis'] as String? ?? '', // Handle potential null synopsis
    );
  }
}
class User {
  String id;
  String name;
  String emailAddress;
  List<Anime>? alerts;

  User({required this.id, required this.name, required this.emailAddress, required this.alerts});
}