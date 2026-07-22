import 'package:flutter/material.dart';

import 'dashboard_screen.dart';
import 'history_screen.dart';
import 'ai_screen.dart';
import 'settings_screen.dart';


class HomeNavigation extends StatefulWidget {

  const HomeNavigation({super.key});


  @override
  State<HomeNavigation> createState() => _HomeNavigationState();

}



class _HomeNavigationState extends State<HomeNavigation> {


  int currentIndex = 0;


  final List<Widget> pages = [

    const DashboardScreen(),

    const HistoryScreen(),

    const AIScreen(),

    const SettingsScreen(),

  ];



  @override
  Widget build(BuildContext context) {


    return Scaffold(

      body: pages[currentIndex],


      bottomNavigationBar: BottomNavigationBar(


        currentIndex: currentIndex,


        type: BottomNavigationBarType.fixed,


        selectedItemColor: Colors.blue,


        unselectedItemColor: Colors.grey,


        onTap: (index) {


          setState(() {

            currentIndex = index;

          });


        },


        items: const [


          BottomNavigationBarItem(

            icon: Icon(Icons.dashboard),

            label: "Dashboard",

          ),


          BottomNavigationBarItem(

            icon: Icon(Icons.history),

            label: "History",

          ),


          BottomNavigationBarItem(

            icon: Icon(Icons.psychology),

            label: "AI",

          ),


          BottomNavigationBarItem(

            icon: Icon(Icons.settings),

            label: "Settings",

          ),


        ],


      ),

    );

  }

}
