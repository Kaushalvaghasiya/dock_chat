import 'package:dock_chat/Screens/User/CreateAccount.dart';
import 'package:dock_chat/Methods.dart';
import 'package:flutter/material.dart';

import '../Search.dart';

class LoginScreen extends StatefulWidget{
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _uname = TextEditingController ();
  final TextEditingController _pass = TextEditingController ();
  bool isLoading=false;
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body:isLoading
          ? Center(
              child: SizedBox(
                height: size.height / 20,
                width: size.height / 20,
                child: const CircularProgressIndicator(),
              ),
            )
          : SingleChildScrollView(
        child: Column(children: [
            SizedBox(
              height: size.height/20,
            ),
            SizedBox(
              height: size.height / 50,
            ),
            Container(
              alignment: Alignment.centerLeft,
              width: size.width / 1.3,
              child: const Text(
                "Welcome to Dock Chat",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              width: size.width / 1.3,
              child: const Text(
                "Sign In to continue!",
                style: TextStyle(
                  color: Colors.grey, fontSize: 25, fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(
              height: size.height / 10,
            ),
            Container(
              width: size.width,
              alignment: Alignment.center,
              child:field(size, "UserName",Icons.account_box_rounded, _uname),
            ),
            SizedBox(
              height: size.height / 50,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 18.0),
              child: Container(
                width: size.width,
                alignment: Alignment.center,
                child:field(size, "Password",Icons.lock_rounded, _pass),
              ),
            ),
            SizedBox(
              height: size.height / 20,
            ),
            customButton(size),
            SizedBox(
              height: size.height / 40,
            ),
            GestureDetector(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CreateAccount())),
              child: const Text("Create Account", style: TextStyle(color: Colors.deepPurple, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget customButton(Size size){
    return TextButton(
      onPressed: () {
        if (_uname.text.isNotEmpty && _pass.text.isNotEmpty){
          setState(() {
              isLoading=true;
            });
          logIn(_uname.text, _pass.text) .then ((user) {
            if (user != null) {
              print("Login Sucessfull");
              Navigator.pushReplacement(context,MaterialPageRoute(builder: (_) => const Search()));
            } else{
                print("Login Failed");
            }
            setState(() {
              isLoading = false;
            });
          });
        }else{
          print("Please Enter Fields");
        }
      },
      child: Container(
        height: size.height / 14, 
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.deepPurpleAccent,
        ),
        alignment: Alignment.center,
        width: size.width / 1.2,
        child: const Text(
          "Login", style: TextStyle(
            color: Colors.white, 
            fontSize : 18,
            fontWeight: FontWeight.bold
            ),
          ),
      ),
    );
  }

  Widget field(Size size, String hintText, IconData icon, TextEditingController cont) {
    return SizedBox(
      height: size.height / 15, 
      width: size.width / 1.1,
      child: TextField(
        controller: cont,
        decoration: InputDecoration ( 
          prefixIcon: Icon(icon),
          hintText: hintText,
          hintStyle: const TextStyle (color: Colors.grey), border: OutlineInputBorder (
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}