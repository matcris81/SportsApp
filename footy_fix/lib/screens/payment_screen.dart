import 'package:flutter/material.dart';
import 'package:footy_fix/services/database_service.dart';
import 'package:footy_fix/services/shared_preferences_service.dart';
import 'package:pay/pay.dart';
import 'dart:io' show Platform;
import 'package:footy_fix/payment_config.dart';

class PaymentScreen extends StatefulWidget {
  final String locationName;
  final String gameID;
  final String date;
  final String price;

  const PaymentScreen(
      {Key? key,
      required this.gameID,
      required this.date,
      required this.price,
      required this.locationName})
      : super(key: key);

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String os = Platform.operatingSystem;

  ApplePayButton _buildApplePayButton() {
    return ApplePayButton(
        paymentConfiguration:
            PaymentConfiguration.fromJsonString(defaultApplePay),
        paymentItems: const [
          PaymentItem(
            label: 'Item A',
            amount: '0.01',
            status: PaymentItemStatus.final_price,
          ),
          PaymentItem(
            label: 'Item B',
            amount: '0.01',
            status: PaymentItemStatus.final_price,
          ),
          PaymentItem(
            label: 'Total',
            amount: '0.01',
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
            _updateDatabaseAfterPayment();
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
        paymentItems: const [
          PaymentItem(
            label: 'Item A',
            amount: '0.01',
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
            _updateDatabaseAfterPayment();
          } else {
            debugPrint('Payment failed or cancelled');
          }
        },
        loadingIndicator: const Center(child: CircularProgressIndicator()));
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
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            // You can place other widgets here if needed
            Spacer(), // This will push the button to the bottom
            Center(
                child: Platform.isIOS
                    ? _buildApplePayButton()
                    : _buildGooglePayButton()),
          ],
        ),
      ),
    );
  }

  void _updateDatabaseAfterPayment() async {
    // Your logic to update the database
    String userID = await PreferencesService().getUserId() ?? '';

    Object? data = await DatabaseServices().retrieveFromDatabase(
        'Location Details/${widget.locationName}/Games/${widget.gameID}');

    await DatabaseServices().addToDataBase(
        'User Preferences/$userID/Games joined/${widget.locationName}/${widget.gameID}',
        data);

    print('data is $data');

    await DatabaseServices().incrementValue(
        'Location Details/${widget.locationName}/Games/${widget.date}/${widget.gameID}/',
        'Players joined');
  }
}
