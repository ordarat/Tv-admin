import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/login_screen.dart';
import 'screens/pages/manage_channels.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyBHVhQFFOyup2eBTAKDMWZFB5In07wMXOg",
      authDomain: "ibrahimtv-c0d5d.firebaseapp.com",
      projectId: "ibrahimtv-c0d5d",
      storageBucket: "ibrahimtv-c0d5d.firebasestorage.app",
      messagingSenderId: "658751407366",
      appId: "1:658751407366:web:5b34e69a4fd4de78330a87",
      // دێڕی measurementId لێرەدا سڕدرایەوە چونکە کێشەی دروست دەکرد
    ),
  );

  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TV Admin Panel',
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return Directionality(textDirection: TextDirection.rtl, child: child!);
      },
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),
      home: FirebaseAuth.instance.currentUser == null 
          ? const LoginScreen() 
          : const ManageChannelsPage(),
    );
  }
}
