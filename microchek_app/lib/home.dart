// home.dart
// ignore_for_file: prefer_const_constructors, sort_child_properties_last// ignore_for_file: prefer_const_constructors, sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:microchek_app/utils/drawer.dart';

class GhanaCardValidationPage extends StatefulWidget {
  const GhanaCardValidationPage({super.key});

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
        title: Text('Applicant Validation'),
        centerTitle: true,
      ),
      drawer: SampleDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUnfocus,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextFormField(
                  controller: _ghanaCardController,
                  keyboardType: TextInputType.text,
                  maxLength: 15,
                  inputFormatters: [
                    GhanaCardNumberFormatter(),
                    // FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: InputDecoration(
                    labelText: 'Ghana Card Number',
                    hintText: 'GHA-00000000-0',
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
        tooltip: 'Add User',
        child: Icon(Icons.add),
      ),
    );
  }

  bool _isValidGhanaCardNumber(String number) {
    // Implement your validation logic here.
    // This is a basic example, adjust it to match the Ghana Card number format.
    String pattern = r'GHA-\d{8}-\d{1}$';
    RegExp regExp = RegExp(pattern);
    return regExp.hasMatch(number);
  }
}

// Formats the input with hyphens
class GhanaCardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue, // Unused.
    TextEditingValue newValue, // New text
  ) {
    final newTextLength = newValue.text.length;
    int selectionIndex = newValue.selection.end;
    int usedSubstringIndex = 0;
    final formattedString = StringBuffer();

    // Add the prefix "GHA-" to the formatted string
    formattedString.write('GHA-');

    // Remove the prefix "GHA-" from the new value
    String newNumberValue = '';
    if (newTextLength >= 4) {
      newNumberValue = newValue.text.substring(4);
    }

    // Remove all non-digit characters from the new value
    newNumberValue = newNumberValue.replaceAll(RegExp(r'[^0-9]'), '');

    // Add the formatted number to the formatted string
    if (newNumberValue.length < 8) {
      formattedString.write(newNumberValue);
    } else {
      formattedString.write(newNumberValue.substring(0, 8) + '-');
      if (newNumberValue.length > 8) {
        formattedString.write(newNumberValue.substring(8));
      }
    }

    // Used for setting cursor position
    selectionIndex = formattedString.length;

    return TextEditingValue(
      text: formattedString.toString(),
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}