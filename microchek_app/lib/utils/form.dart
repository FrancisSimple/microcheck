// utils/form.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:microchek_app/user_configure.dart';
import 'package:microchek_app/utils/loading.dart';
import 'package:provider/provider.dart';

// Update pop up form text fields
Widget buildTextFormField(
  String label,
  IconData icon, {
  required TextEditingController controller,
  String? Function(String?)? validator,
  bool autofill = false,
}) {
  return TextFormField(
    controller: controller,
    enabled: autofill ? false : true,
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

bool isValidGhanaCardNumber(String number) {
  // Implement your validation logic here.
  String pattern = r'GHA-\d{9}-\d{1}$';
  RegExp regExp = RegExp(pattern);
  return regExp.hasMatch(number);
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
  final formKey = GlobalKey<FormState>();
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
            key: formKey,
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
              if (formKey.currentState!.validate()) {
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

// import 'package:flutter/material.dart';
// Add Uer to System
void showAddUserForm(
  BuildContext context,
  Institution institution,
  InstitutionProvider instProvider, {
  String? controllerText,
  bool autofill = false,
}) {
  final formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ghanaCardController =
      TextEditingController(text: controllerText);
  String? selectedStatus;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text(
          'Background Check',
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
                  controller: nameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                  autofill: autofill,
                ),
                // const SizedBox(height: 10),
                // buildTextFormField(
                //   'Phone Number',
                //   Icons.phone,
                //   controller: phoneController,
                //   validator: (value) {
                //     if (value == null || value.isEmpty) {
                //       return 'Please enter a phone number';
                //     } else if (value.length < 10) {
                //       return 'Phone number must be at least 10 digits';
                //     }
                //     return null;
                //   },
                //   autofill: autofill,
                // ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: ghanaCardController,
                  keyboardType: TextInputType.text,
                  maxLength: 15,
                  enabled: autofill ? false : true,
                  inputFormatters: [
                    GhanaCardNumberFormatter(),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Ghana Card Number',
                    hintText: 'GHA-000000000-0',
                    prefixIcon: const Icon(
                      Icons.credit_card,
                      color: Colors.amber,
                    ),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
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
            child: const Text('Add Applicant'),
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                loadingDialog(context);
                try {
                  if (await addNewClient(ghanaCardController.text.trim(),
                      institution.uid, 'Under Consideration',
                      name: nameController.text.trim())) {
                    Client client = await fetchDirectClientData(
                        ghanaCardController.text.trim(), institution.uid);
                    Navigator.pop(context);

                    instProvider.currentInstitution!.replaceClient(client);
                    instProvider.setCurrentInstitution(institution);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Person added successfully')),
                    );
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('This person already exists')),
                    );
                    Navigator.pop(context);
                  }
                } catch (e, stack) {
                  debugPrint('error message here: $e');
                  debugPrint('error message here: $stack');
                }
              }
            },
          ),
        ],
      );
    },
  );
}

// Profile Page Edit Popup
class EditProfilePopup extends StatefulWidget {
  const EditProfilePopup(
      {super.key, required this.currentInst, required this.instPro});

  final Institution currentInst;
  final InstitutionProvider instPro;

  @override
  State<EditProfilePopup> createState() => _EditProfilePopupState();
}

class _EditProfilePopupState extends State<EditProfilePopup> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    // Set the initial values of the controllers
    nameController.text = widget.currentInst.name;
    locationController.text = widget.currentInst.location;
    contactController.text = widget.currentInst.contact;
    emailController.text = widget.currentInst.email;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: const Center(
        child: Text(
          'Edit Profile',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(
                controller: nameController,
                icon: Icons.business,
                label: 'Institution Name',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the institution name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: locationController,
                icon: Icons.location_on,
                label: 'Location',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the location';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: contactController,
                icon: Icons.phone,
                label: 'Contact',
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the contact number';
                  }
                  if (value.length < 10) {
                    return 'Enter a valid phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: emailController,
                icon: Icons.email,
                label: 'Email',
                keyboardType: TextInputType.emailAddress,
                enabled: false,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the email';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Enter a valid email address';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: const Text(
            'Cancel',
            style: TextStyle(color: Colors.redAccent),
          ),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              // Save the profile changes
              loadingDialog(context);
              // Implement save profile functionality here
              await updateInstitutionProfile(
                  widget.currentInst.uid,
                  nameController.text.trim(),
                  locationController.text.trim(),
                  contactController.text.trim());
              Navigator.of(context).pop();
              setState(() {
                widget.currentInst.name = nameController.text.trim();
                widget.currentInst.location = locationController.text.trim();
                widget.currentInst.contact = contactController.text.trim();
              });
              widget.instPro.setCurrentInstitution(widget.currentInst);

              Navigator.of(context).pop();
            }
          },
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: const Text('Save'),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required IconData icon,
    required String label,
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      enabled: enabled,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.amber),
        labelText: label,
        filled: true,
        // fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
      validator: validator,
    );
  }
}
