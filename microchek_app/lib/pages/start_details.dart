// pages/start_details.dart
// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
// import 'package:flutter/material.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      // Save the data to the database or shared preferences
      String institutionName = _nameController.text;
      String location = _locationController.text;
      String contact = _contactController.text;

      // Logic to save the institution details
      // You can replace this with your logic to save data in the backend or locally

      // Navigate to the next page after saving the data
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 50,
              color: Colors.amber[50],
            ),
            Text('MicroCheck',
                style: TextStyle(
                  color: Colors.amber[50],
                )),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.amber,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.amber[50],
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(50),
            // topRight: Radius.circular(50),
          ),
        ),
        padding: EdgeInsets.only(
          top: 50,
          left: 20,
          right: 20,
        ),
        child: ListView(
          children: [
            Text(
              'Setup Your Institution',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUnfocus,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildTextFormField(
                      labelText: 'Institution Name',
                      controller: _nameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the institution name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    _buildTextFormField(
                      labelText: 'Location',
                      controller: _locationController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the location';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    _buildTextFormField(
                      labelText: 'Contact',
                      controller: _contactController,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the contact number';
                        } else if (value.length < 10) {
                          return 'Contact number must be at least 10 digits';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _submitForm,
                      child: Text('Submit'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required String labelText,
    TextEditingController? controller,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        filled: true,
      ),
      validator: validator,
    );
  }
}
