import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


import '../constants/worker_constants.dart';

import '../models/user_input.dart';

import '../providers/auth_provider.dart';
import '../providers/health_provider.dart';



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



  String worker =
      workerTypes.first;



  String activity =
      activities.first;



  String environment =
      environments.first;





  bool sending = false;






  Future<void> _saveWorkerData() async {



    final auth =
        Provider.of<AuthProvider>(
          context,
          listen:false,
        );




    final health =
        Provider.of<HealthProvider>(
          context,
          listen:false,
        );





    if(auth.userId == null){

      return;

    }





    final input =
        UserInput(

          userId:
              auth.userId!,


          workerType:
              worker,


          activity:
              activity,


          environment:
              environment,


        );






    setState(() {

      sending = true;

    });





    await health.startMonitoring(
      input,
    );





    if(mounted){


      setState(() {

        sending = false;

      });


    }





  }









  @override
  Widget build(BuildContext context) {


    return Scaffold(



      appBar: AppBar(

        title:
        const Text(
          "Worker Information",
        ),

      ),






      body:

      Padding(

        padding:
        const EdgeInsets.all(20),



        child:

        Column(



          children: [





            DropdownButtonFormField<String>(


              value:
              worker,


              items:

              workerTypes.map((e){


                return DropdownMenuItem(


                  value:e,


                  child:
                  Text(e),


                );


              }).toList(),



              onChanged:(value){


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


                return DropdownMenuItem(


                  value:e,


                  child:
                  Text(e),


                );


              }).toList(),




              onChanged:(value){


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


                return DropdownMenuItem(


                  value:e,


                  child:
                  Text(e),


                );


              }).toList(),




              onChanged:(value){


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
                sending
                ? null
                : _saveWorkerData,



                child:

                sending

                ?

                const CircularProgressIndicator()

                :

                const Text(
                  "Save & Start Monitoring",
                ),


              ),


            )



          ],


        ),


      ),


    );


  }



}
