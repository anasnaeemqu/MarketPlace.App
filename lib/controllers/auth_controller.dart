import 'package:get/get.dart';

class AuthController extends GetxController {
  void login(String email, String password) {
    print('Email: $email, Password: $password');
  }
}