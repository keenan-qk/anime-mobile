import 'package:flutter/material.dart';

class HomeCall extends StatefulWidget {
  @override
  _HomeCallState createState() => _HomeCallState();
}

class _HomeCallState extends State<HomeCall> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Prevents back button from login screen
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Content Column
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Welcome to',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black, // Adjust text color as needed
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'AniLert',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.black, // Adjust text color as needed
                  ),
                ),
                const SizedBox(height: 40),

                // Continue Button
                ElevatedButton(
                  onPressed: () {
                    // Navigate to the next screen or home screen
                    Navigator.pushReplacementNamed(context, '/home'); // Replace '/home' with your route
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black, // Button color
                    foregroundColor: Colors.white, // Text color
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text('Continue'),
                ),

                const SizedBox(height: 20),

                // Log Out Button
                ElevatedButton(
                  onPressed: () {
                    // Navigate back to the login screen
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black, // Button color
                    foregroundColor: Colors.white, // Text color
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text('Log out'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}