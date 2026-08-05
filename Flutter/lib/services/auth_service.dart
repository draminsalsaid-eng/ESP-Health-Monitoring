import '../models/user_account.dart';


class AuthService {


  // Temporary local users
  final List<UserAccount> _users = const [

    UserAccount(
      userId: '1001',
      password: '1234',
    ),

    UserAccount(
      userId: 'admin',
      password: 'admin',
    ),

  ];



  Future<bool> login(
    String userId,
    String password,
  ) async {


    await Future.delayed(
      const Duration(milliseconds:500),
    );


    for(final user in _users){

      if(user.userId == userId &&
         user.password == password){

        return true;

      }

    }


    return false;

  }

}
