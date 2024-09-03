// utils/drawer.dart
// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:microchek_app/pages/client.dart';
import 'package:microchek_app/pages/dashboard.dart';
import 'package:microchek_app/pages/entry.dart';
import 'package:microchek_app/user_configure.dart';
import 'package:microchek_app/utils/loading.dart';
import 'package:provider/provider.dart';

// import 'package:flutter/material.dart';

class SampleDrawer extends StatelessWidget {
  const SampleDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    InstitutionProvider instProvider = Provider.of<InstitutionProvider>(context, listen: true);
    final currentInst = instProvider.currentInstitution;
    return Drawer(
      child: Column(
        children: [
          // Drawer Header with User Info
          SizedBox(
            width: MediaQuery.sizeOf(context).width,
            // height: 100,
            height: 250,
            child: DrawerHeader(
              margin: EdgeInsets.zero,
              decoration: BoxDecoration(
                color: Colors.amber,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 100,
                    color: Colors.amber[50],
                  ),
                  Text(
                    "MicroCheck",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.amber[50],
                        ),
                  ),
                  // SizedBox(
                  //   height: 50,
                  // )
                ],
              ),
            ),
          ),

          // Flexible List of Drawer Items
          Flexible(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                ListTile(
                  // titleAlignment: ListTileTitleAlignment.center,
                  leading: Icon(Icons.home),
                  title: Center(
                      child: Text(
                    'Applicant Validation',
                    style: Theme.of(context).textTheme.titleMedium,
                  )),
                  onTap: () {
                    Navigator.pop(context);

                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => GhanaCardValidationPage()));
                  },
                ),
                ListTile(
                  // titleAlignment: ListTileTitleAlignment.center,
                  leading: Icon(Icons.groups_rounded),
                  title: Center(
                      child: Text(
                    'Clients',
                    style: Theme.of(context).textTheme.titleMedium,
                  )),
                  onTap: () async {
                    // loadingDialog(context);
                    
                    // Navigator.pop(context);
                    Navigator.pop(context);
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => ClientPage(uid: currentInst!.uid,allClients: currentInst.allClients!,))
                        );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.settings),
                  title: Center(
                      child: Text(
                    'My Microfinance',
                    style: Theme.of(context).textTheme.titleMedium,
                  )),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => MyMicroPage()));
                  },
                ),
                // ListTile(
                //   leading: Icon(Icons.settings),
                //   title: Text('Settings'),
                //   onTap: () {
                //     Navigator.pop(context);
                //   },
                // ),
              ],
            ),
          ),

          // Logout Button fixed at the bottom
          ListTile(
            leading: Icon(Icons.logout),
            title: Center(
                child: Text(
              'Logout',
              style: Theme.of(context).textTheme.titleMedium,
            )),
            onTap: () {
              Navigator.pop(context);
              loadingDialog(context);
              Navigator.pop(context);
              // Implement your logout functionality here
            },
          ),
        ],
      ),
    );
  }
}
