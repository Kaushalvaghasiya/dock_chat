import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GroupInfo extends StatefulWidget {
  final Map<String, dynamic> userMap;
  const GroupInfo({required this.userMap, Key? key}):super (key: key);

  @override
  State<GroupInfo> createState() => _GroupInfo();

}
class _GroupInfo extends State<GroupInfo> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List membersList = [];
  bool isLoading=false;

  @override
  void initState() {
    super.initState();
    getGroupMembers();
  }

  void getGroupMembers ( ) async {

    await _firestore.collection("groups").doc(widget.userMap["id"]).get().then((value){
      setState(() {
        membersList.add(value);
        isLoading=false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: size.height/8,
              width: size.width/1.1,
              child: Row(
                children: [
                  Container(
                    height: size.height/12,
                    width: size.height/12,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey,
                    ),
                    child: Icon(
                      Icons.group,
                      size: size.width/10,
                      color: Colors.white,
                      ),
                  ),
                  SizedBox(
                    width: size.height/25,
                  ),
                  Expanded(
                    child: Text(
                      widget.userMap["email"],
                      style: TextStyle(
                        fontSize: size.width/16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: size.height / 20,
            ),
            SizedBox(
              width: size.height/1.1,
              child: Text(
                "${membersList.length} Members",
                style: TextStyle(
                  fontSize: size.width / 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Flexible(
              child: ListView.builder ( 
                itemCount: membersList.length, 
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: const Icon(Icons.account_circle),
                    title: Text(
                      membersList[index]["email"], 
                      style: TextStyle(
                        fontSize: size.width / 22, 
                        fontWeight: FontWeight. w500,
                      ),
                    ),
                  );
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons. logout, color: Colors. redAccent,), 
              title: Text(
                "Leave Group", 
                style: TextStyle(
                  fontSize: size.width / 22, 
                  fontWeight: FontWeight.w500, 
                  color: Colors.redAccent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}