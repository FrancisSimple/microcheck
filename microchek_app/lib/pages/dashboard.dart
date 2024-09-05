// pages/dashboard.dart
// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:microchek_app/user_configure.dart';
import 'package:microchek_app/utils/drawer.dart';
import 'package:microchek_app/utils/form.dart';
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
  bool _isCleared = false,isWithMe = false,isLoading = true;
  Client? thisClient;

  @override
  void initState() {
    super.initState();

    
  }




  @override
  Widget build(BuildContext context) {
    InstitutionProvider instProvider = Provider.of<InstitutionProvider>(context, listen: true);
    final currentInst = instProvider.currentInstitution;

    if (instProvider.loadingState || currentInst == null){
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
                    onChanged: (value) {
                      debugPrint(_ghanaCardController.text);
                    },
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
                      
                      //validateGhanaCard(currentInst!);
                    },
                    child: Text('loading...'),
                  ),
                  if ((_isFound && _isCleared && _isValid) ||(_isValid && isWithMe && _isCleared) || (!_isFound && !isWithMe && _isValid))
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Text("Person is clear"),
                    )
                  else
                    Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: !_isValid
                            ? Text("")
                            : Text(
                                'Person not cleared!',
                                style: TextStyle(
                                  color:
                                      !_isCleared ? Colors.red : Colors.green,
                                  fontSize: 16,
                                ),
                              )),
                  if ((_isFound && _isCleared && _isValid) ||(_isValid && isWithMe && _isCleared)|| (!_isFound && !isWithMe && _isValid))
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
                                onPressed: () async {
                                  loadingDialog(context);
                                  debugPrint("Clear: $_isCleared");
                                  debugPrint("found: $_isFound");
                                  debugPrint("valid: $_isValid");
                                  debugPrint("withme: $isWithMe");
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text('Considering Person'),
                                          content: Text(
                                              'We are adding this person to the system. You can edit later?'),
                                          actions: [
                                            TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                  Navigator.pop(context);
                                                },
                                                child: Text('No')),
                                            TextButton(
                                                onPressed: () async {
                                                  loadingDialog(context);
                                                  try {
                                                    debugPrint('size before: ${currentInst!.allClients!.length}');
                                                    await addInstToClient(
                                                        _ghanaCardController
                                                            .text
                                                            .trim(),
                                                        currentInst.uid,
                                                        'Under Consideration');
                                                        
                                                        //currentInst.replaceClient(client);
                                                        
                                                    
                                                    Client client = await fetchDirectClientData(_ghanaCardController.text.trim(),currentInst.uid);
                                                    Navigator.pop(context);
                                                    // setState(() {
                                                    //   currentInst.replaceClient(
                                                    //       client);
                                                    // });
                                                    instProvider.currentInstitution!.replaceClient(client);
                                                    instProvider.setCurrentInstitution(currentInst);
                                                    debugPrint('size after: ${currentInst.allClients!.length}');
                                                  } catch (e) {
                                                    debugPrint(
                                                        'error message here: $e');
                                                  }
                                                  
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                        content: Text(
                                                            'Person added successfully')),
                                                  );
                                                  Navigator.pop(context);
                                                  Navigator.pop(context);
                                                },
                                                child: Text('Yes')),
                                          ],
                                        );
                                      });
                                },
                                child: Text(
                                  'Yes',
                                  style: TextStyle(color: Colors.green),
                                ),
                              ),
                              SizedBox(),
                            ],
                          )
                        ],
                      ),
                    ),
                  if ((_isFound && !_isCleared && _isValid) ||(_isValid && isWithMe && !_isCleared))
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
                        child: Text('View Institution Details'),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
    
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
                    onChanged: (value) {
                      debugPrint(_ghanaCardController.text);
                    },
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
                      validateGhanaCard(currentInst);
                    },
                    child: Text('Check'),
                  ),
                  if ((_isFound && _isCleared && _isValid) ||(_isValid && isWithMe && _isCleared) || (!_isFound && !isWithMe && _isValid))
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Text("Person is clear"),
                    )
                  else
                    Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: !_isValid
                            ? Text("")
                            : Text(
                                'Person not cleared!',
                                style: TextStyle(
                                  color:
                                      !_isCleared ? Colors.red : Colors.green,
                                  fontSize: 16,
                                ),
                              )),
                  if ((_isFound && _isCleared && _isValid) ||(_isValid && isWithMe && _isCleared)|| (!_isFound && _isValid))
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
                                onPressed: () async {
                                  loadingDialog(context);
                                  debugPrint("Clear: $_isCleared");
                                  debugPrint("found: $_isFound");
                                  debugPrint("valid: $_isValid");
                                  debugPrint("withme: $isWithMe");
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text('Considering Person'),
                                          content: Text(
                                              'We are adding this person to the system. You can edit later?'),
                                          actions: [
                                            TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                  Navigator.pop(context);
                                                },
                                                child: Text('No')),
                                            TextButton(
                                                onPressed: () async {
                                                  loadingDialog(context);
                                                  try {
                                                    debugPrint('size before: ${currentInst.allClients!.length}');
                                                    await addInstToClient(_ghanaCardController.text.trim(),currentInst.uid,'Under Consideration');
                                                        
                                                        
                                                        
                                                    
                                                    Client client = await fetchDirectClientData(_ghanaCardController.text.trim(),currentInst.uid);
                                                    Navigator.pop(context);
                                                   
                                                    instProvider.currentInstitution!.replaceClient(client);
                                                    instProvider.setCurrentInstitution(currentInst);
                                                    debugPrint('size after: ${currentInst.allClients!.length}');
                                                  } catch (e) {
                                                    debugPrint(
                                                        'error message here: $e');
                                                  }
                                                  
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                        content: Text(
                                                            'Person added successfully')),
                                                  );
                                                  Navigator.pop(context);
                                                  Navigator.pop(context);
                                                },
                                                child: Text('Yes')),
                                          ],
                                        );
                                      });
                                },
                                child: Text(
                                  'Yes',
                                  style: TextStyle(color: Colors.green),
                                ),
                              ),
                              SizedBox(),
                            ],
                          )
                        ],
                      ),
                    ),
                  if ((_isFound && !_isCleared && _isValid) ||(_isValid && isWithMe && !_isCleared))
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
                        child: Text('View Institution Details'),
                      ),
                    ),
                ],
              ),
            ),
          ),
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

  void validateGhanaCard(Institution inst) async {
    if (_formKey.currentState?.validate() ?? false) {

      loadingDialog(context);
      _isValid = true;
      debugPrint(_ghanaCardController.text);

      // Step 1: Check if the Ghana Card is within current institution
      for (Client client in inst.allClients!) {
        if (client.cardNumber == _ghanaCardController.text.trim()) {
          isWithMe = true;
          _isFound = true;
          thisClient = client;
          debugPrint('Client found in database.');
          //  _ghanaCardController.clear();
          break;
        }

        setState(() {
          isWithMe = false;
          _isFound = false;
        });
      }

      //if member not part of current institution, we check if it is present in the system
      if(!isWithMe){
        //document to the particular client in database
        final doc = await FirebaseFirestore.instance.collection('clients').doc(_ghanaCardController.text.trim()).get();
        if(await doc.exists){
          //client is declared found when this document exists
          _isFound = true;
          //client is fetched from database
          thisClient = await fetchClientData(_ghanaCardController.text.trim());
        }
        else{
          _isCleared = true;
        }
      }

      if (_isFound) {
        //when found, we check for clearance
        _isCleared = true;
        for (Institution inst in thisClient!.allInstitutions!){

            if(inst.status != "Clear"){

              _isCleared = false;
              break;

            }
          }

          
        

        // Additional debug info
        debugPrint('Client clearance status: $_isCleared');
      } 
      
      // Update UI
      setState(() {
        _isValid = _isValid;
        _isFound = _isFound;
        _isCleared = _isCleared;
      });

      Navigator.of(context).pop();
    } 
    else {
      setState(() {
        _isValid = false;
        _isFound = false;
        _isCleared = false;
      });
    }
   
  }

 
