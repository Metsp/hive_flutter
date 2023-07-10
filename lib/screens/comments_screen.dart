import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/resources/firestore_methods.dart';
import 'package:hive_flutter/utils/colors.dart';
import 'package:provider/provider.dart';
import '../models/user.dart' as model;
import '../providers/user_provider.dart';
import '../utils/utils.dart';
import '../widgets/comment_card.dart';

class CommentsScreen extends StatefulWidget {
  final snap;
  const CommentsScreen({super.key, required this.snap});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  late Stream<QuerySnapshot<Map<String, dynamic>>> commentsStream;

  final TextEditingController _commentController =
      TextEditingController(); // Controller for the comment textfield

  int commentLen = 0;

  @override
  void initState() {
    super.initState();
    getComments();
    commentsStream = FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.snap['postId'])
        .collection('comments')
        .orderBy('datePublished', descending: true)
        .snapshots();
  }

  // Define a boolean flag to indicate whether the screen needs to be refreshed
  bool refreshScreen = false;

  // Callback function to handle the refresh
  void refresh() {
    setState(() {
      refreshScreen = true;
    });
  }

  // Function to get the number of comments for a post
  void getComments() async {
    try {
      QuerySnapshot snap = await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.snap['postId'])
          .collection('comments')
          .get();
      commentLen = snap.docs.length;
    } catch (e) {
      showSnackBar(e.toString(), context);
    }
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    _commentController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model.User user = Provider.of<UserProvider>(context).getUser;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: hiveBlack),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: hiveWhite,
        elevation: 0.5,
        title: const Text(
          'Comments',
          style: TextStyle(
            color: hiveBlack,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: commentsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: hiveYellow,
                    ),
                  );
                } else if (commentLen == 0) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.comment_outlined,
                          size: 70,
                        ),
                        Text(
                          'No Comments Yet',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Text(
                            'Why don\'t you start the conversation?',
                            style: TextStyle(
                              color: hiveDarkGrey,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: (snapshot.data! as dynamic).docs.length,
                        itemBuilder: (context, index) => CommentCard(
                          snap: (snapshot.data! as dynamic).docs[index].data(),
                          refreshCallback: refresh,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: kToolbarHeight,
          margin:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          padding: const EdgeInsets.only(
            left: 16,
            right: 8,
          ),
          child: Row(children: [
            CircleAvatar(
              backgroundImage: NetworkImage(
                user.photoUrl,
              ),
              radius: 18,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 16, right: 8),
                child: TextField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    hintText: 'Comment as ${user.username}',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () async {
                await FirestoreMethods().postComment(
                  widget.snap['postId'],
                  _commentController.text,
                  user.uid,
                  user.username,
                  user.photoUrl,
                );
                setState(() {
                  _commentController.text = "";
                  getComments();
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                child: const Text(
                  'Post',
                  style: TextStyle(
                    color: hiveYellow,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          ]),
        ),
      ),
    );
  }
}
