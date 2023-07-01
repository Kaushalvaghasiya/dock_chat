import 'package:dock_chat/Screens/User/LoginScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../Screens/Search.dart';

class Authenticate extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Authenticate({super.key});

  @override
  Widget build(BuildContext context) {
    if (_auth.currentUser!= null){
      return const Search();
    }else{
      return const LoginScreen();
    }
  }
}