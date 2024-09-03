// pages/client.dart
// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:microchek_app/pages/dashboard.dart';
import 'package:microchek_app/user_configure.dart';
// import 'package:flutter/material.dart';
import 'package:microchek_app/utils/drawer.dart';
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

  void _filterClients(String query) {
    final lowerQuery = query.toLowerCase();
    setState(() {
      filteredRecords = widget.allClients.where((client) {
        return client.name.toLowerCase().contains(lowerQuery) ||
            client.cardNumber.toLowerCase().contains(lowerQuery);
      }).toList();
    });
  }

  void _showEditClientDialog(BuildContext context,Client client, Institution inst, InstitutionProvider instProvider) {

    final TextEditingController nameController =
        TextEditingController(text: client.name);
    final TextEditingController ghanaCardController =
        TextEditingController(text: client.cardNumber);
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
                    onChanged: (newValue) async{
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
              onPressed: () async {
                loadingDialog(context);
                setState(() {
                  client.name = nameController.text.trim();
                  client.cardNumber = ghanaCardController.text.trim();
                  client.status = selectedStatus!;
                  buildClientTable(context, filteredRecords,inst,instProvider);
                });
                await addInstToClient(client.cardNumber, widget.uid, selectedStatus!);
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                
                await fetchInstitutionData(widget.uid, instProvider);
                
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    InstitutionProvider instProvider = Provider.of<InstitutionProvider>(context, listen: true);
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
              child: buildClientTable(context, filteredRecords,currentInst!,instProvider),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildClientTable(BuildContext context, List<Client> records, Institution inst, InstitutionProvider instProvider) {
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
                      _showEditClientDialog(context,records[index], inst,instProvider);
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



String formatDate(String dateInString){
  DateTime datetime = DateTime.parse(dateInString);
  DateFormat formatter = DateFormat('MMMM dd, yyyy');
  return formatter.format(datetime);
  
}
