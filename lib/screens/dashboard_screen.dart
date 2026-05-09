import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';
import 'pages/manage_channels.dart'; // ئەمە لە هەنگاوی داهاتوو دروست دەکەین

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('پەنجەرەی بەڕێوەبەر'),
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(child: Text(FirebaseAuth.instance.currentUser?.email ?? '')),
          ),
          IconButton(icon: const Icon(Icons.logout, color: Colors.redAccent), onPressed: _logout),
        ],
      ),
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 250,
            color: const Color(0xFF1E1E1E),
            child: ListView(
              children: [
                _buildNavItem(Icons.tv, 'بەڕێوەبردنی کەناڵەکان', 0),
                _buildNavItem(Icons.image, 'سڵایدەری سەرەکی', 1),
                _buildNavItem(Icons.settings, 'ڕێکخستنەکان', 2),
              ],
            ),
          ),
          // Main Content
          Expanded(
            child: Container(
              color: const Color(0xFF121212),
              padding: const EdgeInsets.all(24.0),
              child: _getContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String title, int index) {
    bool isActive = _selectedIndex == index;
    return ListTile(
      leading: Icon(icon, color: isActive ? Colors.blueAccent : Colors.grey),
      title: Text(title, style: TextStyle(color: isActive ? Colors.white : Colors.grey)),
      tileColor: isActive ? Colors.blueAccent.withOpacity(0.1) : Colors.transparent,
      onTap: () => setState(() => _selectedIndex = index),
    );
  }

  Widget _getContent() {
    switch (_selectedIndex) {
      case 0:
        return const ManageChannelsPage(); // ئەمە شاشەی زیادکردنی کەناڵە
      case 1:
        return const Center(child: Text('بەشی سڵایدەر لێرە دروست دەکرێت'));
      default:
        return const Center(child: Text('ڕێکخستنەکان'));
    }
  }
}
