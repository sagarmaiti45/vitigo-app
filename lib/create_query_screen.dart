import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CreateQueryScreen extends StatefulWidget {
  @override
  _CreateQueryScreenState createState() => _CreateQueryScreenState();
}

class _CreateQueryScreenState extends State<CreateQueryScreen> {
  final _formKey = GlobalKey<FormState>();
  String subject = '';
  String description = '';
  String source = 'WEBSITE';
  String priority = 'A';
  String status = 'NEW';
  bool isAnonymous = false;
  String contactEmail = '';
  String contactPhone = '';
  List<int> tags = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Query'),
        foregroundColor: Colors.white,
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField(
                      label: 'Subject',
                      onChanged: (value) => subject = value,
                      validator: (value) => value!.isEmpty ? 'Please enter a subject' : null,
                    ),
                    SizedBox(height: 16),
                    _buildTextField(
                      label: 'Description',
                      maxLines: 5,
                      onChanged: (value) => description = value,
                      validator: (value) => value!.isEmpty ? 'Please enter a description' : null,
                    ),
                    SizedBox(height: 16),
                    _buildDropdownField(
                      label: 'Source',
                      value: source,
                      onChanged: (value) => setState(() => source = value!),
                      items: ['WEBSITE', 'APP', 'EMAIL'].map((source) => DropdownMenuItem(
                        value: source,
                        child: Text(source),
                      )).toList(),
                    ),
                    SizedBox(height: 16),
                    _buildDropdownField(
                      label: 'Priority',
                      value: priority,
                      onChanged: (value) => setState(() => priority = value!),
                      items: ['A', 'B', 'C'].map((priority) => DropdownMenuItem(
                        value: priority,
                        child: Text(priority),
                      )).toList(),
                    ),
                    SizedBox(height: 16),
                    _buildDropdownField(
                      label: 'Status',
                      value: status,
                      onChanged: (value) => setState(() => status = value!),
                      items: ['NEW', 'IN_PROGRESS', 'WAITING', 'RESOLVED'].map((status) => DropdownMenuItem(
                        value: status,
                        child: Text(status),
                      )).toList(),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: isAnonymous,
                          onChanged: (value) {
                            setState(() {
                              isAnonymous = value!;
                              if (isAnonymous) {
                                contactEmail = '';
                                contactPhone = '';
                              }
                            });
                          },
                        ),
                        Text('Submit Anonymously', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                      ],
                    ),
                    if (!isAnonymous) ...[
                      SizedBox(height: 16),
                      _buildTextField(
                        label: 'Contact Email',
                        onChanged: (value) => contactEmail = value,
                        validator: (value) => value!.isEmpty ? 'Please enter an email' : null,
                      ),
                      SizedBox(height: 16),
                      _buildTextField(
                        label: 'Contact Phone',
                        onChanged: (value) => contactPhone = value,
                        validator: (value) => value!.isEmpty ? 'Please enter a phone number' : null,
                      ),
                    ],
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _submitQuery,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                        child: Text('Submit Query', style: TextStyle(fontSize: 16)),
                      ),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({required String label, int maxLines = 1, required ValueChanged<String> onChanged, String? Function(String?)? validator}) {
    return TextFormField(
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.blueAccent, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blueAccent, width: 2),
          borderRadius: BorderRadius.circular(15),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      onChanged: onChanged,
      validator: validator,
    );
  }

  Widget _buildDropdownField({required String label, required String value, required ValueChanged<String?> onChanged, required List<DropdownMenuItem<String>> items}) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.blueAccent, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blueAccent, width: 2),
          borderRadius: BorderRadius.circular(15),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      value: value,
      onChanged: onChanged,
      items: items,
      validator: (value) => value == null ? 'Please select an option' : null,
    );
  }

  Future<void> _submitQuery() async {
    if (_formKey.currentState!.validate()) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? bearerToken = prefs.getString('bearer_token');

      // Create the request body
      final requestBody = {
        "subject": subject,
        "description": description,
        "source": source,
        "priority": priority,
        "status": status,
        "is_anonymous": isAnonymous,
        "contact_email": isAnonymous ? null : contactEmail,
        "contact_phone": isAnonymous ? null : contactPhone,
        "tags": tags.isEmpty ? [] : tags, // Pass empty list if tags are blank
      };

      // Print the raw JSON body for debugging
      print('Request Body (Raw JSON): ${jsonEncode(requestBody)}');

      try {
        // Make the API request
        final response = await http.post(
          Uri.parse('https://vitigo.learnknowdigital.com/api/queries/'),
          headers: {
            'Authorization': 'Bearer $bearerToken',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(requestBody),
        );

        print('Response Status Code: ${response.statusCode}');
        print('Response Body: ${response.body}'); // Debugging: Print the full response

        if (response.statusCode == 200 || response.statusCode == 201) {
          // Success: Show a success snackbar and navigate back
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Query submitted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true); // Signal successful creation for refresh
        } else {
          // Error: Check response type before parsing
          String errorMessage;
          if (response.body.startsWith('<!DOCTYPE html>') || response.headers['content-type']?.contains('text/html') == true) {
            // Handle unexpected HTML response
            errorMessage = 'Unexpected server response. Please try again or contact support.';
          } else {
            // Attempt to parse JSON error
            try {
              final errorResponse = jsonDecode(response.body);
              errorMessage = errorResponse['message'] ?? 'Failed to create query';
            } catch (e) {
              errorMessage = 'Failed to parse server response. Please try again.';
            }
          }

          // Show error message as a snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        // Catch any other exceptions and display an error
        print('Exception occurred: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred. Please check your connection and try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
