import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dock_chat/Methods.dart';
import 'package:dock_chat/Screens/Group/CreateGroup.dart';
import 'package:dock_chat/Screens/User/EditProfile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../widgets/conversationList.dart';
import '../widgets/conversationListGrp.dart';
import '../widgets/profile.dart';
import 'User/ChatRoom.dart';

List? users;
class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> with WidgetsBindingObserver {
  final TextEditingController _search = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int _index=0;
  String currWindow="chat";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    setStatus("Online");
  }

  String chatRoomId (String user1, String user2) {
    if (user1[0].toLowerCase().codeUnits[0] > user2.toLowerCase().codeUnits[0]) {
        return "$user1-$user2";
    }else{ return "$user2-$user1";}
  }

  void setStatus(String status) async{
    await _firestore.collection("users").doc(_auth.currentUser?.displayName).update({"status": status});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if(state==AppLifecycleState.resumed){
      setStatus("Online");
    }else{
      setStatus("Offline");
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    switch (_index) {
      case 0:
        setState(() {
          currWindow="chat";
        });
        break;
      case 1:
        setState(() {
          currWindow="grp";
        });
        break;
      case 2:
        setState(() {
          currWindow="prof";
          
        });
        break;
    }
    final size = MediaQuery.of(context).size;
    if (currWindow=="prof"){
      return Scaffold(
        bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey.shade600,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        type: BottomNavigationBarType.fixed,
        onTap: (newIndex) => setState(() => _index = newIndex),
        currentIndex: _index,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: "Chats",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: "Groups",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_box),
            label: "Profile",
          ),
        ],
      ),
        body: SingleChildScrollView(
        physics:  const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16,right: 16,top: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("User Profile",
                        style: TextStyle(
                          fontSize: 32, fontWeight: FontWeight.bold
                        ),
                      ),
                      Container(
                      padding: const EdgeInsets.only(left: 8,right: 8,top: 0,bottom: 4),
                      height: 35,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Colors.pink[50],
                      ),
                      child: IconButton(onPressed: ()=>logOut(context), icon: const Icon(
                            Icons.logout,
                            color: Colors.pink,
                            size: 20,
                          )),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ProfileWidget(
                imagePath: _auth.currentUser?.photoURL??"Not Found",
                onClicked: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_)=> const EditProfile()));

                },
              ),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  _auth.currentUser?.displayName??"Not Found",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                ),
              ),
              const SizedBox(height: 48),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'About',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    Text(
                      "lorem ipsum",
                      style: TextStyle(fontSize: 16, height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey.shade600,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        type: BottomNavigationBarType.fixed,
        onTap: (newIndex) => setState(() => _index = newIndex),
        currentIndex: _index,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: "Chats",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: "Groups",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_box),
            label: "Profile",
          ),
        ],
      ),

      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(left: 16,right: 16,top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text((currWindow=="chat")?"Conversations":"Groups",style: const TextStyle(fontSize: 32,fontWeight: FontWeight.bold),),
                    (currWindow=="prof")? Container(): 
                    Container(
                      padding: const EdgeInsets.only(left: 8,right: 8,top: 0,bottom: 4),
                      height: 35,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Colors.pink[50],
                      ),
                      child: 
                      IconButton(
                          onPressed: () => (currWindow=="chat")? {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              builder: (BuildContext context) {
                                return Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 50,left: 25,right: 25),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Center(child: Text("People",style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),)),
                                          IconButton(onPressed: (){
                                            Navigator.of(context).pop();
                                          },
                                          icon: const Icon(
                                            Icons.done,
                                            color: Colors.pink,
                                            size: 20,
                                          )),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 16,left: 16,right: 16),
                                      child: TextField(
                                        decoration: InputDecoration(
                                          hintText: "Search...",
                                          hintStyle: TextStyle(color: Colors.grey.shade600),
                                          prefixIcon: Icon(Icons.search,color: Colors.grey.shade600, size: 20,),
                                          filled: true,
                                          fillColor: Colors.grey.shade100,
                                          contentPadding: const EdgeInsets.all(3),
                                          enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(20),
                                              borderSide: BorderSide(
                                                  color: Colors.grey.shade100
                                              )
                                          ),
                                        ),
                                      ),
                                    ),
                                    StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                                      stream: FirebaseFirestore.instance.collection('users').snapshots(),
                                      builder: (context, snapshot) {
                                        if (snapshot.hasError) return Text('Error = ${snapshot.error}');
                                        if (snapshot.hasData) {
                                        final docs = snapshot.data!.docs;
                                        return ListView.builder(
                                          itemCount: docs.length,
                                          shrinkWrap: true,
                                          padding: const EdgeInsets.only(top: 16),
                                          itemBuilder: (BuildContext context, int index) {
                                            if (docs[index]["email"]==_auth.currentUser?.displayName){
                                            return Container();
                                            }
                                            return Padding(
                                              padding: const EdgeInsets.only(left: 16,right: 16,top: 10,bottom: 10),
                                              child: ListTile(
                                                leading: CircleAvatar(
                                                  backgroundImage: NetworkImage(docs[index]["imageUrl"]),
                                                  maxRadius: 25,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(10.0),
                                                ),
                                                onTap: () {
                                                  String? disnameq = _auth.currentUser?.displayName;
                                                  String disname = disnameq ?? "0";
                                                  String roomId = chatRoomId(disname, docs[index]["email"]);
                                                  Navigator.of(context).pop();
                                                  Navigator.of(context)
                                                      .push(MaterialPageRoute(builder: (_) => ChatRoom(roomId, docs[index]["email"])));
                                                },
                                                title: Text(docs[index]["email"], style: const TextStyle(fontSize: 16),),
                                              ),
                                            );
                                          });
                                        }
                                        else{
                                          return Container();
                                        }
                                      }
                                    ),
                                  ],
                                );
                              },
                            )
                          }: 
                          Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) => const CreateGroup())),
                          icon: const Icon(
                            Icons.add,
                            color: Colors.pink,
                            size: 20,
                          )),
                    )
                  ],
                ),
              ),
            ),
            (currWindow=="prof")? Container(): 
            Padding(
              padding: const EdgeInsets.only(top: 16,left: 16,right: 16),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search...",
                  hintStyle: TextStyle(color: Colors.grey.shade600),
                  prefixIcon: Icon(Icons.search,color: Colors.grey.shade600, size: 20,),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: const EdgeInsets.all(8),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(
                          color: Colors.grey.shade100
                      )
                  ),
                ),
              ),
            ),
            (currWindow=="prof")? Container(): 
            (currWindow=="chat")? StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance.collection('chats').orderBy("time", descending: true).snapshots(),
              builder: (_, snapshot) {
                if (snapshot.hasError) return Text('Error = ${snapshot.error}');
                if (snapshot.hasData) {
                  final docs = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: docs.length,
                    shrinkWrap: true,
                    padding: const EdgeInsets.only(top: 16),
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (_, index) {
                      final data = docs[index].data();
                      List user=data["id"].split("-");
                      if (user[0] != _auth.currentUser?.displayName && user[1] != _auth.currentUser?.displayName){
                        return Container();
                      }else{
                        String ouser=user[0]==_auth.currentUser?.displayName ? user[1]: user[0];
                        DateTime dM = (data["time"] as Timestamp).toDate();
                        DateTime dC = DateTime.parse(DateTime.now().toString());
                        Duration diff = dC.difference(dM);
                        // _firestore.collection('users').doc(ouser).get().then((value){
                        //   String imageUrl=value.get("imageUrl");
                          return ConversationList(
                            name: ouser,
                            messageText: data["lastMessage"],
                            imageUrl: "imageUrl",//value.data().toString().contains("imageUrl")?value.get("imageUrl"):"",
                            time: diff.inMinutes.toString(),
                            isMessageRead: (index == 0)?true:false,
                          );
                        // });
                      }
                    },
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ):StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance.collection('users').doc(_auth.currentUser?.displayName).collection("groups").snapshots(),
              builder: (_, snapshot) {
                if (snapshot.hasError) return Text('Error = ${snapshot.error}');
                if (snapshot.hasData) {
                  final docs = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: docs.length,
                    shrinkWrap: true,
                    padding: const EdgeInsets.only(top: 16),
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (_, index) {
                      final data = docs[index].data();
                      String name="",messagetText="",imageUrl="";
                      DateTime dM=DateTime.now();
                      // _firestore.collection("groupChat").doc(data["id"]).get().then((value){         
                      //   name=value.data().toString().contains('email') ? value.get('email') : '';
                      //   messagetText=value.data().toString().contains('lastMessage') ? value.get('lastMessage') : '';
                      //   // dM=(value.data().toString().contains('time') ? value.get('time') : FieldValue.serverTimestamp() as Timestamp).toDate();
                      // });
                      // _firestore.collection("groups").doc(data["id"]).get().then((value){
                      //   imageUrl=value.data().toString().contains('imageUrl') ? value.get('imageUrl') : '';
                      // });
                      // DateTime dC = DateTime.parse(DateTime.now().toString());
                      // Duration diff = dC.difference(dM);
                      return ConversationListGrp(
                        gid: data["id"],
                        name: data["email"],
                        messageText: "messagetText",
                        imageUrl: "imageUrl",
                        time: dM.toString(),
                        isMessageRead: (index == 0)?true:false,
                      );
                    },
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ],
        ),
      ),
    );
  }
}