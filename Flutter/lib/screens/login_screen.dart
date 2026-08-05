import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'worker_setup_screen.dart';
import '../providers/auth_provider.dart';
import '../services/esp_service.dart';
import '../models/user_input.dart';
 
import 'home_navigation.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController userController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  bool obscurePassword = true;

  final ESPService espService = ESPService();

  String selectedWorkerType = "Worker";
  String selectedActivity = "Standing";
  String selectedWorkplace = "Factory";

  final List<String> workerTypes = [
    "Worker",
    "Engineer",
    "Technician",
    "Supervisor",
  ];

  final List<String> activities = [
    "Resting",
    "Standing",
    "Walking",
    "Running",
    "Lifting",
  ];

  final List<String> workplaces = [
    "Factory",
    "Warehouse",
    "Outdoor",
    "Office",
  ];

  @override
  void dispose() {
    userController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final auth =
        Provider.of<AuthProvider>(
      context,
      listen: false,
    );

    final success = await auth.login(
      userController.text.trim(),
      passwordController.text.trim(),
    );

    if (!success || !mounted) {
      return;
    }

    try {
      final user = UserInput(
        userId: userController.text.trim(),
        workerType: selectedWorkerType,
        activity: selectedActivity,
        workplace: selectedWorkplace,
      );

      await espService.sendUserInput(user);

      if (!mounted) return;

      Navigator.pushReplacement(
  context,
  MaterialPageRoute(
    builder: (_) => const WorkerSetupScreen(),
  ),
);
      
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "ESP32 Connection Error\n$e",
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth =
        Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
        centerTitle: true,
      ),

      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),

          child: Column(
            children: [

              const Icon(
                Icons.health_and_safety,
                size: 90,
                color: Colors.green,
              ),

              const SizedBox(height: 20),

              const Text(
                "ESP Health Monitoring",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 35),

              TextField(
                controller: userController,
                decoration: const InputDecoration(
                  labelText: "User ID",
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: passwordController,
                obscureText: obscurePassword,
                decoration: InputDecoration(
                  labelText: "Password",
                  prefixIcon: const Icon(Icons.lock),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        obscurePassword =
                            !obscurePassword;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 20),

              DropdownButtonFormField<String>(
                value: selectedWorkerType,
                decoration: const InputDecoration(
                  labelText: "Worker Type",
                  border: OutlineInputBorder(),
                ),
                items: workerTypes.map((item) {
                  return DropdownMenuItem(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedWorkerType = value!;
                  });
                },
              ),

              const SizedBox(height: 20),

              DropdownButtonFormField<String>(
                value: selectedActivity,
                decoration: const InputDecoration(
                  labelText: "Activity",
                  border: OutlineInputBorder(),
                ),
                items: activities.map((item) {
                  return DropdownMenuItem(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedActivity = value!;
                  });
                },
              ),

              const SizedBox(height: 20),

              DropdownButtonFormField<String>(
                value: selectedWorkplace,
                decoration: const InputDecoration(
                  labelText: "Workplace",
                  border: OutlineInputBorder(),
                ),
                items: workplaces.map((item) {
                  return DropdownMenuItem(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedWorkplace = value!;
                  });
                },
              ),

              const SizedBox(height: 20),

              if (auth.error != null)
                Padding(
                  padding:
                      const EdgeInsets.only(bottom: 10),
                  child: Text(
                    auth.error!,
                    style: const TextStyle(
                      color: Colors.red,
                    ),
                  ),
                ),

              SizedBox(
                width: double.infinity,
                height: 55,

                child: ElevatedButton(
                  onPressed: auth.isLoading
                      ? null
                      : _login,

                  child: auth.isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text(
                          "START MONITORING",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
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
