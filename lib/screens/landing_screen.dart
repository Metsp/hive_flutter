import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
// import 'package:hive_flutter/resources/auth_methods.dart';
import 'package:hive_flutter/screens/signup_screen.dart';
import 'package:hive_flutter/utils/colors.dart';
// import 'package:hive_flutter/utils/utils.dart';
// import 'package:hive_flutter/widgets/text_field_input.dart';
// import '../responsive/mobile_screen_layout.dart';
// import '../responsive/responsive_layout_screen.dart';
// import '../responsive/web_screen_layout.dart';
import 'login_screen.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with SingleTickerProviderStateMixin {
  //Animation controllers used for animating the background
  late AnimationController _controller;
  late Animation<Alignment> _topAlignmentAnimation;
  late Animation<Alignment> _bottomAlignmentAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(
        seconds: 6,
      ),
    );
    _topAlignmentAnimation = TweenSequence<Alignment>(
      [
        TweenSequenceItem<Alignment>(
          tween: Tween<Alignment>(
              begin: Alignment.topLeft, end: Alignment.topRight),
          weight: 1,
        ),
        TweenSequenceItem<Alignment>(
          tween: Tween<Alignment>(
              begin: Alignment.topRight, end: Alignment.bottomRight),
          weight: 1,
        ),
        TweenSequenceItem<Alignment>(
          tween: Tween<Alignment>(
              begin: Alignment.bottomRight, end: Alignment.bottomLeft),
          weight: 1,
        ),
        TweenSequenceItem<Alignment>(
          tween: Tween<Alignment>(
              begin: Alignment.bottomLeft, end: Alignment.topLeft),
          weight: 1,
        ),
      ],
    ).animate(_controller);

    _bottomAlignmentAnimation = TweenSequence<Alignment>(
      [
        TweenSequenceItem<Alignment>(
          tween: Tween<Alignment>(
              begin: Alignment.bottomRight, end: Alignment.bottomLeft),
          weight: 1,
        ),
        TweenSequenceItem<Alignment>(
          tween: Tween<Alignment>(
              begin: Alignment.bottomLeft, end: Alignment.topLeft),
          weight: 1,
        ),
        TweenSequenceItem<Alignment>(
          tween: Tween<Alignment>(
              begin: Alignment.topLeft, end: Alignment.topRight),
          weight: 1,
        ),
        TweenSequenceItem<Alignment>(
          tween: Tween<Alignment>(
              begin: Alignment.topRight, end: Alignment.bottomRight),
          weight: 1,
        ),
      ],
    ).animate(_controller);

    _controller.repeat();
  }

  void navigateToSignup() {
    //Used to navigate the page
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SignupScreen(),
      ),
    );
  }

  void navigateToLogin() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: const [
                    hiveOrange,
                    hiveYellow,
                  ],
                  begin: _topAlignmentAnimation.value,
                  end: _bottomAlignmentAnimation.value,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // SVG Logo
                    Row(
                      children: [
                        Expanded(
                          child: SvgPicture.asset(
                            'assets/hive_logo.svg',
                            height: screenHeight * 0.6,
                            // ignore: deprecated_member_use
                            color: hiveYellow,
                          ),
                        ),
                        Text(
                          'Hive',
                          style: TextStyle(
                            fontSize: screenWidth * 0.25,
                            color: hiveWhite,
                          ),
                        ),
                      ],
                    ),

                    // Column for Text
                    const Column(
                      children: [
                        Text(
                          'Track, Share, Achieve',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: hiveBlack,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          'The only fitness app you will ever need.',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: hiveBlack,
                          ),
                          textAlign: TextAlign.center,
                        )
                      ],
                    ),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: navigateToLogin,
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              foregroundColor: hiveBlack,
                              side: const BorderSide(color: hiveBlack),
                              padding: const EdgeInsets.symmetric(
                                vertical: 20,
                              ),
                            ),
                            child: Text(
                              'Login'.toUpperCase(),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: navigateToSignup,
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              foregroundColor: hiveWhite,
                              backgroundColor: hiveBlack,
                              side: const BorderSide(color: hiveBlack),
                              padding: const EdgeInsets.symmetric(
                                vertical: 20,
                              ),
                            ),
                            child: Text(
                              'Sign Up'.toUpperCase(),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          }),
    );
  }
}
