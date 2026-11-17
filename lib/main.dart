import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:college_campus/firebase_options.dart';
import 'package:college_campus/screens/role_selection_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const CollegeConnectApp());
}

class CollegeConnectApp extends StatelessWidget {
  const CollegeConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'College Connect',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const RoleSelectionScreen(),
    );
  }
}
