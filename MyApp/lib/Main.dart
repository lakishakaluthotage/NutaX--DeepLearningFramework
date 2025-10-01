//Importing essential flutter and firebase packages
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:MobileApp/pages/MainMenu.dart';
import 'firebase_options.dart';
import 'Registration.dart';

//--------MAIN FUNCTION------------------------------//
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}
//-----------ROOT WIDGET---------------------------//
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(), //Set initial screen as LoginPage
    );
  }
}

//---------LOGIN PAGE--------------------------------//
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _errorText = "";

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
//------------LOGIN FUNCTION----------------------------//
  Future<void> _loginUser() async {
    if (_formKey.currentState!.validate()) {
      try {
        setState(() {
          _errorText = "";
        });
        //Attempt to login with email and password
        final authResult = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        final user = authResult.user;

        if (user != null) {
          //Check user's role from Firestore
          final users = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

          if (users.exists) {
            final data = users.data() as Map<String, dynamic>;
            final role = data['role'];
            //Navigate to HOME PAGE if role is "user"
            if (role == 'user') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Home()),
              );
              return;
            }
          }
          setState(() {
            _errorText = "Invalid role.";
          });
        }
      } on FirebaseAuthException catch (e) {
        //Authentication failed
        setState(() {
          _errorText = "Invalid login details.";
        });
      } catch (e) {
        print("Error: $e"); //Handle unexpected errors
      }
    }
  }
//------------------USER INTERFACE BUILD -------------------//
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/Mainback.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 10,
                  color: Colors.white.withOpacity(0.85),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          CircleAvatar(
                            backgroundImage: AssetImage('assets/logo.jpg'),
                            radius: 100,
                          ),
                          SizedBox(height: 20),
                          Text(
                            'NutraX : Login',
                            style: TextStyle(
                                color: Colors.blueAccent,
                                fontSize: 30,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 30),
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.email, color: Colors.blueAccent),
                              labelText: 'Email',
                              labelStyle: TextStyle(color: Colors.blueAccent),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.blueAccent),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.blueAccent),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Email is required';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 20),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.lock, color: Colors.blueAccent),
                              labelText: 'Password',
                              labelStyle: TextStyle(color: Colors.blueAccent),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.blueAccent),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.blueAccent),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Password is required';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _loginUser,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blueAccent,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10)),
                                  ),
                                  icon: Icon(Icons.login, color: Colors.white),
                                  label: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                                    child: Text(
                                      'Login',
                                      style: TextStyle(color: Colors.white, fontSize: 18),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 5),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => AddUserPage()),
                                    );
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.blueAccent, width: 2),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.app_registration, color: Colors.blueAccent),
                                          SizedBox(width: 5),
                                          Text(
                                            'Register here',
                                            style: TextStyle(
                                              color: Colors.blueAccent,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          if (_errorText.isNotEmpty)
                            Text(
                              _errorText,
                              style: TextStyle(color: Colors.red),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
