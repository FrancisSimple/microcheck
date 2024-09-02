// home.dart
// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:microchek_app/utils/drawer.dart';

class UserRecord {
  String company;
  int owed;
  int paid;
  String status;

  UserRecord(this.company, this.owed, this.paid, this.status);
}

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
  bool _isFound = false;

  void _validateGhanaCard() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isValid = true;
        _isFound = _checkIfUserExists(_ghanaCardController.text);
      });
    } else {
      setState(() {
        _isValid = false;
        _isFound = false;
      });
    }
  }

  bool _checkIfUserExists(String cardNumber) {
    return cardNumber == "GHA-12345678-0"; // Example Ghana Card number
  }

  void _showCompanyDetails(BuildContext context) {
    // Sample data
    List<UserRecord> userRecords = [
      UserRecord('Company A', 1000, 500, 'In Debt'),
      UserRecord('Company B', 200, 200, 'Cleared'),
      UserRecord('Company C', 500, 0, 'In Debt'),
      UserRecord('Company D', 800, 300, 'In Debt'),
      UserRecord('Company E', 100, 100, 'Cleared'),
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          insetPadding: EdgeInsets.all(10),
          contentPadding: EdgeInsets.all(10),
          title: Text('Applicant Records'),
          content: SizedBox(
            width: MediaQuery.sizeOf(context).width,
            height: MediaQuery.sizeOf(context).height,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Table(
                  columnWidths: const {
                    0: FlexColumnWidth(3), // Company column wider
                    1: FlexColumnWidth(2),
                    2: FlexColumnWidth(2),
                    3: FlexColumnWidth(2),
                    4: FlexColumnWidth(2)
                  },
                  border: TableBorder(
                    horizontalInside:
                        BorderSide(width: 1, color: Colors.grey[300]!),
                  ),
                  children: [
                    TableRow(
                      decoration: BoxDecoration(
                          color: Colors.amber[200],
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                          )),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Company',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Owed',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Paid',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Status',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Contact',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: userRecords.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Table(
                        columnWidths: const {
                          0: FlexColumnWidth(3), // Company column wider
                          1: FlexColumnWidth(2),
                          2: FlexColumnWidth(2),
                          3: FlexColumnWidth(2),
                          4: FlexColumnWidth(2)
                        },
                        defaultVerticalAlignment:
                            TableCellVerticalAlignment.middle,
                        border: TableBorder(
                          horizontalInside:
                              BorderSide(width: 1, color: Colors.amber[300]!),
                        ),
                        children: [
                          TableRow(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(userRecords[index].company),
                              ),
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('${userRecords[index].owed}'),
                                ),
                              ),
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('${userRecords[index].paid}'),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  userRecords[index].status,
                                  style: TextStyle(
                                    color:
                                        userRecords[index].status == 'Cleared'
                                            ? Colors.green
                                            : Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Center(
                                child: Padding(
                                  padding: EdgeInsets.all(8),
                                  child: IconButton(
                                      onPressed: () {},
                                      icon: const Icon(Icons.call)),
                                ),
                              )
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showAddUserForm(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Add User to System',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Form(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildTextFormField('Name', Icons.person),
                  SizedBox(height: 10),
                  _buildTextFormField('Email', Icons.email),
                  SizedBox(height: 10),
                  _buildTextFormField(
                      'Ghana Card Number', Icons.payment_rounded,
                      enabled: false),
                  SizedBox(height: 10),
                  _buildTextFormField('Phone Number', Icons.phone),
                  // Add more fields as necessary
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.redAccent),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Add User'),
              onPressed: () {
                // Implement the logic to add the user to the system here
                Navigator.of(context).pop(); // Close the dialog after adding
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextFormField(String labelText, IconData icon, {bool? enabled}) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon),
        enabled: enabled ?? true,
        
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        filled: true,
        // fillColor: Colors.grey[100],
      ),
    );
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
                  maxLength: 14,
                  inputFormatters: [
                    GhanaCardNumberFormatter(),
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
                      _isFound
                          ? 'User found in the system!'
                          : 'User not found in the system!',
                      style: TextStyle(
                        color: _isFound ? Colors.green : Colors.red,
                        fontSize: 16,
                      ),
                    ),
                  ),
                if (_isFound && _isValid)
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: ElevatedButton(
                      onPressed: () {
                        _showCompanyDetails(context);
                      },
                      child: Text('View Company Details'),
                    ),
                  ),
                if (!_isFound && _isValid)
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: ElevatedButton(
                      onPressed: () {
                        _showAddUserForm(context);
                      },
                      child: Text('Add User to System'),
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
        child: Icon(Icons.person_add),
      ),
    );
  }

  bool _isValidGhanaCardNumber(String number) {
    // Implement your validation logic here.
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
    // int usedSubstringIndex = 0;
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
      formattedString.write('${newNumberValue.substring(0, 8)}-');
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
