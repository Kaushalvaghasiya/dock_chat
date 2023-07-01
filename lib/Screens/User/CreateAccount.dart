import 'package:dock_chat/Methods.dart';
import 'package:flutter/material.dart';

import '../Search.dart';

class CreateAccount extends StatefulWidget {
  const CreateAccount({super.key});

  @override
  State<CreateAccount> createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final TextEditingController _uname = TextEditingController();
  final TextEditingController _pass = TextEditingController();
  final TextEditingController _scode = TextEditingController();
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: isLoading
          ? Center(
              child: SizedBox(
                height: size.height / 20,
                width: size.height / 20,
                child: const CircularProgressIndicator(),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: size.height / 20,
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    width: size.width / 1.2,
                    child: IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back)),
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
                      "Sign Up to continue!",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 25,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: size.height / 10,
                  ),
                  Container(
                    width: size.width,
                    alignment: Alignment.center,
                    child: field(
                        size, "UserName", Icons.account_box_rounded, _uname),
                  ),
                  SizedBox(
                    height: size.height / 50,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 18.0),
                    child: Container(
                      width: size.width,
                      alignment: Alignment.center,
                      child: field(size, "Password", Icons.lock_rounded, _pass),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 18.0),
                    child: Container(
                      width: size.width,
                      alignment: Alignment.center,
                      child: field(
                          size, "Secret Code", Icons.security_rounded, _scode),
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
                    onTap: () => Navigator.of(context).pop(),
                    child: const Text(
                      "Already have an Account",
                      style: TextStyle(
                          color: Colors.deepPurple,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget customButton(Size size) {
    return TextButton(
      onPressed: () {
        if (_uname.text.isNotEmpty &&
            _pass.text.isNotEmpty &&
            _scode.text.isNotEmpty) {
          if (_scode.text == "GOD") {
            setState(() {
              isLoading = true;
            });
            createAccount(_uname.text, _pass.text).then((user) {
              if (user != null) {
                print("Login Sucessfull");
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (_) => const Search()));
              } else{
                print("Login Failed");
              }
              setState(() {
                isLoading = false;
              });
            });
          }
        } else {
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
          "Create Account",
          style: TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget field(
      Size size, String hintText, IconData icon, TextEditingController cont) {
    return SizedBox(
      height: size.height / 15,
      width: size.width / 1.1,
      child: TextField(
        controller: cont,
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}