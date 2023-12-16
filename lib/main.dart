import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
//import 'firebase_options.dart';
import 'login.dart';
import 'register.dart';
import 'taskspage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
        apiKey: "AIzaSyBu3myX0_btKOmdYMKzk147mZ276p0lQaU",
        authDomain: "todo-flutterapp-team3.firebaseapp.com",
        projectId: "todo-flutterapp-team3",
        storageBucket: "todo-flutterapp-team3.appspot.com",
        messagingSenderId: "662967388694",
        appId: "1:662967388694:web:91f88b890a0a32f8634337",
    ),
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      home: LoginScreen(),
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),  
        '/register': (context) => RegistrationScreen(),
        '/taskspage': (context) => TasksPage(),
      },
    );
  }
}
