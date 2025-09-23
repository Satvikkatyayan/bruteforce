import 'package:flutter/material.dart';
import 'package:sih2025/profile.dart';
// Assuming your task screen is in a file named 'task.dart'
import 'package:sih2025/task.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Helper method to show a dialog when a hotspot is tapped
  void _showHotspotDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: const Text('Learn More'),
              onPressed: () {
                // Navigate to the task screen when 'Learn More' is pressed
                Navigator.of(context).pop(); // Close the dialog first
                Navigator.push(context, MaterialPageRoute(builder: (context) => tasks(topic: "water preservation")));
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Start Task', style: TextStyle(color: Colors.white)),
              onPressed: () {
                // Navigate to the task screen when 'Start Task' is pressed
                Navigator.of(context).pop(); // Close the dialog first
                Navigator.push(context, MaterialPageRoute(builder: (context) => const tasks(topic: "recycling")));
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Background Image
          // Replace 'assets/images/world_map.png' with your actual image path
          Image.asset(
            'assets/images/homebackground.png',
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
            alignment: Alignment.center,
          ),

          // 2. Top Bar UI
          _buildTopBar(context),

          // 3. Invisible Hotspots over the background image symbols.
          // These are positioned to cover the symbols on your map image.
          Positioned(
            top: MediaQuery.of(context).size.height * 0.55,
            left: MediaQuery.of(context).size.width * 0.75,
            child: _buildHotspot(
                size: 60,
                icon: Icons.forest_sharp, // Use a Flutter icon
                iconColor: Colors.greenAccent, // Customize icon color
                containerColor: Colors.black.withOpacity(0.4), // Make background semi-transparent
                onTap: () => _showHotspotDialog(
                    context,
                    'Recycling Challenge',
                    'Learn about the importance of recycling and start a task to earn points.'
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.20,
            left: MediaQuery.of(context).size.width * 0.10,
            child: _buildHotspot(
              size: 60,
              icon: Icons.recycling, // Use a Flutter icon
              iconColor: Colors.greenAccent, // Customize icon color
              containerColor: Colors.black.withOpacity(0.4), // Make background semi-transparent
              onTap: () => _showHotspotDialog(
                  context,
                  'Recycling Challenge',
                  'Learn about the importance of recycling and start a task to earn points.'
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.75,
            left: MediaQuery.of(context).size.width * 0.75,
            child: _buildHotspot(
              size: 60,
              icon: Icons.water_drop, // Use a Flutter icon
              iconColor: Colors.greenAccent, // Customize icon color
              containerColor: Colors.black.withOpacity(0.4), // Make background semi-transparent
              onTap: () => _showHotspotDialog(
                  context,
                  'Recycling Challenge',
                  'Learn about the importance of recycling and start a task to earn points.'
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.45,
            left: MediaQuery.of(context).size.width * 0.35,
            child: _buildHotspot(
              size: 60,
              icon: Icons.spa, // Use a Flutter icon
              iconColor: Colors.greenAccent, // Customize icon color
              containerColor: Colors.black.withOpacity(0.4), // Make background semi-transparent
              onTap: () => _showHotspotDialog(
                  context,
                  'Recycling Challenge',
                  'Learn about the importance of recycling and start a task to earn points.'
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.75,
            left: MediaQuery.of(context).size.width * 0.20,
            child: _buildHotspot(
              size: 60,
              icon: Icons.nature, // Use a Flutter icon
              iconColor: Colors.greenAccent, // Customize icon color
              containerColor: Colors.black.withOpacity(0.4), // Make background semi-transparent
              onTap: () => _showHotspotDialog(
                  context,
                  'Recycling Challenge',
                  'Learn about the importance of recycling and start a task to earn points.'
              ),
            ),
          ),

        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10.0, // Adjust for status bar
      left: 16.0,
      right: 16.0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(30.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 2,
              )
            ]
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                // Replace with your avatar image
                const CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage('assets/images/avatar.png'),
                ),
                const SizedBox(width: 12),
                const Text(
                  '2100 Leaves',
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                // Navigate to My Garden
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[400],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10)
              ),
              child: const Text(
                'My Garden',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // This widget creates an invisible tappable area.
  Widget _buildHotspot({
    required VoidCallback onTap,
    required double size,
    required IconData icon, // Add an icon parameter
    Color iconColor = Colors.white, // Default icon color
    Color containerColor = Colors.transparent, // Default background for the icon
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.translucent, // Ensures the entire area is tappable
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: containerColor, // A semi-transparent background for visibility
          shape: BoxShape.circle, // Makes the container round
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: size * 0.6, // Icon takes up 60% of the container size
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: Colors.green[600],
      unselectedItemColor: Colors.grey[400],
      showUnselectedLabels: true,
      currentIndex: 0, // Set the current index for the 'Home' tab
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.check_circle_outline),
          label: 'Tasks',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people_outline),
          label: 'Community',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profile',
        ),
      ],
      onTap: (index) {
        // Handle navigation based on the selected tab index
        switch (index) {
          case 0: // Home - already on this page
            break;
          case 1: // Tasks
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(builder: (context) => const tasks(topic: "all tasks")),
            // );
            break;
          case 2: // Community
          // Navigate to community page
          // Example: Navigator.push(context, MaterialPageRoute(builder: (context) => CommunityPage()));
            break;
          case 3: // Profile
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfilePage()),
            );
            break;
        }
      },
    );
  }

}

