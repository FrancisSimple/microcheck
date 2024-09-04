// pages/entry.dart
// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:microchek_app/user_configure.dart';
import 'package:microchek_app/utils/drawer.dart';
import 'package:microchek_app/utils/form.dart';
import 'package:microchek_app/utils/loading.dart';
import 'package:provider/provider.dart';

class MyMicroPage extends StatefulWidget {
  const MyMicroPage({super.key});

  @override
  State<MyMicroPage> createState() => _MyMicroPageState();
}

class _MyMicroPageState extends State<MyMicroPage> {
  @override
  Widget build(BuildContext context) {
    InstitutionProvider instProvider =
        Provider.of<InstitutionProvider>(context, listen: true);
    final currentInst = instProvider.currentInstitution;
    return Scaffold(
      appBar: AppBar(
        title: Text('My Institution'),
        centerTitle: true,
      ),
      drawer: SampleDrawer(),
      body: Padding(
        padding: const EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          // bottom: 16,
        ),
        child: ListView(
          children: <Widget>[
            SizedBox(height: 20),
            Center(
              child: CircleAvatar(
                radius: 40,
                child: Icon(
                  Icons.account_balance,
                ),
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
                    buildInfoRow(
                        Icons.business, 'Institution Name', currentInst!.name),
                    buildDivider(),
                    buildInfoRow(
                        Icons.location_on, 'Location', currentInst.location),
                    buildDivider(),
                    buildInfoRow(Icons.phone, 'Contact', currentInst.contact),
                    buildDivider(),
                    buildInfoRow(Icons.email, 'Email', currentInst.email),
                    // buildDivider(),
                    // buildInfoRow(Icons.calendar_today, 'Registered Since',
                    //     'January 1, 2020'),
                    SizedBox(height: 20),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // loadingDialog(context);
                          // Implement edit profile functionality here
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return EditProfilePopup(currentInst: currentInst,);
                            },
                          );
                          // Navigator.of(context).pop();
                        },
                        icon: Icon(
                          Icons.edit,
                          color: Colors.amber,
                        ),
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

