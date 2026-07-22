import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {

  const DashboardScreen({super.key});


  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text(
          "Health Dashboard",
        ),

        centerTitle: true,

      ),


      body: Padding(

        padding: const EdgeInsets.all(16.0),

        child: Column(

          children: [

            VitalCard(

              title: "Heart Rate",

              value: "76 BPM",

              icon: Icons.favorite,

              color: Colors.red,

            ),


            VitalCard(

              title: "SpO₂",

              value: "98 %",

              icon: Icons.water_drop,

              color: Colors.blue,

            ),


            VitalCard(

              title: "Temperature",

              value: "36.8 °C",

              icon: Icons.thermostat,

              color: Colors.orange,

            ),


            VitalCard(

              title: "AI Status",

              value: "Normal",

              icon: Icons.psychology,

              color: Colors.green,

            ),


          ],

        ),

      ),

    );

  }

}



class VitalCard extends StatelessWidget {


  final String title;

  final String value;

  final IconData icon;

  final Color color;



  const VitalCard({

    super.key,

    required this.title,

    required this.value,

    required this.icon,

    required this.color,

  });



  @override
  Widget build(BuildContext context) {


    return Card(

      elevation: 4,

      margin: const EdgeInsets.only(bottom: 15),


      child: ListTile(

        leading: CircleAvatar(

          backgroundColor: color,

          child: Icon(

            icon,

            color: Colors.white,

          ),

        ),


        title: Text(

          title,

          style: const TextStyle(

            fontSize: 18,

            fontWeight: FontWeight.bold,

          ),

        ),


        trailing: Text(

          value,

          style: TextStyle(

            fontSize: 18,

            color: color,

            fontWeight: FontWeight.bold,

          ),

        ),

      ),

    );

  }

}
