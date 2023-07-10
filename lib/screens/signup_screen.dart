import 'dart:typed_data';
import "package:flutter/material.dart";
import 'package:hive_flutter/screens/login_screen.dart';
import 'package:hive_flutter/utils/colors.dart';
import 'package:hive_flutter/widgets/text_field_input.dart';
import 'package:image_picker/image_picker.dart';
import '../resources/auth_methods.dart';
import '../responsive/mobile_screen_layout.dart';
import '../responsive/responsive_layout_screen.dart';
import '../responsive/web_screen_layout.dart';
import '../utils/utils.dart';
import 'landing_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  //Initiating controllers to accept user input
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  String selectedGender = "Empty";

  Uint8List? _image;
  bool _isLoading = false; // Check if the system is loading

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

  void signUpUser() async {
    // Function to sign up user
    bool validDetails = true;
    String res = "Error: ";

    if (_image == null) {
      res = res + "\n• Please upload a profile picture";
      validDetails = false;
    }
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _bioController.text.isEmpty ||
        _usernameController.text.isEmpty ||
        _ageController.text.isEmpty ||
        _weightController.text.isEmpty ||
        _heightController.text.isEmpty) {
      res = res + "\n• Please fill in all required fields";
      validDetails = false;
    } else {
      if (_usernameController.text.length < 7 ||
          _usernameController.text.length > 20) {
        res = res + "\n• Username must be 7-20 characters long";
        validDetails = false;
      }

      if (_passwordController.text.length < 6) {
        res = res + "\n• Password must be at least 6 characters.";
        validDetails = false;
      }

      if (int.tryParse(_ageController.text)! <= 0 ||
          int.tryParse(_ageController.text)! >= 100) {
        res = res + "\n• Age must be between 0-100";
        validDetails = false;
      }
      if (int.tryParse(_heightController.text)! <= 0 ||
          int.tryParse(_heightController.text)! >= 300) {
        res = res + "\n• Height must be between 0-300 cm";
        validDetails = false;
      }
      if (int.tryParse(_weightController.text)! <= 0 ||
          int.tryParse(_weightController.text)! >= 300) {
        res = res + "\n• Weight must be between 0-300 kg";
        validDetails = false;
      }
    }

    if (validDetails) {
      setState(() {
        _isLoading = true;
      });
      res = await AuthMethods().signUpUser(
          email: _emailController.text,
          password: _passwordController.text,
          username: _usernameController.text,
          bio: _bioController.text,
          age: _ageController.text,
          height: _heightController.text,
          weight: _weightController.text,
          gender: selectedGender,
          file: _image!);
    }

    setState(() {
      _isLoading = false;
    });

    if (res != 'success') {
      // ignore: use_build_context_synchronously
      showSnackBar(res, context);
      // showSnackBar("Welcome to Hive!", context);
    } else {
      // ignore: use_build_context_synchronously
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const ResponsiveLayout(
            mobileScreenLayout: MobileScreenLayout(),
            webScreenLayout: WebScreenLayout(),
          ),
        ),
      );
    }
  }

  void navigateToLogin() {
    //Used to navigate the page
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }

  void navigateToLanding() {
    //Used to navigate to the landing page
    Navigator.of(context) // Push user out so they cannot press the back button
        .pushAndRemoveUntil<void>(
      MaterialPageRoute<void>(
          builder: (BuildContext context) => const LandingScreen()),
      ModalRoute.withName('/'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: hiveWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: hiveBlack),
          onPressed: navigateToLanding,
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            width: double.infinity,
            child: Column(
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      'New to Hive?',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: hiveBlack,
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      'Create an account below',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: hiveBlack,
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                  ],
                ),
                Stack(
                  //Stacks are used to place elements on top of each other
                  children: [
                    _image != null
                        ? CircleAvatar(
                            radius: 64,
                            backgroundImage: MemoryImage(_image!),
                          )
                        : const CircleAvatar(
                            radius: 64,
                            backgroundImage: NetworkImage(
                              'https://t4.ftcdn.net/jpg/04/10/43/77/360_F_410437733_hdq4Q3QOH9uwh0mcqAhRFzOKfrCR24Ta.jpg',
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

                //Text field input for username
                TextFieldInput(
                  textEditingController: _usernameController,
                  hintText: "Username",
                  textInputType: TextInputType.text,
                ),

                const SizedBox(
                  //Adds spacing between the textfields
                  height: 16,
                ),

                //Text field input for email
                TextFieldInput(
                  textEditingController: _emailController,
                  hintText: "Email Address",
                  textInputType: TextInputType.emailAddress,
                ),

                const SizedBox(
                  //Adds spacing between the textfields
                  height: 16,
                ),

                //Text field input for password
                TextFieldInput(
                  textEditingController: _passwordController,
                  hintText: "Password",
                  textInputType: TextInputType.text,
                  isPass: true,
                ),

                const SizedBox(
                  //Adds spacing between the textfields
                  height: 16,
                ),
                TextFieldInput(
                  textEditingController: _ageController,
                  hintText: "Age",
                  textInputType: TextInputType.number,
                ),

                const SizedBox(
                  //Adds spacing between the textfields
                  height: 16,
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFieldInput(
                        textEditingController: _heightController,
                        hintText: "Height (cm)",
                        textInputType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: TextFieldInput(
                        textEditingController: _weightController,
                        hintText: "Weight (kg)",
                        textInputType: TextInputType.number,
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
                    border: OutlineInputBorder(
                        borderSide: Divider.createBorderSide(context)),
                    focusedBorder: OutlineInputBorder(
                        borderSide: Divider.createBorderSide(context)),
                    filled: true,
                    contentPadding: const EdgeInsets.all(8),
                  ),
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
                    selectedGender = value!;
                  },
                ),

                const SizedBox(
                  //Adds spacing between the textfields
                  height: 16,
                ),

                //Text field input for bio
                TextFieldInput(
                  textEditingController: _bioController,
                  hintText: "Write a bio to introduce yourself!",
                  textInputType: TextInputType.text,
                ),

                const SizedBox(
                  //Adds spacing between the textfields
                  height: 30,
                ),

                //Sign Up Button
                // Inkwell is used to wrap the button so it is clickable and runs a function
                InkWell(
                  onTap: signUpUser,
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
                    child: _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: primaryColor,
                            ),
                          )
                        : const Text(
                            "Sign Up",
                            style: TextStyle(
                              color: hiveBlack,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(
                  height: 12,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: const Text(
                        "Already have an account?",
                        style: TextStyle(
                          color: hiveBlack,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    GestureDetector(
                      //Used to allow clicking on the text
                      onTap: navigateToLogin,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: const Text(
                          " Login",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: hiveYellow,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: 40,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
