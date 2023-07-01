import 'package:dock_chat/Screens/User/CreateAccount.dart';
import 'package:dock_chat/Screens/User/LoginScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../Screens/Search.dart';

class Welcome extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Welcome({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    if (_auth.currentUser!= null){
      return const Search();
    }else{
      return Scaffold(
        backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
        body: Column(
          children: [
            SizedBox(
              height: size.height / 10,
            ), // sizedBox
            Container(
              height: size.height / 3,
              width: size.width,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    'https://firebasestorage.googleapis.com/v0/b/dock-chat-fbace.appspot.com/o/43013.jpg?alt=media&token=47b6571c-9ec7-4aec-bf89-f868d1578e53'
                  ),
                fit: BoxFit.cover
                ),
              ),
            ),
            SizedBox(
            height: size.height / 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Welcome To ",
                  style: TextStyle(
                      fontSize: size.width / 15, fontWeight: FontWeight.w500),
                ),
                Text(
                  "Dock Chat",
                  style: TextStyle(
                      fontSize: size.width / 11, fontWeight: FontWeight.w500, color: const Color.fromARGB(255, 112, 119, 255),),
                ),
                Text(
                  "..",
                  style: TextStyle(
                      fontSize: size.width / 11, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            SizedBox(
              height: size.height / 20,
            ),
            Text(
              "Chat App a new way to connect",
              style: TextStyle(
                fontSize: size.width / 20,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              "With People.",
              style: TextStyle(
                fontSize: size.width / 20,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(
              height: size.height / 20,
            ),
            TextButton(
              onPressed: () => {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const CreateAccount(),
                ))
              },
              child: Material(
                elevation: 8,
                color: const Color.fromARGB(255, 112, 119, 255),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  alignment: Alignment.center,
                  height: size.height / 13,
                  width: size.width / 1.2,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "Create Account",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: size.width / 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const LoginScreen(),
              )),
              child: Material(
                elevation: 8,
                color: const Color.fromARGB(255, 95, 96, 110),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  alignment: Alignment.center,
                  height: size.height / 13,
                  width: size.width / 1.2,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "Login",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: size.width / 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}