import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:microchek_app/pages/dashboard.dart';

//=========================
// Client class
class Client {
  String name, cardNumber, status;
  String? lastUpdated;
  int loanNumber;
  String contact;
  String created;
  List<Institution>? allInstitutions;

  Client(this.name, this.cardNumber,
      {this.status = 'cleared',
      this.contact = 'not set',
      this.loanNumber = 0,
      this.created = 'not set'});

  String getStatus() => status;

  String getName() => name;

  String getCardNumber() => cardNumber;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'cardNumber': cardNumber,
      'status': status,
    };
  }

  static Client fromJson(Map<String, dynamic> json) {
    return Client(
      json['name'],
      json['cardNumber'],
      status: json['status'],
    );
  }
}
// End of client class

//===========================
// Institution class
class Institution {
  String name, email, location, contact, uid, status, created;
  int clientNumber;
  String? lastUpdated;
  List<Client>? allClients, databaseClients;

  Institution(this.name, this.email, this.uid,
      {this.location = 'Not set',
      this.contact = 'Not set',
      this.clientNumber = 0,
      this.status = 'Not set',
      this.created = 'not set'});

  String getName() => name;

  String getEmail() => email;

  String getLocation() => location;

  String getContact() => contact;

  void setStatus(String newStatus) async {
    status = newStatus;
  }

  void replaceClient(Client client) {
    bool found = false;
    for (Client person in allClients!) {
      if (client.cardNumber == person.cardNumber) {
        allClients!.remove(person);
        allClients!.add(client);
        found = true;
        debugPrint('Client replaced');
        break;
      }
    }
    if (!found) {
      allClients!.add(client);
      debugPrint('Client added');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'uid': uid,
      'location': location,
      'contact': contact,
      'status': status,
    };
  }

  static Institution fromJson(Map<String, dynamic> json) {
    return Institution(
      json['name'],
      json['email'],
      json['uid'],
      location: json['location'],
      status: json['status'],
      contact: json['contact'],
    );
  }
}
// End of institution class

//========================
// InstitutionProvider
class InstitutionProvider extends ChangeNotifier {
  Institution? _institution;
  bool isLoading = false;

  Institution? get currentInstitution => _institution;
  bool get loadingState => isLoading;
  void startLoad() {
    isLoading = true;
    notifyListeners();
  }

  void stopLoad() {
    isLoading = false;
    notifyListeners();
  }

  // Method to set the institution and notify listeners
  void setCurrentInstitution(Institution institution) {
    _institution = institution;
    notifyListeners();
  }
}

//==============================
// Function to check user login status
Future<bool> checkUserLogin(
    String email, String password, BuildContext context) async {
  try {
    UserCredential userCredential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);
    return userCredential.user != null;
  } catch (e) {
    debugPrint('Failed to login due to: $e');
    return false;
  }
}

Future<User?> getUserCredentials(String email, String password) async {
  try {
    UserCredential userCredential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);
    return userCredential.user;
  } catch (e) {
    debugPrint('Error getting user credentials: $e');
    return null;
  }
}

// Check if a client exists
Future<bool> checkClientExists(String number) async {
  DocumentSnapshot userSnapshot =
      await FirebaseFirestore.instance.collection('clients').doc(number).get();
  return userSnapshot.exists;
}

// Check if an institution exists
Future<bool> checkInstitution(String uid) async {
  DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
      .collection('institutions')
      .doc(uid)
      .get();
  return userSnapshot.exists;
}

