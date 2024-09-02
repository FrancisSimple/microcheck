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

  Future<bool> addInstitution(Institution inst) async{
    try{
      //Institution inst = await fetchInstitutionData(uid, instProvider);
      inst.setStatus(status);
      allInstitutions!.add(inst);
      return await updateClientData(this);
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


      if(await currentClient.addInstitution(this) == false){
        debugPrint('Failed to add a new institution to client');
        return false;
      }
      //update database for client
      if (await updateClientData(currentClient) == false){
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
            //'allInstitutions': newClient.allInstitutions?.map((inst) => inst.toJson()).toList(),
      });
      allClients!.add(newClient);
      await FirebaseFirestore.instance.collection('clients').doc(number).collection('myinstitutions').doc(uid).set(toJson());
      //newClient = await fetchClientData(number);
      if(await newClient.addInstitution(this) == false){
        debugPrint('Failed to add a new institution to client');
        return false;
      }
      //now update database for institution
      if(await updateInstitutionData(uid,instProvider) == false){
        debugPrint('Failed to update institution data while adding new client');
        return false;
      }
      //update database for client
      if (await updateClientData(newClient) == false){
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
    List<Client> clients = [];
    final clientSnap = await FirebaseFirestore.instance.collection('institutions').doc(id).collection('myclients').get();
    if(clientSnap.docs.length > 1){
      clients = clientSnap.docs.where((doc) {
        return doc.id != 'default'; // Adjust this condition as needed
      }).map((doc) => Client.fromJson(doc.data() as Map<String, dynamic>)).toList();
    }
    
    //List<dynamic> clientsJson = userSnapShot['allClients'] ?? [];
    //List<Client> clients = clientsJson.map((clientJson) => Client.fromJson(clientJson as Map<String, dynamic>)).toList();
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
      'location': location
    });
    //String name = userSnapShot['name'],email = userSnapShot['email'],location = userSnapShot['location'],contact = userSnapShot['contact'],uid = id;
    
    await FirebaseFirestore.instance.collection('institutions').doc(uid).collection('myclients').doc('default').set({'name':'default'});
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
  
  final institutionSnap = await FirebaseFirestore.instance.collection('clients').doc(number).collection('myinstitutions').get();
  // Check if 'allInstitutions' exists, is not null, and is a List
  List<Institution> institutions = [];
  if(institutionSnap.docs.length > 1){
      institutions = institutionSnap.docs.where((doc) {
        return doc.id != 'default'; // Adjust this condition as needed
      }).map((doc) => Institution.fromJson(doc.data() as Map<String, dynamic>)).toList();
    }
  // Create the Client object
  Client currentClient = Client(name, number, status: status, lastUpdated: lastUpdated, allInstitutions: institutions);

  return currentClient;
}


Future<bool> updateClientData(Client client) async {
  bool state = false;
  try{
  //Client currentClient = await fetchClientData(number);
  await FirebaseFirestore.instance.collection('clients').doc(client.cardNumber).update({
    'name': client.name,
    'cardNumber': client.cardNumber,
    'status': client.status,
    'lastUpdated': client.lastUpdated,
    'allInstitutions': client.allInstitutions?.map((inst) => inst.toJson()).toList()
  });
  final institutionCollection = FirebaseFirestore.instance.collection('clients').doc(client.cardNumber).collection('myinstitutions');
  for (Institution inst in client.allInstitutions!){
      Map<String, dynamic> institutionData = inst.toJson();
      final document = await institutionCollection.doc(inst.uid).get();
      (document.exists) ? await institutionCollection.doc(inst.uid).update(institutionData): await institutionCollection.doc(inst.uid).set(institutionData);
  }
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
    //'allClients': currentInstitution.allClients?.map((inst) => inst.toJson()).toList(),
    'location': currentInstitution.location
  });
  final clientCollection = FirebaseFirestore.instance.collection('institutions').doc(uid).collection('myclients');
  for (Client client in currentInstitution.allClients!){
      Map<String, dynamic> clientData = client.toJson();
      final document = await clientCollection.doc(client.cardNumber).get();
      (document.exists) ? await clientCollection.doc(client.cardNumber).update(clientData): await clientCollection.doc(client.cardNumber).set(clientData);
  }
  return true;
  }
  catch(e){
    debugPrint('Failed to update client data due to: $e');
  }
  return state;
}