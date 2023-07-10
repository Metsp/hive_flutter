import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive_flutter/providers/user_provider.dart';
import 'package:hive_flutter/resources/firestore_methods.dart';
import 'package:hive_flutter/screens/workout_screen.dart';
import 'package:hive_flutter/utils/colors.dart';
import 'package:hive_flutter/utils/utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import 'history_screen.dart';

class AddScreen extends StatefulWidget {
  const AddScreen({super.key});

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen>
    with SingleTickerProviderStateMixin {
  Uint8List? _file;
  final TextEditingController _descriptionController = TextEditingController();
  bool _isLoading = false;
  double imageHeight = 0.0;

  late final TabController _tabController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  void postImage(
    // Function used to post an image
    String uid,
    String username,
    String profImage,
  ) async {
    setState(() {
      _isLoading = true;
    });

    try {
      String res = await FirestoreMethods().uploadPost(
          _descriptionController.text, _file!, uid, username, profImage);
      if (res == "success") {
        setState(() {
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        // ignore: use_build_context_synchronously
        showSnackBar(res, context);
      }
      successUpload();
    } catch (e) {
      showSnackBar(e.toString(), context);
    }
  }

  _selectImage(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: const Text('Upload a Post'),
            children: [
              SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('Take a photo'),
                onPressed: () async {
                  Navigator.of(context)
                      .pop(); // Pop/remove the widget from the screen
                  Uint8List file = await pickImage(
                    ImageSource.camera,
                  );
                  setState(() {
                    _file = file;
                  });
                },
              ),
              SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('Choose from gallery'),
                onPressed: () async {
                  Navigator.of(context)
                      .pop(); // Pop/remove the widget from the screen
                  Uint8List file = await pickImage(
                    ImageSource.gallery,
                  );
                  setState(() {
                    _file = file;
                  });
                },
              ),
              SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  void successUpload() {
    // After post is successful, set image file state back to null and show alert
    showSnackBar("Post Uploaded!", context);
    setState(() {
      _file = null;
      _descriptionController.text = " ";
    });
  }

  void clearAll() {
    // After post is successful, set image file state back to null
    setState(() {
      _file = null;
      _descriptionController.text = " ";
    });
  }

  @override
  void dispose() {
    super.dispose();
    _descriptionController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final User user = Provider.of<UserProvider>(context)
        .getUser; // Use this line to access whatever user information required

    return _file == null
        // Screen for adding workout and photo
        ? SafeArea(
            child: Scaffold(
              body: NestedScrollView(
                physics: const BouncingScrollPhysics(),
                headerSliverBuilder:
                    (BuildContext context, bool innerBoxIsScrolled) {
                  return <Widget>[
                    SliverAppBar(
                      title: SvgPicture.asset(
                        'assets/hive_logo_banner_dark.svg',
                        height: 64,
                      ),
                      actions: [
                        Padding(
                          padding: const EdgeInsets.only(right: 10.0),
                          child: IconButton(
                            onPressed: () => _selectImage(
                              context,
                            ),
                            color: hiveBlack,
                            icon: const Icon(
                              Icons.camera_enhance_rounded,
                              size: 30,
                            ),
                          ),
                        ),
                      ],
                      elevation: 0,
                      backgroundColor: hiveWhite,
                      pinned: true,
                      floating: true,
                      forceElevated: innerBoxIsScrolled,
                      bottom: TabBar(
                        labelStyle: const TextStyle(
                          fontSize: 16,
                        ),
                        labelColor: hiveBlack,
                        unselectedLabelColor: Colors.grey,
                        controller: _tabController,
                        indicatorColor: hiveYellow,
                        tabs: const <Tab>[
                          Tab(text: 'Workout'),
                          Tab(text: 'History'),
                        ],
                      ),
                    ),
                  ];
                },
                body: TabBarView(
                  controller: _tabController,
                  children: const <Widget>[
                    WorkoutScreen(),
                    HistoryScreen(),
                  ],
                ),
              ),
            ),
          )
        // Screen for user to upload their photo with caption
        : Scaffold(
            resizeToAvoidBottomInset: false,
            //Upload Post UI
            appBar: AppBar(
              backgroundColor: hiveWhite,
              elevation: 0.5,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                color: hiveBlack,
                onPressed: clearAll,
              ),
              title: const Text(
                'Post to Feed',
                style: TextStyle(
                  color: hiveBlack,
                ),
              ),
              centerTitle: true,
              actions: [
                TextButton(
                  onPressed: () =>
                      postImage(user.uid, user.username, user.photoUrl),
                  child: const Text(
                    'Post',
                    style: TextStyle(
                      color: hiveYellow,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                )
              ],
            ),
            body: SingleChildScrollView(
              child: Column(children: [
                _isLoading
                    ? const LinearProgressIndicator(
                        // Upload Post Progress Indicator
                        backgroundColor: hiveWhite,
                        color: hiveYellow,
                      )
                    : const Padding(
                        padding: EdgeInsets.only(top: 5),
                      ),
                Container(
                  color: hiveWhite,
                  child: Column(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 16,
                      ).copyWith(right: 0),
                      child: Row(children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundImage: NetworkImage(
                            user.photoUrl,
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
                                Text(
                                  user.username,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ]),
                    ),
                    //Image Section
                    Container(
                      padding: const EdgeInsets.only(
                        top: 8,
                      ),
                      child: SizedBox(
                        height: _file != null
                            ? null
                            : MediaQuery.of(context).size.height * 0.35,
                        width: double.infinity,
                        child: _file != null
                            ? Image.memory(
                                _file!,
                                fit: BoxFit.contain,
                                alignment: FractionalOffset.topCenter,
                              )
                            : Container(),
                      ),
                    ),
                    // Container(
                    //   padding: const EdgeInsets.symmetric(
                    //     vertical: 8,
                    //   ),
                    //   child: SizedBox(
                    //     height: MediaQuery.of(context).size.height * 0.35,
                    //     width: double.infinity,
                    //     child: Container(
                    //       decoration: BoxDecoration(
                    //         image: DecorationImage(
                    //           image: MemoryImage(_file!),
                    //           fit: BoxFit.contain,
                    //           alignment: FractionalOffset.topCenter,
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                    // ),

                    const Divider(
                      height: 0,
                    ),

                    // Write a caption section
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.only(top: 6),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.45,
                              child: TextField(
                                // Padding for keyboard popup
                                scrollPadding:
                                    const EdgeInsets.only(bottom: 100),
                                controller: _descriptionController,
                                decoration: const InputDecoration(
                                  hintText: 'Write a caption...',
                                  border: InputBorder.none,
                                ),
                                maxLines: 10,
                              ),
                            ), // Rich Text is able to expand to fit user requirements
                          ),
                        ],
                      ),
                    ),
                  ]),
                ),
              ]),
            ),
          );
  }
}
