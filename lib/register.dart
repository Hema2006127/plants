import 'package:flutter/material.dart';
import 'upGreenPlantPulse.dart';
import 'textField.dart';
import 'greenButton.dart';
import 'logWithFacebook.dart';
import 'downText.dart';

class Register extends StatelessWidget {
  const Register({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          physics: const BouncingScrollPhysics(),

          children: [
            UpGreenPlantPulse(),
            const SizedBox(height: 24),
            const _RegisterForm(),
          ],
        ),
      ),
    );
  }
}

class _RegisterForm extends StatelessWidget {
  const _RegisterForm();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Textfield(
            keyboardType: TextInputType.name,
            title: "Name",
            hint_text: "Enter Your Name",
          ),
          const SizedBox(height: 12),

          const Textfield(
            title: "Email",
            hint_text: "Enter Your Email",
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),

          const Textfield(
            title: "Password",
            hint_text: "Enter Your Password",
            isPassword: true,
            keyboardType: TextInputType.visiblePassword,
          ),
          const SizedBox(height: 12),

          const Textfield(
            title: "Confirm Password",
            hint_text: "Enter Your Password",
            isPassword: true,
            keyboardType: TextInputType.visiblePassword,
          ),
          const SizedBox(height: 16),
          GreenButton(text: 'Register', onPress: () {}),
          const SizedBox(height: 16),

          LoginWithFaceBook(),
          const SizedBox(height: 12),
          DownText(
            text1: "Have an account?",
            text2: "Login",
            fun: () {
              Navigator.of(context).pushNamed('Login');
            },
          ),
        ],
      ),
    );
  }
}
