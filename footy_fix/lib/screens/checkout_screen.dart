import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:footy_fix/components/game_tile.dart';
import 'package:footy_fix/screens/payment_screen.dart';
import 'package:footy_fix/services/shared_preferences_service.dart';
import 'package:pay/pay.dart';
import 'dart:io' show Platform;
import 'package:footy_fix/payment_config.dart';
import 'package:footy_fix/services/database_services.dart';

class CheckoutScreen extends StatefulWidget {
  final int gameID;
  final int venueId;

  const CheckoutScreen({
    Key? key,
    required this.venueId,
    required this.gameID,
  }) : super(key: key);

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String os = Platform.operatingSystem;
  bool isLoading = true;
  double price = 0.0;
  DateTime? date;

  @override
  void initState() {
    super.initState();
    getGameInfo();
  }

  void getGameInfo() async {
    var token =
        await DatabaseServices().authenticateAndGetToken('admin', 'admin');

    var response = await DatabaseServices().getData(
        '${DatabaseServices().backendUrl}/api/games/${widget.gameID}', token);

    Map<String, dynamic> gameInfo = jsonDecode(response.body);

    print('gameInfo: $gameInfo');

    setState(() {
      isLoading = false;
      price = gameInfo['price'];
    });
  }

  void tempAction() async {
    var userID = await PreferencesService().getUserId();

    var token =
        await DatabaseServices().authenticateAndGetToken('admin', 'admin');

    var body = {
      "id": userID,
      "games": [
        {
          "id": widget.gameID,
        }
      ],
    };

    var paymentBody = {
      "amount": price,
      "dateTime": "2024-02-08T12:00:00Z",
      "status": "PENDING",
      "player": {"id": userID}
    };

    var response = await DatabaseServices().postData(
        '${DatabaseServices().backendUrl}/api/payments', token, paymentBody);

    var result = await DatabaseServices().patchData(
        '${DatabaseServices().backendUrl}/api/players/$userID', token, body);
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: GameTile(
                          locationID: widget.venueId,
                          gameID: widget.gameID,
                          payment: true,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GameTile(
                          locationID: widget.venueId,
                          gameID: widget.gameID,
                        ),
                      ],
                    ),
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
                        onPressed: () {
                          // tempAction();
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) {
                              return PaymentScreen();
                            }),
                          );
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
            // Center(
            //     child: Platform.isIOS
            //         ? _buildApplePayButton()
            //         : _buildGooglePayButton()),
          ],
        ),
      ),
    );
  }
}

//    ApplePayButton _buildApplePayButton() {
//      return ApplePayButton(
//          paymentConfiguration:
//              PaymentConfiguration.fromJsonString(defaultApplePay),
//          paymentItems: [
//            PaymentItem(
//              label: widget.gameID.toString(),
//              amount: price.toStringAsFixed(2),
//              status: PaymentItemStatus.final_price,
//            ),
//          ],
//          style: ApplePayButtonStyle.black,
//          width: double.infinity,
//          height: 50,
//          type: ApplePayButtonType.buy,
//          margin: const EdgeInsets.only(top: 15.0),
//          onPaymentResult: (result) async {
//            debugPrint('Payment Result: $result');
//            if (result['status'] == 'success') {
//              // _updateDatabaseAfterPayment();
//            } else {
//              debugPrint('Payment failed or cancelled');
//            }
//          },
//          loadingIndicator: const Center(child: CircularProgressIndicator()));
//    }
//  
//    GooglePayButton _buildGooglePayButton() {
//      return GooglePayButton(
//          paymentConfiguration:
//              PaymentConfiguration.fromJsonString(defaultGooglePay),
//          paymentItems: [
//            PaymentItem(
//              label: widget.gameID.toString(),
//              amount: price.toStringAsFixed(2),
//              status: PaymentItemStatus.final_price,
//            ),
//          ],
//          width: double.infinity,
//          height: 50,
//          type: GooglePayButtonType.buy,
//          margin: const EdgeInsets.only(top: 15.0),
//          onPaymentResult: (result) {
//            debugPrint('Payment Result: $result');
//            if (result['status'] == 'success') {
//              // _updateDatabaseAfterPayment();
//            } else {
//              debugPrint('Payment failed or cancelled');
//            }
//         },
//          loadingIndicator: const Center(child: CircularProgressIndicator()));
//   }