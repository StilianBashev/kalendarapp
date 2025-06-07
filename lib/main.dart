import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'navigation_screen.dart';
import 'event_form_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginScreen(),
      routes: {
        '/login': (c) => LoginScreen(),
        '/register': (c) => RegisterScreen(),
        '/home': (c) => MainNavigationScreen(),
        '/add_event': (c) {
          var a = ModalRoute.of(c)?.settings.arguments as Map?;
          return EventFormScreen(
            eventId: a?['eventId'],
            existingData: a?['existingData'],
          );
        },
      },
    );
  }
}
