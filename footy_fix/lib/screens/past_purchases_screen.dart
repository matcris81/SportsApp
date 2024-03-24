import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:footy_fix/services/database_services.dart';
import 'package:footy_fix/services/shared_preferences_service.dart';
import 'package:intl/intl.dart';

class PastPurchasesScreen extends StatefulWidget {
  const PastPurchasesScreen({Key? key}) : super(key: key);

  @override
  _PastPurchasesScreenState createState() => _PastPurchasesScreenState();
}

class _PastPurchasesScreenState extends State<PastPurchasesScreen> {
  Future<List<dynamic>> getPlayerData() async {
    List<dynamic> playerData = [];
    var userID = await PreferencesService().getUserId();

    // var token =
    //     await DatabaseServices().authenticateAndGetToken('admin', 'admin');

    var response = await DatabaseServices().getData(
        '${DatabaseServices().backendUrl}/api/payments/user-purchases/$userID');

    playerData = jsonDecode(response.body);

    return playerData;
  }

  Future<String> getUserID() async {
    var userID = await PreferencesService().getUserId();

    return userID!;
  }

  @override
  Widget build(BuildContext buildContext) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Past Purchases',
            style: TextStyle(color: Colors.black, fontSize: 20)),
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(Icons.arrow_back, color: Colors.black),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FutureBuilder(
        future: getPlayerData(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var payments = snapshot.data as List<dynamic>;
            print(payments);
            return ListView.builder(
              itemCount: payments.length,
              itemBuilder: (context, index) {
                final payment = payments[index];
                var formattedDateTime = DateFormat.MMMEd()
                    .format(DateTime.parse(payment['dateTime']));
                return Card(
                  // margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  // child: Padding(
                  // padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('ID: ${payment['id']}'),
                        const SizedBox(height: 30),
                        Text('\$${payment['amount']}',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    subtitle: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(formattedDateTime),
                        const SizedBox(height: 30),
                        Text('${payment['status']}'),
                      ],
                    ),
                  ),
                  // ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
