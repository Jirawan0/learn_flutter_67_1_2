// lib/first_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';

//step 6 : Firestore CMD oparetions
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:learn_flutter_67_1_2/services/firestore.dart';

class FirstScreen extends StatefulWidget {
  const FirstScreen({super.key});

  @override
  State<FirstScreen> createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  @override
  void initState() {
    super.initState();
    // เริ่มนับเวลาเปิด SecondScreen หลัง splash
    Timer(
      const Duration(seconds: 15),
      () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SecondScreen()),
      ),
    );
    // ตรวจเช็ค Internet ตอนเปิดแอป
    checkInternetConnection();
  }

  void checkInternetConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.mobile) {
      _showToast(context, "Mobile network available.");
    } else if (connectivityResult == ConnectivityResult.wifi) {
      _showToast(context, "Wifi network available.");
    } else if (connectivityResult == ConnectivityResult.ethernet) {
      _showToast(context, "Ethernet network available.");
    } else if (connectivityResult == ConnectivityResult.vpn) {
      _showToast(context, "Vpn network available.");
    } else if (connectivityResult == ConnectivityResult.bluetooth) {
      _showToast(context, "Bluetooth network available.");
    } else if (connectivityResult == ConnectivityResult.other) {
      _showToast(context, "Other network available.");
    } else if (connectivityResult == ConnectivityResult.none) {
      _showAlertDialog(
        context,
        "No Internet Connection",
        "Please check your internet connection.",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.pinkAccent, Colors.blueAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image(image: AssetImage('assets/image/icon.png'), width: 200),
              SizedBox(height: 50),
              SpinKitSpinningLines(color: Colors.deepPurple, size: 50.0),
            ],
          ),
        ),
      ),
    );
  }
}

void _showToast(BuildContext context, String msg) {
  Fluttertoast.showToast(
    msg: msg,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    backgroundColor: Colors.lightGreen,
    textColor: Colors.white,
    fontSize: 18.0,
  );
}

void _showAlertDialog(BuildContext context, String title, String msg) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(msg),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("OK"),
          ),
        ],
      );
    },
  );
}

// class SecondScreen extends StatelessWidget {
//   const SecondScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Second Screen')),
//       body: const Center(
//         child: Text(
//           'This is the Second Screen',
//           style: TextStyle(
//             fontSize: 24,
//             color: Colors.amberAccent,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//       ),
//     );
//   }
// }

class SecondScreen extends StatefulWidget {
  const SecondScreen({super.key});

  @override
  State<SecondScreen> createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {
  final FirestoreService firestoreService = FirestoreService();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController ageController = TextEditingController();

  //Open a dialog to add a new person
  void openPersonBox(String? personID) async{
if (personID != null) {
      // Update existing person
      final person = await firestoreService.getPersonById(personID);
      nameController.text = person?['personsName'] ?? '';
      emailController.text = person?['personsEmail'] ?? '';
      ageController.text = person?['personsAge']?? '';
    } else {
      nameController.clear();
      emailController.clear();
      ageController.clear();
    }

    showDialog(context: context, 
    builder: (context) =>AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          TextField(
            controller: emailController,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          TextField(
            controller: ageController,
            decoration: const InputDecoration(labelText: 'Age'),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final String name = nameController.text;
            final String email = emailController.text;
            final int age = int.tryParse(ageController.text) ?? 0;

            if (personID != null) {
              // Update existing person
              firestoreService.updatePerson(personID, name, email, age);
            } else {
              // Add new person
              firestoreService.addPerson(name, email, age);
            }
            nameController.clear();
            emailController.clear();  
            ageController.clear();

            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    appBar : AppBar(
    title: Text("Person List"),
    automaticallyImplyLeading: false,
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: () => openPersonBox(null),
      child: const Icon(Icons.add),
    ),
    body: StreamBuilder<QuerySnapshot>(
      stream: firestoreService.getPersons(),
      builder: (context, snapshot) {
        if (snapshot.hasData){
          List personsList = snapshot.data!.docs;
          return ListView.builder(
            itemCount: personsList.length,
            itemBuilder: (context, index) {
              DocumentSnapshot person = personsList[index];
              String personId = person.id;
              Map<String, dynamic> personData = 
                  person.data() as Map<String, dynamic>;
              String nameText = personData['personsName'] ?? '';
              String EmailText = personData['personsEmail'] ?? '';
              int AgeText = personData['personsAge'] ?? 0;

              return ListTile(
                title: Text('SpersoName (App: $AgeText)'),
                subtitle: Text('emailText'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit), 
                      onPressed: () => openPersonBox(personId),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete), 
                      onPressed: () => firestoreService.deletePerson(personId),
                    ),
                  ],
              )
              );
            },
          );
        }
        // if we don't have data yet, show a loading spinner
        else {
          return const Center(
            child: Text(
              "No Data available",
              style: TextStyle(fontSize: 24, color: Colors.redAccent ),
            ),
          );
        }
      }
    ),
    );
  }
}