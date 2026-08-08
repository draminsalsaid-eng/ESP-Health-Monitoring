import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'monitoring_home_screen.dart';

import '../providers/auth_provider.dart';



class LoginScreen extends StatefulWidget {


  const LoginScreen({
    super.key,
  });



  @override
  State<LoginScreen> createState() =>
      _LoginScreenState();

}





class _LoginScreenState
    extends State<LoginScreen> {



  final TextEditingController userController =
      TextEditingController();



  final TextEditingController passwordController =
      TextEditingController();




  bool obscurePassword = true;






  @override
  void dispose(){


    userController.dispose();


    passwordController.dispose();


    super.dispose();

  }









  Future<void> _login() async {



    final auth =
        Provider.of<AuthProvider>(
          context,
          listen:false,
        );





    final success =
        await auth.login(

          userController.text.trim(),

          passwordController.text.trim(),

        );







    if(!success || !mounted){

      return;

    }
 Navigator.pushReplacement(
  context,
  MaterialPageRoute(
    builder: (_) => MonitoringHomeScreen(
      userId: userController.text.trim(),
    ),
  ),
);

  }

  @override
  Widget build(BuildContext context) {

    final auth =
        Provider.of<AuthProvider>(
          context,
        );





    return Scaffold(



      appBar: AppBar(

        title:
        const Text(
          "Login",
        ),

        centerTitle:true,

      ),







      body:


      Center(



        child:


        SingleChildScrollView(



          padding:
          const EdgeInsets.all(30),



          child:


          Column(



            children:[







              const Icon(

                Icons.health_and_safety,

                size:90,

                color:Colors.green,

              ),







              const SizedBox(

                height:20,

              ),








              const Text(


                "ESP Health Monitoring",


                style:

                TextStyle(

                  fontSize:24,

                  fontWeight:
                  FontWeight.bold,

                ),


              ),








              const SizedBox(

                height:40,

              ),







              TextField(



                controller:
                userController,



                decoration:

                const InputDecoration(



                  labelText:
                  "User ID",



                  prefixIcon:

                  Icon(
                    Icons.person,
                  ),


 
                  border:

                  OutlineInputBorder(),


                ),



              ),







              const SizedBox(

                height:20,

              ),







              TextField(



                controller:
                passwordController,



                obscureText:
                obscurePassword,



                decoration:

                InputDecoration(



                  labelText:
                  "Password",



                  prefixIcon:

                  const Icon(
                    Icons.lock,
                  ),



                  border:

                  const OutlineInputBorder(),




                  suffixIcon:


                  IconButton(



                    icon:

                    Icon(

                      obscurePassword

                      ?

                      Icons.visibility_off

                      :

                      Icons.visibility,

                    ),




                    onPressed:(){



                      setState(() {



                        obscurePassword =

                        !obscurePassword;



                      });



                    },


                  ),



                ),



              ),







              const SizedBox(

                height:20,

              ),







              if(auth.error != null)


                Padding(


                  padding:

                  const EdgeInsets.only(
                    bottom:15,
                  ),



                  child:


                  Text(


                    auth.error!,



                    style:

                    const TextStyle(

                      color:
                      Colors.red,

                    ),



                  ),


                ),







              SizedBox(



                width:

                double.infinity,



                height:

                55,





                child:

                ElevatedButton(



                  onPressed:

                  auth.isLoading

                  ?

                  null

                  :

                  _login,





                  child:


                  auth.isLoading



                  ?


                  const CircularProgressIndicator(

                    color:
                    Colors.white,

                  )



                  :



                  const Text(



                    "LOGIN",



                    style:

                    TextStyle(

                      fontSize:18,

                      fontWeight:
                      FontWeight.bold,

                    ),


                  ),




                ),



              ),







            ],



          ),



        ),



      ),



    );


  }



}