//================================================
// Function to fetch institution data
Future<Institution> fetchInstitutionData(
    String id, InstitutionProvider institutionProvider) async {
  DocumentSnapshot userSnapshot =
      await FirebaseFirestore.instance.collection('institutions').doc(id).get();

  if (!userSnapshot.exists || userSnapshot.data() == null) {
    throw Exception('Institution not found or data is null');
  }

  final collectSnap = FirebaseFirestore.instance
      .collection('institutions')
      .doc(id)
      .collection('myclients');
  final query = await collectSnap.get();
  int len = query.size - 1;

  Institution currentInstitution = Institution(
      userSnapshot['name'], userSnapshot['email'], id,
      location: userSnapshot['location'],
      contact: userSnapshot['contact'],
      clientNumber: len,
      created: userSnapshot['created']);
  currentInstitution.allClients = await fetchClientDataAsList(id);
  currentInstitution.databaseClients = await fetchAllClientDataAsList();

  institutionProvider.setCurrentInstitution(currentInstitution);
  return currentInstitution;
}

Future<Institution> rawInstitutionData(String id) async {
  DocumentSnapshot userSnapshot =
      await FirebaseFirestore.instance.collection('institutions').doc(id).get();

  if (!userSnapshot.exists || userSnapshot.data() == null) {
    throw Exception('Institution not found or data is null');
  }

  final collectSnap = FirebaseFirestore.instance
      .collection('institutions')
      .doc(id)
      .collection('myclients');
  final query = await collectSnap.get();
  int len = query.size - 1;

  List<Client> dataList = [];
  //final collectSnap2 = FirebaseFirestore.instance.collection('institutions').doc(id).collection('myclients');
  for (QueryDocumentSnapshot document in query.docs) {
    // Get the data as a map
    Client dataMap;
    if (document.id != 'default') {
      dataMap = Client(
        document['name'] ?? 'Unknown',
        document['number'],
        status: document['status'] ?? 'Unknown',
        contact: document['contact'] ?? '',
        loanNumber: len,
      );
      dataMap.lastUpdated = document['lastUpdated'];

      dataList.add(dataMap);
    }
  }
  Institution currentInstitution = Institution(
      userSnapshot['name'], userSnapshot['email'], id,
      location: userSnapshot['location'],
      contact: userSnapshot['contact'],
      clientNumber: len,
      created: userSnapshot['created']);
  currentInstitution.allClients = dataList;

  return currentInstitution;
}

Future<void> addInstToClient(String clientNumber, String instId, String status,
    {String? name, String? contact}) async {
  final searchInst = await FirebaseFirestore.instance
      .collection('institutions')
      .doc(instId)
      .get();
  final searchClient = await FirebaseFirestore.instance
      .collection('clients')
      .doc(clientNumber)
      .get();
  if (!searchClient.exists) {
    await FirebaseFirestore.instance
        .collection('clients')
        .doc(clientNumber)
        .set({
      'name': name,
      'number': clientNumber,
      'status': status,
      'created': DateTime.now().toString(),
      'loanNumber': 0,
      'contact': contact,
    });
  }
  final searchClient2 = await FirebaseFirestore.instance
      .collection('clients')
      .doc(clientNumber)
      .get();
  final docSearch = await FirebaseFirestore.instance
      .collection('clients')
      .doc(clientNumber)
      .collection('myinstitutions')
      .doc(instId)
      .get();
  if (docSearch.exists) {
    await FirebaseFirestore.instance
        .collection('clients')
        .doc(clientNumber)
        .collection('myinstitutions')
        .doc(instId)
        .update({
      'name': searchInst['name'],
      'email': searchInst['email'],
      'contact': searchInst['contact'],
      'location': searchInst['location'],
      'clientNumber': 0,
      'status': status,
      'lastUpdated': DateTime.now().toString()
    });
  } else {
    await FirebaseFirestore.instance
        .collection('clients')
        .doc(clientNumber)
        .collection('myinstitutions')
        .doc(instId)
        .set({
      'name': searchInst['name'],
      'email': searchInst['email'],
      'contact': searchInst['contact'],
      'location': searchInst['location'],
      'clientNumber': 0,
      'status': status,
      'lastUpdated': DateTime.now().toString()
    });
  }

  final doc2Search = await FirebaseFirestore.instance
      .collection('institutions')
      .doc(instId)
      .collection('myclients')
      .doc(clientNumber)
      .get();
  if (doc2Search.exists) {
    await FirebaseFirestore.instance
        .collection('institutions')
        .doc(instId)
        .collection('myclients')
        .doc(clientNumber)
        .update({
      'name': (name == null) ? searchClient['name'] : name,
      'number': searchClient2['number'],
      'status': status,
      'lastUpdated': DateTime.now().toString(),
      'loanNumber': 0,
      'contact': searchClient2['contact'],
    });
  } else {
    await FirebaseFirestore.instance
        .collection('institutions')
        .doc(instId)
        .collection('myclients')
        .doc(clientNumber)
        .set({
      'name': (name == null) ? searchClient2['name'] : name,
      'number': searchClient2['number'],
      'status': status,
      'lastUpdated': DateTime.now().toString(),
      'loanNumber': 0,
      'contact': searchClient2['contact'],
    });
  }
}

