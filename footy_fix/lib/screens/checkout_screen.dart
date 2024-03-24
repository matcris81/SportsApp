import 'dart:convert';
import 'package:footy_fix/services/database_services.dart';
import 'package:flutter/material.dart';
import 'package:footy_fix/components/game_tile.dart';
import 'package:go_router/go_router.dart';

class CheckoutScreen extends StatefulWidget {
  final int gameID;

  const CheckoutScreen({
    Key? key,
    required this.gameID,
  }) : super(key: key);

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool isLoading = true;
  double price = 0.0;
  DateTime? date;
  int? venueId;

  @override
  void initState() {
    super.initState();
    getGameInfo();
  }

  void getGameInfo() async {
    // var token =
    //     await DatabaseServices().authenticateAndGetToken('admin', 'admin');

    var response = await DatabaseServices()
        .getData('${DatabaseServices().backendUrl}/api/games/${widget.gameID}');

    Map<String, dynamic> gameInfo = jsonDecode(response.body);

    setState(() {
      isLoading = false;
      price = gameInfo['price'];
      venueId = gameInfo['venueId'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Checkout',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Container(
          constraints: BoxConstraints.expand(), // Add constraints here
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    const Padding(
                      padding: EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Purchase:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GameTile(
                      locationID: venueId ?? 0,
                      gameID: widget.gameID,
                      payment: true,
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          isLoading
                              ? CircularProgressIndicator()
                              : Text(
                                  '\$${price.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  context.go(
                                      '/game/${widget.gameID}/checkout/payment/$price/false');
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30, vertical: 15),
                          ),
                          child: const Text(
                            'Continue to Checkout',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
