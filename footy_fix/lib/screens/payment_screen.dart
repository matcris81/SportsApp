import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:footy_fix/services/database_services.dart';
import 'package:footy_fix/services/shared_preferences_service.dart';
import 'package:go_router/go_router.dart';
import 'package:pay/pay.dart';
import 'package:footy_fix/payment_config.dart';
import 'dart:io' show Platform;

class PaymentScreen extends StatefulWidget {
  final double price;
  final String? label;
  final int? gameID;
  final bool topUp;

  const PaymentScreen({
    Key? key,
    required this.price,
    this.label,
    this.gameID,
    required this.topUp,
  }) : super(key: key);

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  int _selectedPriceIndex = -1;
  late List<double> priceOptions = [widget.price, 25, 50];
  String os = Platform.operatingSystem;
  late PaymentItem _paymentItem;
  List<PaymentItem> _paymentItems = [];
  String? userID;
  double? newPrice;

  @override
  void initState() {
    super.initState();
    getUserId();
    _selectedPriceIndex = widget.topUp ? -1 : 0;

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
    if (!widget.topUp && _paymentItems.isEmpty) {
      _paymentItems = [
        PaymentItem(
          label: widget.label ?? 'Payment',
          amount: widget.price.toStringAsFixed(2),
          status: PaymentItemStatus.final_price,
        ),
      ];
    }

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
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: <Widget>[
            if (widget.topUp) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(priceOptions.length, (index) {
                  newPrice = priceOptions[index];
                  bool isSelected = _selectedPriceIndex == index;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedPriceIndex = index;
                        newPrice = priceOptions[_selectedPriceIndex];
                        _paymentItems = [
                          PaymentItem(
                            label: widget.label ?? 'Payment',
                            amount: newPrice!.toStringAsFixed(2),
                            status: PaymentItemStatus.final_price,
                          ),
                        ];
                      });
                    },
                    child: Container(
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
                        newPrice == 0 ? '\$${widget.price}' : '\$$newPrice',
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ] else ...[
              Container(
                width: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                alignment: Alignment.center,
                child: Text(
                  '\$${widget.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
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
            if (!widget.topUp)
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      processCreditPayment();
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
                            'Pay with credit',
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
            const SizedBox(height: 20),
            Platform.isIOS
                ? Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black),
                    ),
                    child: ApplePayButton(
                      paymentConfiguration:
                          PaymentConfiguration.fromJsonString(defaultApplePay),
                      paymentItems: _paymentItems,
                      style: ApplePayButtonStyle.white,
                      width: double.infinity,
                      height: 50,
                      type: ApplePayButtonType.buy,
                      onPaymentResult: payResult,
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
                    onPaymentResult: payResult,
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
                    showCreditCardInputForm();
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

  Future<void> processCreditPayment() async {
    print('Pay with Credit');

    var token =
        await DatabaseServices().authenticateAndGetToken('admin', 'admin');

    var response = await DatabaseServices().getData(
        '${DatabaseServices().backendUrl}/api/players/$userID/balance', token);

    var balance = jsonDecode(response.body);

    var afterPaymentBalance = balance - widget.price;

    print('afterPaymentBalance: $afterPaymentBalance');

    if (afterPaymentBalance < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Insufficient credit to complete this transaction.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          margin: EdgeInsets.all(10),
        ),
      );
    } else if (afterPaymentBalance >= 0) {
      var money = await DatabaseServices().patchDataWithoutMap(
          '${DatabaseServices().backendUrl}/api/players/$userID/subtract-balance',
          token,
          widget.price);

      var gameBody = {
        "id": userID,
        "games": [
          {
            "id": widget.gameID,
          }
        ],
      };

      var addGameresult = await DatabaseServices().patchData(
          '${DatabaseServices().backendUrl}/api/players/$userID',
          token,
          gameBody);

      context.go('/home/${widget.gameID}');
    }
  }

  void payResult(Map<String, dynamic>? result) async {
    double amount = priceOptions[_selectedPriceIndex];
    print('Pay amount: $amount');

    var token =
        await DatabaseServices().authenticateAndGetToken('admin', 'admin');

    if (widget.topUp) {
      // var topUpBody = {
      //   "id": userID,
      //   "balance": amount,
      // };

      // var balanceBody = {"amount": widget.price};

      var topupBalance = await DatabaseServices().patchDataWithoutMap(
          '${DatabaseServices().backendUrl}/api/players/$userID/add-balance',
          token,
          widget.price);

      context.go('/');
    } else {
      var body = {
        "id": userID,
        "games": [
          {
            "id": widget.gameID,
          }
        ],
      };

      DateTime now = DateTime.now().toUtc();
      String formattedDateTime = '${now.toIso8601String().split('.')[0]}Z';

      // NEED TO FIGURE OUT HOW TO DO STATUS

      var paymentBody = {
        "amount": amount,
        "dateTime": formattedDateTime,
        "status": "COMPLETED",
        "player": {"id": userID}
      };

      var addPaymentResult = await DatabaseServices().postData(
          '${DatabaseServices().backendUrl}/api/payments', token, paymentBody);

      var addGameresult = await DatabaseServices().patchData(
          '${DatabaseServices().backendUrl}/api/players/$userID', token, body);
      context.go('/home/${widget.gameID}');
    }
  }

  Future<void> getUserId() async {
    String? id = await PreferencesService().getUserId();
    setState(() {
      userID = id;
    });
  }

  void showCreditCardInputForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        double height = MediaQuery.of(context).size.height / 2;
        return Container(
          height: height,
          padding: EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const TextField(
                  decoration: InputDecoration(
                    labelText: 'Card Number',
                    hintText: '1234 5678 9012 3456',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const TextField(
                  decoration: InputDecoration(
                    labelText: 'Expiration Date',
                    hintText: 'MM/YY',
                  ),
                  keyboardType: TextInputType.datetime,
                ),
                const TextField(
                  decoration: InputDecoration(
                    labelText: 'CVV',
                    hintText: '123',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const TextField(
                  decoration: InputDecoration(
                    labelText: 'Cardholder Name',
                    hintText: 'John Doe',
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Map<String, dynamic> result = {};
                    payResult(result);
                    // Navigator.pop(context);
                    if (widget.topUp) {
                      context.go('/');
                    } else {
                      context.go('/home/${widget.gameID}');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Pay'),
                ),
              ],
            ),
          ),
        );
      },
    );
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
