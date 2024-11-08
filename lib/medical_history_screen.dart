import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MedicalHistoryScreen extends StatefulWidget {
  const MedicalHistoryScreen({Key? key}) : super(key: key);

  @override
  State<MedicalHistoryScreen> createState() => _MedicalHistoryScreenState();
}

class _MedicalHistoryScreenState extends State<MedicalHistoryScreen> {
  Map<String, dynamic>? medicalHistory;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMedicalHistory();
  }

  Future<void> fetchMedicalHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('bearer_token'); // Retrieve token

      final response = await http.get(
        Uri.parse('https://vitigo.learnknowdigital.com/api/patient-info'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          medicalHistory = data['medical_history'];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load medical history');
      }
    } catch (e) {
      print('Error fetching medical history: $e');
      setState(() {
        isLoading = false; // Stop loading on error
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical History'),
        foregroundColor: Colors.white, // AppBar text color set to white
        backgroundColor: Colors.blue, // AppBar background color set to blue
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Medical History',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue, // Blue color
                  ),
                ),
                const Divider(thickness: 1.5),
                _buildInfoRow(Icons.bug_report, 'Allergies', medicalHistory?['allergies']),
                _buildInfoRow(Icons.health_and_safety, 'Chronic Conditions', medicalHistory?['chronic_conditions']),
                _buildInfoRow(Icons.local_hospital, 'Past Surgeries', medicalHistory?['past_surgeries']),
                _buildInfoRow(Icons.family_restroom, 'Family History', medicalHistory?['family_history']),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blue, size: 24), // Icon color changed to blue
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  (value != null && value.isNotEmpty) ? value : 'Not Found', // Handle null and empty values
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