Future<bool> createNewInstitution(String uid, String name, String email,
    String contact, String location) async {
  try {
    await FirebaseFirestore.instance.collection('institutions').doc(uid).set({
      'name': name,
      'email': email,
      'contact': contact,
      'location': location,
      'clientNumber': 0,
      'created': DateTime.now().toString()
    });

    // Remove creation of default document or conditionally create it if needed
    await FirebaseFirestore.instance
        .collection('institutions')
        .doc(uid)
        .collection('myclients')
        .doc('default')
        .set({'name': 'default'});

    return true;
  } catch (e) {
    debugPrint('Failure to create new institution due to: $e');
    return false;
  }
}

Future<bool> addNewClient(String clientNumber, String instId, String status,
    {String? name, String? contact}) async {
  final searchInst = await FirebaseFirestore.instance
      .collection('institutions')
      .doc(instId)
      .get();
  final searchClient = await FirebaseFirestore.instance
      .collection('institutions')
      .doc(instId)
      .collection('myclients')
      .doc(clientNumber)
      .get();
  if (searchClient.exists) {
    return false;
  }
  final searchClient0 = await FirebaseFirestore.instance
      .collection('clients')
      .doc(clientNumber)
      .get();
  if (!searchClient0.exists) {
    await FirebaseFirestore.instance
        .collection('clients')
        .doc(clientNumber)
        .set({
      'name': name,
      'number': clientNumber,
      'status': status,
      'created': DateTime.now().toString(),
      'loanNumber': 0,
      'contact': contact,
    });
  }
  final searchClient2 = await FirebaseFirestore.instance
      .collection('clients')
      .doc(clientNumber)
      .get();

  final docSearch = await FirebaseFirestore.instance
      .collection('clients')
      .doc(clientNumber)
      .collection('myinstitutions')
      .doc(instId)
      .get();
  if (docSearch.exists) {
    await FirebaseFirestore.instance
        .collection('clients')
        .doc(clientNumber)
        .collection('myinstitutions')
        .doc(instId)
        .update({
      'name': searchInst['name'],
      'email': searchInst['email'],
      'contact': searchInst['contact'],
      'location': searchInst['location'],
      'clientNumber': 0,
      'status': status,
      'lastUpdated': DateTime.now().toString()
    });
  } else {
    await FirebaseFirestore.instance
        .collection('clients')
        .doc(clientNumber)
        .collection('myinstitutions')
        .doc(instId)
        .set({
      'name': searchInst['name'],
      'email': searchInst['email'],
      'contact': searchInst['contact'],
      'location': searchInst['location'],
      'clientNumber': 0,
      'status': status,
      'lastUpdated': DateTime.now().toString()
    });
  }

  final doc2Search = await FirebaseFirestore.instance
      .collection('institutions')
      .doc(instId)
      .collection('myclients')
      .doc(clientNumber)
      .get();
  if (doc2Search.exists) {
    await FirebaseFirestore.instance
        .collection('institutions')
        .doc(instId)
        .collection('myclients')
        .doc(clientNumber)
        .update({
      'name': (name == null) ? searchClient['name'] : name,
      'number': searchClient2['number'],
      'status': status,
      //'lastUpdated': DateTime.now().toString(),
      'lastUpdated': DateTime.now().toString(),
      'loanNumber': 0,
      'contact': searchClient2['contact'],
    });
  } else {
    await FirebaseFirestore.instance
        .collection('institutions')
        .doc(instId)
        .collection('myclients')
        .doc(clientNumber)
        .set({
      'name': (name == null) ? searchClient2['name'] : name,
      'number': searchClient2['number'],
      'status': status,
      //'lastUpdated': DateTime.now().toString(),
      'lastUpdated': DateTime.now().toString(),
      'loanNumber': 0,
      'contact': searchClient2['contact'],
    });
  }
  return true;
}

