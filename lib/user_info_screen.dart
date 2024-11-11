import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vitogo_1/patient_info_screen.dart';
import 'user_info_update_screen.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class UserInfoScreen extends StatefulWidget {
  @override
  _UserInfoScreenState createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  String firstName = '';
  String lastName = '';
  String email = '';
  String role = '';
  String tierName = '';
  String startDate = '';
  String endDate = '';
  String errorMessage = '';
  bool isLoading = true;

  // Patient data
  String dob = '';
  String bloodGroup = '';
  String address = '';
  String phoneNumber = '';
  String emergencyContactName = '';
  String emergencyContactNumber = '';
  String vitiligoOnsetDate = '';
  String vitiligoType = '';
  String affectedBodyAreas = '';

  // Profile picture URL
  String? profilePictureUrl;

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  Future<void> _fetchUserInfo() async {
    setState(() {
      isLoading = true; // Show loading indicator
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('bearer_token');

    if (token == null) {
      setState(() {
        errorMessage = 'Authorization token not found. Please login again.';
        isLoading = false;
      });
      return;
    }

    final response = await http.get(
      Uri.parse('https://vitigo.learnknowdigital.com/api/user-info/'),
      headers: {'Authorization': 'Bearer $token'},
    );

    print("Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");

    if (response.statusCode == 200) {
      final userInfo = jsonDecode(response.body);

      setState(() {
        final user = userInfo['user'];
        final subscription = userInfo['subscription'];
        final patient = userInfo['patient'];

        firstName = user?['first_name'] ?? '';
        lastName = user?['last_name'] ?? '';
        email = user?['email'] ?? '';
        role = user?['role'] ?? '';

        String? profilePicturePath = user?['profile_picture'];
        profilePictureUrl = (profilePicturePath != null && profilePicturePath.isNotEmpty)
            ? '$profilePicturePath'
            : null;

        tierName = subscription?['tier_name'] ?? '';
        startDate = subscription?['start_date'] != null ? _formatDate(subscription['start_date']) : '';
        endDate = subscription?['end_date'] != null ? _formatDate(subscription['end_date']) : '';

        dob = patient?['date_of_birth'] != null ? _formatDate(patient['date_of_birth']) : '';
        bloodGroup = patient?['blood_group'] ?? '';
        address = patient?['address'] ?? '';
        phoneNumber = patient?['phone_number'] ?? '';
        emergencyContactName = patient?['emergency_contact_name'] ?? '';
        emergencyContactNumber = patient?['emergency_contact_number'] ?? '';
        vitiligoOnsetDate = patient?['vitiligo_onset_date'] != null ? _formatDate(patient['vitiligo_onset_date']) : '';
        vitiligoType = patient?['vitiligo_type'] ?? '';
        affectedBodyAreas = patient?['affected_body_areas'] ?? '';

        isLoading = false;
      });
    } else {
      setState(() {
        errorMessage = 'Failed to load user info. Please try again.';
        isLoading = false;
      });
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'Not available';
    DateTime dateTime = DateTime.parse(dateString);
    return DateFormat('dd MMM yyyy').format(dateTime);
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('bearer_token'); // Remove bearer token

    Navigator.of(context).pushReplacementNamed('/login'); // Redirect to login screen
  }

  Future<void> _showLogoutDialog() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              _logout(); // Perform logout
            },
            child: Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Info'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchUserInfo, // Triggers _fetchUserInfo on pull down
        color: Colors.blue,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          physics: const AlwaysScrollableScrollPhysics(), // Allows pull to refresh even if content is not scrollable
          child: errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage, style: TextStyle(color: Colors.red)))
              : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeSection(),
              SizedBox(height: 20),
              _buildUserInfoCard(
                'Personal Information',
                [
                  _buildInfoRow(Icons.person, 'First Name:', firstName),
                  _buildInfoRow(Icons.person_outline, 'Last Name:', lastName),
                  _buildInfoRow(Icons.email, 'Email:', email),
                  _buildInfoRow(Icons.assignment_ind, 'Role:', role),
                ],
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserInfoUpdateScreen(
                          onUpdate: _fetchUserInfo,
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 20),
              _buildUserInfoCard(
                'Patient Information',
                [
                  _buildInfoRow(Icons.cake, 'Date of Birth:', dob),
                  _buildInfoRow(Icons.bloodtype, 'Blood Group:', bloodGroup),
                  _buildInfoRow(Icons.location_on, 'Address:', address),
                  _buildInfoRow(Icons.phone, 'Phone Number:', phoneNumber),
                  _buildInfoRow(Icons.contact_phone, 'Emergency Contact:', '$emergencyContactName ($emergencyContactNumber)'),
                  _buildInfoRow(Icons.access_time, 'Vitiligo Onset Date:', vitiligoOnsetDate),
                  _buildInfoRow(Icons.medical_services, 'Vitiligo Type:', vitiligoType),
                  _buildInfoRow(Icons.map, 'Affected Areas:', affectedBodyAreas),
                ],
                IconButton(
                  icon: Icon(Icons.arrow_forward, color: Colors.blue),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PatientInfoScreen(),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 20),
              _buildUserInfoCard(
                'Subscription Info',
                [
                  _buildInfoRow(Icons.star, 'Tier Name:', tierName),
                  _buildInfoRow(Icons.calendar_today, 'Start Date:', startDate),
                  _buildInfoRow(Icons.calendar_today_outlined, 'End Date:', endDate),
                ],
              ),
              SizedBox(height: 40),
              Center(
                child: ElevatedButton.icon(
                  icon: Icon(Icons.logout),
                  label: Text('Logout'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Colors.redAccent,
                  ),
                  onPressed: _showLogoutDialog,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blueAccent, Colors.lightBlueAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: profilePictureUrl != null
                ? NetworkImage(profilePictureUrl!)
                : AssetImage('assets/default_profile_icon.png') as ImageProvider,
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$firstName $lastName',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  email,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfoCard(String title, List<Widget> children, [Widget? trailing]) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                if (trailing != null) trailing,
              ],
            ),
            Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.blue),
              SizedBox(width: 10),
              Text('$label ', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          isLoading
              ? Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: 100,
              height: 15,
              color: Colors.grey[300],
            ),
          )
              : Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(value),
            ),
          ),
        ],
      ),
    );
  }
}
