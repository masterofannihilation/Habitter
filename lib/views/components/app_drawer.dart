import 'package:flutter/material.dart';
import 'package:habitter_itu/constants.dart';
import 'package:habitter_itu/views/profile_page.dart';
import 'package:habitter_itu/views/journal_page.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: backgroundColor, // Set the background color to match the app
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            // add some padding to the top of the drawer
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Habitter',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            ListTile(
              leading: Icon(Icons.person,
                  color: Colors.white), // Set icon color to white
              title: Text(
                'Profile',
                style:
                    TextStyle(color: Colors.white), // Set text color to white
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.book,
                  color: Colors.white), // Set icon color to white
              title: Text(
                'Journal',
                style:
                    TextStyle(color: Colors.white), // Set text color to white
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => JournalPage()),
                );
              },
            ),
            // Add more ListTile widgets here for other menu items
          ],
        ),
      ),
    );
  }
}
