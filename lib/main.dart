import 'package:flutter/material.dart';
import 'first_screen.dart'; // import relative path ให้ตรงกับ lib/
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

//step 4: Connect to Firebase
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,);
  runApp(const MaterialApp(home: FirstScreen(), debugShowCheckedModeBanner: false,));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FirstScreen(),
    );
  }
}