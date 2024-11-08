import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image/image.dart' as img;

class UserInfoUpdateScreen extends StatefulWidget {
  final Function onUpdate;

  UserInfoUpdateScreen({required this.onUpdate});

  @override
  _UserInfoUpdateScreenState createState() => _UserInfoUpdateScreenState();
}

class _UserInfoUpdateScreenState extends State<UserInfoUpdateScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String errorMessage = '';
  bool _isLoading = false;
  File? _profileImage;
  String? profileImageUrl;

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  Future<void> _fetchUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('bearer_token');

    if (token == null) return;

    final response = await http.get(
      Uri.parse('https://vitigo.learnknowdigital.com/api/user-info/'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final userInfo = jsonDecode(response.body);
      _firstNameController.text = userInfo['user']['first_name'] ?? '';
      _lastNameController.text = userInfo['user']['last_name'] ?? '';
      _emailController.text = userInfo['user']['email'] ?? '';
      profileImageUrl = userInfo['user']['profile_picture'];
    } else {
      print('Failed to fetch user info: ${response.body}');
    }
    setState(() {});
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      // Load the image as a file
      File originalImage = File(pickedFile.path);

      // Read the image file
      final originalBytes = await originalImage.readAsBytes();

      // Decode the image
      img.Image? image = img.decodeImage(originalBytes);

      if (image != null) {
        // Resize the image if necessary (e.g., to a maximum width/height)
        int maxWidth = 800; // Set your max width
        int maxHeight = 800; // Set your max height

        if (image.width > maxWidth || image.height > maxHeight) {
          image = img.copyResize(image, width: maxWidth, height: maxHeight);
        }

        // Compress the image
        List<int> compressedBytes = img.encodeJpg(image, quality: 30); // Lower quality if needed

        // Write the compressed image back to a file
        final compressedImage = File('${originalImage.parent.path}/compressed_${originalImage.uri.pathSegments.last}');
        await compressedImage.writeAsBytes(compressedBytes);

        setState(() {
          _profileImage = compressedImage; // Update the state with the compressed image
        });
      }
    }
  }


  Future<void> _updateProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('bearer_token');

    if (token == null) {
      setState(() {
        errorMessage = 'Authorization token not found. Please login again.';
      });
      return;
    }

    final request = http.MultipartRequest(
      'PUT',
      Uri.parse('https://vitigo.learnknowdigital.com/api/basic-user-info/update/'),
    );
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Content-Type'] = 'multipart/form-data';

    if (_firstNameController.text.isNotEmpty) {
      request.fields['first_name'] = _firstNameController.text;
    }
    if (_lastNameController.text.isNotEmpty) {
      request.fields['last_name'] = _lastNameController.text;
    }
    if (_emailController.text.isNotEmpty) {
      request.fields['email'] = _emailController.text;
    }
    if (_passwordController.text.isNotEmpty) {
      request.fields['password'] = _passwordController.text;
    }
    if (_profileImage != null) {
      request.files.add(await http.MultipartFile.fromPath('profile_picture', _profileImage!.path));
    }

    // Print the request data for debugging
    print('Request Headers: ${request.headers}');
    print('Request Fields: ${request.fields}');
    if (_profileImage != null) {
      print('Request includes profile picture file: ${_profileImage!.path}');
    }

    setState(() {
      _isLoading = true;
    });

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    setState(() {
      _isLoading = false;
    });

    // Print the response status and body for debugging
    print('Profile Update Response status: ${response.statusCode}');
    print('Profile Update Response body: $responseBody');

    if (response.statusCode == 200) {
      final responseData = jsonDecode(responseBody);
      widget.onUpdate();
      _showSnackbar(responseData['message'] ?? 'Profile updated successfully!', Colors.green);
      Navigator.pop(context);
    } else {
      _showSnackbar('Failed to update the profile. Please try again.', Colors.red);
    }
  }

  void _showSnackbar(String message, Color color) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: color,
      duration: Duration(seconds: 3),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(errorMessage, style: TextStyle(color: Colors.red)),
                ),
              _buildProfilePictureSection(),
              _buildTextField(_firstNameController, 'First Name', Icons.person),
              _buildTextField(_lastNameController, 'Last Name', Icons.person_outline),
              _buildTextField(_emailController, 'Email', Icons.email),
              _buildTextField(_passwordController, 'New Password', Icons.lock, obscureText: true),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateProfile,
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('Update', style: TextStyle(fontSize: 16, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              _buildGuidelinesSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePictureSection() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: _profileImage != null
                  ? FileImage(_profileImage!)
                  : (profileImageUrl != null ? NetworkImage(profileImageUrl!) : null),
              child: _profileImage == null && profileImageUrl == null
                  ? Icon(Icons.person, size: 50, color: Colors.grey)
                  : null,
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.camera_alt, color: Colors.white, size: 18),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blue),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.blueAccent),
          ),
        ),
        obscureText: obscureText,
      ),
    );
  }

  Widget _buildGuidelinesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Profile Update Guidelines:',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent,
          ),
        ),
        SizedBox(height: 10),
        _buildBulletPoint('Make sure to enter your correct first and last name.'),
        _buildBulletPoint('Use a valid email address to ensure you receive notifications.'),
        _buildBulletPoint('You can update your password if needed.'),
        _buildBulletPoint('All fields are optional; however, it\'s recommended to provide as much information as possible.'),
      ],
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(Icons.circle, size: 8, color: Colors.blueAccent),
          SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
