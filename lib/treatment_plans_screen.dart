import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // Importing intl package for date formatting
import 'package:shared_preferences/shared_preferences.dart';

class TreatmentPlansScreen extends StatefulWidget {
  const TreatmentPlansScreen({Key? key}) : super(key: key);

  @override
  State<TreatmentPlansScreen> createState() => _TreatmentPlansScreenState();
}

class _TreatmentPlansScreenState extends State<TreatmentPlansScreen> {
  List<dynamic>? treatmentPlans;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTreatmentPlans();
  }

  Future<void> fetchTreatmentPlans() async {
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
          treatmentPlans = data['treatment_plans'] ?? []; // Ensure treatmentPlans is never null
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load treatment plans');
      }
    } catch (e) {
      print('Error fetching treatment plans: $e');
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
        title: const Text('Treatment Plans'),
        foregroundColor: Colors.white, // AppBar text color set to white
        backgroundColor: Colors.blue, // AppBar background color set to blue
      ),
      body: treatmentPlans == null || treatmentPlans!.isEmpty
          ? _buildNoPlansFound() // Display message if no plans found
          : ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: treatmentPlans!.length,
        itemBuilder: (context, index) {
          final plan = treatmentPlans![index];
          return _buildPlanCard(plan, index + 1); // Pass index + 1 for numbering
        },
      ),
    );
  }

  Widget _buildNoPlansFound() {
    return Center(
      child: Text(
        'No Treatment Plans Found.',
        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
      ),
    );
  }

  Widget _buildPlanCard(Map<String, dynamic> plan, int cardNumber) {
    final createdBy = plan['created_by'];
    final createdDate = DateFormat('MMMM dd, yyyy').format(DateTime.parse(plan['created_date']));
    final updatedDate = DateFormat('MMMM dd, yyyy').format(DateTime.parse(plan['updated_date']));

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
                  'Treatment Plan Details',
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
            _buildInfoRow(Icons.calendar_today, 'Created Date', createdDate),
            _buildInfoRow(Icons.update, 'Updated Date', updatedDate),
            _buildInfoRow(Icons.flag, 'Treatment Goals', plan['treatment_goals'] ?? 'N/A'),
            _buildInfoRow(Icons.healing, 'Phototherapy', plan['phototherapy_details'] ?? 'N/A'),
            _buildInfoRow(Icons.thumb_up, 'Lifestyle Recommendations', plan['lifestyle_recommendations'] ?? 'N/A'),
            _buildInfoRow(Icons.schedule, 'Follow-up Frequency', plan['follow_up_frequency'] ?? 'N/A'),
            const SizedBox(height: 10),
            const Text(
              'Created By:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              '${createdBy['full_name'] ?? 'Unknown'} (${createdBy['role'] ?? 'N/A'})',
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
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
