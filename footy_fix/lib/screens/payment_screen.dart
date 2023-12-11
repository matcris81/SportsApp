import 'package:flutter/material.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({Key? key}) : super(key: key);

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(
              top: 500), // Adjust the padding value as needed
          child: buildApplePayButton(),
        ),
      ),
    );
  }

  Widget buildApplePayButton() {
    return ElevatedButton(
      onPressed: () {
        // TODO: Implement Apple Pay Integration
      },
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white, backgroundColor: Colors.black, // Text and icon color
        padding: const EdgeInsets.symmetric(
            horizontal: 32.0, vertical: 12.0), // Increase horizontal padding
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        minimumSize: const Size(200, 50), // Set a minimum size for the button
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // To wrap the content of the row
        children: <Widget>[
          Image.asset('assets/apple_logo.png',
              height: 24.0), // Adjust size as needed
          const SizedBox(width: 8.0),
          const Text('Pay', style: TextStyle(fontSize: 18)),
        ],
      ),
    );
  }
}
