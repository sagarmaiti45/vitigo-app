import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // Importing intl package for date formatting
import 'package:shared_preferences/shared_preferences.dart';

class VitiligoAssessmentsScreen extends StatefulWidget {
  const VitiligoAssessmentsScreen({Key? key}) : super(key: key);

  @override
  State<VitiligoAssessmentsScreen> createState() => _VitiligoAssessmentScreenState();
}

class _VitiligoAssessmentScreenState extends State<VitiligoAssessmentsScreen> {
  List<dynamic>? assessments;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAssessments();
  }

  Future<void> fetchAssessments() async {
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
          assessments = data['vitiligo_assessments'];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load assessments');
      }
    } catch (e) {
      print('Error fetching assessments: $e');
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
        title: const Text('Vitiligo Assessments'),
        foregroundColor: Colors.white, // AppBar text color set to white
        backgroundColor: Colors.blue, // AppBar background color set to blue
      ),
      body: assessments == null || assessments!.isEmpty
          ? Center(child: Text('No assessments found.', style: TextStyle(fontSize: 18, color: Colors.black54)))
          : ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: assessments!.length,
        itemBuilder: (context, index) {
          final assessment = assessments![index];
          return _buildAssessmentCard(assessment, index + 1); // Pass index + 1 for numbering
        },
      ),
    );
  }

  Widget _buildAssessmentCard(Map<String, dynamic> assessment, int cardNumber) {
    final assessedBy = assessment['assessed_by'];
    final assessmentDate = DateFormat('MMMM dd, yyyy').format(DateTime.parse(assessment['assessment_date']));

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
                  'Assessment Details',
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
            _buildInfoRow(Icons.date_range, 'Assessment Date', assessmentDate),
            _buildInfoRow(Icons.circle, 'Body Surface Area',
                assessment['body_surface_area_affected'] != null
                    ? '${assessment['body_surface_area_affected']}%'
                    : 'N/A'),
            _buildInfoRow(Icons.stacked_line_chart, 'VASI Score',
                assessment['vasi_score'] != null
                    ? assessment['vasi_score'].toStringAsFixed(2)
                    : 'N/A'),
            _buildInfoRow(Icons.check_circle, 'Treatment Response',
                assessment['treatment_response'] ?? 'N/A'),
            _buildInfoRow(Icons.note, 'Notes', assessment['notes'] ?? 'N/A'),
            const SizedBox(height: 10),
            const Text(
              'Assessed By:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              assessedBy != null
                  ? '${assessedBy['full_name']} (${assessedBy['role']})'
                  : 'N/A',
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
