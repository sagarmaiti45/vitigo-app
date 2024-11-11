import 'package:flutter/material.dart';

class MenuScreen extends StatefulWidget {
  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Light background color for modern look
      appBar: AppBar(
        title: Text('Menu'),
        foregroundColor: Colors.white,
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUserSection(),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              children: <Widget>[
                _buildMenuItem(Icons.home, 'Home', Colors.blueAccent, () {
                  // Navigate to Home
                }),
                _buildMenuItem(Icons.person, 'Profile', Colors.deepPurple, () {
                  // Navigate to Profile
                }),
                _buildMenuItem(Icons.settings, 'Settings', Colors.teal, () {
                  // Navigate to Settings
                }),
                _buildMenuItem(Icons.logout, 'Logout', Colors.redAccent, () {
                  // Perform logout
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserSection() {
    return Container(
      color: Colors.blueAccent,
      padding: EdgeInsets.symmetric(vertical: 30, horizontal: 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, size: 30, color: Colors.blueAccent),
          ),
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, User!',
                style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
              ),
              Text(
                'user@example.com',
                style: TextStyle(fontSize: 14, color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, Color color, VoidCallback onTap) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 18),
        onTap: onTap,
      ),
    );
  }
}
