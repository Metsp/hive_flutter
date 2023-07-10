import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/material.dart";
import 'package:hive_flutter/utils/colors.dart';
import 'package:image_picker/image_picker.dart';
import '../resources/storage_methods.dart';
import '../utils/utils.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  //Initiating controllers to accept user input
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  // Image as UInt8List
  Uint8List? _image;

  bool isLoading = false;
  String userAge = '';
  String userHeight = '';
  String userWeight = '';
  String userGender = '';
  String userBio = '';
  String userPhotoUrl = '';

  // Used to get data from the user
  getData() async {
    isLoading = true;
    try {
      var userSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      userAge = userSnap.data()!['age'];
      userHeight = userSnap.data()!['height'];
      userWeight = userSnap.data()!['weight'];
      userGender = userSnap.data()!['gender'];
      userBio = userSnap.data()!['bio'];
      userPhotoUrl = userSnap.data()!['photoUrl'];

      _bioController.text = userBio;
      _ageController.text = userAge;
      _weightController.text = userWeight;
      _heightController.text = userHeight;

      setState(() {});
    } catch (e) {
      showSnackBar(e.toString(), context);
    }
    setState(
      () {
        isLoading = false;
      },
    );
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  void dispose() {
    //Used to clear the text controllers as soon as the widgets get disposed.
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _bioController.dispose();
    _usernameController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
  }

  void selectImage() async {
    // Function to select image from gallery
    Uint8List im = await pickImage(ImageSource.gallery);
    setState(() {
      //Set state to a global image variable to be displayed
      _image = im;
    });
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
          'Edit Profile',
          style: TextStyle(
            color: hiveBlack,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: hiveYellow,
              ),
            )
          : Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  width: double.infinity,
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      Stack(
                        //Stacks are used to place elements on top of each other
                        children: [
                          _image != null
                              ? CircleAvatar(
                                  radius: 64,
                                  backgroundImage: MemoryImage(_image!),
                                )
                              : CircleAvatar(
                                  radius: 64,
                                  backgroundImage: NetworkImage(
                                    // 'https://t4.ftcdn.net/jpg/04/10/43/77/360_F_410437733_hdq4Q3QOH9uwh0mcqAhRFzOKfrCR24Ta.jpg',
                                    userPhotoUrl,
                                  ),
                                  backgroundColor: hiveLightGrey,
                                ),
                          Positioned(
                            bottom: -10,
                            left: 85,
                            child: IconButton(
                              onPressed: selectImage,
                              icon: const Icon(
                                Icons.add_a_photo,
                              ),
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        //Adds spacing between the textfields
                        height: 36,
                      ),

                      TextField(
                        controller: _ageController,
                        style: const TextStyle(
                          color: hiveBlack,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Age',
                          floatingLabelStyle: const TextStyle(color: hiveBlack),
                          border: OutlineInputBorder(
                              borderSide: Divider.createBorderSide(context)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: Divider.createBorderSide(context)),
                          filled: true,
                          contentPadding: const EdgeInsets.all(8),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setState(() {
                            userAge = value;
                          });
                        },
                      ),

                      const SizedBox(
                        //Adds spacing between the textfields
                        height: 16,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _heightController,
                              style: const TextStyle(
                                color: hiveBlack,
                              ),
                              decoration: InputDecoration(
                                labelText: 'Height',
                                suffix: const Text("cm"),
                                floatingLabelStyle:
                                    const TextStyle(color: hiveBlack),
                                prefixStyle: const TextStyle(
                                  color: hiveBlack,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                                border: OutlineInputBorder(
                                    borderSide:
                                        Divider.createBorderSide(context)),
                                focusedBorder: OutlineInputBorder(
                                    borderSide:
                                        Divider.createBorderSide(context)),
                                filled: true,
                                contentPadding: const EdgeInsets.all(8),
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                setState(() {
                                  userHeight = value;
                                });
                              },
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: TextField(
                              controller: _weightController,
                              style: const TextStyle(
                                color: hiveBlack,
                              ),
                              decoration: InputDecoration(
                                labelText: 'Weight',
                                suffix: const Text("kg"),
                                floatingLabelStyle:
                                    const TextStyle(color: hiveBlack),
                                prefixStyle: const TextStyle(
                                  color: hiveBlack,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                                border: OutlineInputBorder(
                                    borderSide:
                                        Divider.createBorderSide(context)),
                                focusedBorder: OutlineInputBorder(
                                    borderSide:
                                        Divider.createBorderSide(context)),
                                filled: true,
                                contentPadding: const EdgeInsets.all(8),
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                setState(() {
                                  userWeight = value;
                                });
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        //Adds spacing between the textfields
                        height: 16,
                      ),

                      DropdownButtonFormField(
                        decoration: InputDecoration(
                          hintText: 'Gender',
                          labelText: 'Gender',
                          floatingLabelStyle: const TextStyle(color: hiveBlack),
                          border: OutlineInputBorder(
                              borderSide: Divider.createBorderSide(context)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: Divider.createBorderSide(context)),
                          filled: true,
                          contentPadding: const EdgeInsets.all(8),
                        ),
                        value: userGender,
                        items: const [
                          DropdownMenuItem(
                            value: 'Male',
                            child: Text('Male'),
                          ),
                          DropdownMenuItem(
                            value: 'Female',
                            child: Text('Female'),
                          ),
                          DropdownMenuItem(
                            value: 'Others',
                            child: Text('Others'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            userGender = value!;
                          });
                        },
                      ),

                      const SizedBox(
                        //Adds spacing between the textfields
                        height: 16,
                      ),

                      //Text field input for bio

                      TextField(
                        controller: _bioController,
                        style: const TextStyle(
                          color: hiveBlack,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Write a bio to introduce yourself!',
                          floatingLabelStyle: const TextStyle(color: hiveBlack),
                          border: OutlineInputBorder(
                              borderSide: Divider.createBorderSide(context)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: Divider.createBorderSide(context)),
                          filled: true,
                          contentPadding: const EdgeInsets.all(8),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setState(() {
                            userBio = value;
                          });
                        },
                      ),

                      const SizedBox(
                        //Adds spacing between the textfields
                        height: 30,
                      ),

                      //Sign Up Button
                      // Inkwell is used to wrap the button so it is clickable and runs a function
                      InkWell(
                        onTap: () {
                          updateProfileDetails(
                              age: userAge,
                              height: userHeight,
                              weight: userWeight,
                              gender: userGender,
                              file: _image,
                              bio: userBio);
                        },
                        child: Container(
                          width: double.infinity,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: const ShapeDecoration(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(4),
                              ),
                            ),
                            color: hiveYellow,
                          ),
                          child: isLoading
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    color: primaryColor,
                                  ),
                                )
                              : const Text(
                                  "Update Profile",
                                  style: TextStyle(
                                    color: hiveBlack,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(
                        height: 100,
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Future<void> updateProfileDetails(
      {required String age,
      required String height,
      required String weight,
      required String gender,
      required String bio,
      Uint8List? file}) async {
    String photoUrl;

    if (age.isEmpty ||
        height.isEmpty ||
        weight.isEmpty ||
        gender.isEmpty ||
        bio.isEmpty) {
      showSnackBar("Please fill in all required fields", context);
    } else {
      try {
        if (file == null) {
          photoUrl = userPhotoUrl;
        } else {
          photoUrl = await StorageMethods()
              .uploadImageToStorage('profilepics', file, false);
        }
        final firestore = FirebaseFirestore.instance;
        await firestore
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .update({
          'age': userAge,
          'height': userHeight,
          'weight': userWeight,
          'gender': userGender,
          'bio': userBio,
          'photoUrl': photoUrl,
        });
        // ignore: use_build_context_synchronously
        showSnackBar("Profile Updated!", context);
        // ignore: use_build_context_synchronously
        Navigator.pop(context);
      } catch (e) {
        print(e.toString());
      }
    }
  }
}
