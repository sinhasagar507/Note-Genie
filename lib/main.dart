import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:notes_app/constants/routes.dart';
import 'package:notes_app/firebase_options.dart';
import 'package:notes_app/services/auth/auth_service.dart';
import 'package:notes_app/views/login_view.dart';
import 'package:notes_app/views/notes/create_update_note_view.dart';
import 'package:notes_app/views/notes/notes_view.dart';
import 'package:notes_app/views/registration_view.dart';
import 'package:notes_app/views/verification_view.dart';
import 'dart:developer' as logging show log;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          // brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const HomePage(),
      routes: {
        register: (context) => const RegisterView(),
        login: (context) => const LoginView(),
        notes: (context) => const NotesView(),
        emailVerification: (context) => const VerificationView(),
        createUpdateNote: (context) => const CreateUpdateNoteView(),
      },
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AuthService.firebase().initialize(), // Initialize Firebase;
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            final user = AuthService.firebase().currentUser;
            if (user != null) {
              if (user.isEmailVerified) {
                logging.log("User is verified");
              } else {
                return const VerificationView();
              }
            } else {
              return const LoginView();
            }
            return const NotesView();
          default:
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
        }
      },
    );
  }
}
