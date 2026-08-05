import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/worker_constants.dart';
import '../models/user_input.dart';
import '../providers/auth_provider.dart';
import '../services/esp_service.dart';

import 'home_navigation.dart';



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



  final ESPService espService =
      ESPService();





  Future<void> _saveWorkerData() async {


    setState(() {

      sending = true;

    });




    try {



      final auth =
          Provider.of<AuthProvider>(
            context,
            listen:false,
          );





      final userInput =
          UserInput(


            userId:
              auth.userId ?? "unknown",



            workerType:
              worker,



            activity:
              activity,



            workplace:
              environment,



          );






      await espService.sendUserInput(

        userInput,

      );






      if(!mounted) return;





      Navigator.pushReplacement(


        context,


        MaterialPageRoute(


          builder: (_) =>
              const HomeNavigation(),


        ),


      );






    }


    catch(e){



      if(!mounted) return;



      ScaffoldMessenger.of(context)
          .showSnackBar(


            SnackBar(


              content:
              Text(

                "ESP32 Error : $e",

              ),



              backgroundColor:
                  Colors.red,


            ),


          );


    }



    finally{


      if(mounted){


        setState(() {


          sending=false;


        });


      }


    }



  }








  @override
  Widget build(BuildContext context) {


    return Scaffold(



      appBar:
      AppBar(

        title:
        const Text(

          "Worker Setup",

        ),

        centerTitle:true,

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



              decoration:
              const InputDecoration(

                labelText:
                "Worker Type",

                border:
                OutlineInputBorder(),

              ),




              items:

              workerTypes.map((item){



                return DropdownMenuItem(


                  value:item,


                  child:
                  Text(item),


                );



              }).toList(),





              onChanged:(value){


                setState(() {


                  worker =
                  value!;


                });


              },



            ),






            const SizedBox(height:20),






            DropdownButtonFormField<String>(


              value:
              activity,



              decoration:
              const InputDecoration(

                labelText:
                "Activity",

                border:
                OutlineInputBorder(),


              ),





              items:


              activities.map((item){



                return DropdownMenuItem(


                  value:item,


                  child:
                  Text(item),


                );



              }).toList(),





              onChanged:(value){



                setState(() {


                  activity =
                  value!;


                });


              },


            ),







            const SizedBox(height:20),








            DropdownButtonFormField<String>(


              value:
              environment,



              decoration:
              const InputDecoration(

                labelText:
                "Environment",

                border:
                OutlineInputBorder(),


              ),





              items:


              environments.map((item){



                return DropdownMenuItem(


                  value:item,


                  child:
                  Text(item),


                );



              }).toList(),






              onChanged:(value){



                setState(() {


                  environment =
                  value!;


                });



              },



            ),







            const Spacer(),






            SizedBox(



              width:
              double.infinity,



              height:
              55,




              child:


              ElevatedButton(



                onPressed:
                sending
                ? null
                : _saveWorkerData,



                child:

                sending

                ?

                const CircularProgressIndicator(
                  color:Colors.white,
                )


                :

                const Text(

                  "SAVE & START",

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
