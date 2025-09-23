import 'package:flutter/material.dart';
// Assuming your task screen is in a file named 'task.dart'
import 'package:sih2025/task.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // --- UPDATED HELPER METHOD ---
  // Now accepts a 'topic' to pass to the tasks screen
  void _showHotspotDialog(BuildContext context, String title, String content, String topic) {
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
                // This could navigate to a different learning screen in the future
                Navigator.of(context).pop(); // Close the dialog first
                Navigator.push(context, MaterialPageRoute(builder: (context) => tasks(topic: topic)));
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
                // Navigate to the task screen, now with the correct topic
                Navigator.of(context).pop(); // Close the dialog first
                Navigator.push(context, MaterialPageRoute(builder: (context) => tasks(topic: topic)));
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
          Image.asset(
            'assets/images/homebackground.png',
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
            alignment: Alignment.center,
          ),

          // 2. Top Bar UI
          _buildTopBar(context),

          // --- 3. UPDATED Hotspots ---
          // Each hotspot now has a unique title, content, and topic
          Positioned(
            top: MediaQuery.of(context).size.height * 0.20,
            left: MediaQuery.of(context).size.width * 0.10,
            child: _buildHotspot(
              size: 60,
              icon: Icons.recycling,
              onTap: () => _showHotspotDialog(
                context,
                'Recycling Challenge',
                'Learn about the importance of recycling and start a task to earn points.',
                'Recycling and Waste Management', // Topic for Gemini
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.45,
            left: MediaQuery.of(context).size.width * 0.35,
            child: _buildHotspot(
              size: 60,
              icon: Icons.eco, // Using 'eco' for sustainable dev
              onTap: () => _showHotspotDialog(
                context,
                'Sustainable Development',
                'Explore the principles of sustainable development for a better future.',
                'Sustainable Development Goals', // Topic for Gemini
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.75,
            left: MediaQuery.of(context).size.width * 0.20,
            child: _buildHotspot(
              size: 60,
              icon: Icons.park, // Using 'park' for green spaces
              onTap: () => _showHotspotDialog(
                context,
                'Protect Green Spaces',
                'Discover the role of parks and forests in our ecosystem and how you can help.',
                'Protecting Green Spaces and National Parks', // Topic for Gemini
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.55,
            left: MediaQuery.of(context).size.width * 0.75,
            child: _buildHotspot(
              size: 60,
              icon: Icons.forest_sharp,
              onTap: () => _showHotspotDialog(
                context,
                'Biodiversity',
                'Learn about the variety of life on Earth and why it is so important to protect.',
                'Biodiversity and Ecosystems', // Topic for Gemini
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.75,
            left: MediaQuery.of(context).size.width * 0.75,
            child: _buildHotspot(
              size: 60,
              icon: Icons.water_drop,
              onTap: () => _showHotspotDialog(
                context,
                'Water Conservation',
                'Discover ways to save water in your daily life. Ready to take the challenge?',
                'Water Conservation', // Topic for Gemini
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
                  '2100 Leaves', // This is a placeholder for now
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

  // This widget creates the tappable icon hotspot
  Widget _buildHotspot({
    required VoidCallback onTap,
    required double size,
    required IconData icon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5), // Semi-transparent background for better visibility
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Colors.greenAccent, // A bright color for the icon
          size: size * 0.6,
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
      currentIndex: 0,
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
        // Handle navigation to other screens here
      },
    );
  }
}



