import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:task_manager/login_screen.dart';
import 'package:task_manager/task_screen.dart';
import 'task_item.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main()async {
  WidgetsFlutterBinding.ensureInitialized(); //ensuring firebase is up and running
  await Hive.initFlutter(); //intialize hive
  Hive.registerAdapter(TaskItemAdapter());  
  await Hive.openBox<TaskItem>('tasks');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme:ThemeData(
        useMaterial3:true,
        brightness:Brightness.dark,
        textTheme: GoogleFonts.poppinsTextTheme(
          ThemeData(brightness:Brightness.dark).textTheme,
        ),
        colorScheme: ColorScheme.fromSeed( 
          seedColor: const Color(0xFF2E7D32),
          brightness: Brightness.dark,
          primary: const Color(0xFF4CAF50),
          secondary: const Color(0xFFFFC107), 
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1B5E20),
          centerTitle: true,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF1E1E1E),
          surfaceTintColor: Colors.green,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF4CAF50),
          foregroundColor: Colors.white,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.05),
          labelStyle: const TextStyle(color: Colors.white70),
          hintStyle: const TextStyle(color: Colors.white38),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF4CAF50)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
          ),
        ),
      ),
      
      
      home:StreamBuilder<User?>(stream: FirebaseAuth.instance.authStateChanges(), builder: (context,asyncSnapshot){ //live loading enabled by streambuilder
        if(asyncSnapshot.connectionState==ConnectionState.waiting){ //if still connecting
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(),) //show a loading animation
          );
        }
        if(asyncSnapshot.hasData){ //if we log in
          return const TaskScreen(); //show the task screen
        }
        return const LoginScreen(); //else just show the login screen by default
      })
    );
  }
}

