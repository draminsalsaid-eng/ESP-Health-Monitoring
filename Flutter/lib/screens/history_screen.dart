import 'package:flutter/material.dart';


class HistoryScreen extends StatelessWidget {

  const HistoryScreen({super.key});


  @override
  Widget build(BuildContext context) {

    final historyData = [

      {
        "time": "10:30 AM",
        "heart": "76 BPM",
        "spo2": "98 %",
        "temp": "36.8 °C",
      },

      {
        "time": "10:35 AM",
        "heart": "78 BPM",
        "spo2": "97 %",
        "temp": "36.9 °C",
      },

      {
        "time": "10:40 AM",
        "heart": "80 BPM",
        "spo2": "99 %",
        "temp": "36.7 °C",
      },

    ];


    return Scaffold(

      appBar: AppBar(

        title: const Text(
          "Health History",
        ),

        centerTitle: true,

      ),


      body: ListView.builder(

        padding: const EdgeInsets.all(16),


        itemCount: historyData.length,


        itemBuilder: (context, index) {


          final item = historyData[index];


          return Card(

            elevation: 3,

            margin: const EdgeInsets.only(bottom: 15),


            child: Padding(

              padding: const EdgeInsets.all(16),


              child: Column(

                crossAxisAlignment: CrossAxisAlignment.start,


                children: [


                  Text(

                    item["time"]!,

                    style: const TextStyle(

                      fontSize: 18,

                      fontWeight: FontWeight.bold,

                    ),

                  ),


                  const SizedBox(height: 10),


                  Text(
                    "❤️ Heart Rate : ${item["heart"]}",
                  ),


                  Text(
                    "🩸 SpO₂ : ${item["spo2"]}",
                  ),


                  Text(
                    "🌡 Temperature : ${item["temp"]}",
                  ),


                ],

              ),

            ),

          );

        },

      ),

    );

  }

}
