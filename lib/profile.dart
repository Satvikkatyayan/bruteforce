import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  bool _isLoading = true;
  bool _isEditing = false;
  Map<String, dynamic> _userData = {};

  // Color palette
  final Color lightBackground = const Color(0xFFF8F6F1);
  final Color primaryGreen = const Color(0xFF4A7C59);
  final Color secondaryGreen = const Color(0xFFA9D1A7);
  final Color lightSecondaryGreen = const Color(0xFFC6E7C4);
  final Color darkGreen = const Color(0xFF3B5B41);
  final Color lightGray = const Color(0xFFD9D9D9);
  final Color darkGray = const Color(0xFF2C2C2C);

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      User? user = _auth.currentUser;
      if (user != null) {
        // Set data from Firebase Auth
        _nameController.text = user.displayName ?? '';

        // Try to load additional data from Firestore
        final docSnapshot = await _firestore.collection('users').doc(user.uid).get();

        if (docSnapshot.exists) {
          setState(() {
            _userData = docSnapshot.data() ?? {};
            _phoneController.text = _userData['phone'] ?? '';
            _addressController.text = _userData['address'] ?? '';
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading profile: $e")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      User? user = _auth.currentUser;
      if (user != null) {
        // Update name in Firebase Auth
        if (_nameController.text.isNotEmpty) {
          await user.updateDisplayName(_nameController.text.trim());
        }

        // Update additional data in Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'name': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'address': _addressController.text.trim(),
          'email': user.email,
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Profile updated successfully"),
            backgroundColor: primaryGreen,
          ),
        );

        setState(() {
          _isEditing = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating profile: $e")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signOut() async {
    try {
      await _auth.signOut();
      if (context.mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error signing out: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;

    return Scaffold(
      backgroundColor: lightBackground,
      appBar: AppBar(
        backgroundColor: lightBackground,
        foregroundColor: darkGreen,
        elevation: 0,
        title: Text(
          'My Profile',
          style: TextStyle(
            color: darkGreen,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          _isEditing
              ? IconButton(
            icon: Icon(Icons.save, color: primaryGreen),
            onPressed: _isLoading ? null : _saveProfile,
          )
              : IconButton(
            icon: Icon(Icons.edit, color: primaryGreen),
            onPressed: () => setState(() => _isEditing = true),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: primaryGreen))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Image
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: lightSecondaryGreen,
                border: Border.all(color: primaryGreen, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: darkGreen.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
                image: user?.photoURL != null
                    ? DecorationImage(
                  image: NetworkImage(user!.photoURL!),
                  fit: BoxFit.cover,
                )
                    : null,
              ),
              child: user?.photoURL == null
                  ? Icon(Icons.person, size: 70, color: darkGreen)
                  : null,
            ),

            const SizedBox(height: 24),

            // User information fields
            _buildProfileField(
              label: 'Name',
              controller: _nameController,
              icon: Icons.person_outline,
              isEditing: _isEditing,
            ),

            _buildProfileField(
              label: 'Email',
              value: user?.email ?? 'Not available',
              icon: Icons.email_outlined,
              isEditing: false, // Email cannot be edited
            ),

            _buildProfileField(
              label: 'Phone Number',
              controller: _phoneController,
              icon: Icons.phone_outlined,
              isEditing: _isEditing,
            ),

            _buildProfileField(
              label: 'Address',
              controller: _addressController,
              icon: Icons.home_outlined,
              isEditing: _isEditing,
            ),

            const SizedBox(height: 40),

            // Sign out button
            ElevatedButton.icon(
              onPressed: _signOut,
              icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text(
                'Sign Out',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                minimumSize: const Size(200, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 2,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: primaryGreen,
        unselectedItemColor: lightGray,
        currentIndex: 3, // Profile tab
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
          if (index != 3) { // If not already on Profile page
            Navigator.pop(context); // Go back to previous screen
          }
        },
      ),
    );
  }

  Widget _buildProfileField({
    required String label,
    String? value,
    TextEditingController? controller,
    required IconData icon,
    required bool isEditing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: isEditing && controller != null
          ? Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: lightGray),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: controller,
          style: TextStyle(
            color: darkGray,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(color: primaryGreen),
            prefixIcon: Icon(icon, color: primaryGreen),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 16,
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      )
          : Card(
        elevation: 1,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: lightGray, width: 0.5),
        ),
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: lightSecondaryGreen,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: darkGreen, size: 24),
          ),
          title: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: primaryGreen,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            controller != null ? controller.text : (value ?? 'Not available'),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: darkGray,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
    );
  }
}
