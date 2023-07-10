import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/utils/colors.dart';
import 'package:hive_flutter/utils/utils.dart';
import 'package:timeago/timeago.dart' as timeago;

class CommentCard extends StatefulWidget {
  final VoidCallback refreshCallback;
  final snap;
  const CommentCard(
      {super.key, required this.snap, required this.refreshCallback});

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  String commentUsername = "";
  String commentPhotoUrl = "";
  bool isUser = false;

  void getCommentsUser() async {
    try {
      var userSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.snap['uid'])
          .get();

      commentUsername = userSnap.data()!['username'];
      commentPhotoUrl = userSnap.data()!['photoUrl'];
      setState(() {});
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCommentsUser();
  }

  @override
  Widget build(BuildContext context) {
    // Check if comment is by user
    if (widget.snap['uid'] == FirebaseAuth.instance.currentUser!.uid) {
      isUser = true;
    }
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 18,
        horizontal: 16,
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(
              commentPhotoUrl,
            ),
            radius: 18,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(
                left: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: commentUsername,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: hiveBlack,
                          ),
                        ),
                        TextSpan(
                          text: ' ${widget.snap['text']}',
                          style: const TextStyle(
                            color: hiveBlack,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      timeago.format(widget.snap['datePublished'].toDate()),
                      // DateFormat.yMMMd()
                      //     .format(widget.snap['datePublished'].toDate()),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: hiveBlack,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          isUser
              ? InkWell(
                  onTap: () {
                    deleteComment(
                        widget.snap['postID'], widget.snap['commentID']);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: const Icon(
                      Icons.delete_rounded,
                      size: 16,
                    ),
                  ),
                )
              : Container()
        ],
      ),
    );
  }

  void refreshPage() {
    widget.refreshCallback();
  }

  Future<void> deleteComment(String postID, String commentID) async {
    final firestore = FirebaseFirestore.instance;
    try {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            actionsAlignment: MainAxisAlignment.spaceBetween,
            contentPadding:
                const EdgeInsets.only(top: 20, bottom: 5, left: 20, right: 20),
            contentTextStyle: const TextStyle(fontWeight: FontWeight.w600),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 0,
            backgroundColor: hiveWhite,
            title: const Text(
              'Delete Comment',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: const Text(
              'Are you sure you want to delete this comment?',
              style: TextStyle(
                  fontWeight: FontWeight.w400, color: hiveBlack, fontSize: 17),
            ),
            actions: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: Colors.transparent, // Background color
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                        color: hiveBlack, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: hiveYellow, // Background color
                  ),
                  child: const Text(
                    'Delete',
                    style: TextStyle(
                      color: hiveBlack,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await firestore
                        .collection('posts')
                        .doc(postID)
                        .collection('comments')
                        .doc(commentID)
                        .delete();
                    refreshPage();
                    // ignore: use_build_context_synchronously
                    showSnackBar('Comment Deleted!', context);
                  },
                ),
              ),
            ],
          );
        },
      );
    } catch (err) {
      print(err.toString());
    }
  }
}
