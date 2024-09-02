// home.dart
// ignore_for_file: prefer_const_constructors, sort_child_properties_last// ignore_for_file: prefer_const_constructors, sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:microchek_app/utils/drawer.dart';

class GhanaCardValidationPage extends StatefulWidget {
  @override
  _GhanaCardValidationPageState createState() =>
      _GhanaCardValidationPageState();
}

class _GhanaCardValidationPageState extends State<GhanaCardValidationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _ghanaCardController = TextEditingController();
  bool _isValid = false;

  void _validateGhanaCard() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isValid = true;
      });
    } else {
      setState(() {
        _isValid = false;
      });
    }
  }

  @override
  void dispose() {
    _ghanaCardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Validate Applicant'),
      ),
      drawer: SampleDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextFormField(
                  controller: _ghanaCardController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: 'Ghana Card Number',
                    hintText: 'Enter Ghana Card Number',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the Ghana Card Number';
                    } else if (!_isValidGhanaCardNumber(value)) {
                      return 'Invalid Ghana Card Number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 50),
                ElevatedButton(
                  onPressed: _validateGhanaCard,
                  child: Text('Validate'),
                ),
                if (_isValid)
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Text(
                      'Ghana Card Number is valid!',
                      style: TextStyle(color: Colors.green, fontSize: 16),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Implement the functionality to add a user to the system here
        },
        child: Icon(Icons.add),
        tooltip: 'Add User',
      ),
    );
  }

  bool _isValidGhanaCardNumber(String number) {
    // Implement your validation logic here. 
    // This is a basic example, adjust it to match the Ghana Card number format.
    String pattern = r'^[A-Z]{3}-\d{3}-\d{3}-\d{4}[A-Z]{1}$';
    RegExp regExp = RegExp(pattern);
    return regExp.hasMatch(number);
  }
}
