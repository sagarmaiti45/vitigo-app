import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vitogo_1/update_patient_profile_screen.dart';
import 'patient_form_screen.dart'; // Import your PatientForm

class PatientDetailsScreen extends StatefulWidget {
  const PatientDetailsScreen({Key? key}) : super(key: key);

  @override
  State<PatientDetailsScreen> createState() => _PatientDetailsScreenState();
}

class _PatientDetailsScreenState extends State<PatientDetailsScreen> {
  Map<String, dynamic>? patientData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPatientDetails();
  }

  Future<void> fetchPatientDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('bearer_token');
      final response = await http.get(
        Uri.parse('https://vitigo.learnknowdigital.com/api/patient-info'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          patientData = data['patient'];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false; // Stop loading if patient not found
        });
      }
    } catch (e) {
      print('Error fetching patient details: $e');
      setState(() {
        isLoading = false; // Stop loading on error
      });
    }
  }

  void refreshData() {
    fetchPatientDetails(); // Refresh the patient details
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (patientData == null) {
      // If patient data is null, show the form
      return Scaffold(
        appBar: AppBar(
          title: const Text('Patient Details'),
          foregroundColor: Colors.white,
          backgroundColor: Colors.blue,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: PatientForm(onSuccess: refreshData), // Pass the refresh function
        ),
      );
    }

    // If patient data is available, display the details
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Details'),
        foregroundColor: Colors.white,
        backgroundColor: Colors.blue,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Patient Information',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => UpdatePatientProfileScreen()),
                        );
                      },
                    ),
                  ],
                ),
                const Divider(thickness: 1.5),
                ..._buildPatientInfo(),
              ],
            ),
          ),
        ),
      ),
    );
  }


  List<Widget> _buildPatientInfo() {
    final List<IconData> icons = [
      Icons.cake,
      Icons.female,
      Icons.bloodtype,
      Icons.home,
      Icons.phone,
      Icons.person_outline,
      Icons.phone_forwarded,
      Icons.calendar_today,
      Icons.info_outline,
      Icons.area_chart,
    ];

    final fields = [
      'date_of_birth',
      'gender',
      'blood_group',
      'address',
      'phone_number',
      'emergency_contact_name',
      'emergency_contact_number',
      'vitiligo_onset_date',
      'vitiligo_type',
      'affected_body_areas',
    ];

    return List.generate(fields.length, (index) {
      String key = fields[index];
      String value = patientData![key]?.toString() ?? 'N/A';

      if (key.contains('date')) {
        value = formatDate(value);
      }

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icons[index], color: Colors.blue, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    capitalize(key.replaceAll('_', ' ')),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  String formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMMM dd, yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  String capitalize(String text) {
    return text
        .split(' ')
        .map((word) => word.isNotEmpty
        ? word[0].toUpperCase() + word.substring(1)
        : '')
        .join(' ');
  }
}
