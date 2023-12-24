import 'package:flutter/material.dart';
import 'package:footy_fix/services/db_services.dart';
import 'package:footy_fix/services/shared_preferences_service.dart';
import 'package:pay/pay.dart';
import 'dart:io' show Platform;
import 'package:footy_fix/payment_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaymentScreen extends StatefulWidget {
  final String gameID;
  final String date;
  final double price;

  const PaymentScreen({
    Key? key,
    required this.gameID,
    required this.date,
    required this.price,
  }) : super(key: key);

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String os = Platform.operatingSystem;

  ApplePayButton _buildApplePayButton() {
    return ApplePayButton(
        paymentConfiguration:
            PaymentConfiguration.fromJsonString(defaultApplePay),
        paymentItems: [
          PaymentItem(
            label: widget.gameID,
            amount: widget.price.toStringAsFixed(2),
            status: PaymentItemStatus.final_price,
          ),
        ],
        style: ApplePayButtonStyle.black,
        width: double.infinity,
        height: 50,
        type: ApplePayButtonType.buy,
        margin: const EdgeInsets.only(top: 15.0),
        onPaymentResult: (result) async {
          debugPrint('Payment Result: $result');
          if (result['status'] == 'success') {
            // _updateDatabaseAfterPayment();
          } else {
            debugPrint('Payment failed or cancelled');
          }
        },
        loadingIndicator: const Center(child: CircularProgressIndicator()));
  }

  GooglePayButton _buildGooglePayButton() {
    return GooglePayButton(
        paymentConfiguration:
            PaymentConfiguration.fromJsonString(defaultGooglePay),
        paymentItems: [
          PaymentItem(
            label: widget.gameID,
            amount: widget.price.toStringAsFixed(2),
            status: PaymentItemStatus.final_price,
          ),
        ],
        width: double.infinity,
        height: 50,
        type: GooglePayButtonType.buy,
        margin: const EdgeInsets.only(top: 15.0),
        onPaymentResult: (result) {
          debugPrint('Payment Result: $result');
          if (result['status'] == 'success') {
            // _updateDatabaseAfterPayment();
          } else {
            debugPrint('Payment failed or cancelled');
          }
        },
        loadingIndicator: const Center(child: CircularProgressIndicator()));
  }

  void tempAction() async {
    var userID = await PreferencesService().getUserId();

    await PostgresService().executeQuery(
        "INSERT INTO user_game_participation (user_id, game_id, status) "
        "VALUES ('$userID', ${widget.gameID}, 'Pending')");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Payment',
          style: TextStyle(
            fontSize: 16,
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
            Text(
              'Total Price: \$${widget.price.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  tempAction();
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue, // Button color
                  onPrimary: Colors.white, // Text color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // Rounded corners
                  ),
                  padding: EdgeInsets.symmetric(
                      horizontal: 30, vertical: 15), // Button padding
                ),
                child: Text(
                  'Proceed to Pay',
                  style: TextStyle(fontSize: 16),
                ),
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

  // void _updateDatabaseAfterPayment() async {
  //   // Your logic to update the database
  //   String userID = await PreferencesService().getUserId() ?? '';

  //   Object? data = await DatabaseServices().retrieveFromDatabase(
  //       'Location Details/${widget.locationName}/Games/${widget.gameID}');

  //   await DatabaseServices().addWithoutIDToDataBase(
  //       'User Preferences/$userID/Games joined/${widget.locationName}/${widget.gameID}',
  //       data);

  //   await DatabaseServices().incrementValue(
  //       'Location Details/${widget.locationName}/Games/${widget.gameID}/',
  //       'Players joined');
  // }
}
