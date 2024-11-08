import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; // Import intl package

class AppointmentDetailsScreen extends StatefulWidget {
  final int appointmentId;

  AppointmentDetailsScreen({required this.appointmentId});

  @override
  _AppointmentDetailsScreenState createState() => _AppointmentDetailsScreenState();
}

class _AppointmentDetailsScreenState extends State<AppointmentDetailsScreen> {
  Map<String, dynamic>? appointmentDetails;
  String? appointmentDate; // New field for Appointment Date
  String? timeSlot; // New field for Time Slot

  @override
  void initState() {
    super.initState();
    fetchAppointmentDetails();
  }

  // Function to format the date in a human-readable format
  String _formatDate(String dateStr) {
    final DateTime dateTime = DateTime.parse(dateStr);
    return DateFormat('MMMM d, yyyy').format(dateTime); // Example: October 24, 2024
  }

  // Function to format the time in a human-readable format
  String _formatTime(String timeStr) {
    final DateTime time = DateFormat('HH:mm:ss').parse(timeStr);
    return DateFormat('h:mm a').format(time); // Example: 9:00 AM
  }

  Future<void> fetchAppointmentDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('bearer_token'); // Retrieve token from shared preferences

    if (token != null) {
      // Fetch appointment details
      final response = await http.get(
        Uri.parse('https://vitigo.learnknowdigital.com/api/appointments/${widget.appointmentId}'),
        headers: {
          'Authorization': 'Bearer $token', // Use the retrieved token
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          appointmentDetails = json.decode(response.body);
        });

        // Fetch time slot details
        await fetchTimeSlotDetails(appointmentDetails!['time_slot'], token);
      } else {
        throw Exception('Failed to load appointment details');
      }
    } else {
      // Handle case when token is not found
      print('Token not found');
    }
  }

  Future<void> fetchTimeSlotDetails(int timeSlotId, String token) async {
    final response = await http.get(
      Uri.parse('https://vitigo.learnknowdigital.com/api/doctors/time-slot/$timeSlotId'),
      headers: {
        'Authorization': 'Bearer $token', // Use the retrieved token
      },
    );

    if (response.statusCode == 200) {
      final timeSlotDetails = json.decode(response.body);
      setState(() {
        appointmentDate = _formatDate(timeSlotDetails['data']['date']); // Format and assign Appointment Date
        timeSlot = _formatTime(timeSlotDetails['data']['start_time']); // Format and assign Time Slot
      });
    } else {
      throw Exception('Failed to load time slot details');
    }
  }

  Widget _buildDetailRow(String title, String value, IconData icon, {Color? iconColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: iconColor ?? Colors.blue),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Text(
            value,
            style: TextStyle(color: Colors.black87),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Appointment Details'),
        foregroundColor: Colors.white,
        backgroundColor: Colors.blue,
      ),
      body: appointmentDetails == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'Appointment ID: ${appointmentDetails!['id']}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // Appointment details
                _buildDetailRow(
                    'Patient Name:',
                    '${appointmentDetails!['patient']['first_name']} ${appointmentDetails!['patient']['last_name']}',
                    Icons.person),
                _buildDetailRow(
                    'Doctor Name:',
                    '${appointmentDetails!['doctor']['first_name']} ${appointmentDetails!['doctor']['last_name']}',
                    Icons.local_hospital,
                    iconColor: Colors.green),

                // New fields for Appointment Date and Time Slot
                _buildDetailRow('Appointment Date:', appointmentDate ?? 'Loading...', Icons.calendar_today,
                    iconColor: Colors.orange),
                _buildDetailRow('Time Slot:', timeSlot ?? 'Loading...', Icons.access_time,
                    iconColor: Colors.purple),
                _buildDetailRow('Type:', appointmentDetails!['appointment_type'], Icons.medical_services,
                    iconColor: Colors.red),
                _buildDetailRow('Status:', appointmentDetails!['status'], Icons.check_circle,
                    iconColor: Colors.blue),
                _buildDetailRow('Priority:', appointmentDetails!['priority'], Icons.priority_high,
                    iconColor: Colors.amber),
                _buildDetailRow('Notes:', appointmentDetails!['notes'] ?? 'No notes', Icons.note_alt),

                // Divider line before created_at and updated_at
                SizedBox(height: 20),
                Divider(
                  color: Colors.grey[400],
                  thickness: 1,
                ),
                SizedBox(height: 10),

                // Creation and Update info
                _buildDetailRow('Created At:', _formatDate(appointmentDetails!['created_at']), Icons.calendar_today,
                    iconColor: Colors.orange),
                _buildDetailRow('Updated At:', _formatDate(appointmentDetails!['updated_at']), Icons.update,
                    iconColor: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
