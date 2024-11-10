import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';  // Import the intl package

import 'create_query_screen.dart';

class QueriesScreen extends StatefulWidget {
  @override
  _QueriesScreenState createState() => _QueriesScreenState();
}

class _QueriesScreenState extends State<QueriesScreen> {
  List<dynamic> queries = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchQueries();
  }

  Future<void> _fetchQueries() async {
    setState(() {
      isLoading = true; // Show shimmer effect during the refresh
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? bearerToken = prefs.getString('bearer_token');

    final response = await http.get(
      Uri.parse('https://vitigo.learnknowdigital.com/api/queries/'),
      headers: {
        'Authorization': 'Bearer $bearerToken',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        queries = json.decode(response.body);
        isLoading = false; // Stop loading when data is fetched
      });
    } else {
      print('Failed to load queries');
      setState(() {
        isLoading = false;
      });
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'A':
        return Colors.red;
      case 'B':
        return Colors.blue;
      case 'C':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'NEW':
        return Colors.orange;
      case 'IN_PROGRESS':
        return Colors.blue;
      case 'WAITING':
        return Colors.yellow.shade700;
      case 'RESOLVED':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(String dateString) {
    try {
      // Parse the date string to a DateTime object
      DateTime dateTime = DateTime.parse(dateString);
      // Format the date and time in a human-readable format
      return DateFormat('MMM dd, yyyy hh:mm a').format(dateTime);
    } catch (e) {
      // If the date parsing fails, return the original string
      return dateString;
    }
  }

  void _openCreateQueryScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateQueryScreen()),
    );

    if (result == true) {
      _fetchQueries();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Query created successfully'), backgroundColor: Colors.green),
      );
    } else if (result == false) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create query'), backgroundColor: Colors.red),
      );
    }
  }

  Widget _buildShimmerEffect() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    color: Colors.white,
                  ),
                  SizedBox(width: 8),
                  Container(
                    height: 20,
                    width: 150,
                    color: Colors.white,
                  ),
                ],
              ),
              SizedBox(height: 6),
              Container(height: 15, width: double.infinity, color: Colors.white),
              SizedBox(height: 8),
              Container(height: 15, width: 100, color: Colors.white),
              SizedBox(height: 6),
              Container(height: 15, width: 80, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Queries'),
        foregroundColor: Colors.white,
        backgroundColor: Colors.blue.shade700,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchQueries, // Refresh the queries on pull-down
        color: Colors.blueAccent, // Set color of the refresh icon
        child: isLoading
            ? ListView.builder(
          itemCount: 6,
          itemBuilder: (context, index) => _buildShimmerEffect(),
        )
            : ListView.builder(
          itemCount: queries.length,
          itemBuilder: (context, index) {
            final query = queries[index];
            return Card(
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.help_outline, color: Colors.blue.shade800),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            query['subject'],
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6),
                    Text(query['description']),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 6.0,
                      children: [
                        for (var tag in query['tags'])
                          Chip(
                            label: Text(
                              tag['name'],
                              style: TextStyle(fontSize: 11),
                            ),
                            backgroundColor: Colors.blue.shade100,
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          ),
                        Chip(
                          label: Text(
                            'Priority: ${query['priority']}',
                            style: TextStyle(fontSize: 11, color: Colors.white),
                          ),
                          backgroundColor: _getPriorityColor(query['priority']),
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        ),
                        Chip(
                          label: Text(
                            'Status: ${query['status']}',
                            style: TextStyle(fontSize: 11, color: Colors.white),
                          ),
                          backgroundColor: _getStatusColor(query['status']),
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        ),
                      ],
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Source: ${query['source']}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Created: ${_formatDate(query['created_at'])}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreateQueryScreen,
        child: Icon(Icons.add),
        foregroundColor: Colors.white,
        backgroundColor: Colors.blue.shade700,
      ),
    );
  }
}
