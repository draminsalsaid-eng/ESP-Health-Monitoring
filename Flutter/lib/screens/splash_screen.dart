import 'package:flutter/material.dart';
import 'home_navigation.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}


class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();

    Future.delayed(
      const Duration(seconds: 3),
      () {
       Navigator.pushReplacement(
       context,
       MaterialPageRoute(
       builder: (context) => const HomeNavigation(),
          ),
       );
      },
    );
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.blue,

      body: Center(

        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,

          children: [

            const Icon(
              Icons.favorite,
              color: Colors.white,
              size: 90,
            ),

            const SizedBox(height: 20),

            const Text(

              "ESP Health Monitoring",

              style: TextStyle(

                color: Colors.white,

                fontSize: 26,

                fontWeight: FontWeight.bold,

              ),

            ),

            const SizedBox(height: 10),

            const Text(

              "AI Medical System",

              style: TextStyle(

                color: Colors.white70,

                fontSize: 18,

              ),

            ),

          ],

        ),

      ),

    );

  }
}
