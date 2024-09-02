// pages/client.dart
// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
// import 'package:flutter/material.dart';
import 'package:microchek_app/utils/drawer.dart';

class ClientRecord {
  final String name;
  final String clientId;
  final String ghanaCardNumber;
  final double amountOwing;
  final double amountPaid;
  final String status;
  final String phoneNumber;
  final String email;

  ClientRecord({
    required this.name,
    required this.clientId,
    required this.ghanaCardNumber,
    required this.amountOwing,
    required this.amountPaid,
    required this.status,
    required this.phoneNumber,
    required this.email,
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
      clientId: '001',
      ghanaCardNumber: 'GHA-123456789-0',
      amountOwing: 1500.0,
      amountPaid: 500.0,
      status: 'In Debt',
      phoneNumber: '0240000001',
      email: 'john@example.com',
    ),
    ClientRecord(
      name: 'Jane Smith',
      clientId: '002',
      ghanaCardNumber: 'GHA-987654321-0',
      amountOwing: 0.0,
      amountPaid: 1000.0,
      status: 'Cleared',
      phoneNumber: '0240000002',
      email: 'jane@example.com',
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
            client.clientId.toLowerCase().contains(lowerQuery) ||
            client.ghanaCardNumber.toLowerCase().contains(lowerQuery);
      }).toList();
    });
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
                prefixIcon: Icon(Icons.search),
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
            DataColumn(label: Text('Client ID')),
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('Ghana Card Number')),
            DataColumn(label: Text('Amount Owing')),
            DataColumn(label: Text('Amount Paid')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Phone Number')),
            DataColumn(label: Text('Email')),
          ],
          rows: List<DataRow>.generate(
            records.length,
            (index) => DataRow(
              cells: [
                DataCell(Text(records[index].clientId)),
                DataCell(Text(records[index].name)),
                DataCell(Text(records[index].ghanaCardNumber)),
                DataCell(Text(records[index].amountOwing.toStringAsFixed(2))),
                DataCell(Text(records[index].amountPaid.toStringAsFixed(2))),
                DataCell(
                  Text(
                    records[index].status,
                    style: TextStyle(
                      color: records[index].status == 'Cleared'
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                ),
                DataCell(Text(records[index].phoneNumber)),
                DataCell(Text(records[index].email)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
