import 'package:anime_mobile/anime_screen.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'anime_summary_screen.dart';
import 'package:anime_mobile/models.dart';
import 'dart:convert';
import 'background_container.dart'; // ✅ Add this line

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

      final response = await http.post(
        Uri.parse(loginURL),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonData,
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        User loggedInUser = User(
          id: BigInt.parse(responseData['id'], radix: 16),
          name: responseData['name'],
          emailAddress: loginControl.text,
          alerts: responseData['alerts'] ?? [],
        );

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AnimeScreen(user: loggedInUser)),
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
        backgroundColor: Colors.black87,
      ),
      body: BackgroundContainer(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              _buildTextField(loginControl, 'Email'),
              _buildTextField(passwordControl, 'Password', obscure: true),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _postData,
                child: Text('Submit'),
              ),
              SizedBox(height: 10),
              Text(
                result,
                style: TextStyle(color: Colors.redAccent),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool obscure = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white.withOpacity(0.9),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}
