import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/worker_constants.dart';
import '../providers/worker_provider.dart';


class WorkerSetupScreen extends StatefulWidget {

  const WorkerSetupScreen({
    super.key,
  });


  @override
  State<WorkerSetupScreen> createState() =>
      _WorkerSetupScreenState();

}



class _WorkerSetupScreenState
    extends State<WorkerSetupScreen> {


  String worker = workerTypes.first;

  String activity = activities.first;

  String environment = environments.first;



  @override
  Widget build(BuildContext context) {


    return Scaffold(


      appBar: AppBar(

        title:
        const Text(
          "Worker Information",
        ),

      ),



      body: Padding(


        padding:
        const EdgeInsets.all(20),



        child: Column(


          children: [



            DropdownButtonFormField<String>(


              value:
              worker,



              items:
              workerTypes.map((e){


                return DropdownMenuItem<String>(


                  value:
                  e,


                  child:
                  Text(e),


                );


              }).toList(),



              onChanged:
              (value){


                setState(() {


                  worker =
                      value!;


                });


              },



              decoration:
              const InputDecoration(


                labelText:
                "Worker Type",


                border:
                OutlineInputBorder(),


              ),


            ),




            const SizedBox(
              height:20,
            ),





            DropdownButtonFormField<String>(


              value:
              activity,



              items:
              activities.map((e){


                return DropdownMenuItem<String>(


                  value:
                  e,


                  child:
                  Text(e),


                );


              }).toList(),



              onChanged:
              (value){


                setState(() {


                  activity =
                      value!;


                });


              },



              decoration:
              const InputDecoration(


                labelText:
                "Activity",


                border:
                OutlineInputBorder(),


              ),


            ),





            const SizedBox(
              height:20,
            ),






            DropdownButtonFormField<String>(


              value:
              environment,



              items:
              environments.map((e){


                return DropdownMenuItem<String>(


                  value:
                  e,


                  child:
                  Text(e),


                );


              }).toList(),



              onChanged:
              (value){


                setState(() {


                  environment =
                      value!;


                });


              },



              decoration:
              const InputDecoration(


                labelText:
                "Environment",


                border:
                OutlineInputBorder(),


              ),


            ),





            const Spacer(),





            SizedBox(


              width:
              double.infinity,



              height:
              50,



              child:
              ElevatedButton(


                onPressed:
                () {


                  /*
                    حفظ بيانات العامل
                    داخل التطبيق
                  */


                  Provider.of<WorkerProvider>(

                    context,

                    listen:false,

                  ).saveData(


                    worker:
                    worker,


                    activityName:
                    activity,


                    environmentName:
                    environment,


                  );





                  ScaffoldMessenger.of(context)
                      .showSnackBar(


                    const SnackBar(


                      content:
                      Text(
                        "Worker information saved",
                      ),


                    ),


                  );



                  /*
                    هنا لاحقاً سنضيف:
                    إرسال البيانات إلى ESP32
                  */



                },



                child:
                const Text(

                  "Save & Continue",

                  style:
                  TextStyle(

                    fontSize:18,

                  ),

                ),


              ),


            )




          ],


        ),


      ),


    );


  }


}
