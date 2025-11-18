// import 'dart:convert';
// import 'dart:developer';
//
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:razorpay_flutter/razorpay_flutter.dart';
//
// import '../../views/HomeServiceView.dart';
// import '../models/customer_data_model.dart';
//
// class PaymentService {
//   static final PaymentService _instance = PaymentService._internal();
//
//   factory PaymentService() => _instance;
//
//   PaymentService._internal();
//
//   final Razorpay _razorpay = Razorpay();
//
//   bool _initialized = false;
//
//   void _init(BuildContext context, int amount, String orderNumber) {
//     if (_initialized) return;
//     _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS,
//         (PaymentSuccessResponse response) {
//       log("Payment res----->>${response.signature}----->>${response.orderId}");
//       _handlePaymentSuccess(
//         context,
//         response,
//         amount,
//         orderNumber,
//       );
//     });
//     _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR,
//         (PaymentFailureResponse response) {
//       _handlePaymentError(context, response);
//     });
//     _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET,
//         (ExternalWalletResponse response) {
//       _handleExternalWallet(context, response);
//     });
//     _initialized = true;
//   }
//
//   void startPayment(
//     BuildContext context, {
//     required int amount,
//     required String orderNumber,
//     required CustomerModel customerData,
//     String apiKey = 'rzp_test_RcOxA7Dz05K2DM',
//   }) {
//     _init(
//       context,
//       amount,
//       orderNumber,
//     );
//
//     var options = {
//       'key': apiKey,
//       'amount': (amount * 100).toInt(), // Razorpay takes amount in paise
//       'name': customerData.data.customerName.isNotEmpty
//           ? customerData.data.customerName
//           : 'User',
//       'description': 'Payment for service',
//       'prefill': {
//         'contact': customerData.data.mobileNo.isNotEmpty
//             ? customerData.data.mobileNo
//             : '',
//         'email':
//             customerData.data.email.isNotEmpty ? customerData.data.email : '',
//       },
//       'currency': 'INR',
//       'theme': {'color': '#3399cc'},
//     };
//
//     try {
//       _razorpay.open(options);
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: $e')),
//       );
//     }
//   }
//
//   Future<void> _handlePaymentSuccess(
//     BuildContext context,
//     PaymentSuccessResponse response,
//     int amount,
//     String orderNumber,
//   ) async {
//     log('----Order number------->>${orderNumber}');
//     await callSuccessApi(
//       context: context,
//       amount: amount,
//       orderNumber: orderNumber,
//       paymentResponse: response,
//     );
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Payment Successful! ID: ${response.paymentId}')),
//     );
//     debugPrint('Payment Success: ${response.paymentId}');
//   }
//
//   void _handlePaymentError(
//       BuildContext context, PaymentFailureResponse response) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Payment Failed: ${response.message}')),
//     );
//     debugPrint('Payment Failed: ${response.code} | ${response.message}');
//   }
//
//   void _handleExternalWallet(
//       BuildContext context, ExternalWalletResponse response) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('External Wallet: ${response.walletName}')),
//     );
//     debugPrint('External Wallet Selected: ${response.walletName}');
//   }
//
//   void clear() {
//     _razorpay.clear();
//     _initialized = false;
//   }
//
//   //call success api
//
//   Future<void> callSuccessApi({
//     required BuildContext context,
//     required int amount,
//     required String orderNumber,
//     required PaymentSuccessResponse paymentResponse,
//   }) async {
//     // Step 1: Call your backend API to initiate payment
//     final url = Uri.parse('https://54kidsstreet.org/api/payment/initiate');
//     final body = {
//       'order_no': orderNumber,
//       'amount': amount,
//     };
//
//     try {
//       debugPrint('📤 Sending payment initiation request to: $url');
//       debugPrint('➡️ Body: $body');
//
//       final response = await http.post(
//         url,
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode(body),
//       );
//
//       debugPrint('📥 Response Code: ${response.statusCode}');
//       debugPrint('📥 Response Body: ${response.body}');
//
//       if (response.statusCode == 200) {
//         // final data = jsonDecode(response.body);
//         // await callWebhook(
//         //   context: context,
//         //   response: paymentResponse,
//         //   orderId: orderNumber,
//         // );
//         if (paymentResponse != null) {
//           await verifyPayment(
//             response: paymentResponse,
//             context: context,
//           );
//         }
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Payment initiation failed.')),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error initiating payment: $e')),
//       );
//       debugPrint('❌ Payment initiation error: $e');
//     }
//   }
//
//   Future<void> verifyPayment({
//     required PaymentSuccessResponse response,
//     required BuildContext context,
//   }) async {
//     final url = Uri.parse("https://54kidsstreet.org/api/payment/verify");
//
//     final body = {
//       "razorpay_payment_id": "${response.paymentId}",
//       "razorpay_order_id": "${response.orderId}",
//       "razorpay_signature": "${response.signature}"
//     };
//
//     log('Body---->>${body}');
//
//     try {
//       final response = await http.post(
//         url,
//         headers: {
//           "Content-Type": "application/json",
//           "Accept": "application/json"
//         },
//         body: jsonEncode(body),
//       );
//
//       if (response.statusCode == 200) {
//         log("Payment Verified Successfully");
//         Navigator.of(context).pushAndRemoveUntil(
//           MaterialPageRoute(builder: (context) => const HomeServiceView()),
//           (Route<dynamic> route) => false,
//         );
//         log('Payment verify res---->>>${response.body}');
//       } else {
//         log("Failed: ${response.statusCode}");
//         log(response.body);
//       }
//     } catch (e) {
//       log("Error: $e");
//     }
//   }
//
// // Future<void> callWebhook({
// //   required BuildContext context,
// //   required PaymentSuccessResponse response,
// //   required String orderId,
// // }) async {
// //   log('Webhook order id---->>${orderId}');
// //   final webhookUrl =
// //       Uri.parse('https://54kidsstreet.org/api/payment/webhook');
// //   // Create the payload similar to your backend format
// //   final webhookBody = {
// //     "payload": {
// //       "payment": {
// //         "entity": {
// //           "id": response.paymentId ?? '',
// //           "order_id": orderId ?? '',
// //           "status": "captured",
// //           "method": "upi"
// //         }
// //       }
// //     }
// //   };
// //
// //   try {
// //     debugPrint('📤 Sending webhook data to: $webhookUrl');
// //     debugPrint('➡️ Body: ${jsonEncode(webhookBody)}');
// //
// //     final webhookResponse = await http.post(
// //       webhookUrl,
// //       headers: {'Content-Type': 'application/json'},
// //       body: jsonEncode(webhookBody),
// //     );
// //
// //     debugPrint('📥 Webhook Response Code: ${webhookResponse.statusCode}');
// //     debugPrint('📥 Webhook Response Body: ${webhookResponse.body}');
// //
// //     if(webhookResponse.statusCode == 200){
// //       Navigator.of(context).pushAndRemoveUntil(
// //         MaterialPageRoute(builder: (context) => const HomeServiceView()),
// //             (Route<dynamic> route) => false,
// //       );
// //     }
// //   } catch (e) {
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(content: Text('Error initiating payment: ${e.toString()}')),
// //     );
// //     debugPrint('❌ Error sending webhook: $e');
// //   }
// // }
// }


