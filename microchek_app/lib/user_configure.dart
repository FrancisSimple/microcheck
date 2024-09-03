// user_configure.dart
import 'package:firebase_auth/firebase_auth.dart';import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:microchek_app/pages/dashboard.dart';
import 'package:microchek_app/utils/forms.dart';

//=========================
// Client class
class Client {
  String name, cardNumber, status;
  String? lastUpdated;
  int loanNumber;
  String contact;
  String created;
  List<Institution>? allInstitutions;

  Client(this.name, this.cardNumber, {this.status = 'cleared', this.contact = 'not set',this.loanNumber = 0,this.created = 'not set'});

  String getStatus() => status;

  String getName() => name;

  // void updateStatus(String newStatus, String newDate) {
  //   status = newStatus;
  //   lastUpdated = newDate;
  // }

  String getCardNumber() => cardNumber;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'cardNumber': cardNumber,
      'status': status,
      //'lastUpdated': lastUpdated,
      //'allInstitutions': allInstitutions?.map((inst) => inst.toJson()).toList(),
    };
  }

  static Client fromJson(Map<String, dynamic> json) {
    return Client(
      json['name'],
      json['cardNumber'],
      status: json['status'],
      //lastUpdated: json['lastUpdated'],
    );
  }

//   Future<bool> addInstitution(Institution inst) async {
//     try {
//       inst.setStatus(status);
//       //allInstitutions!.add(inst);
//       return await updateClientData(this);
//     } catch (e) {
//       debugPrint('Error adding institution to client: $e');
//       return false;
//     }
//   }
 }
// End of client class

//===========================
// Institution class
class Institution {
  String name, email, location, contact, uid, status, created;
  int clientNumber;
  List<Client>? allClients;

  Institution(this.name, this.email, this.uid, {this.location = 'Not set', this.contact = 'Not set', this.clientNumber = 0, this.status = 'Not set',this.created = 'not set'});

  String getName() => name;

  String getEmail() => email;

  String getLocation() => location;

  String getContact() => contact;

  void setStatus(String newStatus) async {
    status = newStatus;

  }



  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'uid': uid,
      'location': location,
      'contact': contact,
      'status': status,
      //'allClients': allClients?.map((inst) => inst.toJson()).toList(),
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

// Future<bool> addClient(String number, String status, InstitutionProvider instProvider, {String? name}) async {
//   DateTime date = DateTime.now();

//   // Check if the client already exists
//   bool clientExists = await checkClientExists(number);

//   if (clientExists) {
//     // Fetch existing client data
//     Client currentClient = await fetchClientData(number);

//     // Update client's status and last updated date
//     currentClient.updateStatus(status, date.toString());

//     // Add the current institution to the client's institution list
//     bool addedToClient = await currentClient.addInstitution(this);

//     if (!addedToClient) {
//       debugPrint('Failed to add institution to client');
//       return false;
//     }

//     // Add the client to the institution's client list
//     allClients!.add(currentClient);

//     // Update both client and institution data in Firestore
//     bool clientUpdated = await updateClientData(currentClient);
//     bool institutionUpdated = await updateInstitutionData(uid, instProvider);

//     if (!clientUpdated || !institutionUpdated) {
//       debugPrint('Failed to update either client or institution data');
//       return false;
//     }
//   } else {
//     // Create a new client
//     Client newClient = Client(
//       name!,
//       number,
//       status: status,
//       lastUpdated: date.toString(),
//       //allInstitutions: [this], // Add the current institution to new client's institution list
//     );

//     // Store the new client in Firestore
//     await FirebaseFirestore.instance.collection('clients').doc(number).set(newClient.toJson());

//     // Add the new client to the institution's client list
//     allClients!.add(newClient);

//     // Store the institution's data in the client's institutions sub-collection
//     await FirebaseFirestore.instance.collection('clients').doc(number).collection('myinstitutions').doc(uid).set(toJson());

//     // Update both client and institution data in Firestore
//     bool clientAddedToInstitution = await newClient.addInstitution(this);
//     bool institutionUpdated = await updateInstitutionData(uid, instProvider);

//     if (!clientAddedToInstitution || !institutionUpdated) {
//       debugPrint('Failed to add institution to new client or update institution data');
//       return false;
//     }
//   }

//   return true;
// }
 }
