import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:io';
import 'package:udp/udp.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
  );
  runApp(const mywifi());
}

class mywifi extends StatefulWidget {
  const mywifi({Key? key}) : super(key: key);

  @override
  State<mywifi> createState() => _mywifiState();
}

class _mywifiState extends State<mywifi> {

  Future<void> scanNetwork() async {
    StreamController socketListen;

    var sender = await UDP.bind(Endpoint.any(port: Port(1234)));
    var dataLength = await sender.send("marco".codeUnits,
        Endpoint.broadcast(port: Port(4210)));

    sender.asStream(timeout: Duration(milliseconds: 5000)).listen((datagram) {
      var str = String.fromCharCodes(datagram!.data);
      if (str == 'polo'){
        myip = datagram?.address.address!;
        print(myip);
        sender.close();

      }

    });
    // close the UDP instances and their sockets.
  }
  Future<void> opendoor() async {
    var multicastEndpoint =
    Endpoint.multicast(InternetAddress(myip!), port: Port(4210));
    var sender = await UDP.bind(Endpoint.any());
    await sender.send("open".codeUnits, multicastEndpoint);
    print("open door sent");
    sender.asStream(timeout: Duration(milliseconds: 5000)).listen((datagram) {
      var str = String.fromCharCodes(datagram!.data);
      if (str == 'ok'){
        print("door opened");
        sender.close();

      }
    });


  }



  String? myip = '';
  @override
  void initState() {
    // firebaseinit();
    // ipcheck();
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to Flutter',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Welcome to Flutter'),
        ),
        body: const Center(
          child: Text('ready'),
        ),
          floatingActionButton: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  backgroundColor: Colors.red
                  ,

                  onPressed: () => {

                    scanNetwork()
                  },
                  child: Icon(Icons.abc),
                  heroTag: "fab1",

                ),
                FloatingActionButton(
                  onPressed: () => {
                    opendoor()

                  },
                  child: Icon(Icons.navigate_next_rounded),
                  heroTag: "fab2",
                ),
              ]
          )
      ),
    );
  }

  Future<void> firebaseinit() async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: 'mywifiswitch@gmail.com',
          password: 'mywifi123'
      );
      print(credential.user?.uid);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    }
  }
}




//
//   Future<void> ipcheck() async {
//     //1. Range
//     const String address = '192.168.18.1';
//     // or You can also get address using network_info_plus package
//     // final String? address = await (NetworkInfo().getWifiIP());
//     final String subnet = address.substring(0, address.lastIndexOf('.'));
//
//     // [New] Scan for a single open port in a subnet
//     // You can set [firstSubnet] and scan will start from this host in the network.
//     // Similarly set [lastSubnet] and scan will end at this host in the network.
//     final stream2 = HostScanner.scanDevicesForSinglePort(
//       subnet,
//       4210,
//       // firstSubnet: 1,
//       // lastSubnet: 254,
//       progressCallback: (progress) {
//         // print('Progress for port discovery on host : $progress');
//       },
//     );
//
//     stream2.listen(
//           (activeHost) {
//             print("in");
//         final OpenPort deviceWithOpenPort = activeHost.openPort[0];
//         if (deviceWithOpenPort.isOpen) {
//           print(
//             'Found open port: ${deviceWithOpenPort.port} on ${activeHost.address}',
//           );
//         }
//       },
//       onDone: () {
//         print('Port Scan completed');
//       },
//     ); // Don't forget to cancel the stream when not in use.// Don't forget to cancel the stream when not in use.
//   }
//   void ipc2(){
//     const port = 80;
//     final stream = NetworkAnalyzer.discover2(
//       '192.168.18', port,
//       timeout: Duration(milliseconds: 5000),
//     );
//
//     int found = 0;
//     stream.listen((NetworkAddress addr) {
//       if (addr.exists) {
//         found++;
//         print('Found device: ${addr.ip}:$port');
//       }
//     }).onDone(() => print('Finish. Found $found device(s)'));
//
// }
