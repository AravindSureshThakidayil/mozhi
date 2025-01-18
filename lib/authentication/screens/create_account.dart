import 'package:flutter/material.dart';
import 'auth_service.dart';
class CreateAccount extends StatefulWidget {
  const CreateAccount({Key? key}) : super(key: key);

  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
    appBar: AppBar(
      title: const Text("Create Account"),
    ),
    body: Center(child: SizedBox(
      width: 250,
      height: 250,
      child:  Column(
      children: [
        Text('EMAIL'),
         TextField(
          controller: _emailController,
        ),
        Text('password'),
        TextField(controller: _passwordController,obscureText: true),
        ElevatedButton(onPressed: (){
           createUserwithEmailAndPassword(_emailController.text, _passwordController.text, context);
        },child: const Text("Create Account"))
      ]  
        )
    ),
    )
    );
  }
}
