import 'package:flutter/material.dart';
import 'package:itu_habitter/components/appbar.dart';
import 'package:itu_habitter/constants.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _name = "John Doe"; // Initial name
  String _email = "email@example.com"; // Initial email
  String _bio = "jedendvatri"; // Initial bio

  void _changeName(String newName) {
    setState(() {
      _name = newName;
    });
  }

  void _changeEmail(String newEmail) {
    setState(() {
      _email = newEmail;
    });
  }

  void _changeBio(String newBio) {
    setState(() {
      _bio = newBio;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: CustomAppBar(),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey, // Placeholder color
                        image: DecorationImage(
                          image: AssetImage('assets/profile.svg'),
                          fit: BoxFit.cover,
                        ),
                        borderRadius:
                            BorderRadius.circular(8.0), // Rounded corners
                      ),
                    ),
                    SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _name,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          _email,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          _bio,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Bio',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  onChanged: (newBio) {
                    _changeBio(newBio);
                  },
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                // Handle edit button press
              },
            ),
          ),
        ],
      ),
    );
  }
}
