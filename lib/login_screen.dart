import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'task_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController=TextEditingController();
  final _passwordController=TextEditingController();
  bool isLoading=false;
  bool isPasswordVisible=false;
  Future <void> authAction({required bool isLogin}) async {
    setState(() {
      isLoading=true;
    });
    try{
      if(isLogin){
        await FirebaseAuth.instance.signInWithEmailAndPassword(email: _emailController.text.trim(), password: _passwordController.text.trim());
      }
      else{
        await FirebaseAuth.instance.createUserWithEmailAndPassword(email: _emailController.text.trim(), password: _passwordController.text.trim());
      }
      if(mounted){ //succesful login
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>const TaskScreen()));
      }
    }
   on FirebaseAuthException catch (e) {
    String errorMessage = "Authentication failed";

    // Check the specific error code from Firebase
    if (e.code == 'email-already-in-use') {
      errorMessage = "This email is already registered. Try logging in!";
    } else if (e.code == 'user-not-found') {
      errorMessage = "No account found with this email.";
    } else if (e.code == 'wrong-password') {
      errorMessage = "Incorrect password.";
    } else if (e.code == 'weak-password') {
      errorMessage = "Password is too weak (needs 6+ characters).";
    } else if (e.code == 'invalid-email') {
      errorMessage = "Please enter a valid email address.";
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage), 
          backgroundColor: Colors.red
        ),
      );
    }
  } catch (e) {
    // Catch any other weird errors
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  } finally {
    if (mounted) setState(() => isLoading = false);
  }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome'),
        centerTitle: true,
      ),
      body:Padding(
        padding: const EdgeInsets.all(10),
        child:Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                hintText: 'Email',
                border: OutlineInputBorder()
              ),
            ),
            const SizedBox(height: 10,),
            TextField(
              controller: _passwordController,
              obscureText: !isPasswordVisible,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Password',
                suffixIcon: IconButton(onPressed: (){
                  setState(() {
                    isPasswordVisible=!isPasswordVisible;
                  });
                }, icon: Icon(isPasswordVisible?Icons.visibility:Icons.visibility_off))
                
              ),
            ),
            const SizedBox(height: 20,),
            if(isLoading)
              const CircularProgressIndicator()
            else
              Column(
                children: [
                  ElevatedButton(
                    onPressed: ()=>authAction(isLogin: true),
                    style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                    child: const Text('Login'),
                  ),
                  TextButton(
                    onPressed: () => authAction(isLogin: false),
                    child: const Text('Create Account'),
                  ),
                ],
              )

            
            
          ],
        ),
      ),
    );
  }
}