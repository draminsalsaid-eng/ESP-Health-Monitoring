import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import 'dashboard_screen.dart';



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



    if(success && mounted){

     Navigator.pushReplacement(
  context,
  MaterialPageRoute(
    builder: (_) =>
        const HomeNavigation(),
  ),
);


    }

  }





  @override
  Widget build(BuildContext context) {


    final auth =
        Provider.of<AuthProvider>(
          context,
        );



    return Scaffold(


      body: Center(


        child: SingleChildScrollView(


          padding:
              const EdgeInsets.all(30),


          child: Column(


            mainAxisAlignment:
                MainAxisAlignment.center,


            children: [



              const Icon(
                Icons.health_and_safety,
                size:80,
                color:Colors.green,
              ),



              const SizedBox(
                height:20,
              ),



              const Text(
                'ESP Health Monitoring',
                style:TextStyle(
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
                    'User ID',

                  border:
                    OutlineInputBorder(),

                  prefixIcon:
                    Icon(Icons.person),

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
                    'Password',


                  border:
                    const OutlineInputBorder(),


                  prefixIcon:
                    const Icon(Icons.lock),


                  suffixIcon:
                    IconButton(

                      icon:
                      Icon(
                        obscurePassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                      ),


                      onPressed:(){

                        setState((){

                          obscurePassword =
                              !obscurePassword;

                        });

                      },

                    ),

                ),

              ),





              const SizedBox(
                height:25,
              ),




              if(auth.error != null)

                Text(

                  auth.error!,

                  style:
                    const TextStyle(
                      color:Colors.red,
                    ),

                ),





              const SizedBox(
                height:15,
              ),





              SizedBox(

                width:
                  double.infinity,


                height:
                  50,


                child:
                ElevatedButton(


                  onPressed:
                  auth.isLoading
                  ? null
                  : _login,


                  child:

                  auth.isLoading

                  ?

                  const CircularProgressIndicator()

                  :

                  const Text(
                    'LOGIN',
                    style:
                    TextStyle(
                      fontSize:18,
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
