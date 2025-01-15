
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'launching.dart';
import 'notification_provider.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  /*await Firebase.initializeApp(options: const FirebaseOptions(
    apiKey: "AIzaSyARn1DpdxpXekr7Phfxht60bBDBqTzlcVg",
     appId: "1:345118548610:android:1fa9d83491df3b0b6aca9b",
      messagingSenderId: "345118548610",
       projectId: "ebetz-91c72"
    )
  );*/
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  runApp(ChangeNotifierProvider(
      create: (_) => NotificationProvider(),
      child:const MyApp(),
    ),);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home:SplashScreen(),
    );
  }
}
