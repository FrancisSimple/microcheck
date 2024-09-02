// pages/client.dart
// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
// import 'package:flutter/material.dart';
import 'package:microchek_app/utils/drawer.dart';

class ClientRecord {
  String name;
  String ghanaCardNumber;
  String lastUpdated;
  String status;

  ClientRecord({
    required this.name,
    required this.ghanaCardNumber,
    required this.lastUpdated,
    required this.status,
  });
}

class ClientPage extends StatefulWidget {
  const ClientPage({super.key});

  @override
  State<ClientPage> createState() => _ClientPageState();
}

class _ClientPageState extends State<ClientPage> {
  List<ClientRecord> clientRecords = [
    ClientRecord(
        name: 'John Doe',
        ghanaCardNumber: 'GHA-123456789-0',
        lastUpdated: "12/05/2000",
        status: "Cleared"),
    ClientRecord(
      name: 'Jane Smith',
      ghanaCardNumber: 'GHA-987654321-0',
      lastUpdated: "06/08/1970",
      status: "Considering",
    ),
    ClientRecord(
      name: 'Jane Smith',
      ghanaCardNumber: 'GHA-987654321-0',
      lastUpdated: "06/08/1970",
      status: "Active ",
    ),
    // Add more sample clients here
  ];

  List<ClientRecord> filteredRecords = [];

  @override
  void initState() {
    super.initState();
    filteredRecords = clientRecords;
  }

  void _filterClients(String query) {
    final lowerQuery = query.toLowerCase();
    setState(() {
      filteredRecords = clientRecords.where((client) {
        return client.name.toLowerCase().contains(lowerQuery) ||
            client.ghanaCardNumber.toLowerCase().contains(lowerQuery);
      }).toList();
    });
  }

  void _showEditClientDialog(ClientRecord client) {
    final TextEditingController nameController =
        TextEditingController(text: client.name);
    final TextEditingController ghanaCardController =
        TextEditingController(text: client.ghanaCardNumber);
    String? selectedStatus; // Variable to store the selected dropdown value

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Update Client Info',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Form(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildTextFormField(
                    'Name',
                    Icons.person,
                    controller: nameController,
                  ),
                  SizedBox(height: 10),
                  _buildTextFormField(
                    'Ghana Card Number',
                    Icons.payment_rounded,
                    controller: ghanaCardController,
                  ),
                  SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    decoration: InputDecoration(
                      labelText: 'Application Status',
                      prefixIcon: Icon(
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
                        value: status.split("").first,
                        child: Text(
                          status,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
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
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.redAccent),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Update'),
              onPressed: () {
                setState(() {
                  client.name = nameController.text.trim();
                  client.ghanaCardNumber = ghanaCardController.text.trim();
                  client.lastUpdated = DateTime.now().toString();
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clients'),
        centerTitle: true,
      ),
      drawer: SampleDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
              child: buildClientTable(context, filteredRecords),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildClientTable(BuildContext context, List<ClientRecord> records) {
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
                DataCell(Text(records[index].ghanaCardNumber)),
                DataCell(Center(child: Text(records[index].status))),
                DataCell(Text(records[index].lastUpdated)),
                DataCell(
                  ElevatedButton(
                    onPressed: () {
                      _showEditClientDialog(records[index]);
                    },
                    child: Text('Update'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField(
    String label,
    IconData icon, {
    required TextEditingController controller,
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
        // fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
