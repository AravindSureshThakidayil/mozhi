import 'package:flutter/material.dart';
import 'auth_service.dart';

class CreateAccount extends StatefulWidget {
  const CreateAccount({super.key});

  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _usernameController =
      TextEditingController(); // Added username controller

  DateTime? _selectedDate;
  bool _obscurePassword = true;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime.now());
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dobController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Account"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: SizedBox(
            width: 350, // Increased width for better readability
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: _usernameController, // Username field
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    hintText: 'Choose a username',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email Address',
                    hintText: 'Enter your email',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _dobController,
                  readOnly: true,
                  onTap: () => _selectDate(context),
                  decoration: const InputDecoration(
                    labelText: 'Date of Birth',
                    hintText: 'Tap to select your date of birth',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    // You might want to include input validation here before calling the auth service
                    createUserwithEmailAndPassword(
                      _emailController.text,
                      _passwordController.text,
                      context,
                      dob: _selectedDate,
                      username: _usernameController.text, // Pass the username
                    );
                    // Consider adding feedback to the user upon attempting to create the account
                    // (e.g., a loading indicator)
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: const Text("Create Account"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
