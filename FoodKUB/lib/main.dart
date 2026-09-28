import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';
import 'main_screen.dart'; // 🟢 เปลี่ยนการ Import มาที่หน้า MainScreen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FoodKUB',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // ระหว่างรอโหลด
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator(color: Colors.green)),
            );
          }

          // 🟢 ถ้าเคย Login แล้ว ให้ไปหน้าเลือกรา้นค้า (MainScreen)
          if (snapshot.hasData) {
            return  MainScreen();
          }

          // 🔴 ถ้ายังไม่ได้ Login ให้ไปหน้า Login
          return const LoginScreen();
        },
      ),
    );
  }
}