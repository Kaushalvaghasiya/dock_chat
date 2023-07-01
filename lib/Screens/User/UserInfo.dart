import 'package:flutter/material.dart';

class UserInfo extends StatelessWidget {
  final Map<String, dynamic> userMap;

  const UserInfo(this.userMap, {super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return const Scaffold();
  }
}