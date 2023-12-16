import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'taskspage.dart'; 
import 'register.dart';


class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _errorText = '';

  Future<void> _handleGoogleSignIn() async {
    try {
      // Google Sign-In using Firebase Authentication.
      final UserCredential userCredential = await _auth.signInWithPopup(
        GoogleAuthProvider(),
      );

      if (userCredential.user != null) {
        // Successful Google Sign-In, go to TasksPage.
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => TasksPage(),
            settings: RouteSettings(name: '/taskspage'),
          ),
        );
      }
    } catch (error) {
      print("Google Sign-In Error: $error");
      // Handle sign-in error.
    }
  }

  Future<void> _handleEmailPasswordSignIn() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final String email = _emailController.text;
        final String password = _passwordController.text;
        final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        if (userCredential.user != null) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => TasksPage(),
              settings: RouteSettings(name: '/taskspage'), 
            ),
          );
        }
      } catch (error) {
        setState(() {
          _errorText = "Email/Password Sign-In Error: Invalid Credentials"; 
        });
      }
    }
  }

  Future<void> _handlePasswordReset() async {
    final String email = _emailController.text;
    try {
      await _auth.sendPasswordResetEmail(email: email);
      // Display a success message or go to a password reset confirmation page.
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Password Reset Email Sent'),
            content: Text('An email with instructions to reset your password has been sent to $email.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (error) {
      // Handle password reset error (such as email not found, network issues).
      print("Password Reset Error: $error");
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Password Reset Failed'),
            content: Text('Unable to reset your password. Please check your email address and try again.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.indigo],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.lightBlue.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: Colors.white,
                      size: 40,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'To-Do List',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ), 
        Center( // Wrap the Column in a SingleChildScrollView
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  SizedBox(height: 16),
                  Text(
                    'Sign in with Email/Password:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),

                  SizedBox(height: 16),
                  
                  // Email Field
                  Container(
                    width: 300,
                    child: TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: _validateEmail,
                    ),
                  ),
                  
                  SizedBox(height: 16),
                  
                  // Password Field
                  Container(
                    width: 300,
                    child: TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock),
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                      validator: _validatePassword,
                    ),
                  ),
                  
                  SizedBox(height: 16),

                  // Error Text
                  if (_errorText.isNotEmpty) 
                    Text(
                      _errorText,
                      style: TextStyle(color: Colors.red),
                    ),

                  SizedBox(height: 16),
                  
                  // Sign in with Email/Password Button
                  ElevatedButton(
                    onPressed: _handleEmailPasswordSignIn,
                    child: Text('Sign in with Email/Password'),
                  ),

                  SizedBox(height: 16),

                  // Sign in with Google
                  ElevatedButton(
                    onPressed: _handleGoogleSignIn,
                    child: Text('Sign in with Google'),
                    style: ElevatedButton.styleFrom(primary: Colors.white, onPrimary: Colors.black),
                  ),
                  
                  SizedBox(height: 16),
                  
                  // Forgot Password
                  TextButton(
                    onPressed: _handlePasswordReset,
                    child: Text('Forgot Password?', style: TextStyle(color: Colors.blue)),
                  ),
                  
                  SizedBox(height: 16),
                  
                  // Register Section
                  Text(
                    'New User? Register here:',
                    style: TextStyle(fontSize: 16),
                  ),
                  ElevatedButton(
                    onPressed: _navigateToRegistration,
                    child: Text('Register'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ], 
    ), 
  );
}
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your email.';
    if (!value.contains('@')) return 'Invalid email address.';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your password.';
    if (value.length < 6) return 'Password must be at least 6 characters.';
    return null;
  }

  void _navigateToRegistration() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RegistrationScreen(),
        settings: RouteSettings(name: '/register'),
      ),
    );
  }

}