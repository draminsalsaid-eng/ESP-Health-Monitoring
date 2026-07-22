import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';


void main() {

  runApp(
    const ESPHealthApp(),
  );

}



class ESPHealthApp extends StatelessWidget {

  const ESPHealthApp({super.key});


  @override
  Widget build(BuildContext context) {

    return MaterialApp(

      title: 'ESP Health Monitoring',

      debugShowCheckedModeBanner: false,


      theme: ThemeData(

        primarySwatch: Colors.blue,

        useMaterial3: true,

      ),


      home: const SplashScreen(),

    );

  }

}
