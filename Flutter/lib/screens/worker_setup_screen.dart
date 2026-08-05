import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/worker_constants.dart';
import '../models/user_input.dart';
import '../providers/health_provider.dart';

import 'home_navigation.dart';



class WorkerSetupScreen extends StatefulWidget {


  final String userId;



  const WorkerSetupScreen({

    super.key,

    required this.userId,

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



  bool loading = false;








  Future<void> _startMonitoring() async {



    setState(() {

      loading = true;

    });






    final health =
        Provider.of<HealthProvider>(

          context,

          listen:false,

        );








    final userInput =
        UserInput(


          userId:

          widget.userId,



          workerType:

          worker,



          activity:

          activity,



          environment:

          environment,



        );








    await health.startMonitoring(

      userInput,

    );









    if(!mounted) return;







    setState(() {

      loading = false;

    });







    Navigator.pushReplacement(


      context,


      MaterialPageRoute(


        builder: (_) =>

            const HomeNavigation(),


      ),


    );





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



          children:[








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

              workerTypes.map((e){



                return DropdownMenuItem(



                  value:e,



                  child:

                  Text(e),



                );



              }).toList(),







              onChanged:(value){



                setState(() {



                  worker = value!;



                });



              },




            ),







            const SizedBox(

              height:20,

            ),







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

              activities.map((e){



                return DropdownMenuItem(



                  value:e,



                  child:

                  Text(e),



                );



              }).toList(),







              onChanged:(value){



                setState(() {



                  activity = value!;



                });



              },




            ),







            const SizedBox(

              height:20,

            ),







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

              environments.map((e){



                return DropdownMenuItem(



                  value:e,



                  child:

                  Text(e),



                );



              }).toList(),







              onChanged:(value){



                setState(() {



                  environment = value!;



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

                loading

                ? null

                : _startMonitoring,







                child:


                loading



                ?



                const CircularProgressIndicator(


                  color:

                  Colors.white,


                )





                :





                const Text(



                  "SAVE & START MONITORING",




                  style:



                  TextStyle(



                    fontSize:17,



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
