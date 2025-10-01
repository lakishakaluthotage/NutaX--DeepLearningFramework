import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main.dart';

class AddUserPage extends StatefulWidget {
  @override
  _AddUserPageState createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorText = "";
  bool _isLoading = false;

  Future<void> _addUser() async {
    try {
      setState(() {
        _errorText = "";
        _isLoading = true;
      });

      // Validate inputs
      if (_nameController.text.isEmpty ||
          _emailController.text.isEmpty ||
          _passwordController.text.isEmpty) {
        throw "Please fill all fields";
      }

      // Check if email is already registered
      final signInMethods = await FirebaseAuth.instance
          .fetchSignInMethodsForEmail(_emailController.text);

      if (signInMethods.isNotEmpty) {
        throw "Email already in use";
      }

      // Create user in Firebase Auth
      final UserCredential authUser =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Store additional user data in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(authUser.user!.uid)
          .set({
        'name': _nameController.text,
        'email': _emailController.text,
        'role': 'user',
        'createdAt': FieldValue.serverTimestamp(),
        'uid': authUser.user!.uid,
      });

      setState(() {
        _errorText = 'Registration successful!';
        _isLoading = false;
      });

      // Clear form after successful registration
      _nameController.clear();
      _emailController.clear();
      _passwordController.clear();

    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorText = _getFirebaseAuthErrorMessage(e);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorText = e.toString();
        _isLoading = false;
      });
    }
  }

  String _getFirebaseAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'Password is too weak';
      case 'invalid-email':
        return 'Invalid email address';
      case 'email-already-in-use':
        return 'Email already in use';
      default:
        return 'Registration failed: ${e.message}';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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
              child: Container(
                constraints: BoxConstraints(maxWidth: 400),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: <Widget>[
                    CircleAvatar(
                      backgroundImage: AssetImage('assets/logo.jpg'),
                      radius: 100,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'NutraX : New User',
                      style: TextStyle(
                        color: Colors.deepOrange,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    _buildTextField(_nameController, 'Name', Icons.person),
                    SizedBox(height: 10),
                    _buildTextField(_emailController, 'Email', Icons.email),
                    SizedBox(height: 10),
                    _buildTextField(
                      _passwordController,
                      'Password',
                      Icons.lock,
                      obscureText: true,
                    ),
                    SizedBox(height: 16),
                    _buildButtons(),
                    SizedBox(height: 8),
                    if (_errorText.isNotEmpty)
                      Text(
                        _errorText,
                        style: TextStyle(
                          color: _errorText.contains('success')
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                    if (_isLoading)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: CircularProgressIndicator(),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String label,
      IconData icon, {
        bool obscureText = false,
      }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.blueAccent),
        prefixIcon: Icon(icon, color: Colors.blueAccent),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blueAccent),
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blueAccent),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _addUser,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: Icon(Icons.person_add, color: Colors.white),
            label: Text(
              'Register Me',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        ),
        SizedBox(width: 5),
        Expanded(
          child: GestureDetector(
            onTap: _isLoading
                ? null
                : () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
            ),
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
                    Icon(Icons.login, color: Colors.blueAccent),
                    SizedBox(width: 5),
                    Text(
                      'Login here',
                      style: TextStyle(color: Colors.blueAccent, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}