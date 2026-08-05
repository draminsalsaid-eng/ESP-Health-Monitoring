import 'package:flutter/foundation.dart';

import '../services/auth_service.dart';



class AuthProvider extends ChangeNotifier {


  final AuthService _authService =
      AuthService();



  bool _isLoading = false;

  bool get isLoading => _isLoading;



  bool _loggedIn = false;

  bool get loggedIn => _loggedIn;



  String? _userId;

  String? get userId => _userId;



  String? _error;

  String? get error => _error;





  Future<bool> login(
      String userId,
      String password,
  ) async {


    _isLoading = true;

    _error = null;

    notifyListeners();



    final result =
        await _authService.login(
          userId,
          password,
        );



    if(result){

      _loggedIn = true;

      _userId = userId;

    }

    else{

      _error =
        'Invalid User ID or Password';

    }



    _isLoading = false;

    notifyListeners();



    return result;

  }



  void logout(){

    _loggedIn = false;

    _userId = null;

    notifyListeners();

  }


}
