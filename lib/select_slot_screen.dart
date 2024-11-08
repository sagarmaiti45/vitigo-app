import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'appointment_summary_screen.dart';

class SelectSlotScreen extends StatefulWidget {
  final String doctorId;

  SelectSlotScreen({required this.doctorId});

  @override
  _SelectSlotScreenState createState() => _SelectSlotScreenState();
}

class _SelectSlotScreenState extends State<SelectSlotScreen> {
  DateTime selectedDate = DateTime.now();
  List<dynamic> availableSlots = [];
  bool isLoading = false;
  String doctorName = '';
  int? selectedSlotIndex;

  @override
  void initState() {
    super.initState();
    fetchDoctorName();
    fetchAvailableSlots();
  }

  Future<void> fetchDoctorName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('bearer_token');

    if (token != null) {
      final response = await http.get(
        Uri.parse('https://vitigo.learnknowdigital.com/api/doctors/${widget.doctorId}'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          doctorName = '${data['data']['user']['first_name']} ${data['data']['user']['last_name']}';
        });
      } else {
        throw Exception('Failed to load doctor name: ${response.statusCode} - ${response.body}');
      }
    } else {
      print('Token not found');
    }
  }

  Future<void> fetchAvailableSlots() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('bearer_token');

    if (token != null) {
      setState(() {
        isLoading = true;
      });

      final String apiUrl = 'https://vitigo.learnknowdigital.com/api/appointments/timeslots/available/?doctor_id=${widget.doctorId}&date=${DateFormat('yyyy-MM-dd').format(selectedDate)}';
      print('API URL: $apiUrl');

      try {
        final response = await http.get(
          Uri.parse(apiUrl),
          headers: {
            'Authorization': 'Bearer $token',
          },
        );

        print('Response from fetchAvailableSlots: ${response.body}');

        if (response.statusCode == 200) {
          var data = json.decode(response.body);

          if (data is Map && data['data'] is List) {
            setState(() {
              availableSlots = data['data'];
              isLoading = false;
            });
          } else {
            throw Exception('Unexpected response structure: ${data.runtimeType}');
          }
        } else {
          print('Error fetching slots: ${response.statusCode}');
          print('Response body: ${response.body}');
          throw Exception('Failed to load available slots: ${response.statusCode} - ${response.body}');
        }
      } catch (e) {
        print('Exception occurred while fetching slots: $e');
        setState(() {
          isLoading = false;
        });
      }
    } else {
      print('Token not found');
    }
  }

  void onDaySelected(DateTime day, DateTime focusedDay) {
    if (!isSameDay(selectedDate, day)) {
      setState(() {
        selectedDate = day;
      });
      fetchAvailableSlots();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Slot'),
        foregroundColor: Colors.white,
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Select slot with $doctorName',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          TableCalendar(
            focusedDay: selectedDate,
            firstDay: DateTime.now(),
            lastDay: DateTime.now().add(Duration(days: 30)),
            onDaySelected: onDaySelected,
            calendarFormat: CalendarFormat.month,
            selectedDayPredicate: (day) => isSameDay(selectedDate, day),
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.blueAccent,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              weekendTextStyle: TextStyle(color: Colors.red),
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Available Slots',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 10),
          isLoading
              ? Center(child: CircularProgressIndicator())
              : Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: availableSlots.length,
                itemBuilder: (context, index) {
                  final slot = availableSlots[index];
                  bool isSelected = index == selectedSlotIndex;

                  return Card(
                    color: isSelected ? Colors.orange : Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          selectedSlotIndex = index;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.access_time, size: 16, color: Colors.white),
                            SizedBox(width: 4),
                            Text(
                              '${DateFormat('hh:mm a').format(DateFormat('HH:mm:ss').parse(slot['start_time']))}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8.0,
              spreadRadius: 0.5,
              offset: Offset(0, -2), // changes position of shadow
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: selectedSlotIndex != null
                ? () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              int? patientId = prefs.getInt('user_id');

              String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
              int selectedSlotId = availableSlots[selectedSlotIndex!]['id'];
              int doctorId = int.parse(widget.doctorId);

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AppointmentSummaryScreen(
                    doctorName: doctorName,
                    selectedSlotId: selectedSlotId,
                    selectedSlotTime: DateFormat('hh:mm a').format(DateFormat('HH:mm:ss').parse(availableSlots[selectedSlotIndex!]['start_time'])),
                    selectedDate: formattedDate,
                    doctorId: doctorId,
                  ),
                ),
              );
            }
                : null,
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.blue,
              padding: EdgeInsets.symmetric(vertical: 16.0), // Text color
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0), // Border radius
              ),
            ),
            child: Text('Next', style: TextStyle(fontWeight: FontWeight.bold),),
          ),
        ),
      ),
    );
  }
}
