import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dock_chat/Methods.dart';
import 'package:flutter/material.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  Map<String, dynamic>? userMap;
  final TextEditingController _search = TextEditingController();

  void onSearch() async{
    FirebaseFirestore _firestore = FirebaseFirestore.instance;

    await _firestore
    .collection("users")
    .where("email",isEqualTo:_search.text+"@gmail.com")
    .get().then((value){
      userMap = value. docs [0]. data();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text ("Search"),
        actions: [
          IconButton (icon: Icon(Icons.logout_rounded), onPressed: () => logOut(context)),
        ],
      ),
      body: Column(children: [
        SizedBox(
          height: size.height / 20,
        ),
        Container(
          height: size.height / 14,
          width: size.width,
          alignment: Alignment.center,
          child: SizedBox(
            height: size.height / 14,
            width: size.width / 1.2,
            child: TextField(
              onChanged: (value) => onSearch(),
              controller: _search,
              decoration: InputDecoration ( 
              hintText: "Search",
              hintStyle: TextStyle (color: Colors.grey), border: OutlineInputBorder (
                borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ),
        userMap != null ? ListTile(
          title: Text (userMap?['email']), 
        )
        : Container (),
       ],
      ),
    );
  }
}