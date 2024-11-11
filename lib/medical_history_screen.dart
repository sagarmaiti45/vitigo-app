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
  bool hasError = false;

  // Controllers for the medical history form inputs
  final TextEditingController allergiesController = TextEditingController();
  final TextEditingController chronicConditionsController = TextEditingController();
  final TextEditingController pastSurgeriesController = TextEditingController();
  final TextEditingController familyHistoryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchMedicalHistory();
  }

  // Fetch medical history from the API
  Future<void> fetchMedicalHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('bearer_token');
      final userId = prefs.getInt('user_id');

      if (token == null || userId == null) {
        throw Exception('Token or User ID not found');
      }

      final response = await http.get(
        Uri.parse('https://vitigo.learnknowdigital.com/api/patient-info'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          medicalHistory = data['medical_history'];
          isLoading = false;
          hasError = false;
        });
      } else {
        print('Error: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to load medical history');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
      print('Error fetching medical history: $e');
      showSnackbar('Error fetching medical history', Colors.red);
    }
  }

  // Function to submit medical history (POST request)
  Future<void> submitMedicalHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('bearer_token');
      final userId = prefs.getInt('user_id');

      if (token == null || userId == null) {
        throw Exception('Token or User ID not found');
      }

      final response = await http.post(
        Uri.parse('https://vitigo.learnknowdigital.com/api/patient/${userId.toString()}/medical-history/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          'allergies': allergiesController.text,
          'chronic_conditions': chronicConditionsController.text,
          'past_surgeries': pastSurgeriesController.text,
          'family_history': familyHistoryController.text,
        }),
      );

      if (response.statusCode == 201) {
        showSnackbar('Medical history created successfully', Colors.green);
        fetchMedicalHistory(); // Refresh medical history
      } else {
        throw Exception('Failed to create medical history');
      }
    } catch (e) {
      showSnackbar('Error creating medical history', Colors.red);
    }
  }

  // Function to update medical history (PUT request)
  Future<void> updateMedicalHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('bearer_token');
      final userId = prefs.getInt('user_id');

      if (token == null || userId == null) {
        throw Exception('Token or User ID not found');
      }

      final response = await http.put(
        Uri.parse('https://vitigo.learnknowdigital.com/api/patient/${userId.toString()}/medical-history/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          'allergies': allergiesController.text,
          'chronic_conditions': chronicConditionsController.text,
          'past_surgeries': pastSurgeriesController.text,
          'family_history': familyHistoryController.text,
        }),
      );

      if (response.statusCode == 200) {
        showSnackbar('Medical history updated successfully', Colors.green);
        fetchMedicalHistory(); // Refresh medical history
      } else {
        throw Exception('Failed to update medical history');
      }
    } catch (e) {
      showSnackbar('Error updating medical history', Colors.red);
    }
  }

  // Show a colored Snackbar message
  void showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  // Build medical history form UI or the fetched medical history UI
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (hasError || medicalHistory == null) {
      // Show the form to create medical history
      return Scaffold(
        appBar: AppBar(
          title: const Text('Create Medical History'),
          foregroundColor: Colors.white,
          backgroundColor: Colors.blue,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Please fill in your medical history:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildTextField('Allergies', allergiesController),
              _buildTextField('Chronic Conditions', chronicConditionsController),
              _buildTextField('Past Surgeries', pastSurgeriesController),
              _buildTextField('Family History', familyHistoryController),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: submitMedicalHistory,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Blue background color
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Rounded corners
                  ),
                ),
                child: const Text('Submit', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      );
    }

    // Show fetched medical history with edit option
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical History'),
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
                      'Medical History',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      color: Colors.blue,
                      onPressed: _showEditDialog,
                    ),
                  ],
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

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.grey[200], // Light grey background for text field
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
          Icon(icon, color: Colors.blue, size: 24),
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
                  (value != null && value.isNotEmpty) ? value : 'Not Found',
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Show the edit dialog
  void _showEditDialog() {
    allergiesController.text = medicalHistory?['allergies'] ?? '';
    chronicConditionsController.text = medicalHistory?['chronic_conditions'] ?? '';
    pastSurgeriesController.text = medicalHistory?['past_surgeries'] ?? '';
    familyHistoryController.text = medicalHistory?['family_history'] ?? '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Medical History'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField('Allergies', allergiesController),
              _buildTextField('Chronic Conditions', chronicConditionsController),
              _buildTextField('Past Surgeries', pastSurgeriesController),
              _buildTextField('Family History', familyHistoryController),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                updateMedicalHistory();
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
