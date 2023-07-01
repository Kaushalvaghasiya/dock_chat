import 'package:dock_chat/Screens/User/LoginScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<User?> createAccount(String uname, String pass) async{
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  try {
    User? user= (await _auth.createUserWithEmailAndPassword(email: uname+"@gmail.com", password: pass))
    .user;

    if(user!=null){
      print("Account Created Sucessful");
      user.updateDisplayName(uname);
      await _firestore.collection("users").doc(_auth.currentUser?.uid).set({
        "email": uname,
        "uid" : _auth.currentUser?.uid,
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

    if(user!=null){
      print("Login Sucessful");
      return user;
    }
    else{
      print("Login Unsucessful");
      return null;
    }
  } catch (e) {
    print(e);
    return null;
  }
}

Future<User?> logOut(BuildContext context) async{
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  try {
    await _firestore.collection("users").doc(_auth.currentUser?.uid).update({"status": "Offline"});
    await _auth.signOut().then((value){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
    });
  } catch (e) {
    print(e);
  }
}