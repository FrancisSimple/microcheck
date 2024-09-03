// utils/forms.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:microchek_app/user_configure.dart';
import 'package:microchek_app/utils/loading.dart';

// Update pop up form text fields
Widget buildTextFormField(
  String label,
  IconData icon, {
  required TextEditingController controller,
  String? Function(String?)? validator,
  bool enabled = true,
}) {
  return TextFormField(
    controller: controller,
    enabled: enabled,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(
        icon,
        color: Colors.amber,
      ),
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
    ),
    validator: validator,
  );
}

// Update Pop Up
void showEditClientDialog(
  BuildContext context,
  Client client,
  Institution inst,
  InstitutionProvider instProvider,
  String uid,
  void Function(String) updateFilteredRecords,
) {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController =
      TextEditingController(text: client.name);
  final TextEditingController ghanaCardController =
      TextEditingController(text: client.cardNumber);
  String? selectedStatus;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Update Client Info',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                buildTextFormField(
                  'Name',
                  Icons.person,
                  controller: nameController,
                  enabled: false,
                ),
                const SizedBox(height: 10),
                buildTextFormField(
                  'Ghana Card Number',
                  Icons.payment_rounded,
                  controller: ghanaCardController,
                  enabled: false,
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: selectedStatus,
                  decoration: InputDecoration(
                    labelText: 'Application Status',
                    prefixIcon: const Icon(
                      Icons.assignment,
                      color: Colors.amber,
                    ),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: [
                    'Consider Application',
                    'Approve Application',
                    'Clear'
                  ].map((String status) {
                    return DropdownMenuItem<String>(
                      value: status,
                      child: Text(
                        status,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    );
                  }).toList(),
                  onChanged: (newValue) async {
                    selectedStatus = newValue;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select an application status';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.redAccent),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          ElevatedButton(
            child: const Text('Update'),
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                if (selectedStatus != null) {
                  loadingDialog(context);
                  client.name = nameController.text.trim();
                  client.cardNumber = ghanaCardController.text.trim();
                  client.status = selectedStatus!;
                  updateFilteredRecords;
                  await addInstToClient(
                      client.cardNumber, uid, selectedStatus!);
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();

                  await fetchInstitutionData(uid, instProvider);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Select Application Status")));
                }
              }
            },
          ),
        ],
      );
    },
  );
}

String formatDate(String dateInString) {
  DateTime datetime = DateTime.parse(dateInString);
  DateFormat formatter = DateFormat('MMMM dd, yyyy');
  return formatter.format(datetime);
}

// Show Company In Pop Up
void showCompanyDetails(BuildContext context, List<Institution> allInsts) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        insetPadding: const EdgeInsets.all(10),
        contentPadding: const EdgeInsets.all(10),
        title: const Text('Applicant Records'),
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
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                        )),
                    children: const [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Company',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Address',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
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
              const SizedBox(height: 10),
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
                                padding: const EdgeInsets.all(8),
                                child: Text(
                                  allInsts[index].contact,
                                  style: Theme.of(context).textTheme.bodySmall,
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
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}


void showAddUserForm(
  BuildContext context,
  String ghanaCardNumber,
  Institution institution,
  InstitutionProvider instProvider,
  void Function(void Function() fn) setStatusFunc,
) {
  // loadingDialog(context);
  final formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  // final TextEditingController emailController = TextEditingController();
  final TextEditingController ghanaCardController = TextEditingController(
      text: ghanaCardNumber); // Pre-fill Ghana Card Number
  final TextEditingController phoneController = TextEditingController();
  String? selectedStatus; // Variable to store the selected dropdown value

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text(
          'Add Applicant',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                buildTextFormField(
                  'Name',
                  Icons.person,
                  enabled: true,
                  controller: nameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                const SizedBox(height: 10),
                buildTextFormField(
                  'Phone Number',
                  Icons.phone,
                  enabled: true,
                  controller: phoneController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a phone number';
                    } else if (value.length < 10) {
                      return 'Phone number must be at least 10 digits';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                buildTextFormField(
                  'Ghana Card Number',
                  Icons.payment_rounded,
                  controller: ghanaCardController,
                  enabled:
                      false, // Keep this field disabled as it's auto-filled
                  validator: (value) {
                    bool isValidGhanaCardNumber(String number) {
                      // Implement your validation logic here.
                      String pattern = r'GHA-\d{9}-\d{1}$';
                      RegExp regExp = RegExp(pattern);
                      return regExp.hasMatch(number);
                    }

                    if (value == null || value.isEmpty) {
                      return 'Please enter a Ghana Card Number';
                    } else if (!isValidGhanaCardNumber(value)) {
                      return 'Invalid Ghana Card Number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: selectedStatus,
                  decoration: InputDecoration(
                    labelText: 'Application Status',
                    prefixIcon: const Icon(
                      Icons.assignment,
                      color: Colors.amber,
                    ),
                    filled: true,
                    // fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: ['Consider Application', 'Approve Application']
                      .map((String status) {
                    return DropdownMenuItem<String>(
                      value: status,
                      child: Text(
                        status,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setStatusFunc(() {
                      selectedStatus = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select an application status';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.redAccent),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          ElevatedButton(
            child: const Text('Add Applicant'),
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                // Implement the logic to add the user to the system here
                debugPrint("Validated");
                loadingDialog(context);
                await addInstToClient(ghanaCardController.text.trim(),
                    institution.uid, selectedStatus!,
                    name: nameController.text.trim(),
                    contact: phoneController.text.trim());
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Client added Successfully')),
                );
                Navigator.of(context).pop(); // Close the dialog after adding
              }
            },
          ),
        ],
      );
    },
  );
}

bool isValidGhanaCardNumber(String number) {
  // Implement your validation logic here.
  String pattern = r'GHA-\d{9}-\d{1}$';
  RegExp regExp = RegExp(pattern);
  return regExp.hasMatch(number);
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
    if (newNumberValue.length < 9) {
      formattedString.write(newNumberValue);
    } else {
      formattedString.write('${newNumberValue.substring(0, 9)}-');
      if (newNumberValue.length > 9) {
        formattedString.write(newNumberValue.substring(9));
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