//================FUNCTION TO DISPLAY ALL INSTUTIONS IN THE NAME OF CLIENT
  void _showCompanyDetails(BuildContext context, List<Institution> allInsts) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          insetPadding: EdgeInsets.all(10),
          contentPadding: EdgeInsets.all(10),
          title: Text('Person Records'),
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
        Client dataMap = await fetchDirectClientData(document.id,instId);

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

Future<List<Client>> fetchAllClientDataAsList() async {
  try {
    // Get a reference to the Firestore collection
    CollectionReference collection =
        FirebaseFirestore.instance.collection('clients');

    // Fetch all documents from the collection
    QuerySnapshot querySnapshot = await collection.get();

    // Initialize a list to hold the maps
    List<Client> dataList = [];

    // Iterate through each document in the collection
    for (QueryDocumentSnapshot document in querySnapshot.docs) {
      // Get the data as a map
      if (document.id != 'default') {
        Client dataMap = await fetchClientData(document.id);

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

Future<List<Institution>> fetchAllInstitutionsDataAsList() async {
  try {
    // Get a reference to the Firestore collection
    CollectionReference collection =
        FirebaseFirestore.instance.collection('clients');

    // Fetch all documents from the collection
    QuerySnapshot querySnapshot = await collection.get();

    // Initialize a list to hold the maps
    List<Institution> dataList = [];

    // Iterate through each document in the collection
    for (QueryDocumentSnapshot document in querySnapshot.docs) {
      // Get the data as a map
      if (document.id != 'default') {
        Institution dataMap = await rawInstitutionData(document.id);

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
