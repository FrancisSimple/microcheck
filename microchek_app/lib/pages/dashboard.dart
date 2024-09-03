// pages/dashboard.dart
// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:microchek_app/user_configure.dart';
import 'package:microchek_app/utils/drawer.dart';
import 'package:microchek_app/utils/forms.dart';
import 'package:microchek_app/utils/loading.dart';
import 'package:provider/provider.dart';

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
  bool _isCleared = false;
  Client? thisClient;

  // bool _checkIfUserExists(String cardNumber) {
  //   return cardNumber == "GHA-123456789-0"; // Example Ghana Card number

  @override
  void dispose() {
    _ghanaCardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    InstitutionProvider instProvider =
        Provider.of<InstitutionProvider>(context, listen: true);
    final currentInst = instProvider.currentInstitution;
    //fetchInstitutionData(currentInst!.uid, instProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text('Applicant Validation'),
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
                    onPressed: () {
                      _validateGhanaCard(
                          _formKey,
                          context,
                          _isValid,
                          _isFound,
                          _isCleared,
                          _ghanaCardController,
                          (fn) => setState(fn));
                    },
                    child: Text('Validate'),
                  ),
                  if (_isValid)
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Text(
                        _isFound
                            ? 'Existing Records Found!'
                            : 'No Existing Records!',
                        style: TextStyle(
                          color: _isFound ? Colors.red : Colors.green,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  if (_isCleared && _isValid)
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Text(
                        'Applicant is Cleared!',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 16,
                        ),
                      ),
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
                  if (_isCleared && _isFound && _isValid)
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: ElevatedButton(
                        onPressed: () async {
                          // _showCompanyDetails(context);
                          loadingDialog(context);

                          await addInstToClient(
                              _ghanaCardController.text.trim(),
                              currentInst!.uid,
                              'Consider Application');
                          Navigator.of(context).pop();
                          //Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    'Application put under consideration')),
                          );
                          final list =
                              await fetchClientDataAsList(currentInst.uid);
                          setState(() {
                            currentInst.allClients = list;
                          });
                          await fetchInstitutionData(
                              currentInst.uid, instProvider);
                        },
                        child: Text('Consider Application'),
                      ),
                    ),
                  if (_isCleared && _isFound && _isValid)
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: ElevatedButton(
                        onPressed: () async {
                          loadingDialog(context);
                          // _showCompanyDetails(context);
                          await addInstToClient(
                              _ghanaCardController.text.trim(),
                              currentInst!.uid,
                              'Approve Application');
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Application approved')),
                          );
                          // setState(() {});
                          await fetchInstitutionData(
                              currentInst.uid, instProvider);
                        },
                        child: Text('Approve Application'),
                      ),
                    ),
                  if (_isFound && _isValid && !_isCleared)
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: ElevatedButton(
                        onPressed: () async {
                          //loadingDialog(context);
                          showCompanyDetails(
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
                          showAddUserForm(context, _ghanaCardController.text,
                              currentInst!, instProvider, (fn) => setState(fn));
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

          showAddUserForm(
              context, _ghanaCardController.text, currentInst!, instProvider,
              (newValue) {
            setState(() {
              // selectedStatus = newValue;
            });
          });
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

  // Card Validation Form
  void _validateGhanaCard(
    GlobalKey<FormState> formKey,
    BuildContext context,
    bool isValid,
    bool isFound,
    bool isCleared,
    TextEditingController ghanaCardController,
    void Function(void Function()) setState,
    // Client thisClient,
  ) async {
    if (formKey.currentState?.validate() ?? false) {
      loadingDialog(context);

      isValid = true;
      isFound = await checkClientExists(ghanaCardController.text);
      if (isFound) {
        Client thisClient = await fetchClientData(ghanaCardController.text);
        //clientList = thisClient!.allInstitutions;
        if (thisClient != null) {
          isCleared = true;
          for (Institution inst in thisClient!.allInstitutions!) {
            if (inst.status != "Clear") {
              isCleared = false;
              break;
            }
          }
        }
      } else {
        isCleared = true;
      }
      setState(() {
        isValid = isValid;
        isFound = isFound;
        isCleared = isCleared;
      });
      Navigator.of(context).pop();
    } else {
      setState(() {
        isValid = false;
        isFound = false;
        isCleared = false;
      });
    }
  }
}
