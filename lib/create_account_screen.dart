import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'background_container.dart'; // ✅ Import reusable background

class CreateAccountScreen extends StatefulWidget {
  @override
  _CreateAccountScreenState createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';

  Future<void> _registerUser() async {
    final String apiUrl = 'http://194.195.211.99:5000/api/register';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'name': _nameController.text,
          'login': _loginController.text,
          'emailAddress': _emailController.text,
          'password': _passwordController.text,
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration successful!')),
        );
        Navigator.pop(context);
      } else {
        final responseData = json.decode(response.body);
        setState(() {
          _errorMessage = responseData['message'] ?? 'Registration failed.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred during registration.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Account'),
        backgroundColor: Colors.black87,
      ),
      body: BackgroundContainer(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              _buildTextField(_nameController, 'Name'),
              _buildTextField(_loginController, 'Username'),
              _buildTextField(_emailController, 'Email Address'),
              _buildTextField(_passwordController, 'Password', obscure: true),
              SizedBox(height: 10),
              if (_errorMessage.isNotEmpty)
                Text(
                  _errorMessage,
                  style: TextStyle(color: Colors.red),
                ),
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
                onPressed: _registerUser,
                child: Text('Create Account'),
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
