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
      Uri.parse(
          'https://vitigo.learnknowdigital.com/api/doctors/specializations/'),
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
      print(
          'Appointments Response: $data'); // Print the entire response for debugging

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
    // Define a modern color palette
    final Color primaryColor = Colors.blue.shade800;
    final Color accentColor = Colors.blue.shade200;
    final Color backgroundColor = Colors.grey.shade100;
    final TextStyle headerStyle = TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: primaryColor,
    );
    final TextStyle sectionTitleStyle = TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: primaryColor,
    );
    final TextStyle itemTextStyle = TextStyle(
      fontSize: 16,
      color: Colors.grey.shade800,
    );

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with welcome message and notification icon with badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    isLoading
                        ? shimmerEffect(
                            width: 200,
                            height: 24,
                            borderRadius: BorderRadius.circular(12),
                          ) // Shimmer effect for user name
                        : Text(
                            'Hello, $fullName',
                            style: headerStyle,
                          ),
                    Stack(
                      children: [
                        IconButton(
                          icon: Icon(Icons.notifications, color: primaryColor),
                          onPressed: () {
                            // Add notification functionality here
                          },
                        ),
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.redAccent,
                              shape: BoxShape.circle,
                            ),
                            constraints: BoxConstraints(
                              minWidth: 12,
                              minHeight: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: 20),

                // Search box for doctors
                isLoading
                    ? shimmerEffect(
                        width: double.infinity,
                        height: 50,
                        borderRadius: BorderRadius.circular(12),
                      )
                    : TextField(
                        decoration: InputDecoration(
                          hintText: 'Search for doctors',
                          prefixIcon: Icon(Icons.search, color: primaryColor),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.filter_list, color: primaryColor),
                            onPressed: () {
                              // Add filter functionality here
                              print("Filter icon pressed");
                            },
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(vertical: 15),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                SizedBox(height: 20),

                // Categories section
                Text(
                  'Categories',
                  style: sectionTitleStyle,
                ),
                SizedBox(height: 10),
                isLoading
                    ? shimmerEffect(
                        width: double.infinity,
                        height: 80,
                        borderRadius: BorderRadius.circular(12),
                      )
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: categories.map((category) {
                            String iconPath =
                                'assets/icons/pharmacy.png'; // Default icon path
                            // Here you could use different icons based on category if needed
                            return Container(
                              margin: EdgeInsets.only(right: 12),
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: accentColor,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset(
                                    iconPath,
                                    width: 30,
                                    height: 30,
                                    color: primaryColor, // Optional: tint color
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    category['name'],
                                    style: itemTextStyle,
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                SizedBox(height: 20),

                // Banner carousel section
                isLoading
                    ? shimmerEffect(
                  width: double.infinity,
                  height: 200,
                  borderRadius: BorderRadius.circular(12),
                )
                    : CarouselSlider(
                  items: [
                    'assets/banner_1.png',
                    'assets/banner_1.png',
                    'assets/banner_1.png',
                  ]
                      .map((assetPath) => Container(
                    margin: EdgeInsets.symmetric(horizontal: 5), // Small margin between images
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        assetPath,
                        fit: BoxFit.cover, // Use fitWidth to ensure the image scales proportionally
                        width: double.infinity, // Ensures full width of container
                        height: 200, // Fixed height for the container
                      ),
                    ),
                  ))
                      .toList(),
                  options: CarouselOptions(
                    autoPlay: true,
                    aspectRatio: 2, // Maintain 400x200 ratio
                    enlargeCenterPage: true,
                    viewportFraction: 0.8, // Increase view of adjacent images
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
                      width: 8,  // Smaller dot size
                      height: 8,
                      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 3), // Adjust spacing
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentImageIndex == index
                            ? primaryColor
                            : Colors.grey.shade400,
                      ),
                    );
                  }),
                ),

                SizedBox(height: 20),

                // Upcoming Appointments section
                Row(
                  children: [
                    Text(
                      'Upcoming Appointments',
                      style: sectionTitleStyle,
                    ),
                    SizedBox(
                        width: 10), // Increased spacing between text and dot
                    Container(
                      width: 10, // Size of the dot
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors
                            .green, // Green color to indicate availability
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                isLoading
                    ? Column(
                        children: List.generate(
                          3,
                          (index) => Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: shimmerEffect(
                              width: double.infinity,
                              height: 50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      )
                    : Column(
                        children: appointments.isNotEmpty
                            ? appointments.map((appointment) {
                                return Container(
                                  margin: EdgeInsets.only(
                                      bottom: 8), // Slim spacing
                                  padding: EdgeInsets.symmetric(
                                      vertical: 8,
                                      horizontal: 12), // Slim padding
                                  decoration: BoxDecoration(
                                    color: Colors.blue
                                        .shade100, // Single consistent background color
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.15),
                                        spreadRadius: 2,
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      // Circle avatar with initials or icon
                                      CircleAvatar(
                                        radius:
                                            20, // Smaller avatar for slim design
                                        backgroundColor:
                                            primaryColor.withOpacity(0.2),
                                        child: Text(
                                          appointment['doctor']['full_name'][
                                              0], // First initial of the doctor's name
                                          style: TextStyle(
                                            color: primaryColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                          width:
                                              10), // Reduced spacing between avatar and text

                                      // Appointment details
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              appointment['doctor']
                                                  ['full_name'],
                                              style: itemTextStyle.copyWith(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14, // Slimmer font
                                                color: Colors
                                                    .black87, // Darker color for readability
                                              ),
                                            ),
                                            SizedBox(
                                                height:
                                                    2), // Reduced vertical space
                                            Row(
                                              children: [
                                                Icon(Icons.calendar_today,
                                                    size: 14,
                                                    color:
                                                        primaryColor), // Smaller icon
                                                SizedBox(width: 4),
                                                Text(
                                                  appointment['date'],
                                                  style: itemTextStyle.copyWith(
                                                    color: Colors
                                                        .black54, // Muted color for date text
                                                    fontSize:
                                                        12, // Smaller font for date
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Action icon
                                      IconButton(
                                        icon: Icon(Icons.more_vert,
                                            color: primaryColor,
                                            size:
                                                18), // Smaller icon for slim design
                                        onPressed: () {
                                          // Add action (e.g., view appointment details)
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              }).toList()
                            : [
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    "No upcoming appointments",
                                    style: itemTextStyle.copyWith(
                                        color: Colors.grey),
                                  ),
                                ),
                              ],
                      ),

                SizedBox(height: 20),

                // Best Specialists section
                Text(
                  'Best Specialists',
                  style: sectionTitleStyle,
                ),
                SizedBox(height: 10),
                isLoading
                    ? Column(
                        children: List.generate(
                          3,
                          (index) => Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: shimmerEffect(
                              width: double.infinity,
                              height: 80,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      )
                    : Column(
                        children: specialists.map((specialist) {
                          String? profilePicturePath =
                              specialist['user']['profile_picture'];

                          // Construct the image URL conditionally
                          String? imageUrl = (profilePicturePath != null &&
                                  !profilePicturePath.startsWith('http'))
                              ? baseImageUrl + profilePicturePath
                              : profilePicturePath;

                          return Container(
                            margin: EdgeInsets.only(bottom: 12),
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 3,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundImage: imageUrl != null
                                      ? NetworkImage(imageUrl)
                                      : null,
                                  backgroundColor: accentColor,
                                  child: imageUrl == null
                                      ? Icon(Icons.person,
                                          color: Colors.white, size: 30)
                                      : null,
                                ),
                                SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${specialist['user']['first_name']} ${specialist['user']['last_name']}',
                                      style: itemTextStyle.copyWith(
                                          fontWeight: FontWeight.w600),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      specialist['qualification'],
                                      style: itemTextStyle.copyWith(
                                          color: Colors.grey.shade600),
                                    ),
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

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}


// Function to create shimmer effect with border radius
Widget shimmerEffect(
    {double? width, double? height, BorderRadius? borderRadius}) {
  return Shimmer.fromColors(
    baseColor: Colors.grey.shade300,
    highlightColor: Colors.grey.shade100,
    child: Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: borderRadius ?? BorderRadius.circular(8),
      ),
    ),
  );
}
