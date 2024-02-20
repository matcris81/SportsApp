import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:footy_fix/services/database_services.dart';
import 'package:footy_fix/services/shared_preferences_service.dart';
import 'package:pay/pay.dart';
import 'package:footy_fix/payment_config.dart';
import 'dart:io' show Platform;

class PaymentScreen extends StatefulWidget {
  final double price;
  final String label;
  final int gameID;

  const PaymentScreen({
    Key? key,
    required this.price,
    required this.label,
    required this.gameID,
  }) : super(key: key);

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>(); // Add a key for the form
  int _selectedPriceIndex = -1; // Initial state, no selection
  final List<double> _priceOptions = [0, 25, 50];
  String os = Platform.operatingSystem;
  late PaymentItem _paymentItem;
  List<PaymentItem> _paymentItems = [];

  @override
  void initState() {
    super.initState();
    // _paymentItems = [
    //   PaymentItem(
    //     label: widget.label,
    //     amount: widget.price.toStringAsFixed(2),
    //     status: PaymentItemStatus.final_price,
    //   ),
    //   // Add more PaymentItems if necessary
    // ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Top up',
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
        padding: const EdgeInsets.all(15),
        child: Column(
          children: <Widget>[
            const SizedBox(height: 15),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Amount",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Center(
              child: Text(
                "Select the amount you want to top up",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_priceOptions.length, (index) {
                // 'index' is defined here, within the scope of this lambda function.
                double price = _priceOptions[index];
                bool isSelected = _selectedPriceIndex == index;
                // The 'index' is accessible here, inside the lambda function.
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedPriceIndex = index;
                      // Now update the payment items based on the selected price.
                      _paymentItems = [
                        PaymentItem(
                          label: widget.label,
                          amount: price == 0
                              ? widget.price.toStringAsFixed(2)
                              : price.toStringAsFixed(2),
                          status: PaymentItemStatus.final_price,
                        ),
                        // Add more PaymentItems if necessary.
                      ];
                    });
                  },
                  child: Container(
                    // Container properties...
                    width: 80,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.black : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: isSelected ? Colors.blue : Colors.black),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    alignment: Alignment.center,
                    child: Text(
                      price == 0 ? '\$${widget.price}' : '\$$price',
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(height: 30),
            const Center(
              child: Text(
                "All transactions can be seen in profile/past transactions",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 50),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Select Payment Method',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Platform.isIOS
                ? Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: Colors.black), // Add black border
                    ),
                    child: ApplePayButton(
                      paymentConfiguration:
                          PaymentConfiguration.fromJsonString(defaultApplePay),
                      paymentItems: _paymentItems,
                      style: ApplePayButtonStyle.white,
                      width: double.infinity,
                      height: 50,
                      type: ApplePayButtonType.buy,
                      onPaymentResult: onApplePayResult,
                      loadingIndicator:
                          const Center(child: CircularProgressIndicator()),
                    ),
                  )
                // : RawGooglePayButton(
                //     onPressed: () {},
                //     type: GooglePayButtonType.pay,
                //   ),
                // : Container(
                //     padding: const EdgeInsets.all(2),
                //     decoration: BoxDecoration(
                //       color: Colors.white,
                //       borderRadius: BorderRadius.circular(12),
                //       border:
                //           Border.all(color: Colors.black), // Add black border
                //     ),
                //     child
                : GooglePayButton(
                    paymentConfiguration:
                        PaymentConfiguration.fromJsonString(defaultGooglePay),
                    paymentItems: _paymentItems,
                    type: GooglePayButtonType.pay,
                    margin: const EdgeInsets.only(top: 15.0),
                    width: double.infinity,
                    onPaymentResult: onGooglePayResult,
                    loadingIndicator: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
            // ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black), // Add black border
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    // Handle Apple Pay button tap
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(11.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.credit_card,
                          size: 30,
                          color: Colors.grey,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Credit/Debit Card',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  void onApplePayResult(Map<String, dynamic> result) async {
    int count = 0;
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

    DateTime now = DateTime.now().toUtc(); // Ensure it's in UTC
    String formattedDateTime = '${now.toIso8601String().split('.')[0]}Z';

    // NEED TO FIGURE OUT HOW TO DO STATUS

    var paymentBody = {
      "amount": widget.price,
      "dateTime": formattedDateTime,
      "status": "PENDING",
      "player": {"id": userID}
    };

    var response = await DatabaseServices().postData(
        '${DatabaseServices().backendUrl}/api/payments', token, paymentBody);

    var result = await DatabaseServices().patchData(
        '${DatabaseServices().backendUrl}/api/players/$userID', token, body);

    Navigator.popUntil(context, (route) {
      return count++ == 2;
    });
  }

  void onGooglePayResult(Map<String, dynamic> result) {
    print("Apple Pay Result: $result");
  }

  //   Future<void> presentApplePay(Map paymentItems) async {
  //   try {
  //     await Stripe.instance.presentApplePay(
  //       paymentItems: paymentItems,
  //       onApplePayResult: onApplePayResult,
  //     );
  //   }
  // }

  // GooglePayButton _buildGooglePayButton() {
  //   return GooglePayButton(
  //       paymentConfiguration:
  //           PaymentConfiguration.fromJsonString(defaultGooglePay),
  //       paymentItems: [
  //         PaymentItem(
  //           amount: widget.price.toStringAsFixed(2),
  //           status: PaymentItemStatus.final_price,
  //         ),
  //       ],
  //       width: double.infinity,
  //       height: 50,
  //       type: GooglePayButtonType.buy,
  //       margin: const EdgeInsets.only(top: 15.0),
  //       onPaymentResult: (result) {
  //         debugPrint('Payment Result: $result');
  //         if (result['status'] == 'success') {
  //           // _updateDatabaseAfterPayment();
  //         } else {
  //           debugPrint('Payment failed or cancelled');
  //         }
  //       },
  //       loadingIndicator: const Center(child: CircularProgressIndicator()));
  // }
}
