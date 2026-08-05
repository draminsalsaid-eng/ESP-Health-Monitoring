import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/splash_screen.dart';

import 'providers/auth_provider.dart';
import 'providers/health_provider.dart';



void main() {

  runApp(

    const ESPHealthApp(),

  );

}





class ESPHealthApp extends StatelessWidget {


  const ESPHealthApp({
    super.key,
  });



  @override
  Widget build(BuildContext context) {


    return MultiProvider(

      providers: [


        ChangeNotifierProvider(

          create: (_) =>
              AuthProvider(),

        ),



        ChangeNotifierProvider(

          create: (_) =>
              HealthProvider(),

        ),


      ],



      child: MaterialApp(


        title:
            'ESP Health Monitoring',



        debugShowCheckedModeBanner:
            false,



        theme:
            ThemeData(

          primarySwatch:
              Colors.blue,

          useMaterial3:
              true,

        ),



        home:
            const SplashScreen(),


      ),

    );


  }

}
