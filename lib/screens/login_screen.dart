import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive_flutter/resources/auth_methods.dart';
import 'package:hive_flutter/screens/admin_screen.dart';
import 'package:hive_flutter/screens/landing_screen.dart';
import 'package:hive_flutter/screens/signup_screen.dart';
import 'package:hive_flutter/utils/colors.dart';
import 'package:hive_flutter/utils/utils.dart';
import 'package:hive_flutter/widgets/text_field_input.dart';

import '../responsive/mobile_screen_layout.dart';
import '../responsive/responsive_layout_screen.dart';
import '../responsive/web_screen_layout.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    //Used to clear the text controllers as soon as the widgets get disposed.
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  // Used to login the user to the application
  void loginUser() async {
    setState(() {
      _isLoading = true;
    });
    String res = await AuthMethods().loginUser(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (_emailController.text == "admin" &&
        _passwordController.text == "admin") {
      // ignore: use_build_context_synchronously
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const AdminScreen(),
        ),
      );
    } else if (res == "success") {
      // ignore: use_build_context_synchronously
      Navigator.of(context).pushReplacement(
        // Push replacement ensures the user cant press back to go back
        MaterialPageRoute(
          builder: (context) => const ResponsiveLayout(
            mobileScreenLayout: MobileScreenLayout(),
            webScreenLayout: WebScreenLayout(),
          ),
        ),
      );
    } else {
      // ignore: use_build_context_synchronously
      showSnackBar(res, context);
    }
    setState(() {
      _isLoading = false;
    });
  }

  void navigateToSignup() {
    //Used to navigate the page
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SignupScreen(),
      ),
    );
  }

  void navigateToLanding() {
    //Used to navigate to the landing page
    Navigator.of(context) // Push user out so they cannot press the back button
        .pushReplacement(
      MaterialPageRoute(
        builder: (context) => const LandingScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    //var screenWidth = MediaQuery.of(context).size.width;

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
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            width: double.infinity,
            child: Column(
              children: [
                Center(
                  child: SvgPicture.asset(
                    'assets/hive_logo.svg',
                    height: screenHeight * 0.2,
                    // ignore: deprecated_member_use
                    color: hiveYellow,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const Text(
                      'Welcome Back,',
                      style: TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.w800,
                        color: hiveBlack,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      'Let\'s get to training, shall we?',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        color: hiveBlack,
                      ),
                    ),
                    const SizedBox(
                      height: 40,
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
                      height: 36,
                    ),

                    //Login Button
                    InkWell(
                      onTap: loginUser,
                      // Used to wrap the button so it is clickable and runs a fucntion
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
                        child:
                            _isLoading // IF the state "is loading", then show a circular progress indicator, else...
                                ? const Center(
                                    child: CircularProgressIndicator(
                                      color: primaryColor,
                                    ),
                                  )
                                : const Text(
                                    "Login",
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
                    //Transition to Sign Up
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: const Text(
                            "Don't have an account?",
                            style: TextStyle(
                              color: hiveBlack,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        GestureDetector(
                          //Used to allow clicking on the text
                          onTap: navigateToSignup,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: const Text(
                              " Sign up",
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
                      height: 24,
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
