import 'package:flutter/material.dart';

class GroupInfo extends StatelessWidget {
  final Map<String, dynamic> userMap;

  GroupInfo(this.userMap, {super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: size.height/8,
              width: size.width/1.1,
              child: Row(
                children: [
                  Container(
                    height: size.height/12,
                    width: size.height/12,
                    decoration: BoxDecoration(
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
                    child: Container(
                      child: Text(
                        "Group Name",
                        style: TextStyle(
                          fontSize: size.width/16,
                          fontWeight: FontWeight.w500,
                        ),
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
                "60 Members",
                style: TextStyle(
                  fontSize: size.width / 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Flexible(
              child: ListView.builder ( 
                itemCount: 10, 
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Icon(Icons.account_circle),
                    title: Text(
                      "User", 
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
              leading: Icon(Icons. logout, color: Colors. redAccent,), 
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