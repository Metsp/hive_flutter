import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/providers/user_provider.dart';
import 'package:hive_flutter/responsive/mobile_screen_layout.dart';
import 'package:hive_flutter/responsive/responsive_layout_screen.dart';
import 'package:hive_flutter/responsive/web_screen_layout.dart';
import 'package:hive_flutter/screens/landing_screen.dart';
import 'package:hive_flutter/utils/colors.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); //Added to initialize the binder and fix the "FlutterError (Binding has not yet been initialized." error.
  if (kIsWeb) {
    //Check if web app or mobile app, if web app, then initialize firebase another way
    await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: 'AIzaSyC-bHCPTkfxz0tmhF-jfzwQcUEd4PLwzAg',
          appId: '1:613818040318:web:2f600ae4a3395cfae20aaf',
          messagingSenderId: '613818040318',
          projectId: 'hivefitness-d6d3a',
          storageBucket: "hivefitness-d6d3a.appspot.com"),
    );
  } else {
    await Firebase.initializeApp(); // Used to initialize the app in firebase
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      //Wrap with multiprovider as a one time setup
      providers: [
        ChangeNotifierProvider(
          create: (_) => UserProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner:
            false, //NOTE: Used to disable the "Debug" banner.
        title: 'Hive',
        theme: ThemeData.light().copyWith(
          scaffoldBackgroundColor: hiveWhite,
          textTheme: ThemeData.light().textTheme.apply(
                fontFamily: 'Inter',
              ),
          primaryTextTheme: ThemeData.light().textTheme.apply(
                fontFamily: 'Inter',
              ),
          textSelectionTheme:
              const TextSelectionThemeData(cursorColor: hiveYellow),
        ),
        home: StreamBuilder(
          stream: FirebaseAuth.instance
              .authStateChanges(), //AuthStateChanges only runs only when the user signs in or signs out
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              if (snapshot.hasData) {
                return const ResponsiveLayout(
                  mobileScreenLayout: MobileScreenLayout(),
                  webScreenLayout: WebScreenLayout(),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('${snapshot.error}'),
                );
              }
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: primaryColor,
                ),
              );
            }
            return const LandingScreen(); //Check if the user is authenticated, if not, return login screen
          },
        ),
      ),
    );
  }
}
