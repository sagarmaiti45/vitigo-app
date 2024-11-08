import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PatientForm extends StatefulWidget {
  final Function onSuccess; // Callback for successful form submission

  const PatientForm({Key? key, required this.onSuccess}) : super(key: key);

  @override
  State<PatientForm> createState() => _PatientFormState();
}

class _PatientFormState extends State<PatientForm> {
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
  final List<String> bodyAreas = ['Hands', 'Legs', 'Face', 'Arms', 'Body', 'Feet']; // Body areas for selection

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        isLoading = true; // Show loading indicator
      });

      // Construct request body
      final requestBody = jsonEncode({
        'date_of_birth': dateOfBirth,
        'gender': gender,
        'blood_group': bloodGroup,
        'address': address,
        'phone_number': phoneNumber,
        'emergency_contact_name': emergencyContactName,
        'emergency_contact_number': emergencyContactNumber,
        'vitiligo_onset_date': vitiligoOnsetDate,
        'vitiligo_type': vitiligoType,
        'affected_body_areas': selectedAreas.join(', '), // Join selected areas into a single string
      });

      print('Request Body: $requestBody'); // Log request body

      // Send POST request
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('bearer_token');
      final userId = prefs.getInt('user_id'); // Assume user_id is saved as an int
      final response = await http.post(
        Uri.parse('https://vitigo.learnknowdigital.com/api/patient/$userId/profile/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: requestBody,
      );

      setState(() {
        isLoading = false; // Hide loading indicator
      });

      if (response.statusCode == 201) { // Check for created status
        print('Patient profile created successfully');
        widget.onSuccess(); // Call the onSuccess callback to refresh data
        _showSnackBar('Patient profile created successfully!', Colors.green);
      } else {
        print('Failed to create patient profile: ${response.body}');
        _showSnackBar('Failed to create patient profile: ${response.body}', Colors.red);
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
          dateOfBirth = formattedDate; // Set date of birth
        } else {
          vitiligoOnsetDate = formattedDate; // Set vitiligo onset date
        }
      });
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView( // Make the form scrollable
      child: Card(
        elevation: 10, // Add shadow for depth
        margin: const EdgeInsets.all(8.0), // Margin around the card
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0), // Rounded corners
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0), // Padding inside the card
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
                  onTap: () => _selectDate(context, true), // Call for birth date
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your date of birth';
                    }
                    return null;
                  },
                  onSaved: (value) => dateOfBirth = value!,
                  controller: TextEditingController(text: dateOfBirth), // Set the text field's value
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
                  keyboardType: TextInputType.phone,
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
                  keyboardType: TextInputType.phone,
                  onSaved: (value) => emergencyContactNumber = value!,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Vitiligo Onset Date',
                    suffixIcon: Icon(Icons.calendar_today, color: Colors.blue),
                    hintText: 'YYYY-MM-DD',
                    helperText: 'The date when the patient first noticed the symptoms of vitiligo',
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(color: Colors.blue, width: 2.0),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  readOnly: true,
                  onTap: () => _selectDate(context, false), // Call for vitiligo onset date
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the vitiligo onset date';
                    }
                    return null;
                  },
                  onSaved: (value) => vitiligoOnsetDate = value!,
                  controller: TextEditingController(text: vitiligoOnsetDate), // Set the text field's value
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: vitiligoType,
                  decoration: InputDecoration(
                    labelText: 'Vitiligo Type',
                    helperText: 'Select type of vitiligo',
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
                Wrap(
                  spacing: 8.0,
                  children: bodyAreas.map((area) {
                    return ChoiceChip(
                      label: Text(area, style: const TextStyle(color: Colors.white)),
                      selected: selectedAreas.contains(area),
                      backgroundColor: Colors.grey,
                      selectedColor: Colors.blue, // Color when selected
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
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
                Center(
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _submitForm, // Disable if loading
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue, // Set background color to blue
                      foregroundColor: Colors.white, // Set text color to white
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), // Add padding to button
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0), // Rounded button
                      ),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(
                      color: Colors.white,
                    )
                        : const Text('Create'), // Button text
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
