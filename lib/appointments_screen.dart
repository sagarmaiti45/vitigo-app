import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'appointment_details_screen.dart';
import 'package:shimmer/shimmer.dart';
import 'select_treatment_screen.dart';

class AppointmentsScreen extends StatefulWidget {
  @override
  _AppointmentsScreenState createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  List appointments = [];
  Map<int, Map<String, String>> timeSlotDetails = {}; // Cache time slot details
  String? errorMessage;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAppointments();
  }

  Future<void> fetchAppointments() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('bearer_token');

    if (token != null) {
      try {
        final response = await http.get(
          Uri.parse('https://vitigo.learnknowdigital.com/api/appointments/'),
          headers: {
            'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          if (responseData.isEmpty) {
            setState(() {
              errorMessage = 'No appointments found.';
              appointments = [];
              isLoading = false;
            });
          } else {
            setState(() {
              appointments = responseData;
              errorMessage = null;
            });

            // Fetch time slot details for all appointments
            await fetchAllTimeSlotDetails(token);
          }
        } else {
          setState(() {
            errorMessage = 'Failed to load appointments: ${response.reasonPhrase}';
            isLoading = false;
          });
        }
      } catch (error) {
        setState(() {
          errorMessage = 'An error occurred: $error';
          isLoading = false;
        });
      }
    } else {
      setState(() {
        errorMessage = 'Token not found';
        isLoading = false;
      });
    }
  }

  Future<void> fetchAllTimeSlotDetails(String token) async {
    for (var appointment in appointments) {
      final timeSlotId = appointment['time_slot'];
      await fetchTimeSlotDetails(timeSlotId, token);
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> fetchTimeSlotDetails(int timeSlotId, String token) async {
    try {
      final response = await http.get(
        Uri.parse('https://vitigo.learnknowdigital.com/api/doctors/time-slot/$timeSlotId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final timeSlotData = json.decode(response.body)['data'];
        String appointmentDate = _formatDate(timeSlotData['date']);
        String timeSlot = _formatTime(timeSlotData['start_time']);

        setState(() {
          timeSlotDetails[timeSlotId] = {
            'appointment_date': appointmentDate,
            'time_slot': timeSlot,
          };
        });
      }
    } catch (error) {
      print('Error fetching time slot: $error');
    }
  }

  String _formatDate(String dateStr) {
    final DateTime dateTime = DateTime.parse(dateStr);
    return DateFormat('MMMM d, yyyy').format(dateTime); // Human-readable format
  }

  String _formatTime(String timeStr) {
    final DateTime time = DateFormat('HH:mm:ss').parse(timeStr);
    return DateFormat('h:mm a').format(time); // Example: 9:00 AM
  }

  Widget buildAppointmentCard(Map appointment) {
    final timeSlotId = appointment['time_slot'];
    final timeSlotInfo = timeSlotDetails[timeSlotId] ?? {
      'appointment_date': 'Loading...',
      'time_slot': 'Loading...'
    };

    return Card(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Dr. ${appointment['doctor']['first_name']} ${appointment['doctor']['last_name']}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.orange, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    appointment['status'],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ),
              ],
            ),
            Divider(color: Colors.grey[300], thickness: 1.5, height: 20),
            SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.assignment, color: Colors.deepPurple),
                SizedBox(width: 10),
                Text(
                  'Type: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(appointment['appointment_type']),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.green),
                SizedBox(width: 10),
                Text(
                  'Appointment Date: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(timeSlotInfo['appointment_date'] ?? 'Loading...'),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.access_time, color: Colors.blueAccent),
                SizedBox(width: 10),
                Text(
                  'Time Slot: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(timeSlotInfo['time_slot'] ?? 'Loading...'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildShimmerEffect() {
    return ListView.builder(
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Card(
            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 150,
                    height: 20,
                    color: Colors.white,
                  ),
                  SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    height: 15,
                    color: Colors.white,
                  ),
                  SizedBox(height: 10),
                  Container(
                    width: 100,
                    height: 15,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Appointments'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? buildShimmerEffect()
          : errorMessage != null
          ? Center(
        child: Text(
          errorMessage!,
          style: TextStyle(fontSize: 18, color: Colors.red),
        ),
      )
          : ListView.builder(
        itemCount: appointments.length,
        itemBuilder: (context, index) {
          final appointment = appointments[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AppointmentDetailsScreen(
                    appointmentId: appointment['id'],
                  ),
                ),
              );
            },
            child: buildAppointmentCard(appointment),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SelectTreatmentScreen(),
            ),
          );
        },
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        child: Icon(Icons.add),
        tooltip: 'Add New Appointment',
      ),
    );
  }
}
