import 'package:flutter/material.dart';


class AIScreen extends StatelessWidget {

  const AIScreen({super.key});


  @override
  Widget build(BuildContext context) {


    return Scaffold(

      appBar: AppBar(

        title: const Text(
          "AI Health Analysis",
        ),

        centerTitle: true,

      ),


      body: Padding(

        padding: const EdgeInsets.all(16.0),


        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,


          children: [


            Card(

              elevation: 4,


              child: Padding(

                padding: const EdgeInsets.all(20),


                child: Column(

                  crossAxisAlignment: CrossAxisAlignment.start,


                  children: [


                    const Row(

                      children: [

                        Icon(

                          Icons.psychology,

                          color: Colors.blue,

                          size: 35,

                        ),


                        SizedBox(width: 10),


                        Text(

                          "AI Report",

                          style: TextStyle(

                            fontSize: 22,

                            fontWeight: FontWeight.bold,

                          ),

                        ),

                      ],

                    ),


                    const SizedBox(height: 20),


                    const Text(

                      "Patient status is stable.",

                      style: TextStyle(

                        fontSize: 18,

                      ),

                    ),


                    const SizedBox(height: 10),


                    const Text(

                      "No abnormal health indicators detected.",

                      style: TextStyle(

                        fontSize: 16,

                      ),

                    ),


                  ],

                ),

              ),

            ),


            const SizedBox(height: 25),


            Card(

              color: Colors.green.shade50,


              child: const ListTile(

                leading: Icon(

                  Icons.check_circle,

                  color: Colors.green,

                  size: 35,

                ),


                title: Text(

                  "Risk Level",

                  style: TextStyle(

                    fontWeight: FontWeight.bold,

                  ),

                ),


                subtitle: Text(

                  "LOW",

                ),

              ),

            ),


          ],

        ),

      ),

    );

  }

}
