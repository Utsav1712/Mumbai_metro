import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer';
import '../../models/PaymentModel.dart';
import '../models/customer_data_model.dart';
import '../constant/app_formatter.dart';

const Color darkBlue = Color(0xFF03669d);
const Color mediumBlue = Color(0xFF37b3e7);
const Color lightBlue = Color(0xFF7ed2f7);
const Color whiteColor = Color(0xFFf7f7f7);

class PaymentDetailsScreen extends StatefulWidget {
  final int customerId; // Accept customerId
  const PaymentDetailsScreen(
      {super.key, this.customerId = 41}); // Default for now

  @override
  State<PaymentDetailsScreen> createState() => _PaymentDetailsScreenState();
}

class _PaymentDetailsScreenState extends State<PaymentDetailsScreen> {
  List<PaymentModel> payments = [];
  bool isLoading = true;
  String? errorMessage;
  CustomerModel? customerModel;

  @override
  void initState() {
    super.initState();
    _fetchAllData();
  }

  Future<void> _fetchAllData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      await Future.wait([
        _fetchPayments(),
        _fetchCustomerData(),
      ]);
    } catch (e) {
      setState(() {
        errorMessage = 'An error occurred: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchCustomerData() async {
    try {
      final String apiUrl =
          "http://54kidsstreet.org/api/customer/${widget.customerId}";
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint("url: $apiUrl");
        debugPrint("Customer Data: $data");
        // Assuming the structure matches MyProfileScreen logic
        if (data['status'] == true || data['data'] != null) {
          setState(() {
            customerModel = CustomerModel.fromJson(data);
          });
        }
      } else {
        log("Failed to load customer data: ${response.statusCode}");
      }
    } catch (e) {
      log("Error fetching customer data: $e");
    }
  }

  Future<void> _fetchPayments() async {
    try {
      final String apiUrl =
          'https://54kidsstreet.org/api/customer/${widget.customerId}/payments';
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true) {
          setState(() {
            payments = (jsonData['data'] as List)
                .map((data) => PaymentModel.fromJson(data))
                .toList();
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = 'Failed to load payments';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'Error: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'An error occurred: $e';
        isLoading = false;
      });
    }
  }

  String _calculate10Percent(String? amount) {
    if (amount == null || amount.isEmpty) return "0.00";
    try {
      double value = double.parse(amount);
      return (value * 0.10).toStringAsFixed(2);
    } catch (e) {
      return "0.00";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        title: const Text(
          'Payment Details',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        backgroundColor: darkBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: darkBlue))
          : errorMessage != null
              ? Center(
                  child: Text(errorMessage!,
                      style: const TextStyle(color: Colors.red)))
              : payments.isEmpty
                  ? const Center(child: Text("No payments found"))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: payments.length,
                      itemBuilder: (context, index) {
                        final payment = payments[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Customer ID
                              Row(
                                children: [
                                  const Text(
                                    "Customer ID: ",
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: darkBlue,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Poppins'),
                                  ),
                                  Text(
                                    "${customerModel?.data.id ?? 'N/A'}",
                                    style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black,
                                        fontFamily: 'Poppins'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              // Name
                              Row(
                                children: [
                                  const Text(
                                    "Name : ",
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: darkBlue,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Poppins'),
                                  ),
                                  Expanded(
                                    child: Text(
                                      customerModel?.data.customerName ?? 'N/A',
                                      style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black,
                                          fontFamily: 'Poppins'),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              // Mobile
                              Row(
                                children: [
                                  const Text(
                                    "Mobile : ",
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: darkBlue,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Poppins'),
                                  ),
                                  Text(
                                    customerModel?.data.mobileNo ?? 'N/A',
                                    style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black,
                                        fontFamily: 'Poppins'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              // Email
                              Row(
                                children: [
                                  const Text(
                                    "E-MAIL: ",
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: darkBlue,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Poppins'),
                                  ),
                                  Expanded(
                                    child: Text(
                                      customerModel?.data.email ?? 'N/A',
                                      style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black,
                                          fontFamily: 'Poppins'),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              // 10% Paid Amount
                              Row(
                                children: [
                                  const Text(
                                    "10% Paid Amount: ",
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: darkBlue,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Poppins'),
                                  ),
                                  Text(
                                    "₹${_calculate10Percent(payment.totalAmount)}",
                                    style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black,
                                        fontFamily: 'Poppins'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              // Payment (Transaction) Id
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Payment (Transaction) Id: ",
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: darkBlue,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Poppins'),
                                  ),
                                  Expanded(
                                    child: Text(
                                      payment.transactionId ?? 'N/A',
                                      style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black,
                                          fontFamily: 'Poppins'),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              // Time
                              Row(
                                children: [
                                  const Text(
                                    "Time: ",
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: darkBlue,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Poppins'),
                                  ),
                                  Expanded(
                                    child: Text(
                                      AppFormatter.convertCreateDate(
                                          input: payment.paymentDate ?? 'N/A'),
                                      style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black,
                                          fontFamily: 'Poppins'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
    );
  }
}
