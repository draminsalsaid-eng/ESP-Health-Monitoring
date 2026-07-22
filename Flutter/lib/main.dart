import 'package:flutter/material.dart';

void main() {
  runApp(const ESPHealthApp());
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
      ),

      home: const HomePage(),
    );
  }
}


class HomePage extends StatelessWidget {

  const HomePage({super.key});


  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          "ESP Health Monitoring",
        ),
      ),


      body: const Center(

        child: Text(

          "System Ready",

          style: TextStyle(

            fontSize: 24,

            fontWeight: FontWeight.bold,

          ),

        ),

      ),

    );

  }
}
