import 'package:flutter/material.dart';

import '../constants/worker_constants.dart';

class WorkerSetupScreen extends StatefulWidget {

  const WorkerSetupScreen({super.key});

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
        title: const Text("Worker Information"),
      ),

      body: Padding(

        padding: const EdgeInsets.all(20),

        child: Column(

          children: [

            DropdownButtonFormField(

              value: worker,

              items: workerTypes.map((e){

                return DropdownMenuItem(

                  value: e,

                  child: Text(e),

                );

              }).toList(),

              onChanged: (value){

                setState(() {

                  worker = value!;

                });

              },

              decoration: const InputDecoration(

                labelText: "Worker Type",

              ),

            ),

            const SizedBox(height:20),

            DropdownButtonFormField(

              value: activity,

              items: activities.map((e){

                return DropdownMenuItem(

                  value: e,

                  child: Text(e),

                );

              }).toList(),

              onChanged: (value){

                setState(() {

                  activity = value!;

                });

              },

              decoration: const InputDecoration(

                labelText: "Activity",

              ),

            ),

            const SizedBox(height:20),

            DropdownButtonFormField(

              value: environment,

              items: environments.map((e){

                return DropdownMenuItem(

                  value: e,

                  child: Text(e),

                );

              }).toList(),

              onChanged: (value){

                setState(() {

                  environment = value!;

                });

              },

              decoration: const InputDecoration(

                labelText: "Environment",

              ),

            ),

            const Spacer(),

            SizedBox(

              width: double.infinity,

              child: ElevatedButton(

                onPressed: () async {

                  // هنا سنرسلها إلى ESP32

                },

                child: const Text("Save & Continue"),

              ),

            )

          ],

        ),

      ),

    );

  }

}
