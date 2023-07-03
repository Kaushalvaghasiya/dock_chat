import 'package:flutter/material.dart';

class UserProfile extends StatelessWidget {
  final Map<String, dynamic> userMap;

  const UserProfile(this.userMap, {super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return const Scaffold();
  }
}