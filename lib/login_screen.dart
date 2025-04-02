import 'package:flutter/material.dart';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'home_screen.dart';
import 'package:anime_mobile/models.dart';
import 'dart:convert';


class LoginCall extends StatefulWidget {
  @override
  _LoginCallState createState() => _LoginCallState();
}

class _LoginCallState extends State<LoginCall> {
  final String loginURL = 'http://194.195.211.99:5000/api/login';
  final TextEditingController loginControl = TextEditingController();
  final TextEditingController passwordControl = TextEditingController();
  String result = '';

  @override
  void dispose() {
    loginControl.dispose();
    passwordControl.dispose();
    super.dispose();
  }

  Future<void> _postData() async {
    try {
      final jsonData = jsonEncode(<String, dynamic>{
        'login': loginControl.text,
        'password': passwordControl.text,
      });

      print('Login Request Payload: $jsonData');

      final response = await http.post(
        Uri.parse(loginURL),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonData,
      );

      print('Login Response Status Code: ${response.statusCode}');
      print('Login Response Body: ${response.body}');

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        User loggedInUser = User(
          id:  BigInt.parse(responseData['id'], radix: 16),
          name: responseData['name'],
          emailAddress: loginControl.text,
          alerts: responseData['alerts'] ?? [],
        );

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomeCall(user: loggedInUser)),
        );
      } else {
        String errorMessage = 'Login failed.';
        if (responseData.containsKey('id')) {
          errorMessage = 'Login failed: ${responseData['id']}';
        }
        setState(() {
          result = errorMessage;
        });
      }
    } catch (e) {
      setState(() {
        result = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: loginControl,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordControl,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _postData();
              },
              child: Text('Submit'),
            ),
            Text(result),
          ],
        ),
      ),
    );
  }
}