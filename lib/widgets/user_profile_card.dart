import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/utils/colors.dart';

import '../screens/profile_screen.dart';

class UserCard extends StatefulWidget {
  final snap;
  const UserCard({super.key, required this.snap});

  @override
  State<UserCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<UserCard> {
  String profileUsername = "";
  String profilePhotoUrl = "";
  bool isUser = false;

  void getUser() async {
    try {
      var userSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.snap['uid'])
          .get();

      profileUsername = userSnap.data()!['username'];
      profilePhotoUrl = userSnap.data()!['photoUrl'];
      setState(() {});
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUser();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ProfileScreen(
              uid: widget.snap['uid'],
            ),
          ),
        );
      },
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.black,
              width: 0.1,
            ),
          ),
        ),
        padding: const EdgeInsets.symmetric(
          vertical: 15,
          horizontal: 16,
        ),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(
                    profilePhotoUrl,
                  ),
                  radius: 20,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 16,
                    ),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: profileUsername,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: hiveBlack,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
