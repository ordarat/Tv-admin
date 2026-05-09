import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/pages/manage_channels.dart'; // دڵنیابە ئەم ڕێڕەوە ڕاستە بەپێی فایلەکانت

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // لێرەدا فایەربەیسمان بە دەستی بەستۆتەوە بۆ ئەوەی کێشەی نەبوونی فایلەکە دروست نەبێت
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyBHVhQFFOyup2eBTAKDMWZFB5In07wMXOg",
      authDomain: "ibrahimtv-c0d5d.firebaseapp.com",
      projectId: "ibrahimtv-c0d5d",
      storageBucket: "ibrahimtv-c0d5d.firebasestorage.app",
      messagingSenderId: "658751407366",
      appId: "1:658751407366:web:5b34e69a4fd4de78330a87",
      measurementId: "G-JMRKFQHLQP",
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
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),
      home: const ManageChannelsPage(),
    );
  }
}
