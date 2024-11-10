import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dashboard_screen.dart';

class AppointmentSummaryScreen extends StatefulWidget {
  final int doctorId;
  final int selectedSlotId;
  final String selectedSlotTime;
  final String selectedDate;
  final String doctorName;

  AppointmentSummaryScreen({
    required this.doctorId,
    required this.selectedSlotId,
    required this.selectedSlotTime,
    required this.selectedDate,
    required this.doctorName,
  });

  @override
  _AppointmentSummaryScreenState createState() => _AppointmentSummaryScreenState();
}

class _AppointmentSummaryScreenState extends State<AppointmentSummaryScreen> {
  bool isLoading = false;

  Future<void> createAppointment(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? patientId = prefs.getInt('user_id');

    if (patientId != null) {
      final String apiUrl = 'https://vitigo.learnknowdigital.com/api/appointments/create/';

      final Map<String, dynamic> requestBody = {
        'patient': patientId,
        'doctor': widget.doctorId,
        'appointment_type': 'CONSULTATION',
        'date': widget.selectedDate,
        'time_slot': widget.selectedSlotId,
        'status': 'PENDING',
        'priority': 'B',
        'notes': 'This is a sample note.',
      };

      try {
        setState(() {
          isLoading = true;
        });

        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${prefs.getString('bearer_token')}',
          },
          body: jsonEncode(requestBody),
        );

        setState(() {
          isLoading = false;
        });

        if (response.statusCode == 200 || response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Appointment created successfully!'),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate back to DashboardScreen and set the appointments tab as selected
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => DashboardScreen(initialTabIndex: 0)), // 1 for Appointments
                (route) => false,
          );
        } else {
          print('Failed to create appointment: ${response.statusCode} - ${response.body}');
        }
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        print('Exception while creating appointment: $e');
      }
    } else {
      print('Patient ID not found in SharedPreferences');
    }
  }



  Future<Map<String, dynamic>> fetchDoctorDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('bearer_token');

    if (token != null) {
      final response = await http.get(
        Uri.parse('https://vitigo.learnknowdigital.com/api/doctors/${widget.doctorId}/'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body)['data'];
      } else {
        throw Exception('Failed to load doctor details');
      }
    } else {
      throw Exception('Token not found');
    }
  }

  Future<Map<String, dynamic>> fetchUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('bearer_token');

    if (token != null) {
      final response = await http.get(
        Uri.parse('https://vitigo.learnknowdigital.com/api/user-info/'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load user details');
      }
    } else {
      throw Exception('Token not found');
    }
  }

  int calculateAge(String dateOfBirth) {
    DateTime dob = DateTime.parse(dateOfBirth);
    DateTime today = DateTime.now();
    int age = today.year - dob.year;
    if (today.month < dob.month || (today.month == dob.month && today.day < dob.day)) {
      age--;
    }
    return age;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Appointment Summary'),
        foregroundColor: Colors.white,
        backgroundColor: Colors.blueAccent,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: Future.wait([fetchDoctorDetails(), fetchUserDetails()]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final doctorDetails = snapshot.data![0]['user'];
            final profilePicturePath = doctorDetails['profile_picture'];
            final profilePictureUrl = 'https://vitigo.learnknowdigital.com$profilePicturePath';
            final registrationNumber = snapshot.data![0]['registration_number'];
            final qualification = snapshot.data![0]['qualification'];
            final experience = snapshot.data![0]['experience'];
            final consultationFee = snapshot.data![0]['consultation_fee'];
            //final address = snapshot.data![0]['address'];
            final city = snapshot.data![0]['city'];
            final state = snapshot.data![0]['state'];
            final country = snapshot.data![0]['country'];

            final userDetails = snapshot.data![1]['user'];
            final dateOfBirth = snapshot.data![1]['patient']['date_of_birth'];
            final gender = snapshot.data![1]['patient']['gender'];
            final fullName = userDetails['full_name'];
            final age = calculateAge(dateOfBirth);

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  // Doctor Info Section
                  Card(
                    elevation: 4,
                    margin: const EdgeInsets.only(bottom: 16.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundImage: NetworkImage(profilePictureUrl),
                                radius: 30,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Doctor: ${doctorDetails['first_name']} ${doctorDetails['last_name']}',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          InfoRow(title: 'Registration Number', content: registrationNumber),
                          InfoRow(title: 'Qualification', content: qualification),
                          InfoRow(title: 'Experience', content: experience),
                          InfoRow(title: 'Consultation Fee', content: '₹$consultationFee'),
                          //InfoRow(title: 'Address', content: address),
                          InfoRow(title: 'City', content: city),
                          InfoRow(title: 'Country', content: country),
                        ],
                      ),
                    ),
                  ),
                  // Slot Details Section
                  Card(
                    elevation: 4,
                    margin: const EdgeInsets.only(bottom: 16.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.access_time, color: Colors.blueAccent),
                              SizedBox(width: 8),
                              Text(
                                'Slot Details:',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          InfoRow(title: 'Selected Date', content: widget.selectedDate),
                          InfoRow(title: 'Selected Slot', content: widget.selectedSlotTime),
                        ],
                      ),
                    ),
                  ),
                  // User Details Section
                  Card(
                    elevation: 4,
                    margin: const EdgeInsets.only(bottom: 16.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.person_pin, color: Colors.blueAccent),
                              SizedBox(width: 8),
                              Text(
                                'Consult For:',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          InfoRow(title: 'Name', content: fullName),
                          InfoRow(title: 'Gender', content: gender),
                          InfoRow(title: 'Age', content: age.toString()),
                        ],
                      ),
                    ),
                  ),
                  // Terms and Conditions Section
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => TermsAndConditionsPage()),
                        );
                      },
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(fontSize: 12, color: Colors.black),
                          children: [
                            TextSpan(text: '*By proceeding, you agree to VitiGo\'s '),
                            TextSpan(
                              text: 'Terms and Conditions',
                              style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return Center(child: Text('No data available.'));
          }
        },
      ),
      bottomNavigationBar: FutureBuilder<Map<String, dynamic>>(
        future: fetchDoctorDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SizedBox.shrink();
          } else if (snapshot.hasError) {
            return SizedBox.shrink();
          } else if (snapshot.hasData) {
            final consultationFee = snapshot.data!['consultation_fee'];
            return Container(
              padding: EdgeInsets.only(bottom: 16.0, left: 16.0, right: 16.0, top: 10.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8.0,
                    spreadRadius: 1.0,
                    offset: Offset(0, -1),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'To Pay: ₹$consultationFee',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton(
                    onPressed: isLoading ? null : () => createAppointment(context),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                    child: isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text('Confirm'),
                  ),
                ],
              ),
            );
          } else {
            return SizedBox.shrink();
          }
        },
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final String title;
  final String content;

  const InfoRow({
    Key? key,
    required this.title,
    required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Aligns title and content
        children: [
          Text(
            '$title: ',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          Expanded(
            child: Text(
              content,
              style: TextStyle(fontSize: 14),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right, // Aligns text to the right
            ),
          ),
        ],
      ),
    );
  }
}

class TermsAndConditionsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Terms and Conditions'),
      ),
      body: Center(
        child: Text('Terms and conditions content goes here.'),
      ),
    );
  }
}
