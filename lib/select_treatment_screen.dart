import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'doctor_list_screen.dart'; // For shared preferences

class SelectTreatmentScreen extends StatefulWidget {
  @override
  _SelectTreatmentScreenState createState() => _SelectTreatmentScreenState();
}

class _SelectTreatmentScreenState extends State<SelectTreatmentScreen> {
  List<Map<String, dynamic>> specializations = [];
  List<Map<String, dynamic>> treatmentMethods = [];
  List<Map<String, dynamic>> bodyAreas = [];
  List<Map<String, dynamic>> associatedConditions = [];
  bool isLoading = true;
  String? bearerToken;

  @override
  void initState() {
    super.initState();
    fetchBearerToken();
  }

  // Fetch the Bearer token from SharedPreferences
  Future<void> fetchBearerToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('bearer_token'); // assuming you saved the token as 'bearer_token'

    if (token != null) {
      setState(() {
        bearerToken = token;
      });
      fetchTreatmentData();  // Proceed with API calls after token is fetched
    } else {
      print('No token found');
      setState(() {
        isLoading = false;  // Stop loading if no token is available
      });
    }
  }

  // Fetch all treatment-related data from the APIs
  Future<void> fetchTreatmentData() async {
    try {
      final specResponse = await http.get(
        Uri.parse('https://vitigo.learnknowdigital.com/api/doctors/specializations/'),
        headers: {'Authorization': 'Bearer $bearerToken'},
      );
      final treatResponse = await http.get(
        Uri.parse('https://vitigo.learnknowdigital.com/api/doctors/treatment-methods/'),
        headers: {'Authorization': 'Bearer $bearerToken'},
      );
      final bodyResponse = await http.get(
        Uri.parse('https://vitigo.learnknowdigital.com/api/doctors/body-areas/'),
        headers: {'Authorization': 'Bearer $bearerToken'},
      );
      final condResponse = await http.get(
        Uri.parse('https://vitigo.learnknowdigital.com/api/doctors/associated-conditions/'),
        headers: {'Authorization': 'Bearer $bearerToken'},
      );

      if (specResponse.statusCode == 200 &&
          treatResponse.statusCode == 200 &&
          bodyResponse.statusCode == 200 &&
          condResponse.statusCode == 200) {
        setState(() {
          specializations = List<Map<String, dynamic>>.from(json.decode(specResponse.body));
          treatmentMethods = List<Map<String, dynamic>>.from(json.decode(treatResponse.body));
          bodyAreas = List<Map<String, dynamic>>.from(json.decode(bodyResponse.body));
          associatedConditions = List<Map<String, dynamic>>.from(json.decode(condResponse.body));
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (error) {
      print('Error fetching data: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Treatment'),
        foregroundColor: Colors.white,
        backgroundColor: Colors.blueAccent,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildSection('Specializations', specializations, Icons.health_and_safety, (id) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DoctorListScreen(
                      apiUrl: 'https://vitigo.learnknowdigital.com/api/doctors/?specialization=$id',
                      bearerToken: bearerToken!,
                    ),
                  ),
                );
              }),
              buildSection('Treatment Methods', treatmentMethods, Icons.local_hospital, (id) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DoctorListScreen(
                      apiUrl: 'https://vitigo.learnknowdigital.com/api/doctors/?treatment-method=$id',
                      bearerToken: bearerToken!,
                    ),
                  ),
                );
              }),
              buildSection('Body Areas', bodyAreas, Icons.accessibility_new, (id) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DoctorListScreen(
                      apiUrl: 'https://vitigo.learnknowdigital.com/api/doctors/?body-area=$id',
                      bearerToken: bearerToken!,
                    ),
                  ),
                );
              }),
              buildSection('Associated Conditions', associatedConditions, Icons.healing, (id) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DoctorListScreen(
                      apiUrl: 'https://vitigo.learnknowdigital.com/api/doctors/?associated-condition=$id',
                      bearerToken: bearerToken!,
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSection(String title, List<Map<String, dynamic>> items, IconData icon, Function(int) onCardTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0),
          child: Row(
            children: [
              Icon(icon, color: Colors.blue),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 120,  // Adjust height for horizontal scrolling cards
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => onCardTap(items[index]['id']),
                child: Card(
                  margin: EdgeInsets.symmetric(horizontal: 8),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Container(
                    width: 150,
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blueAccent, Colors.blue],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Center(
                      child: Text(
                        items[index]['name'],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
