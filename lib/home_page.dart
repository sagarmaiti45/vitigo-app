import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shimmer/shimmer.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String fullName = '';
  List categories = [];
  List appointments = [];
  List specialists = [];
  int _currentImageIndex = 0;
  bool isLoading = true; // Add a loading state variable

  // Define the base URL for images
  final String baseImageUrl = 'https://vitigo.learnknowdigital.com';

  @override
  void initState() {
    super.initState();
    fetchUserData();
    fetchCategories();
    fetchAppointments();
    fetchSpecialists();
  }

  Future<void> fetchUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('bearer_token');
    final response = await http.get(
      Uri.parse('https://vitigo.learnknowdigital.com/api/user-info/'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        fullName = data['user']['full_name'];
        isLoading = false; // Set loading to false after fetching data
      });
    }
  }

  Future<void> fetchCategories() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('bearer_token');
    final response = await http.get(
      Uri.parse('https://vitigo.learnknowdigital.com/api/doctors/specializations/'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      setState(() {
        categories = json.decode(response.body);
      });
    }
  }

  Future<void> fetchAppointments() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('bearer_token');
    final response = await http.get(
      Uri.parse('https://vitigo.learnknowdigital.com/api/appointments/'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('Appointments Response: $data');  // Print the entire response for debugging

      if (data is List) {
        setState(() {
          appointments = data.take(3).toList();
        });
      } else {
        print('Error: Data is not a list');
      }
    } else {
      print('Failed to fetch appointments: ${response.statusCode}');
    }
  }

  Future<void> fetchSpecialists() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('bearer_token');
    final response = await http.get(
      Uri.parse('https://vitigo.learnknowdigital.com/api/doctors/'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        specialists = data['results'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with welcome message and notification icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    isLoading
                        ? shimmerEffect(width: 200, height: 24) // Shimmer effect for user name
                        : Text(
                      'Hello, $fullName',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: Icon(Icons.notifications, color: Colors.blue),
                      onPressed: () {
                        // Add notification functionality here
                      },
                    ),
                  ],
                ),

                SizedBox(height: 20),

                // Search box for doctors
                isLoading
                    ? shimmerEffect(width: double.infinity, height: 50)
                    : TextField(
                  decoration: InputDecoration(
                    hintText: 'Search for doctors',
                    prefixIcon: Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.blue.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                SizedBox(height: 20),

                // Categories section
                Text(
                  'Categories',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                isLoading
                    ? shimmerEffect(width: double.infinity, height: 50)
                    : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: categories
                        .map((category) => Container(
                      margin: EdgeInsets.only(right: 10),
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.category, color: Colors.blue),
                          Text(category['name']),
                        ],
                      ),
                    ))
                        .toList(),
                  ),
                ),

                SizedBox(height: 20),

                // Image Carousel
                isLoading
                    ? shimmerEffect(width: double.infinity, height: 200)
                    : CarouselSlider(
                  items: [
                    'https://picsum.photos/400/200',
                    'https://picsum.photos/400/200',
                    'https://picsum.photos/400/200',
                  ].map((url) => Container(
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(url, fit: BoxFit.cover),
                    ),
                  )).toList(),
                  options: CarouselOptions(
                    autoPlay: true,
                    aspectRatio: 4 / 2,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _currentImageIndex = index;
                      });
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) {
                    return Container(
                      width: 8,
                      height: 8,
                      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentImageIndex == index ? Colors.blue : Colors.grey,
                      ),
                    );
                  }),
                ),

                SizedBox(height: 20),

                // Upcoming Appointments section
                Text(
                  'Upcoming Appointments',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                isLoading
                    ? shimmerEffect(width: double.infinity, height: 50)
                    : Column(
                  children: appointments.map((appointment) {
                    return Container(
                      margin: EdgeInsets.only(bottom: 10),
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(appointment['doctor']['full_name']),
                          Text(appointment['date']),
                        ],
                      ),
                    );
                  }).toList(),
                ),

                SizedBox(height: 20),

                // Best Specialists section
                Text(
                  'Best Specialists',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                isLoading
                    ? shimmerEffect(width: double.infinity, height: 50)
                    : Column(
                  children: specialists.map((specialist) {
                    String? profilePicturePath = specialist['user']['profile_picture'];

                    // Construct the image URL conditionally
                    String? imageUrl = (profilePicturePath != null && !profilePicturePath.startsWith('http'))
                        ? baseImageUrl + profilePicturePath
                        : profilePicturePath;

                    return Container(
                      margin: EdgeInsets.only(bottom: 10),
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: imageUrl != null
                                ? NetworkImage(imageUrl)
                                : null,
                            child: imageUrl == null ? Icon(Icons.person) : null,
                          ),
                          SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${specialist['user']['first_name']} ${specialist['user']['last_name']}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(specialist['qualification']),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),

      // Floating Action Button for Booking Appointment
      // Floating Action Button for Booking Appointment
      // floatingActionButton: Container(
      //   margin: EdgeInsets.only(bottom: 20, right: 0), // Adjust margins as needed
      //   child: FloatingActionButton.extended(
      //     onPressed: () {
      //       // Navigate to the booking appointment page or show a dialog
      //       // Navigator.push(context, MaterialPageRoute(builder: (context) => BookingAppointmentPage()));
      //     },
      //     backgroundColor: Colors.blue,
      //     foregroundColor: Colors.white,
      //     icon: Icon(Icons.add),
      //     label: Text('Book Appointment'),
      //     tooltip: 'Book Appointment',
      //   ),
      // ),

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // Function to create shimmer effect
  Widget shimmerEffect({double? width, double? height}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        color: Colors.white,
      ),
    );
  }
}
