import 'package:flutter/material.dart';
import '../../common/color_extension.dart';
import '../../common/extension.dart';
import '../../common_widget/round_button.dart';
import '../../view/login/login_view.dart';

import '../../common/globs.dart';
import '../../common/service_call.dart';
import '../../common_widget/round_textfield.dart';
import '../on_boarding/on_boarding_view.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  TextEditingController txtName = TextEditingController();
  TextEditingController txtMobile = TextEditingController();
  TextEditingController txtAddress = TextEditingController();
  TextEditingController txtEmail = TextEditingController();
  TextEditingController txtPassword = TextEditingController();
  TextEditingController txtConfirmPassword = TextEditingController();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 64,
              ),
              Text(
                "Sign Up",
                style: TextStyle(
                    color: TColor.primaryText,
                    fontSize: 30,
                    fontWeight: FontWeight.w800),
              ),
              Text(
                "Add your details to sign up",
                style: TextStyle(
                    color: TColor.secondaryText,
                    fontSize: 14,
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(
                height: 25,
              ),
              RoundTextfield(
                hintText: "Name",
                controller: txtName,
              ),
              const SizedBox(
                height: 25,
              ),
              RoundTextfield(
                hintText: "Email",
                controller: txtEmail,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(
                height: 25,
              ),
              RoundTextfield(
                hintText: "Mobile No",
                controller: txtMobile,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(
                height: 25,
              ),
              RoundTextfield(
                hintText: "Address",
                controller: txtAddress,
              ),
              const SizedBox(
                height: 25,
              ),
              RoundTextfield(
                hintText: "Password",
                controller: txtPassword,
                obscureText: true,
              ),
               const SizedBox(
                height: 25,
              ),
              RoundTextfield(
                hintText: "Confirm Password",
                controller: txtConfirmPassword,
                obscureText: true,
              ),
              const SizedBox(
                height: 25,
              ),
              RoundButton(title: "Sign Up", onPressed: () {
                btnSignUp();
                //  Navigator.push(
                //       context,
                //       MaterialPageRoute(
                //         builder: (context) => const OTPView(),
                //       ),
                //     );
              }),
              const SizedBox(
                height: 30,
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginView(),
                    ),
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Already have an Account? ",
                      style: TextStyle(
                          color: TColor.secondaryText,
                          fontSize: 14,
                          fontWeight: FontWeight.w500),
                    ),
                    Text(
                      "Login",
                      style: TextStyle(
                          color: TColor.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //TODO: Action
  
  void btnSignUp() {
    if (txtName.text.trim().isEmpty) {
      mdShowAlert(Globs.appName, "Please enter your name", () {});
      return;
    }

    if (!txtEmail.text.isEmail) {
      mdShowAlert(Globs.appName, MSG.enterEmail, () {});
      return;
    }

    if (txtMobile.text.trim().isEmpty) {
      mdShowAlert(Globs.appName, "Please enter your mobile number", () {});
      return;
    }

    if (txtAddress.text.trim().isEmpty) {
      mdShowAlert(Globs.appName, "Please enter your address", () {});
      return;
    }

    if (txtPassword.text.length < 6) {
      mdShowAlert(Globs.appName, MSG.enterPassword, () {});
      return;
    }

    if (txtPassword.text != txtConfirmPassword.text) {
      mdShowAlert(Globs.appName, "Passwords do not match", () {});
      return;
    }

    endEditing();

    // Laravel registration API call
    serviceCallSignUp({
      "name": txtName.text.trim(),
      "email": txtEmail.text.trim(),
      "mobile": txtMobile.text.trim(),
      "address": txtAddress.text.trim(),
      "password": txtPassword.text,
      "password_confirmation": txtConfirmPassword.text,
    });
  }

  // Laravel API Registration Service Call
  void serviceCallSignUp(Map<String, dynamic> parameter) {
    Globs.showHUD();

    ServiceCall.post(parameter, SVKey.svSignUp,
        withSuccess: (responseObj) async {
      Globs.hideHUD();

      // Laravel typically returns success with user data and token
      if (responseObj['success'] == true || responseObj['status'] == 'success') {
        // Store user data and token
        Map<String, dynamic> userData = {};

        if (responseObj['user'] != null) {
          userData = responseObj['user'] as Map<String, dynamic>;
        }

        if (responseObj['token'] != null || responseObj['access_token'] != null) {
          userData['token'] = responseObj['token'] ?? responseObj['access_token'];
        }

        // Store user payload and login status
        Globs.udSet(userData, Globs.userPayload);
        Globs.udBoolSet(true, Globs.userLogin);
        ServiceCall.userPayload = userData;

        // Show success message
        mdShowAlert(Globs.appName, "Registration successful! Welcome to Nine27 Pharmacy.", () {
          // Navigate to main app
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const OnBoardingView(),
              ),
              (route) => false);
        });
      } else {
        // Handle registration failure
        String errorMessage = responseObj['message'] ??
                             responseObj['error'] ??
                             'Registration failed. Please try again.';
        mdShowAlert(Globs.appName, errorMessage, () {});
      }
    }, failure: (err) async {
      Globs.hideHUD();
      mdShowAlert(Globs.appName, 'Network error: ${err.toString()}', () {});
    });
  }
}
