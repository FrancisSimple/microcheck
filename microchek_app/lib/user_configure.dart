// user_configure.dart


import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

//=========================
//client class
class Client{

  String name,cardNumber,status;
  String lastUpdated;
  List<Institution>? allInstitutions;
  Client(this.name,this.cardNumber,{this.status = 'cleared',this.lastUpdated = '',this.allInstitutions});

  void getStatus() => status;

  void getName() => name;  
  
  void updateStatus(String newStatus, String newDate) {
    status = newStatus;
    lastUpdated = newDate;
  }

  void getCardNumber() => cardNumber;

  Map<String,dynamic> toJson(){
    return {
      'name': name,
      'cardNumber': cardNumber,
      'status': status,
      'lastUpdated': lastUpdated,
      'allInstitutions': allInstitutions?.map((inst) => inst.toJson()).toList(),
    };
  }
  
  static Client fromJson(Map<String,dynamic> json){
    return Client(json['name'], json['cardNumber'], status: json['status'],lastUpdated: json['lastUpdated'],
    allInstitutions: json['allInstitutions']!= null
          ? (json['allInstitutions'] as List).map((instJson) => Institution.fromJson(instJson)).toList()
          : null,
    );
  }

  Future<bool> addInstitution(String uid, InstitutionProvider instProvider,String status) async{
    try{
      Institution inst = await fetchInstitutionData(uid, instProvider);
      inst.setStatus(status);
      allInstitutions!.add(inst);
      return await updateClientData(cardNumber);
    }
    catch(e){
      debugPrint('Error adding institution to client: $e');
    }
    


    return false;
  }
}
//End of client class


//===========================
//the institution class
class Institution{

  String name, email,location,contact,uid,status;
  List<Client>? allClients;
  Institution(this.name,this.email,this.uid,{this.location = 'Not set',this.contact = 'Not set',this.allClients,this.status = 'Not set'});

  void getName() => name;

  void getEmail() => email;

  void getLocation() => location;

  void getContact() => contact;

  void setStatus(String newStatus){
    status = newStatus;
  }

  Client getClient(String cardNumber){
    Client myClient = Client('None','None');
    for (Client client in allClients!){
      if (client.cardNumber == cardNumber){
        myClient = client;
        break;
      }
    }
    return myClient;

  }

  Map<String,dynamic> toJson(){
    return {
      'name': name,
      'email': email,
      'uid': uid,
      'location': location,
      'contact': contact,
      'status': status,
      'allClients': allClients?.map((inst) => inst.toJson()).toList()
    };
  }

  static Institution fromJson(Map<String,dynamic> json){
    return Institution(json['name'], json['email'], json['uid'],location: json['location'],status: json['status'], contact:json['contact'],allClients: 
    json['allClients']!= null
          ? (json['allClients'] as List).map((instJson) => Client.fromJson(instJson)).toList()
          : null,
    );
  }

  Future<bool> addClient(String number,String status,InstitutionProvider instProvider,{String? name}) async{
    //check if the user is anywhere in the database first or not
    if(await checkClientExists(number)){
      //add new user to current institution database if the user exists already
      DateTime date = DateTime.now();
      Client currentClient = await fetchClientData(number);
      currentClient.updateStatus(status, date.toString());
      allClients!.add(currentClient);


      if(await currentClient.addInstitution(uid,instProvider,status) == false){
        debugPrint('Failed to add a new institution to client');
        return false;
      }
      //update database for client
      if (await updateClientData(number) == false){
        debugPrint('Failed to update client data while adding new client');
        return false;
      }
      //now update database for institution
      if(await updateInstitutionData(uid,instProvider) == false){
        debugPrint('Failed to update institution data while adding new client');
        return false;
      }
      
      
    }
    //in case the user is new
    else{
      Client newClient = Client(name!,number,status: status,lastUpdated: DateTime.now().toString(),allInstitutions: []);
      await FirebaseFirestore.instance.collection('clients').doc(number).set({
            'name': newClient.name,
            'cardNumber': newClient.cardNumber,
            'status': newClient.status,
            'lastUpdated': newClient.lastUpdated,
            'allInstitutions': newClient.allInstitutions?.map((inst) => inst.toJson()).toList(),
      });
      newClient = await fetchClientData(number);
      if(await newClient.addInstitution(uid,instProvider,status) == false){
        debugPrint('Failed to add a new institution to client');
        return false;
      }
      //now update database for institution
      if(await updateInstitutionData(uid,instProvider) == false){
        debugPrint('Failed to update institution data while adding new client');
        return false;
      }
      //update database for client
      if (await updateClientData(number) == false){
        debugPrint('Failed to update client data while adding new client');
        return false;
      }

    }
    return true;
  }
  
}
//end of institution class


//========================
//Client provider
class ClientProvider extends ChangeNotifier{
  Client? _client;
  Client? get currentClient => _client;

  void setCurrentClient(Client client){
    _client = client;
    notifyListeners();
  }
}

//========================
//Institution provider
class InstitutionProvider extends ChangeNotifier{
  Institution? _institution;
  Institution? get currentInstitution => _institution;

  void setCurrentInstitution(Institution institution){
    _institution = institution;
    notifyListeners();
  }
}


