import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'select_slot_screen.dart';

class DoctorListScreen extends StatelessWidget {
  final String apiUrl;
  final String bearerToken;

  DoctorListScreen({required this.apiUrl, required this.bearerToken});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Doctors List'),
        foregroundColor: Colors.white,
        backgroundColor: Colors.blueAccent,
      ),
      body: FutureBuilder(
        future: fetchDoctors(apiUrl),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error fetching doctors'));
          } else {
            final doctors = snapshot.data as List<Doctor>;
            return ListView.builder(
              itemCount: doctors.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16),
                    leading: FutureBuilder<Map<String, String>>(
                      future: doctors[index].fetchQualificationAndProfilePicture(bearerToken),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.grey[200],
                            child: CircularProgressIndicator(color: Colors.blue),
                          );
                        } else if (snapshot.hasError || snapshot.data?['profilePicture'] == null) {
                          return CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.grey[200],
                            child: Icon(
                              Icons.person,
                              color: Colors.blue,
                              size: 30,
                            ),
                          );
                        } else {
                          return CircleAvatar(
                            radius: 25,
                            backgroundImage: NetworkImage(snapshot.data!['profilePicture']!),
                          );
                        }
                      },
                    ),
                    title: Text(
                      'Dr. ${doctors[index].firstName} ${doctors[index].lastName}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.blue[800],
                      ),
                    ),
                    subtitle: FutureBuilder<Map<String, String>>(
                      future: doctors[index].fetchQualificationAndProfilePicture(bearerToken),
                      builder: (context, qualSnapshot) {
                        if (qualSnapshot.connectionState == ConnectionState.waiting) {
                          return Text('Loading qualification...');
                        } else if (qualSnapshot.hasError) {
                          return Text('Qualification not available');
                        } else {
                          return Text(
                            qualSnapshot.data?['qualification'] ?? 'No qualification',
                            style: TextStyle(color: Colors.blue[600], fontSize: 14),
                          );
                        }
                      },
                    ),
                    trailing: Text(
                      '₹${doctors[index].consultationFee}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.blue[900],
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SelectSlotScreen(
                            doctorId: doctors[index].id,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  Future<List<Doctor>> fetchDoctors(String apiUrl) async {
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {'Authorization': 'Bearer $bearerToken'},
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      List<dynamic> results = data['results'];
      print('Doctor List Response: ${data}');
      return results.map((item) => Doctor.fromJson(item)).toList();
    } else {
      print('Failed to load doctors: ${response.body}');
      throw Exception('Failed to load doctors');
    }
  }
}

class Doctor {
  final String id;
  final String firstName;
  final String lastName;
  final String consultationFee;

  Doctor({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.consultationFee,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['user']['id'].toString(),
      firstName: json['user']['first_name'],
      lastName: json['user']['last_name'],
      consultationFee: json['consultation_fee'].toString(),
    );
  }

  Future<Map<String, String>> fetchQualificationAndProfilePicture(String bearerToken) async {
    final response = await http.get(
      Uri.parse('https://vitigo.learnknowdigital.com/api/doctors/$id'),
      headers: {'Authorization': 'Bearer $bearerToken'},
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      String? profilePicturePath = data['data']['user']['profile_picture'];

      // Construct the full URL for the profile picture
      String profilePictureUrl = profilePicturePath != null && profilePicturePath.isNotEmpty
          ? 'https://vitigo.learnknowdigital.com$profilePicturePath'
          : '';

      print('Profile Picture and Qualification Response: ${data}'); // Log the API response
      return {
        'qualification': data['data']['qualification'] ?? 'No qualification available',
        'profilePicture': profilePictureUrl
      };
    } else {
      print('Failed to load qualification or profile picture: ${response.body}');
      throw Exception('Failed to load qualification or profile picture');
    }
  }

}
