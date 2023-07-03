import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dock_chat/Screens/Group/GroupChatRoom.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class CreateGroup extends StatefulWidget {
  const CreateGroup({super.key});

  @override
  State<CreateGroup> createState() => _CreateGroup();
}

class _CreateGroup extends State<CreateGroup> {
  final TextEditingController _search = TextEditingController();
  final TextEditingController _grpname = TextEditingController();
  List<Map<String, dynamic>> addUsers = [];
  List <String> addUsersId = [];
  bool doneAdd = false, isLoading = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    getCurrentUserDetails();
  }

  void getCurrentUserDetails() async {
    await _firestore
        .collection("users")
        .doc(_auth.currentUser?.displayName)
        .get()
        .then((value) {
      setState(() {
        addUsers.add({
          "email": value["email"],
          "isAdmin": true,
        });
        addUsersId.add(value["email"]);
      });
    });
  }

  void createGroup() async{
    String groupId = const Uuid().v1();
    await _firestore.collection("groups").doc(groupId).set({
      "members": addUsers,
      "id": groupId,
    });
    for (var i in addUsers) {
      await _firestore
          .collection("users")
          .doc(i["email"])
          .collection("groups")
          .doc(groupId)
          .set({
            "email": _grpname.text,
            "id": groupId,
          });
    }
    await _firestore.collection("groups").doc(groupId).collection("chats").add({
      "message": "${_auth.currentUser?.displayName} Created this Group",
      "type": "notify",
      "time": FieldValue.serverTimestamp(),
    });
    Navigator.pushReplacement(context,MaterialPageRoute(builder: (_) => GroupChatRoom({"email":_grpname.text, "id": groupId})));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Creating a Group"),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          doneAdd
              ? SizedBox(
                  height: size.height / 8,
                  width: size.width / 1.1,
                  child: Row(
                    children: [
                      Container(
                        height: size.height / 12,
                        width: size.height / 12,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey,
                        ),
                        child: Icon(
                          Icons.group,
                          size: size.width / 10,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(
                        width: size.height / 25,
                      ),
                      Expanded(
                        child: TextField(
                          controller: _grpname,
                          decoration: InputDecoration(
                            hintText: "Enter Group Name",
                            hintStyle: const TextStyle(color: Colors.grey),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Flexible(
                  child: (addUsers.length > 1)
                      ? ListView.builder(
                          itemCount: addUsers.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            if (index==0) {
                              return Container();
                            } else {
                              return ListTile(
                                leading: const Icon(Icons.account_circle),
                                title: Text(addUsers[index]["email"]),
                                trailing: IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: (){
                                    setState(() {
                                      addUsers.removeAt(index);
                                      addUsersId.removeAt(index);
                                    });
                                  },
                                ),
                              );
                            }
                          })
                      : const SizedBox(),
                ),
          doneAdd
              ? TextButton(
                  onPressed: () {
                    if(_grpname.text.isNotEmpty){
                      createGroup();
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
                      "Create Group",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                )
              : Container(
                  height: size.height / 19,
                  width: size.width,
                  alignment: Alignment.center,
                  child: SizedBox(
                    height: size.height,
                    width: size.width / 1.1,
                    child: TextField(
                      controller: _search,
                      decoration: InputDecoration(
                        hintText: "Search",
                        hintStyle: const TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ),
          doneAdd ? Container() :
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance.collection('users').snapshots(),
            builder: (_, snapshot) {
              if (snapshot.hasError) return Text('Error = ${snapshot.error}');
              if (snapshot.hasData) {
                final docs = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: docs.length,
                  shrinkWrap: true,
                  itemBuilder: (_, i) {
                    final data = docs[i].data();
                    if (addUsersId.contains(data["email"])) {
                      return Container();
                    } else {
                      return ListTile(
                        onTap: () {
                          setState(() {
                            addUsers.add({
                              "email": data["email"],
                              "isAdmin": false,
                            });
                            addUsersId.add(data["email"]);
                          });
                        },
                        leading: const Icon(Icons.account_box_rounded),
                        title: Text(data["email"]),
                        trailing: const Icon(Icons.add),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      );
                    }
                  },
                );
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(doneAdd ? Icons.arrow_upward_rounded : Icons.forward),
        onPressed: () {
          if(addUsersId.length>1){
            setState(() {
              doneAdd = !doneAdd;
            });
          }
        },
      ),
    );
  }
}
