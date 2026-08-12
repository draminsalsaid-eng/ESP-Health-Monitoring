import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/health_provider.dart';



class DashboardScreen extends StatefulWidget {


  const DashboardScreen({
    super.key,
  });



  @override
  State<DashboardScreen> createState() =>
      _DashboardScreenState();

}





class _DashboardScreenState
    extends State<DashboardScreen> {



  @override
  void initState(){

    super.initState();


    Future.microtask((){


      Provider.of<HealthProvider>(
        context,
        listen:false,

      ).getLatestHealthData();



    });


  }





  @override
  Widget build(BuildContext context) {



    final health =
        Provider.of<HealthProvider>(
          context,
        );





    final data =
        health.healthData;





    return Scaffold(


      appBar:
      AppBar(

        title:
        const Text(
          "Health Dashboard",
        ),

        centerTitle:true,

      ),






      body:


      RefreshIndicator(


        onRefresh: () async {


          await health
              .getLatestHealthData();


        },



        child:


        ListView(


          padding:
          const EdgeInsets.all(16),



          children: [





            VitalCard(

              title:
              "Heart Rate",

              value:

              data == null

              ? "--"

              :

              "${data.heartRate} BPM",


              icon:
              Icons.favorite,


              color:
              Colors.red,


            ),







            VitalCard(

              title:
              "SpO₂",

              value:

              data == null

              ? "--"

              :

              "${data.spo2} %",


              icon:
              Icons.water_drop,


              color:
              Colors.blue,


            ),







            VitalCard(

              title:
              "Temperature",

              value:

              data == null

              ? "--"

              :

              "${data.environmentTemperature} °C",


              icon:
              Icons.thermostat,


              color:
              Colors.orange,


            ),







            VitalCard(

              title:
              "AI Status",

              value:

              data == null

              ? "Waiting"

              :

              data.prediction,


              icon:
              Icons.psychology,


              color:
              Colors.green,


            ),






            const SizedBox(
              height:20,
            ),






            if(data == null)

              const Center(

                child:
                CircularProgressIndicator(),

              )



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
  Widget build(BuildContext context){



    return Card(


      elevation:4,


      margin:
      const EdgeInsets.only(
        bottom:15,
      ),



      child:


      ListTile(


        leading:
        CircleAvatar(


          backgroundColor:
          color,


          child:
          Icon(

            icon,

            color:
            Colors.white,

          ),


        ),





        title:
        Text(

          title,

          style:
          const TextStyle(

            fontSize:18,

            fontWeight:
            FontWeight.bold,

          ),

        ),






        trailing:
        Text(

          value,

          style:
          TextStyle(

            fontSize:18,

            color:
            color,

            fontWeight:
            FontWeight.bold,

          ),

        ),



      ),



    );


  }


}
