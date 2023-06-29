import 'package:dock_chat/LoginScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<User?> createAccount(String uname, String pass) async{
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  try {
    User? user= (await _auth.createUserWithEmailAndPassword(
      email: uname+"@gmail.com", password: pass))
    .user;

    if(user!=Null){
      print("Account Created Sucessful");
      await _firestore.collection("users").doc(_auth.currentUser?.uid).set({
        "email": uname+"@gmail.com",
        "satus": "Unavailable",
      });
    }
    else{
      print("Unsucessful");
    }
    return user;
  } catch (e) {
    print(e);
    return null;
  }
}

Future<User?> logIn(String uname, String pass) async{
  FirebaseAuth _auth = FirebaseAuth.instance;
  try {
    User? user= (await _auth.signInWithEmailAndPassword(
      email: uname+"@gmail.com", password: pass))
    .user;

    if(user!=Null){
      print("Login Sucessful");
    }
    else{
      print("Login Unsucessful");
    }
    return user;
  } catch (e) {
    print(e);
    return null;
  }
}

Future<User?> logOut(BuildContext context) async{
  FirebaseAuth _auth = FirebaseAuth.instance;
  try {
    await _auth.signOut().then((value){
      Navigator.push(context, MaterialPageRoute(builder: (_) => LoginScreen()));
    });
  } catch (e) {
    print(e);
  }
}