//==============================
//function that checks if a user has logged in or not:
Future<bool> checkUserLogin(String email, String password, BuildContext context) async{
  try{
    UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email,password:password);
    User? user = userCredential.user;

    if(user != null){
      return true;
    }
    else{
      return false;
    }
  }
  catch(e){
    debugPrint('Failed to login due to: $e');
  }
  return false;
}

Future<User?> getUserCredentials(String email,String password) async{
    UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email,password: password);
    User? user = userCredential.user; 
    return user;
}

//Check client exists:
Future<bool> checkClientExists(String number) async {
  DocumentSnapshot userSnapShot = await FirebaseFirestore.instance.collection('clients').doc(number).get();
  return userSnapShot.exists;
}



//Check if the institution exists

Future<bool> checkInstitution(String uid) async {
  DocumentSnapshot userSnapShot = await FirebaseFirestore.instance.collection('institutions').doc(uid).get();
  return userSnapShot.exists;
}

//================================================
//Function that fetches the institution data:
Future<Institution> fetchInstitutionData(String id, InstitutionProvider institutionProvider) async{
    
    DocumentSnapshot userSnapShot = await FirebaseFirestore.instance.collection('institutions').doc(id).get();
    //create the institution object
    String name = userSnapShot['name'],email = userSnapShot['email'],location = userSnapShot['location'],contact = userSnapShot['contact'],uid = id;
    List<dynamic> clientsJson = userSnapShot['allClients'] ?? [];
    List<Client> clients = clientsJson.map((clientJson) => Client.fromJson(clientJson as Map<String, dynamic>)).toList();
    //List<Client> clients = userSnapShot['allClients'].map((instJson) => Client.fromJson(instJson)).toList();
    Institution currentInstitution = Institution(name, email,uid,location: location,contact: contact,allClients: clients);
    institutionProvider.setCurrentInstitution(currentInstitution);
    
    return currentInstitution;
    }


Future<bool> createNewInstitution(String uid,String name,String email,String contact,String location) async {
  bool state = false;
  try{
    await FirebaseFirestore.instance.collection('institutions').doc(uid).set({
      'name': name,
      'email': email,
      'contact': contact,
      'allClients': [],
      'location': location
    });
    state = true;
    }
  catch(e){
    debugPrint('Failure to create new user due to: $e');
  }

  return state;
}


//Function that fetches the client data
Future<Client> fetchClientData(String number) async {
  // Fetch the document snapshot
  DocumentSnapshot userSnapShot = await FirebaseFirestore.instance.collection('clients').doc(number).get();

  // Check if the snapshot exists and contains data
  if (!userSnapShot.exists || userSnapShot.data() == null) {
    throw Exception('Client not found or data is null');
  }

  // Extract data safely using a map
  Map<String, dynamic> data = userSnapShot.data() as Map<String, dynamic>;

  // Extract the required fields with null checks and default values
  String name = data['name'] ?? 'Unknown'; // Provide a default value if 'name' is missing
  String status = data['status'] ?? 'Unknown'; // Provide a default value if 'status' is missing
  String lastUpdated = data['lastUpdated'] ?? ''; // Provide a default value if 'lastUpdated' is missing

  // Safely handle the 'allInstitutions' field
  List<Institution> institutions = [];

  // Check if 'allInstitutions' exists, is not null, and is a List
  if (data.containsKey('allInstitutions') && data['allInstitutions'] != null) {
    if (data['allInstitutions'] is List) {
      // Map each item in the list to an Institution object, if the list is empty, it will just stay as an empty list
      institutions = (data['allInstitutions'] as List)
          .map((instJson) => Institution.fromJson(instJson as Map<String, dynamic>))
          .toList();
    } else {
      // Log or handle the unexpected type for 'allInstitutions'
      debugPrint('Expected a list for allInstitutions, but got a different type.');
    }
  }

  // Create the Client object
  Client currentClient = Client(name, number, status: status, lastUpdated: lastUpdated, allInstitutions: institutions);

  return currentClient;
}


Future<bool> updateClientData(String number) async {
  bool state = false;
  try{
  Client currentClient = await fetchClientData(number);
  await FirebaseFirestore.instance.collection('clients').doc(number).update({
    'name': currentClient.name,
    'cardNumber': currentClient.cardNumber,
    'status': currentClient.status,
    'lastUpdated': currentClient.lastUpdated,
    'allInstitutions': currentClient.allInstitutions?.map((inst) => inst.toJson()).toList()
  });
  state = true;
  }
  catch(e){
    debugPrint('Failed to update client data due to: $e');
  }
  return state;
}




Future<bool> updateInstitutionData(String uid,InstitutionProvider instProvider) async {
  bool state = false;
  try{
  Institution currentInstitution = await fetchInstitutionData(uid,instProvider);
  await FirebaseFirestore.instance.collection('institutions').doc(uid).update({
    'name': currentInstitution.name,
    'email': currentInstitution.email,
    'contact': currentInstitution.contact,
    'allClients': currentInstitution.allClients?.map((inst) => inst.toJson()).toList(),
    'location': currentInstitution.location
  });
  return true;
  }
  catch(e){
    debugPrint('Failed to update client data due to: $e');
  }
  return state;
}