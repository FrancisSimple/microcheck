// pages/client.dart
// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:microchek_app/pages/dashboard.dart';
import 'package:microchek_app/user_configure.dart';
// import 'package:flutter/material.dart';
import 'package:microchek_app/utils/drawer.dart';
import 'package:microchek_app/utils/forms.dart';
import 'package:microchek_app/utils/loading.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class ClientPage extends StatefulWidget {
  const ClientPage({super.key, required this.uid, required this.allClients});
  final String uid;
  final List<Client> allClients;
  @override
  State<ClientPage> createState() => _ClientPageState();
}

class _ClientPageState extends State<ClientPage> {
  List<Client> filteredRecords = [];

  @override
  void initState() {
    super.initState();

    filteredRecords = widget.allClients;
  }

  @override
  Widget build(BuildContext context) {
    InstitutionProvider instProvider =
        Provider.of<InstitutionProvider>(context, listen: true);
    final currentInst = instProvider.currentInstitution;

    //filteredRecords = await fetchInstitutionDataAsList(currentInst!.uid);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clients'),
        centerTitle: true,
      ),
      drawer: SampleDrawer(),
      body: Padding(
        padding: const EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          // bottom: 16,
        ),
        child: Column(
          children: [
            TextField(
              onChanged: _filterClients,
              decoration: InputDecoration(
                labelText: 'Search for Clients',
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.amber,
                ),
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
              ),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: buildClientTable(
                  context, filteredRecords, currentInst!, instProvider),
            ),
          ],
        ),
      ),
    );
  }

// Client Data Table
  Widget buildClientTable(
    BuildContext context,
    List<Client> records,
    Institution inst,
    InstitutionProvider instProvider,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('Ghana Card Number')),
            DataColumn(label: Center(child: Text('Status'))),
            DataColumn(label: Text('Last Updated')),
            DataColumn(label: Text('')),
          ],
          rows: List<DataRow>.generate(
            records.length,
            (index) => DataRow(
              cells: [
                DataCell(Text(records[index].name)),
                DataCell(Text(records[index].cardNumber)),
                DataCell(Center(child: Text(records[index].status))),
                DataCell(Text(formatDate(records[index].lastUpdated!))),
                DataCell(
                  ElevatedButton(
                    onPressed: () {
                      // loadingDialog(context);
                      showEditClientDialog(
                        context,
                        records[index],
                        inst,
                        instProvider,
                        widget.uid,
                        _filterClients,
                      );
                      // Navigator.of(context).pop();
                    },
                    child: Text(
                      'Update',
                      // style: TextStyle(color: Colors.redAccent),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

// Filter Function
  void _filterClients(String query) {
    final lowerQuery = query.toLowerCase();
    setState(() {
      filteredRecords = widget.allClients.where((client) {
        return client.name.toLowerCase().contains(lowerQuery) ||
            client.cardNumber.toLowerCase().contains(lowerQuery);
      }).toList();
    });
  }
}
