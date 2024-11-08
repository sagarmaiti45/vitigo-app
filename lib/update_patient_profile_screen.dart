import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'patient_details_screen.dart'; // Ensure to import the PatientDetailsScreen

class UpdatePatientProfileScreen extends StatefulWidget {
  const UpdatePatientProfileScreen({Key? key}) : super(key: key);

  @override
  State<UpdatePatientProfileScreen> createState() => _UpdatePatientProfileScreenState();
}

class _UpdatePatientProfileScreenState extends State<UpdatePatientProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String dateOfBirth = '';
  String gender = 'M'; // Default gender
  String bloodGroup = 'O+'; // Default blood group
  String address = '';
  String phoneNumber = '';
  String emergencyContactName = '';
  String emergencyContactNumber = '';
  String vitiligoOnsetDate = '';
  String vitiligoType = 'Segmental'; // Default vitiligo type
  List<String> selectedAreas = []; // Store selected body areas
  bool isLoading = false; // Loading state for the button

  final List<String> genders = ['M', 'F'];
  final List<String> bloodGroups = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];
  final List<String> vitiligoTypes = ['Segmental', 'Non-Segmental'];
  final List<String> bodyAreas = ['Hands', 'Legs', 'Face', 'Arms', 'Body', 'Feet'];

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        isLoading = true;
      });

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('bearer_token');
      final userId = prefs.getInt('user_id')?.toString(); // Convert int to String
      final url = 'https://vitigo.learnknowdigital.com/api/patient/$userId/profile/';

      // Building the request body dynamically based on filled fields
      final Map<String, dynamic> requestBody = {};

      if (dateOfBirth.isNotEmpty) requestBody['date_of_birth'] = dateOfBirth;
      if (gender.isNotEmpty) requestBody['gender'] = gender;
      if (bloodGroup.isNotEmpty) requestBody['blood_group'] = bloodGroup;
      if (address.isNotEmpty) requestBody['address'] = address;
      if (phoneNumber.isNotEmpty) requestBody['phone_number'] = phoneNumber;
      if (emergencyContactName.isNotEmpty) requestBody['emergency_contact_name'] = emergencyContactName;
      if (emergencyContactNumber.isNotEmpty) requestBody['emergency_contact_number'] = emergencyContactNumber;
      if (vitiligoOnsetDate.isNotEmpty) requestBody['vitiligo_onset_date'] = vitiligoOnsetDate;
      if (vitiligoType.isNotEmpty) requestBody['vitiligo_type'] = vitiligoType;
      if (selectedAreas.isNotEmpty) requestBody['affected_body_areas'] = selectedAreas.join(', ');

      print('Request Body: ${jsonEncode(requestBody)}'); // Log request body

      try {
        final response = await http.put(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(requestBody),
        );

        setState(() {
          isLoading = false;
        });

        // Print the response details in console
        print('Response Status Code: ${response.statusCode}');
        print('Response Body: ${response.body}');

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Profile updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate to PatientDetailsScreen and remove UpdatePatientProfileScreen from the stack
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const PatientDetailsScreen()),
                (Route<dynamic> route) => route.isFirst, // Ensures that we return to the first route in the stack
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update profile: ${response.body}'),
              backgroundColor: Colors.red,
            ),
          );
        }


      } catch (e) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context, bool isBirthDate) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
      setState(() {
        if (isBirthDate) {
          dateOfBirth = formattedDate;
        } else {
          vitiligoOnsetDate = formattedDate;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Patient Profile'),
        foregroundColor: Colors.white,
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Card(
          elevation: 10,
          margin: const EdgeInsets.all(8.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Date of Birth',
                      suffixIcon: Icon(Icons.calendar_today, color: Colors.blue),
                      hintText: 'YYYY-MM-DD',
                      helperText: 'Enter your date of birth',
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(color: Colors.blue, width: 2.0),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    readOnly: true,
                    onTap: () => _selectDate(context, true),
                    onSaved: (value) => dateOfBirth = value!,
                    controller: TextEditingController(text: dateOfBirth),
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: gender,
                    decoration: InputDecoration(
                      labelText: 'Gender',
                      helperText: 'Select your gender',
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(color: Colors.blue, width: 2.0),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    items: genders.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        gender = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: bloodGroup,
                    decoration: InputDecoration(
                      labelText: 'Blood Group',
                      helperText: 'Select your blood group',
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(color: Colors.blue, width: 2.0),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    items: bloodGroups.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        bloodGroup = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Address',
                      helperText: 'Enter your address',
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(color: Colors.blue, width: 2.0),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    onSaved: (value) => address = value!,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      helperText: 'Enter your phone number',
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(color: Colors.blue, width: 2.0),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    onSaved: (value) => phoneNumber = value!,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Emergency Contact Name',
                      helperText: 'Enter emergency contact name',
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(color: Colors.blue, width: 2.0),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    onSaved: (value) => emergencyContactName = value!,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Emergency Contact Number',
                      helperText: 'Enter emergency contact number',
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(color: Colors.blue, width: 2.0),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    onSaved: (value) => emergencyContactNumber = value!,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Vitiligo Onset Date',
                      suffixIcon: Icon(Icons.calendar_today, color: Colors.blue),
                      hintText: 'YYYY-MM-DD',
                      helperText: 'Enter your vitiligo onset date',
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(color: Colors.blue, width: 2.0),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    readOnly: true,
                    onTap: () => _selectDate(context, false),
                    onSaved: (value) => vitiligoOnsetDate = value!,
                    controller: TextEditingController(text: vitiligoOnsetDate),
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: vitiligoType,
                    decoration: InputDecoration(
                      labelText: 'Vitiligo Type',
                      helperText: 'Select your vitiligo type',
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(color: Colors.blue, width: 2.0),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    items: vitiligoTypes.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        vitiligoType = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  Text('Affected Body Areas:'),
                  Wrap(
                    spacing: 8.0,
                    children: bodyAreas.map((area) {
                      return ChoiceChip(
                        label: Text(area),
                        selected: selectedAreas.contains(area),
                        onSelected: (isSelected) {
                          setState(() {
                            if (isSelected) {
                              selectedAreas.add(area);
                            } else {
                              selectedAreas.remove(area);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: isLoading ? null : _updateProfile,
                    child: isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : const Text('Update'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
