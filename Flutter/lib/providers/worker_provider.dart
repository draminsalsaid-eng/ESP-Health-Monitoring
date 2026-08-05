import 'package:flutter/material.dart';

class WorkerProvider extends ChangeNotifier {

  String workerType = "";
  String activity = "";
  String environment = "";

  void saveData({
    required String worker,
    required String activityName,
    required String environmentName,
  }) {

    workerType = worker;
    activity = activityName;
    environment = environmentName;

    notifyListeners();
  }
}
