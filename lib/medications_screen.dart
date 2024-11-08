import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // Import the intl package
import 'package:shared_preferences/shared_preferences.dart';

class MedicationsScreen extends StatefulWidget {
  const MedicationsScreen({Key? key}) : super(key: key);

  @override
  State<MedicationsScreen> createState() => _MedicationsScreenState();
}

class _MedicationsScreenState extends State<MedicationsScreen> {
  List<dynamic>? medications;
  bool isLoading = true;
  String errorMessage = ''; // Variable to store error messages

  @override
  void initState() {
    super.initState();
    fetchMedications();
  }

  Future<void> fetchMedications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('bearer_token'); // Retrieve token from SharedPreferences

      final response = await http.get(
        Uri.parse('https://vitigo.learnknowdigital.com/api/patient-info'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          medications = data['medications'] ?? []; // Ensure medications is always a list
          isLoading = false;
          // Clear any previous error messages
          errorMessage = '';
        });
      } else {
        throw Exception('Failed to load medications');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error fetching medications: $e'; // Set error message
        medications = []; // Ensure medications is empty on error
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
        title: const Text('Medications'),
        foregroundColor: Colors.white, // AppBar text color set to white
        backgroundColor: Colors.blue, // AppBar background color set to blue
      ),
      body: medications != null && medications!.isNotEmpty
          ? ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: medications!.length,
        itemBuilder: (context, index) {
          final medication = medications![index];
          return _buildMedicationCard(medication, index + 1); // Pass index + 1 for numbering
        },
      )
          : Center(
        child: Text(
          errorMessage.isNotEmpty
              ? 'No medications found.' // Show this on error
              : 'No medications found.', // Show this if medications are empty
          style: const TextStyle(fontSize: 18, color: Colors.black54),
        ),
      ),
    );
  }

  Widget _buildMedicationCard(Map<String, dynamic> medication, int cardNumber) {
    final prescribedBy = medication['prescribed_by'];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Rounded corners
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Medication Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue, // Text color set to blue
                  ),
                ),
                Text(
                  '#$cardNumber', // Card number
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const Divider(thickness: 1.5),
            _buildInfoRow(Icons.medication, 'Name', medication['name']),
            _buildInfoRow(Icons.local_pharmacy, 'Dosage', medication['dosage']),
            _buildInfoRow(Icons.schedule, 'Frequency', medication['frequency']),
            _buildInfoRow(Icons.date_range, 'Start Date', _formatDate(medication['start_date'])),
            _buildInfoRow(Icons.date_range, 'End Date', _formatDate(medication['end_date'] ?? 'Ongoing')),
            const SizedBox(height: 10),
            const Text(
              'Prescribed By:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              '${prescribedBy['full_name']} (${prescribedBy['role']})',
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String? date) {
    if (date == null || date.isEmpty) return 'N/A'; // Handle empty or null date

    try {
      final DateTime parsedDate = DateTime.parse(date); // Attempt to parse the date
      return DateFormat('MMMM dd, yyyy').format(parsedDate); // Format date to desired format
    } catch (e) {
      print('Date parsing error: $e'); // Print parsing error
      return 'Invalid Date'; // Return a fallback value
    }
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blue, size: 24), // Icon color set to blue
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
                  value.isNotEmpty ? value : 'N/A',
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
