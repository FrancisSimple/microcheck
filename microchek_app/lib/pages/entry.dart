// pages/entry.dart
// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:microchek_app/utils/drawer.dart';

class MyMicroPage extends StatefulWidget {
  const MyMicroPage({super.key});

  @override
  State<MyMicroPage> createState() => _MyMicroPageState();
}

class _MyMicroPageState extends State<MyMicroPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Microfinance'),
        centerTitle: true,
      ),
      drawer: SampleDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            SizedBox(height: 20),
            Center(
              child: CircleAvatar(
                radius: 40,
                child: Icon(Icons.account_balance),
                // backgroundImage: AssetImage('assets/logo.png'), // Add a logo or relevant image
              ),
            ),
            SizedBox(height: 20),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    buildInfoRow(Icons.business, 'Institution Name',
                        'Microfinance Inc.'),
                    buildDivider(),
                    buildInfoRow(Icons.location_on, 'Location',
                        '123 Finance Avenue, Accra, Ghana'),
                    buildDivider(),
                    buildInfoRow(Icons.phone, 'Contact', '+233 24 123 4567'),
                    buildDivider(),
                    buildInfoRow(
                        Icons.email, 'Email', 'info@microfinanceinc.com'),
                    buildDivider(),
                    buildInfoRow(Icons.calendar_today, 'Registered Since',
                        'January 1, 2020'),
                    SizedBox(height: 20),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Implement edit profile functionality here
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return EditProfilePopup();
                            },
                          );
                        },
                        icon: Icon(Icons.edit),
                        label: Text('Edit Profile'),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
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

  Widget buildInfoRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, size: 28, color: Colors.amber),
        SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              Text(
                value,
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Divider buildDivider() {
    return Divider(
      height: 40,
      thickness: 1.5,
      color: Colors.grey[300],
    );
  }
}

// import 'package:flutter/material.dart';

// Pop up for profile edit
class EditProfilePopup extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  EditProfilePopup({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Center(
        child: Text(
          'Edit Profile',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTextField(
              controller: nameController,
              icon: Icons.business,
              label: 'Institution Name',
            ),
            SizedBox(height: 20),
            _buildTextField(
              controller: locationController,
              icon: Icons.location_on,
              label: 'Location',
            ),
            SizedBox(height: 20),
            _buildTextField(
              controller: contactController,
              icon: Icons.phone,
              label: 'Contact',
            ),
            SizedBox(height: 20),
            _buildTextField(
              controller: emailController,
              icon: Icons.email,
              label: 'Email',
            ),
          ],
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
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            backgroundColor: Colors.redAccent.shade100,
          ),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            // Implement save functionality here
          },
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: Text('Save Changes'),
        ),
      ],
    );
  }

  Widget _buildTextField(
      {required TextEditingController controller,
      required IconData icon,
      required String label}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.blue),
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[700]),
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
