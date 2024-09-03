// utils/forms.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:microchek_app/user_configure.dart';
import 'package:microchek_app/utils/loading.dart';

// Update pop up form text fields
Widget buildTextFormField(
  String label,
  IconData icon, {
  required TextEditingController controller,
  String? Function(String?)? validator,
}) {
  return TextFormField(
    controller: controller,
    enabled: false,
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
                ),
                const SizedBox(height: 10),
                buildTextFormField(
                  'Ghana Card Number',
                  Icons.payment_rounded,
                  controller: ghanaCardController,
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
