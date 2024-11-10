import 'package:flutter/material.dart';
import 'appointments_screen.dart';
import 'user_info_screen.dart';
import 'home_page.dart';
import 'queries_screen.dart';
import 'menu_screen.dart';  // Import the MenuScreen

class DashboardScreen extends StatefulWidget {
  final int? initialTabIndex;

  DashboardScreen({this.initialTabIndex});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final PageController _pageController;
  int _selectedIndex = 2;

  final List<String> _tabLabels = ["Appoints", "Profile", "Home", "Queries", "Menu"];  // Added "Menu"
  final List<IconData> _tabIcons = [
    Icons.event,
    Icons.person,
    Icons.home,
    Icons.question_answer,
    Icons.menu,  // Added menu icon
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTabIndex ?? 2;
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade700, Colors.blue.shade400],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          children: [
            AppointmentsScreen(),
            UserInfoScreen(),
            HomePage(),
            QueriesScreen(),
            MenuScreen(),  // MenuScreen added as a PageView child
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.blue.shade800,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: BottomNavigationBar(
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white.withOpacity(0.7),
          backgroundColor: Colors.blue.shade800,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          elevation: 8.0,
          type: BottomNavigationBarType.fixed,
          items: List.generate(5, (index) {  // Updated item count to 5
            return BottomNavigationBarItem(
              icon: Icon(
                _tabIcons[index],
                size: 28,
              ),
              label: _tabLabels[index],
            );
          }),
        ),
      ),
    );
  }
}
