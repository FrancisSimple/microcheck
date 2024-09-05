import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:microchek_app/user_configure.dart';
import 'package:microchek_app/utils/drawer.dart';
import 'package:microchek_app/utils/form.dart';
import 'package:microchek_app/utils/loading.dart';

class ClientPage extends StatefulWidget {
  const ClientPage({super.key});

  @override
  State<ClientPage> createState() => _ClientPageState();
}

class _ClientPageState extends State<ClientPage> {
  List<Client> filteredRecords = [];
  bool isLoading = true;
  // final List<Client> allClients = [];


 @override
  void initState() {
    super.initState();
    // The filteredRecords will initially be the same as the full client list
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final clientRecords = Provider.of<InstitutionProvider>(context, listen: false).currentInstitution!.allClients;
      setState(() {
        filteredRecords = clientRecords!;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final instProvider = Provider.of<InstitutionProvider>(context);
    final currentInst = instProvider.currentInstitution;
    // final List<Client> filteredRecords = [];

    if (instProvider.loadingState || currentInst == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('People'),
          centerTitle: true,
        ),
        drawer: const SampleDrawer(),
        body: Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16),
          child: Column(
            children: [
              TextField(
                enabled: false,
                onChanged: _filterClients,
                decoration: const InputDecoration(
                  labelText: 'Search for People',
                  prefixIcon: Icon(Icons.search, color: Colors.amber),
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                ),
              ),
              const SizedBox(height: 16.0),
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              ),
            ],
          ),
        ),
      );
    }
    if (!instProvider.loadingState) {
      
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Persons'),
        centerTitle: true,
      ),
      drawer: const SampleDrawer(),
      body: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0 ,top: 16),
        child: Column(
          children: [
            TextField(
              onChanged: _filterClients,
              decoration: const InputDecoration(
                labelText: 'Search for Persons',
                prefixIcon: Icon(Icons.search, color: Colors.amber),
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
              ),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: buildClientTable(
                  context, filteredRecords.isNotEmpty ? filteredRecords : currentInst.allClients!, currentInst, instProvider),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showAddUserForm(
            context,
            currentInst,
            instProvider,
            autofill: false,
          );
          setState(() {}); // Update the state after adding user
        },
        tooltip: 'Add Person',
        child: const Icon(Icons.person_add),
      ),
    );
  }

  Widget buildClientTable(BuildContext context, List<Client> records,
      Institution inst, InstitutionProvider instProvider) {
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
            DataColumn(label: Text('Edit options')),
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
                      _showEditClientDialog(
                          context, records[index], inst, instProvider);
                    },
                    child: const Text('Update'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _filterClients(String query) {
    final lowerQuery = query.toLowerCase();
    setState(() {
      filteredRecords = Provider.of<InstitutionProvider>(context, listen: false)
          .currentInstitution!.allClients!.where((client) {
        return client.name.toLowerCase().contains(lowerQuery) ||
            client.cardNumber.toLowerCase().contains(lowerQuery)
            || client.contact.toLowerCase().contains(lowerQuery);
      }).toList();
    });
  }

  void _showEditClientDialog(BuildContext context, Client client,
      Institution inst, InstitutionProvider instProvider) {
    final formKey = GlobalKey<FormState>();
    final TextEditingController nameController =
        TextEditingController(text: client.name);
    //final TextEditingController ghanaCardController = TextEditingController(text: client.cardNumber);
    String? selectedStatus;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Update Person Info',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  buildTextFormField('Name', Icons.person,
                      controller: nameController),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    decoration: InputDecoration(
                      labelText: 'Application Status',
                      prefixIcon:
                          const Icon(Icons.assignment, color: Colors.amber),
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
                        child: Text(status,
                            style: Theme.of(context).textTheme.bodySmall),
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
              child: const Text('Cancel',
                  style: TextStyle(color: Colors.redAccent)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Update'),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  loadingDialog(context);
                  setState(() {
                    client.name = nameController.text.trim();
                    client.status = selectedStatus!;
                    client.lastUpdated = DateTime.now().toString();
                    inst.replaceClient(client);
                    instProvider.setCurrentInstitution(inst);
                  });
                  await addInstToClient(
                      client.cardNumber, inst.uid, selectedStatus!,
                      name: client.name);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }
}

String formatDate(String dateInString) {
  DateTime datetime = DateTime.parse(dateInString);
  DateFormat formatter = DateFormat('MMMM dd, yyyy');
  return formatter.format(datetime);
}
