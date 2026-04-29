import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


import 'package:fast_complaint_portal/screens/login_screen.dart';
import 'package:fast_complaint_portal/screens/register_screen.dart';
import 'package:fast_complaint_portal/screens/student_home_screen.dart';
import 'package:fast_complaint_portal/screens/admin_dashboard_screen.dart';
import 'package:fast_complaint_portal/screens/audit_log_screen.dart';
import 'package:fast_complaint_portal/screens/complaint_detail_screen.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize Supabase
  await Supabase.initialize(
    url: 'https://dnbrfgbujzteedxvkvhv.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRuYnJmZ2J1anp0ZWVkeHZrdmh2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzY5MjcyODUsImV4cCI6MjA5MjUwMzI4NX0.Qwct1A2VIaHqxKcLwKnMWpf6xWTbGARiXIGj7o2tVM8',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FAST Complaint Portal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
      
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF003366),
          primary: const Color(0xFF003366),
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF003366),
          foregroundColor: Colors.white, 
          elevation: 0,
        ),
      ),

      // 2. Initial Screen
      initialRoute: '/login',

      // 3. Routing Map
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/student_home': (context) => const StudentHomeScreen(),
        '/admin_dashboard': (context) => const AdminDashboardScreen(),
        '/audit_log': (context) => const AuditLogScreen(),
      },

      // 4. Handle dynamic routing (for Complaint Details)
      onGenerateRoute: (settings) {
        if (settings.name == '/complaint_detail') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => ComplaintDetailScreen(complaint: args),
          );
        }
        return null;
      },
    );
  }
}
