import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notes_app/constants/routes.dart';
import 'package:notes_app/services/auth/auth_exception.dart';
import 'package:notes_app/services/auth/auth_service.dart';

import 'package:notes_app/utilities/error_dialog.dart';
import 'dart:developer' as logging show log;

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    // Implement initState
    super.initState();
    _email = TextEditingController();
    _password = TextEditingController();
  }

  @override
  void dispose() {
    // Implement dispose
    super.dispose();
    _email.dispose();
    _password.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
      ),
      body: Column(
        children: [
          TextField(
            controller: _email,
            enableSuggestions: false,
            autocorrect: false,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: "Enter your email",
            ),
          ),
          TextField(
            controller: _password,
            enableSuggestions: false,
            autocorrect: false,
            obscureText: true,
            decoration: const InputDecoration(
              hintText: "Enter your password",
            ),
          ),
          const SizedBox(height: 15), // Add a SizedBox
          TextButton(
            onPressed: () async {
              final email = _email.text.trim();
              final password = _password.text.trim();

              try {
                await AuthService.firebase().login(
                    email: email,
                    password:
                        password); // Agr user exist hi nai krta, then login nai krega

                final user = FirebaseAuth.instance.currentUser;

                if (user?.emailVerified ?? false) {
                  logging.log("User is verified");
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil(notes, (route) => false);
                } else {
                  logging.log("Main kahan hui yaar");
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      emailVerification, (route) => false);
                }

                // logging.log(
                //     userCredential.toString()); // Log the user registration

                // If the user is logged in, navigate to the notes page
                // Navigator.of(context).pushNamedAndRemoveUntil(
                //   '/notes/',
                //   (_) => false,
                // );
              } on UserNotFoundAuthException {
                await showErrorDialog(
                    context, "Wrong password provided for that user.");
              } on InvalidEmailException {
                await showErrorDialog(context, "No user found for that email.");
              } on GenericAuthException {
                await showErrorDialog(context, "Authentication Error");
              }
            },
            child: const Text("Login"),
          ),
          const SizedBox(height: 5), // Add a SizedBox
          TextButton(
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/register/',
                (route) => false,
              );
            },
            child: const Text("Not registered yet? Register here"),
          ),
        ],
      ),
    );
  }
}
