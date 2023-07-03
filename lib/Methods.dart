import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<User?> createAccount(String uname, String pass) async{
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  try {
    User? user= (await _auth.createUserWithEmailAndPassword(email: "$uname@gmail.com", password: pass))
    .user;

    if(user!=null){
      print("Account Created Sucessful");
      user.updateDisplayName(uname);
      user.updatePhotoURL("https://images.unsplash.com/photo-1554151228-14d9def656e4?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=333&q=80");
      await _firestore.collection("users").doc(uname).set({
        "email": uname,
        "imageUrl": "https://images.unsplash.com/photo-1554151228-14d9def656e4?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=333&q=80",
        "status": "Online"
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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  try {
    User? user= (await _auth.signInWithEmailAndPassword(
      email: "$uname@gmail.com", password: pass))
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

Future<void> logOut(BuildContext context) async{
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  try {
    await _firestore.collection("users").doc(_auth.currentUser?.displayName).update({"status": "Offline"});
    await _auth.signOut().then((value){
      Navigator.pushReplacementNamed(context, "login");
    });
  } catch (e) {
    print(e);
  }
}