// Function to fetch client data
Future<Client> fetchClientData(String number) async {
  DocumentSnapshot userSnapshot =
      await FirebaseFirestore.instance.collection('clients').doc(number).get();

  if (!userSnapshot.exists || userSnapshot.data() == null) {
    throw Exception('Client not found or data is null');
  }

  Map<String, dynamic> data = userSnapshot.data() as Map<String, dynamic>;

  final collectSnap = FirebaseFirestore.instance
      .collection('clients')
      .doc(number)
      .collection('myinstitutions');
  final query = await collectSnap.get();
  int len = query.size;
  List<Institution> dataList = [];
  //final collectSnap2 = FirebaseFirestore.instance.collection('institutions').doc(id).collection('myclients');
  for (QueryDocumentSnapshot document in query.docs) {
    // Get the data as a map
    if (document.id != 'default') {
      Institution dataMap = Institution(
        document['name'] ?? 'Unknown',
        document['email'],
        document.id,
        status: document['status'] ?? 'Unknown',
        contact: document['contact'] ?? '',
        location: document['location'],
      );
      dataMap.lastUpdated = document['lastUpdated'];
      // Add the map to the list
      dataList.add(dataMap);
    }
  }
  Client client = Client(
    data['name'] ?? 'Unknown',
    number,
    status: data['status'] ?? 'Unknown',
    contact: data['contact'] ?? '',
    loanNumber: len,
    created: data['created'],
  );
  client.allInstitutions = dataList;

  return client;
}

// Function to fetch client data
Future<Client> fetchDirectClientData(String number, String instId) async {
  try {
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('institutions')
        .doc(instId)
        .collection('myclients')
        .doc(number)
        .get();
    debugPrint('snapshot obtained: ${userSnapshot.exists}');

    if (!userSnapshot.exists || userSnapshot.data() == null) {
      throw Exception('Client not found or data is null');
    }

    // Proceed only if the data exists
    final collectSnap = FirebaseFirestore.instance
        .collection('clients')
        .doc(number)
        .collection('myinstitutions');

    final query = await collectSnap.get();
    debugPrint('got query: $query');

    List<Institution> dataList = [];
    for (QueryDocumentSnapshot document in query.docs) {
      if (document.id != 'default') {
        Institution dataMap = Institution(
          document['name'] ?? 'Unknown',
          document['email'],
          document.id,
          status: document['status'] ?? 'Unknown',
          contact: document['contact'] ?? '',
          location: document['location'],
        );
        dataMap.lastUpdated = document['lastUpdated'];
        dataList.add(dataMap);
      }
    }

    Client client = Client(userSnapshot['name'] ?? 'Unknown', number,
        status: userSnapshot['status'] ?? 'Unknown',
        contact: userSnapshot['contact'] ?? '');
    client.lastUpdated = userSnapshot['lastUpdated'];
    client.allInstitutions = dataList;
    debugPrint('client formed status: ${client.status}');

    return client;
  } catch (e) {
    debugPrint('Error fetching direct client data: $e');
    throw Exception('Error in fetching direct client data');
  }
}

Future<void> updateInstitutionProfile(
    String uid, String name, String location, String contact) async {
  await FirebaseFirestore.instance
      .collection('institutions')
      .doc(uid)
      .update({'name': name, 'location': location, 'contact': contact});
}
