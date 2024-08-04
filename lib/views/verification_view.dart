import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:notes_app/constants/routes.dart';
import 'package:notes_app/services/auth/auth_service.dart';

class VerificationView extends StatelessWidget {
  const VerificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        const SizedBox(height: 20),
        const Text("We have already sent you an email verification"),
        const Text("Please verify your email address"),
        Center(
          child: TextButton(
            onPressed: () {
              AuthService.firebase().sendEmailVerification();
            },
            child: const Text("Send User Verification"),
          ), 
        ),
        TextButton(onPressed: () async{
          await FirebaseAuth.instance.signOut(); 
          Navigator.of(context).pushNamedAndRemoveUntil(register, (route) => false,);}, // Remove all previous routes
          child: const Text("Sign Out"),
         ),
      ],),
    );
  }
}

