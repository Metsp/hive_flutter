import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/models/user.dart';
import 'package:hive_flutter/providers/user_provider.dart';
import 'package:hive_flutter/resources/firestore_methods.dart';
import 'package:hive_flutter/screens/comments_screen.dart';
import 'package:hive_flutter/utils/colors.dart';
import 'package:hive_flutter/utils/utils.dart';
import 'package:hive_flutter/widgets/like_animation.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../screens/profile_screen.dart';

class PostCard extends StatefulWidget {
  final snap;
  const PostCard({super.key, required this.snap});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool isLikeAnimating = false;
  int commentLen = 0;
  bool isUser = false;
  bool noComments = false;
  bool hasReported = false;

  @override
  void initState() {
    super.initState();
    getComments();
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
      if (commentLen == 0) {
        noComments = true;
      }
    } catch (e) {
      showSnackBar(e.toString(), context);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final User user =
        Provider.of<UserProvider>(context).getUser; // Get user data

    //Used to check if the user id matches with the current user
    if (user.uid == widget.snap['uid']) {
      isUser = true;
    }

    return Container(
      margin: EdgeInsets.zero,
      color: hiveWhite,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 16,
            ),
            child: Row(
              children: [
                InkWell(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ProfileScreen(
                        uid: widget.snap['uid'],
                      ),
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 16,
                    backgroundImage: NetworkImage(
                      widget.snap['profImage'],
                    ),
                    backgroundColor: hiveLightGrey,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 12,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ProfileScreen(
                                uid: widget.snap['uid'],
                              ),
                            ),
                          ),
                          child: Text(
                            widget.snap['username'],
                            style: const TextStyle(
                              color: hiveBlack,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                isUser
                    ? IconButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => Dialog(
                              child:
                                  // Container(
                                  //   padding: const EdgeInsets.all(25),
                                  //   child: const Text(
                                  //     'Delete Post',
                                  //     style: TextStyle(
                                  //       color: hiveBlack,
                                  //     ),
                                  //   ),
                                  // ),

                                  ListView(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shrinkWrap: true,
                                children: [
                                  'Delete Post',
                                ]
                                    .map(
                                      (e) => InkWell(
                                        onTap: () {
                                          Navigator.of(context).pop();
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                actionsAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                contentPadding:
                                                    const EdgeInsets.only(
                                                        top: 20,
                                                        bottom: 5,
                                                        left: 20,
                                                        right: 20),
                                                contentTextStyle:
                                                    const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                elevation: 0,
                                                backgroundColor: hiveWhite,
                                                title: const Text(
                                                  'Delete Post',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                content: const Text(
                                                  'Are you sure you want to delete this post?',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: hiveBlack,
                                                      fontSize: 17),
                                                ),
                                                actions: <Widget>[
                                                  Padding(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 8.0),
                                                    child: ElevatedButton(
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        elevation: 0,
                                                        backgroundColor: Colors
                                                            .transparent, // Background color
                                                      ),
                                                      child: const Text(
                                                        'Cancel',
                                                        style: TextStyle(
                                                            color: hiveBlack,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 8.0),
                                                    child: ElevatedButton(
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        elevation: 0,
                                                        backgroundColor:
                                                            hiveYellow, // Background color
                                                      ),
                                                      child: const Text(
                                                        'Yes',
                                                        style: TextStyle(
                                                          color: hiveBlack,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      onPressed: () async {
                                                        FirestoreMethods()
                                                            .deletePost(
                                                                widget.snap[
                                                                    'postId']);
                                                        Navigator.pop(
                                                            context, 'Yes');
                                                        showSnackBar(
                                                            "Post Deleted",
                                                            context);
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                          // showDialog<String>(
                                          //   context: context,
                                          //   builder: (BuildContext context) =>
                                          //       AlertDialog(
                                          //     content: const Text(
                                          //         'Confirm Deletion?'),
                                          //     actions: <Widget>[
                                          //       TextButton(
                                          //         onPressed: () =>
                                          //             Navigator.pop(
                                          //                 context, 'Cancel'),
                                          //         child: const Text(
                                          //           'Cancel',
                                          //           style: TextStyle(
                                          //             color: hiveBlack,
                                          //           ),
                                          //         ),
                                          //       ),
                                          //       TextButton(
                                          //         onPressed: () async {
                                          //           FirestoreMethods()
                                          //               .deletePost(widget
                                          //                   .snap['postId']);
                                          //           Navigator.pop(
                                          //               context, 'Yes');
                                          //           showSnackBar("Post Deleted",
                                          //               context);
                                          //         },
                                          //         child: const Text(
                                          //           'Yes',
                                          //           style: TextStyle(
                                          //             color: hiveBlack,
                                          //           ),
                                          //         ),
                                          //       ),
                                          //     ],
                                          //   ),
                                          // );
                                        },

                                        // async {
                                        //   FirestoreMethods()
                                        //       .deletePost(widget.snap['postId']);
                                        //   Navigator.of(context)
                                        //       .pop(); // Remove dialog box
                                        // },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12, horizontal: 16),
                                          child: Text(e),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.more_vert,
                        ),
                      )
                    : IconButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => Dialog(
                              child:
                                  // Container(
                                  //   padding: const EdgeInsets.all(25),
                                  //   child: const Text(
                                  //     'Delete Post',
                                  //     style: TextStyle(
                                  //       color: hiveBlack,
                                  //     ),
                                  //   ),
                                  // ),

                                  ListView(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shrinkWrap: true,
                                children: [
                                  'Report Post',
                                ]
                                    .map(
                                      (e) => InkWell(
                                        onTap: () {
                                          Navigator.of(context).pop();
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                actionsAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                contentPadding:
                                                    const EdgeInsets.only(
                                                        top: 20,
                                                        bottom: 5,
                                                        left: 20,
                                                        right: 20),
                                                contentTextStyle:
                                                    const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                elevation: 0,
                                                backgroundColor: hiveWhite,
                                                title: const Text(
                                                  'Report Post',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                content: const Text(
                                                  'Do you want to report this post?',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: hiveBlack,
                                                      fontSize: 17),
                                                ),
                                                actions: <Widget>[
                                                  Padding(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 8.0),
                                                    child: ElevatedButton(
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        elevation: 0,
                                                        backgroundColor: Colors
                                                            .transparent, // Background color
                                                      ),
                                                      child: const Text(
                                                        'Cancel',
                                                        style: TextStyle(
                                                            color: hiveBlack,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 8.0),
                                                    child: ElevatedButton(
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        elevation: 0,
                                                        backgroundColor:
                                                            hiveYellow, // Background color
                                                      ),
                                                      child: const Text(
                                                        'Yes',
                                                        style: TextStyle(
                                                          color: hiveBlack,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      onPressed: () async {
                                                        FirestoreMethods()
                                                            .reportPost(
                                                                widget.snap[
                                                                    'postId'],
                                                                user.uid);
                                                        Navigator.pop(
                                                            context, 'Report');
                                                        showSnackBar(
                                                            "Post Reported!",
                                                            context);
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                          // showDialog<String>(
                                          //   context: context,
                                          //   builder: (BuildContext context) =>
                                          //       AlertDialog(
                                          //     content: const Text(
                                          //         'Do you want to report the post?'),
                                          //     actions: <Widget>[
                                          //       TextButton(
                                          //         onPressed: () =>
                                          //             Navigator.pop(
                                          //                 context, 'Cancel'),
                                          //         child: const Text(
                                          //           'Cancel',
                                          //           style: TextStyle(
                                          //             color: hiveBlack,
                                          //           ),
                                          //         ),
                                          //       ),
                                          //       TextButton(
                                          //         onPressed: () async {
                                          //           FirestoreMethods()
                                          //               .reportPost(
                                          //                   widget
                                          //                       .snap['postId'],
                                          //                   user.uid);
                                          //           Navigator.pop(
                                          //               context, 'Report');
                                          //           showSnackBar(
                                          //               "Post Reported!",
                                          //               context);
                                          //         },
                                          //         child: const Text(
                                          //           'Yes',
                                          //           style: TextStyle(
                                          //             color: hiveBlack,
                                          //           ),
                                          //         ),
                                          //       ),
                                          //     ],
                                          //   ),
                                          // );
                                        },

                                        // async {
                                        //   FirestoreMethods()
                                        //       .deletePost(widget.snap['postId']);
                                        //   Navigator.of(context)
                                        //       .pop(); // Remove dialog box
                                        // },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12, horizontal: 16),
                                          child: Text(e),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.more_vert,
                        ),
                      ),
              ],
            ),
          ),

          //Image Section
          GestureDetector(
            onDoubleTap: () async {
              await FirestoreMethods().likePost(
                widget.snap['postId'],
                user.uid,
                widget.snap['likes'],
              );
              setState(() {
                isLikeAnimating = true;
              });
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  // height: MediaQuery.of(context).size.height * 0.35,
                  width: double.infinity,
                  child: Image.network(
                    widget.snap['postUrl'],
                    fit: BoxFit.fill, // Used to be contain
                  ),
                ),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: isLikeAnimating ? 1 : 0,
                  child: LikeAnimation(
                    isAnimating: isLikeAnimating,
                    duration: const Duration(
                      milliseconds: 400,
                    ),
                    onEnd: () {
                      setState(() {
                        isLikeAnimating = false;
                      });
                    },
                    child: const Icon(
                      Icons.favorite,
                      color: hiveWhite,
                      size: 100,
                    ),
                  ),
                )
              ],
            ),
          ),

          // Likes / Comments section
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              LikeAnimation(
                isAnimating: widget.snap['likes'].contains(user.uid),
                smallLike: true,
                child: IconButton(
                  onPressed: () async {
                    await FirestoreMethods().likePost(
                      widget.snap['postId'],
                      user.uid,
                      widget.snap['likes'],
                    );
                  },
                  icon: widget.snap['likes'].contains(user.uid)
                      ? const Icon(
                          Icons.favorite,
                          color: hiveYellow,
                        )
                      : const Icon(
                          Icons.favorite_border,
                        ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => CommentsScreen(
                      snap: widget.snap,
                    ),
                  ),
                ),
                icon: const Icon(
                  Icons.comment_outlined,
                ),
              ),
              // IconButton(
              //   onPressed: () {},
              //   icon: const Icon(
              //     Icons.send,
              //   ),
              // ),
              // Expanded(
              //   child: Align(
              //     alignment: Alignment.bottomRight,
              //     child: IconButton(
              //       icon: const Icon(Icons.bookmark_border),
              //       onPressed: () {},
              //     ),
              //   ),
              // )
            ],
          ),

          // Description / Number of Comments
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DefaultTextStyle(
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(fontWeight: FontWeight.w800),
                  child: Text(
                    '${widget.snap['likes'].length} likes', // String interpolation as "likes" is an array value
                    style: const TextStyle(
                        color: hiveBlack,
                        fontSize: 14,
                        fontWeight: FontWeight.w500),
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 7),
                  child: RichText(
                    text: TextSpan(
                        style: const TextStyle(
                          color: hiveWhite,
                        ),
                        children: [
                          TextSpan(
                            text: widget.snap['username'],
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => ProfileScreen(
                                        uid: widget.snap['uid'],
                                      ),
                                    ),
                                  ),
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: hiveBlack,
                            ),
                          ),
                          TextSpan(
                              text: ' ${widget.snap['description']}',
                              style: const TextStyle(
                                color: hiveBlack,
                              ))
                        ]),
                  ), // Rich Text is able to expand to fit user requirements
                ),
                noComments
                    ? Container(
                        padding: const EdgeInsets.only(
                          bottom: 7,
                        ),
                      )
                    : InkWell(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => CommentsScreen(
                              snap: widget.snap,
                            ),
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            'View all $commentLen comments',
                            style: const TextStyle(
                              fontSize: 14,
                              color: secondaryColor,
                            ),
                          ),
                        ),
                      ),
                Text(
                  timeago.format(widget.snap['datePublished'].toDate()),
                  // DateFormat.yMMMd().format(
                  //   widget.snap['datePublished'].toDate(),
                  // ), // Using the "intl" package to format the timestamp
                  style: const TextStyle(
                    fontSize: 12,
                    color: secondaryColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          )
        ],
      ),
    );
  }
}