import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../views/HomeServiceView.dart';
import '../models/customer_data_model.dart';

class PaymentService {
  static final PaymentService _instance = PaymentService._internal();
  factory PaymentService() => _instance;
  PaymentService._internal();

  final Razorpay _razorpay = Razorpay();
  bool _initialized = false;

  BuildContext? _currentContext;
  int? _currentAmount;
  String? _currentOrderNumber;

  // Initialize Razorpay callbacks
  void _init(BuildContext context, int amount, String orderNumber) {
    if (_initialized) return;

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS,
            (PaymentSuccessResponse response) {
          log("✔ SUCCESS → paymentId=${response.paymentId}, orderId=${response.orderId}, signature=${response.signature}");
          _handlePaymentSuccess(context, response);
        });

    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR,
            (PaymentFailureResponse response) {
          _handlePaymentError(context, response);
        });

    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET,
            (ExternalWalletResponse response) {
          _handleExternalWallet(context, response);
        });

    _initialized = true;

    _currentContext = context;
    _currentAmount = amount;
    _currentOrderNumber = orderNumber;
  }

  // ---------------------------------------------------------
  //  PUBLIC: START PAYMENT FLOW
  // ---------------------------------------------------------
  Future<void> startPaymentFlow(
      BuildContext context, {
        required int amount,
        required String orderNumber,
        required CustomerModel customerData,
        String apiKey = 'rzp_test_RcOxA7Dz05K2DM',
      }) async {
    _init(context, amount, orderNumber);

    try {
      // STEP 1 — call backend to create Razorpay order
      final initiateUrl =
      Uri.parse('https://54kidsstreet.org/api/payment/initiate');

      final body = {
        "order_no": orderNumber,
        "amount": amount,
      };

      log("📤 INITIATE CALL BODY → $body");

      final initRes = await http.post(
        initiateUrl,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      log("📥 INITIATE RESPONSE → ${initRes.body}-->>${initRes.statusCode}");

      // if (initRes.statusCode != 200) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(content: Text("Payment initiation failed.")),
      //   );
      //   return;
      // }

      final data = jsonDecode(initRes.body);

      // 🔥 Adjust according to your backend EXACT structure
      final razorpayOrderId = data["razorpay_order_id"];

      if (razorpayOrderId == null || razorpayOrderId == "") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid Razorpay order id.")),
        );
        return;
      }

      log("✔ Razorpay Order ID → $razorpayOrderId");

      // STEP 2 — open Razorpay checkout
      startPayment(
        context,
        amount: amount,
        orderNumber: orderNumber,
        customerData: customerData,
        apiKey: apiKey,
        razorpayOrderId: razorpayOrderId,
      );
    } catch (e, st) {
      log("❌ Exception in startPaymentFlow → $e\n$st");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  // ---------------------------------------------------------
  //  YOUR UPDATED startPayment() (WITH order_id added)
  // ---------------------------------------------------------
  void startPayment(
      BuildContext context, {
        required int amount,
        required String orderNumber,
        required CustomerModel customerData,
        required String razorpayOrderId,
        String apiKey = 'rzp_test_RcOxA7Dz05K2DM',
      }) {
    _init(context, amount, orderNumber);

    var options = {
      'key': apiKey,
      'order_id': razorpayOrderId, // 🔴 CRITICAL FIX
      'amount': (amount * 100).toInt(),
      'name': customerData.data.customerName.isNotEmpty
          ? customerData.data.customerName
          : 'User',
      'description': 'Payment for service',
      'prefill': {
        'contact': customerData.data.mobileNo.isNotEmpty
            ? customerData.data.mobileNo
            : '',
        'email': customerData.data.email.isNotEmpty
            ? customerData.data.email
            : '',
      },
      'currency': 'INR',
      'theme': {'color': '#3399cc'},
    };

    log("🧾 Razorpay Options → $options");

    try {
      _razorpay.open(options);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  // ---------------------------------------------------------
  //  SUCCESS HANDLER → calls verify API
  // ---------------------------------------------------------
  Future<void> _handlePaymentSuccess(
      BuildContext context, PaymentSuccessResponse response) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment Success: ${response.paymentId}")),
    );

    await verifyPayment(context: context, response: response);
  }

  // ---------------------------------------------------------
  //  VERIFY PAYMENT API
  // ---------------------------------------------------------
  Future<void> verifyPayment({
    required BuildContext context,
    required PaymentSuccessResponse response,
  }) async {
    final url = Uri.parse("https://54kidsstreet.org/api/payment/verify");

    final body = {
      "razorpay_payment_id": response.paymentId,
      "razorpay_order_id": response.orderId,
      "razorpay_signature": response.signature
    };

    log("📤 VERIFY BODY → $body");

    try {
      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      log("📥 VERIFY → ${res.body}");

      if (res.statusCode == 200) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeServiceView()),
              (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Payment verification failed.")),
        );
      }
    } catch (e) {
      log("❌ Error verifying payment → $e");
    }
  }

  void _handlePaymentError(
      BuildContext context, PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment Failed: ${response.message}")),
    );
  }

  void _handleExternalWallet(
      BuildContext context, ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("External Wallet: ${response.walletName}")),
    );
  }

  void clear() {
    _razorpay.clear();
    _initialized = false;
  }
}
