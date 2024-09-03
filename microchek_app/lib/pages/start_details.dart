// pages/start_details.dart
// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:microchek_app/pages/dashboard.dart';
import 'package:microchek_app/user_configure.dart';
import 'package:microchek_app/utils/loading.dart';
import 'package:provider/provider.dart';
// import 'package:flutter/material.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key, required this.uid, required this.email});
  final String uid;
  final String email;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();

  void _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      loadingDialog(context);
      // Save the data to the database or shared preferences
      String institutionName = _nameController.text.trim();
      String location = _locationController.text.trim();
      String contact = _contactController.text.trim();
      await createNewInstitution(
          widget.uid, institutionName, widget.email, contact, location);
      InstitutionProvider inst =
          Provider.of<InstitutionProvider>(context, listen: false);
      await fetchInstitutionData(widget.uid, inst);
      // Logic to save the institution details
      // You can replace this with your logic to save data in the backend or locally
      Navigator.of(context).pop();
      // Navigate to the next page after saving the data
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => GhanaCardValidationPage(),
      ));
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
        padding: const EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          // bottom: 16,
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
