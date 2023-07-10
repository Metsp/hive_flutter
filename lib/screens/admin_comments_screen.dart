import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/utils/colors.dart';
import 'package:hive_flutter/widgets/admin_comment_card.dart';
import '../utils/utils.dart';

class AdminCommentsScreen extends StatefulWidget {
  final snap;
  const AdminCommentsScreen({super.key, required this.snap});

  @override
  State<AdminCommentsScreen> createState() => _AdminCommentsScreenState();
}

class _AdminCommentsScreenState extends State<AdminCommentsScreen> {
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
                        itemBuilder: (context, index) => AdminCommentCard(
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
    );
  }
}