// End of institution class

//========================
// ClientProvider
class ClientProvider extends ChangeNotifier {
  Client? _client;

  Client? get currentClient => _client;

  void setCurrentClient(Client client) {
    _client = client;
    notifyListeners();
  }
}

//========================
// InstitutionProvider
class InstitutionProvider extends ChangeNotifier {
  Institution? _institution;

  Institution? get currentInstitution => _institution;

  void setCurrentInstitution(Institution institution) {
    _institution = institution;
    notifyListeners();
  }
}

//==============================
// Function to check user login status
Future<bool> checkUserLogin(String email, String password, BuildContext context) async {
  try {
    UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
    return userCredential.user != null;
  } catch (e) {
    debugPrint('Failed to login due to: $e');
    return false;
  }
}

Future<User?> getUserCredentials(String email, String password) async {
  try {
    UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
    return userCredential.user;
  } catch (e) {
    debugPrint('Error getting user credentials: $e');
    return null;
  }
}

// Check if a client exists
Future<bool> checkClientExists(String number) async {
  DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('clients').doc(number).get();
  return userSnapshot.exists;
}

// Check if an institution exists
Future<bool> checkInstitution(String uid) async {
  DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('institutions').doc(uid).get();
  return userSnapshot.exists;
}

//================================================
// Function to fetch institution data
Future<Institution> fetchInstitutionData(String id, InstitutionProvider institutionProvider) async {
  DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('institutions').doc(id).get();

  if (!userSnapshot.exists || userSnapshot.data() == null) {
    throw Exception('Institution not found or data is null');
  }

  final collectSnap = FirebaseFirestore.instance.collection('institutions').doc(id).collection('myclients');
  final query = await collectSnap.get();
  int len = query.size-1;

  Institution currentInstitution = Institution(
    userSnapshot['name'],
    userSnapshot['email'],
    id,
    location: userSnapshot['location'],
    contact: userSnapshot['contact'],
    clientNumber: len,
    created: userSnapshot['created']
  );
  currentInstitution.allClients = await fetchClientDataAsList(id);

  institutionProvider.setCurrentInstitution(currentInstitution);
  return currentInstitution;
}

Future<Institution> rawInstitutionData(String id) async {
  DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('institutions').doc(id).get();

  if (!userSnapshot.exists || userSnapshot.data() == null) {
    throw Exception('Institution not found or data is null');
  }

  final collectSnap = FirebaseFirestore.instance.collection('institutions').doc(id).collection('myclients');
  final query = await collectSnap.get();
  int len = query.size-1;

  Institution currentInstitution = Institution(
    userSnapshot['name'],
    userSnapshot['email'],
    id,
    location: userSnapshot['location'],
    contact: userSnapshot['contact'],
    clientNumber: len,
    created: userSnapshot['created']
  );
  return currentInstitution;
}


Future<void> addInstToClient(String clientNumber,String instId,String status,{String? name, String? contact}) async{

  final searchClient = await FirebaseFirestore.instance.collection('clients').doc(clientNumber).get();
  if (!searchClient.exists){
    await FirebaseFirestore.instance.collection('clients').doc(clientNumber).set({
    'name': name,
    'number': clientNumber,
    'status': status,
    //'lastUpdated': DateTime.now().toString(),
    'created': DateTime.now().toString(),
    'loanNumber': 0,
    'contact': contact,
    });
  }

  final docSearch = await FirebaseFirestore.instance.collection('clients').doc(clientNumber).collection('myinstitutions').doc(instId).get();
  if (docSearch.exists){
    await FirebaseFirestore.instance.collection('clients').doc(clientNumber).collection('myinstitutions').doc(instId).update({
      'status': status,
      'lastUpdated': DateTime.now().toString()
    });
  }
  else{
    await FirebaseFirestore.instance.collection('clients').doc(clientNumber).collection('myinstitutions').doc(instId).set({
      'status': status,
      'lastUpdated': DateTime.now().toString() 
    });

  }

    final doc2Search = await FirebaseFirestore.instance.collection('institutions').doc(instId).collection('myclients').doc(clientNumber).get();
  if (doc2Search.exists){
    await FirebaseFirestore.instance.collection('institutions').doc(instId).collection('myclients').doc(clientNumber).update({
      'status': status,
      'lastUpdated': DateTime.now().toString()
    });
  }
  else{
    await FirebaseFirestore.instance.collection('institutions').doc(instId).collection('myclients').doc(clientNumber).set({
      'status': status,
      'lastUpdated': DateTime.now().toString() 
    });
    
  }
}



 

