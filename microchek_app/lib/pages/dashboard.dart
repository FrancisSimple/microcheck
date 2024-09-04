// pages/dashboard.dart
// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:microchek_app/pages/client.dart';
import 'package:microchek_app/pages/entry.dart';
import 'package:microchek_app/user_configure.dart';
import 'package:microchek_app/utils/drawer.dart';
import 'package:microchek_app/utils/form.dart';
import 'package:microchek_app/utils/loading.dart';
import 'package:provider/provider.dart';

class GhanaCardValidationPage extends StatefulWidget {
  const GhanaCardValidationPage({super.key});

  @override
  State<GhanaCardValidationPage> createState() =>
      _GhanaCardValidationPageState();
}

class _GhanaCardValidationPageState extends State<GhanaCardValidationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _ghanaCardController = TextEditingController();
  bool _isValid = false;
  bool _isFound = false;
  bool _isCleared = false;
  Client? thisClient;

  @override
  Widget build(BuildContext context) {
    InstitutionProvider instProvider =
        Provider.of<InstitutionProvider>(context, listen: true);
    final currentInst = instProvider.currentInstitution;
    //fetchInstitutionData(currentInst!.uid, instProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text('Background Check'),
        centerTitle: true,
      ),
      drawer: SampleDrawer(),
      body: Padding(
        padding: const EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          bottom: 16,
        ),
        child: Center(
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUnfocus,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
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
                    ],
                    decoration: InputDecoration(
                      labelText: 'Ghana Card Number',
                      hintText: 'GHA-000000000-0',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the Ghana Card Number';
                      } else if (!isValidGhanaCardNumber(value)) {
                        return 'Invalid Ghana Card Number';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 50),
                  ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(
                            Theme.of(context).colorScheme.primaryContainer)),
                    onPressed: validateGhanaCard,
                    child: Text('Check'),
                  ),
                  // if (_isValid)
                  //   Padding(
                  //     padding: const EdgeInsets.only(top: 20.0),
                  //     child: Text(
                  //       _isFound
                  //           ? 'Existing Records Found!'
                  //           : 'No Existing Records!',
                  //       style: TextStyle(
                  //         color: _isFound ? Colors.red : Colors.green,
                  //         fontSize: 16,
                  //       ),
                  //     ),
                  //   ),
                  //
                  if (_isCleared && _isValid)
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Text("Applicant is Cleared"),
                    )
                  else
                    Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: !_isValid
                            ? Text("")
                            : Text(
                                'Applicant is Not Cleared!',
                                style: TextStyle(
                                  color:
                                      !_isCleared ? Colors.red : Colors.green,
                                  fontSize: 16,
                                ),
                              )),
                  if (_isCleared && _isValid)
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text("Are you considering this person?"),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(),
                              ElevatedButton(
                                onPressed: () async {},
                                child: Text(
                                  'Yes',
                                  style: TextStyle(color: Colors.green),
                                ),
                              ),
                              // SizedBox(
                              //   height: 30,
                              // ),
                              // ElevatedButton(
                              //   onPressed: () async {},
                              //   child: Text('No',
                              //       style: TextStyle(color: Colors.red)),
                              // ),
                              SizedBox(),
                            ],
                          )
                        ],
                      ),
                    ),
                  if (_isFound && _isValid && !_isCleared)
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: ElevatedButton(
                        onPressed: () async {
                          //loadingDialog(context);
                          _showCompanyDetails(
                              context, thisClient!.allInstitutions!);
                          //Navigator.of(context).pop();
                          //Navigator.of(context).pop();
                        },
                        child: Text('View Company Details'),
                      ),
                    ),
                  if (!_isFound && _isValid)
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: ElevatedButton(
                        onPressed: () {
                          // loadingDialog(context);
                          showAddUserForm(context, currentInst!, instProvider,
                              controllerText: _ghanaCardController.text);
                          // Navigator.of(context).pop();
                        },
                        child: Text('Add Applicant'),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Implement the functionality to add a user to the system here

          showAddUserForm(context, currentInst!, instProvider,
              controllerText: _ghanaCardController.text, autofill: true);
          // Navigator.of(context).pop();
        },
        tooltip: 'Add Applicant',
        child: Icon(
          Icons.person_add,
          // color: Colors.amber,
        ),
      ),
    );
  }

  bool isValidGhanaCardNumber(String number) {
    // Implement your validation logic here.
    String pattern = r'GHA-\d{9}-\d{1}$';
    RegExp regExp = RegExp(pattern);
    return regExp.hasMatch(number);
  }

  void validateGhanaCard() async {
    if (_formKey.currentState?.validate() ?? false) {
      loadingDialog(context);
      _isValid = true;
      _isFound = await checkClientExists(_ghanaCardController.text);
      if (_isFound) {
        thisClient = await fetchClientData(_ghanaCardController.text);
        //clientList = thisClient!.allInstitutions;
        if (thisClient != null) {
          _isCleared = true;
          for (Institution inst in thisClient!.allInstitutions!) {
            if (inst.status != "Clear") {
              _isCleared = false;
              break;
            }
          }
        }
      } else {
        _isCleared = true;
      }
      setState(() {
        _isValid = _isValid;
        _isFound = _isFound;
        _isCleared = _isCleared;
      });
      Navigator.of(context).pop();
    } else {
      setState(() {
        _isValid = false;
        _isFound = false;
        _isCleared = false;
      });
    }
  }

  // bool _checkIfUserExists(String cardNumber) {
  //   return cardNumber == "GHA-123456789-0"; // Example Ghana Card number
  // }

  void _showCompanyDetails(BuildContext context, List<Institution> allInsts) {
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
                    0: FlexColumnWidth(2), // Company column wider
                    1: FlexColumnWidth(3),
                    2: FlexColumnWidth(2),
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
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Address',
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
                    itemCount: allInsts.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Table(
                        columnWidths: const {
                          0: FlexColumnWidth(2), // Company column wider
                          1: FlexColumnWidth(3),
                          2: FlexColumnWidth(2),
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
                                child: Text(
                                  allInsts[index].name,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      allInsts[index].email,
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                    Text(
                                      allInsts[index].location,
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              Center(
                                child: Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Text(
                                    allInsts[index].contact,
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
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

// Replace the existing _showAddUserForm call with the new one

  Widget _buildTextFormField(
    String labelText,
    IconData iconData, {
    TextEditingController? controller,
    bool enabled = true,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(
          iconData,
          color: Colors.amber,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        filled: true,
        // fillColor: enabled ? Colors.white : Colors.grey[300],
      ),
      validator: validator,
    );
  }

  @override
  void dispose() {
    _ghanaCardController.dispose();
    super.dispose();
  }
}

// Formats the input with hyphens

// Function to fetch data and create a list of string maps

// Function to fetch data and create a list of maps
Future<List<Institution>> fetchInstitutionDataAsList(String clientId) async {
  try {
    // Get a reference to the Firestore collection
    CollectionReference collection = FirebaseFirestore.instance
        .collection('clients')
        .doc(clientId)
        .collection('myinstitutions');

    // Fetch all documents from the collection
    QuerySnapshot querySnapshot = await collection.get();

    // Initialize a list to hold the maps
    List<Institution> dataList = [];

    // Iterate through each document in the collection
    for (QueryDocumentSnapshot document in querySnapshot.docs) {
      // Get the data as a map

      Institution dataMap = await rawInstitutionData(document.id);
      dataMap.status = document['status'];

      // Add the map to the list
      dataList.add(dataMap);
    }

    return dataList;
  } catch (e) {
    // Handle errors
    debugPrint('Error fetching documents: $e');
    return [];
  }
}

Future<List<Client>> fetchClientDataAsList(String instId) async {
  try {
    // Get a reference to the Firestore collection
    CollectionReference collection = FirebaseFirestore.instance
        .collection('institutions')
        .doc(instId)
        .collection('myclients');

    // Fetch all documents from the collection
    QuerySnapshot querySnapshot = await collection.get();

    // Initialize a list to hold the maps
    List<Client> dataList = [];

    // Iterate through each document in the collection
    for (QueryDocumentSnapshot document in querySnapshot.docs) {
      // Get the data as a map
      if (document.id != 'default') {
        Client dataMap = await fetchClientData(document.id);
        dataMap.lastUpdated = document['lastUpdated'];
        dataMap.status = document['status'];

        // Add the map to the list
        dataList.add(dataMap);
      }
    }

    return dataList;
  } catch (e, stacktrace) {
    // Handle errors
    debugPrint('Error fetching documents: $e');
    debugPrint('stack: $stacktrace');
    return [];
  }
}
