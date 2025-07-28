import 'package:flutter/material.dart';
import 'profile_screen.dart';
import 'monitoring_screen.dart';
import 'about_screen.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  int _currentIndex = 1; // Start with monitoring tab
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // List of screens
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();

    // Initialize screens
    _screens = [
      ProfileScreen(),
      MonitoringScreen(),
      AboutScreen(),
    ];

    // Setup animation controller
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });

      // Reset and play animation
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Color(0xFF2196F3),
        unselectedItemColor: Colors.grey[600],
        selectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
        ),
        elevation: 0,
        items: [
          BottomNavigationBarItem(
            icon: AnimatedContainer(
              duration: Duration(milliseconds: 200),
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: _currentIndex == 0
                    ? Color(0xFF2196F3).withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _currentIndex == 0 ? Icons.person : Icons.person_outline,
                size: 24,
              ),
            ),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: AnimatedContainer(
              duration: Duration(milliseconds: 200),
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: _currentIndex == 1
                    ? Color(0xFF2196F3).withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _currentIndex == 1 ? Icons.dashboard : Icons.dashboard_outlined,
                size: 24,
              ),
            ),
            label: 'Monitoring',
          ),
          BottomNavigationBarItem(
            icon: AnimatedContainer(
              duration: Duration(milliseconds: 200),
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: _currentIndex == 2
                    ? Color(0xFF2196F3).withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _currentIndex == 2 ? Icons.info : Icons.info_outline,
                size: 24,
              ),
            ),
            label: 'About',
          ),
        ],
      ),
    );
  }
}