Future<bool> createNewInstitution(String uid, String name, String email, String contact, String location) async {
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
    await FirebaseFirestore.instance.collection('institutions').doc(uid).collection('myclients').doc('default').set({'name': 'default'});

    return true;
  } catch (e) {
    debugPrint('Failure to create new institution due to: $e');
    return false;
  }
}




// Function to fetch client data
Future<Client> fetchClientData(String number) async {
  DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('clients').doc(number).get();

  if (!userSnapshot.exists || userSnapshot.data() == null) {
    throw Exception('Client not found or data is null');
  }

  Map<String, dynamic> data = userSnapshot.data() as Map<String, dynamic>;

  final collectSnap = FirebaseFirestore.instance.collection('clients').doc(number).collection('myinstitutions');
  final query = await collectSnap.get();
  int len = query.size;

  Client client = Client(
    data['name'] ?? 'Unknown',
    number,
    status: data['status'] ?? 'Unknown',
    contact: data['contact'] ?? '',
    loanNumber: len,
    created: data['created'],
    

  );
  client.allInstitutions = await fetchInstitutionDataAsList(number);

  return client;
}


// Function to update client data
// Future<bool> updateClientData(Client client) async {
//   try {
//     await FirebaseFirestore.instance.collection('clients').doc(client.cardNumber).update(client.toJson());

//     // Update or add institutions in the client's institution collection
//     // if (client.allInstitutions != null) {
//     //   for (Institution inst in client.allInstitutions!) {
//     //     Map<String, dynamic> institutionData = inst.toJson();
//     //     final institutionCollection = FirebaseFirestore.instance.collection('clients').doc(client.cardNumber).collection('myinstitutions');
//     //     final document = await institutionCollection.doc(inst.uid).get();

//     //     if (document.exists) {
//     //       await institutionCollection.doc(inst.uid).update(institutionData);
//     //     } else {
//     //       await institutionCollection.doc(inst.uid).set(institutionData);
//     //     }
//     //   }
//     // }

//     return true;
//   } catch (e, stacktrace) {
//     debugPrint('Failed to update client data due to: $e');
//     debugPrint('Stack trace: $stacktrace');
//     return false;
//   }
// }


// // Function to update institution data
// Future<bool> updateInstitutionData(String uid, InstitutionProvider instProvider) async {
//   try {
//     Institution currentInstitution = await fetchInstitutionData(uid, instProvider);
//     await FirebaseFirestore.instance.collection('institutions').doc(uid).update(currentInstitution.toJson());

//     // Update or add clients in the institution's client collection
//     if (currentInstitution.allClients != null) {
//       for (Client client in currentInstitution.allClients!) {
//         Map<String, dynamic> clientData = client.toJson();
//         final clientCollection = FirebaseFirestore.instance.collection('institutions').doc(uid).collection('myclients');
//         final document = await clientCollection.doc(client.cardNumber).get();

//         if (document.exists) {
//           await clientCollection.doc(client.cardNumber).update(clientData);
//         } else {
//           await clientCollection.doc(client.cardNumber).set(clientData);
//         }
//       }
//     }

//     return true;
//   } catch (e) {
//     debugPrint('Failed to update institution data due to: $e');
//     return false;
//   }
// }

