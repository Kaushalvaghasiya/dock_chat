import 'package:dock_chat/Screens/Search.dart';
import 'package:dock_chat/Screens/User/CreateAccount.dart';
import 'package:dock_chat/Screens/User/LoginScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp() );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.grey.shade900,
        primaryColorDark: Colors.blue.shade300,
        colorScheme: const ColorScheme.dark(primary: Colors.blue),
        dividerColor: const Color.fromARGB(255, 104, 104, 104),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: 'login',
      routes: {
        'login': (context) => const LoginScreen(),
        'register': (context) => const CreateAccount(),
        'home': (context) => const Search(),
      }
    );
    // MaterialApp(
    //   title: 'Dock Chat',
    //   theme: ThemeData(
    //     colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
    //     useMaterial3: true,
    //   ),
    //   debugShowCheckedModeBanner: false,
    //   home: Welcome(),
    // );
  }
}

