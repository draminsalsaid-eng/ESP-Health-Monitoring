import 'package:flutter/material.dart';


class SettingsScreen extends StatelessWidget {

  const SettingsScreen({super.key});


  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text(
          "Settings",
        ),

        centerTitle: true,

      ),


      body: Padding(

        padding: const EdgeInsets.all(16.0),


        child: Column(

          children: [


            Card(

              child: ListTile(

                leading: const Icon(
                  Icons.router,
                  color: Colors.blue,
                ),

                title: const Text(
                  "ESP32 IP Address",
                ),

                subtitle: const Text(
                  "192.168.1.100",
                ),

                trailing: const Icon(
                  Icons.edit,
                ),

              ),

            ),


            Card(

              child: ListTile(

                leading: const Icon(
                  Icons.timer,
                  color: Colors.orange,
                ),

                title: const Text(
                  "Refresh Interval",
                ),

                subtitle: const Text(
                  "5 Seconds",
                ),

              ),

            ),


            Card(

              child: SwitchListTile(

                secondary: const Icon(
                  Icons.dark_mode,
                  color: Colors.indigo,
                ),

                title: const Text(
                  "Dark Mode",
                ),

                value: false,

                onChanged: (value) {},

              ),

            ),


            Card(

              child: ListTile(

                leading: const Icon(
                  Icons.language,
                  color: Colors.green,
                ),

                title: const Text(
                  "Language",
                ),

                subtitle: const Text(
                  "Arabic / English",
                ),

              ),

            ),


          ],

        ),

      ),

    );

  }

}
