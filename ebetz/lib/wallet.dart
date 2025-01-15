import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'sqflite_helper_database.dart';

class MyWallet extends StatefulWidget {
  final String username;
  const MyWallet({Key? key, required this.username}) : super(key: key);

  @override
  State<MyWallet> createState() => _MyWalletState();
}

class _MyWalletState extends State<MyWallet>
    with SingleTickerProviderStateMixin {
  TextEditingController amountAdditionToWalletController =
      TextEditingController();
  TextEditingController amountWithdrawToWalletController =
      TextEditingController();
  late AnimationController _controller;
  late Animation<double> _balanceAnimation;
  double accountBalance = 0.0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadTransactions();

    //accountBalance = _fetchAccountBalance(widget.username) as double;
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _balanceAnimation = Tween<double>(begin: 0, end: accountBalance).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _fetchAndSetAccountBalance().then((_) {
      setState(() {
        isLoading = false;
      });
    });
  }

  Future<void> _fetchAndSetAccountBalance() async {
    if (widget.username.isEmpty) {
      return;
    }
    final fetchedBalance = await _fetchAccountBalance(widget.username);
    setState(() {
      accountBalance = fetchedBalance ?? 0.0; // Default to 0 if null
      _balanceAnimation = Tween<double>(begin: 0, end: accountBalance).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      );
      _controller.forward();
    });
  }

  Future<double?> _fetchAccountBalance(String username) async {
    try {
      // Query Firestore to find the document where the 'username' field matches.
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users') // Replace 'users' with your collection name.
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      // Check if a document exists.
      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        return doc['Account_Balance']
            ?.toDouble(); // Replace with the actual field name in Firestore.
      } else {
        return null; // Username not found.
      }
    } catch (e) {
      return null;
    }
  }

  void _showAddFundsDialog({double amount = 0.0}) {
    // Set the amount to the controller's text
    amountAdditionToWalletController.text = amount.toString();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      builder: (BuildContext context) {
        double responsiveWidth = MediaQuery.of(context).size.width / 400;

        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: EdgeInsets.all(16.0 * responsiveWidth),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(0, 0, 41, 1),
               Color.fromRGBO(53, 52, 92, 1),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Enter Amount to Add',
                  style: TextStyle(
                    fontSize: 22 * responsiveWidth,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 20 * responsiveWidth),
                TextField(
                  controller: amountAdditionToWalletController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10 * responsiveWidth),
                      borderSide: BorderSide.none,
                    ),
                    hintText: 'Enter amount',
                    hintStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: const Icon(Icons.currency_rupee,
                        color: Colors.greenAccent),
                  ),
                ),
                SizedBox(height: 20 * responsiveWidth),
                FancyButton(
                  text: "Add Funds",
                  icon: Icons.add,
                  gradientColors: const [
                    Color.fromARGB(255, 105, 240, 174),
                    Color.fromARGB(255, 59, 138, 62)
                  ],
                  onPressed: () {
                    Navigator.pop(context);
                    _showPaymentOptionsDialog();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  void _showWithdrawFundsDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      builder: (BuildContext context) {
        double responsiveWidth = MediaQuery.of(context).size.width / 400;

        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: EdgeInsets.all(16.0 * responsiveWidth),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(0, 0, 41, 1),
               Color.fromRGBO(53, 52, 92, 1),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height *
                      0.9, // Max height for the modal
                ),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Enter Amount to Withdraw',
                        style: TextStyle(
                          fontSize: 22 * responsiveWidth,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 20 * responsiveWidth),
                      TextField(
                        controller: amountWithdrawToWalletController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(10 * responsiveWidth),
                            borderSide: BorderSide.none,
                          ),
                          hintText: 'Enter amount',
                          hintStyle: const TextStyle(color: Colors.grey),
                          prefixIcon: const Icon(
                            Icons.currency_rupee,
                            color: Colors.greenAccent,
                          ),
                        ),
                      ),
                      SizedBox(height: 20 * responsiveWidth),
                      FancyButton(
                        text: "Withdraw Funds",
                        icon: Icons.remove,
                        gradientColors: const [
                              Colors.redAccent,
                              Color.fromARGB(255, 95, 23, 18)
                            ],
                        onPressed: () async {
                          Navigator.pop(context);
                          double? amount = double.tryParse(
                              amountWithdrawToWalletController.text);
                          if (amount != null) {
                            withdrawData(amount);
                          }
                          if (amount != null && amount <= accountBalance) {
                            if (amount > 0) {
                              transcationflag = false;
                              await _WithdrawFunds(amount);
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter valid amount!'),
                                duration: Duration(seconds: 2),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                          }
                          amountWithdrawToWalletController.clear();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showPaymentOptionsDialog() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      builder: (BuildContext context) {
        double responsiveWidth = MediaQuery.of(context).size.width / 400;

        return Container(
          padding: EdgeInsets.all(16.0 * responsiveWidth),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromRGBO(0, 0, 41, 1),
               Color.fromRGBO(53, 52, 92, 1),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Payment Option',
                style: TextStyle(
                  fontSize: 22 * responsiveWidth,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 20 * responsiveWidth),
              _buildPaymentOption(
                  Icons.account_balance_wallet, "PhonePe", responsiveWidth),
              _buildPaymentOption(
                  Icons.account_balance_wallet, "Google Pay", responsiveWidth),
              _buildPaymentOption(
                  Icons.account_balance_wallet, "Paytm", responsiveWidth),
              _buildPaymentOption(
                  Icons.account_balance_wallet, "Amazon Pay", responsiveWidth),
              SizedBox(height: 10 * responsiveWidth),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPaymentOption(
      IconData icon, String title, double responsiveWidth) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10 * responsiveWidth),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10 * responsiveWidth),
      ),
      child: ListTile(
          leading:
              Icon(icon, color: Colors.blueAccent, size: 24 * responsiveWidth),
          title: Text(
            title,
            style:
                TextStyle(color: Colors.white, fontSize: 18 * responsiveWidth),
          ),
          trailing: Icon(Icons.arrow_forward_ios,
              color: Colors.white, size: 18 * responsiveWidth),
          onTap: () async {
            // Handle payment option selection
            Navigator.pop(context);
            double? amount =
                double.tryParse(amountAdditionToWalletController.text);
            if (amount != null) {
              addNewData(amount);
            }
            if (amount != null && amount > 0) {
              transcationflag = true;
              await _addFunds(amount);
            }
            amountAdditionToWalletController.clear();
          }),
    );
  }

  Future<void> _addFunds(double amount) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: widget.username)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        await doc.reference.update({
          'Account_Balance': FieldValue.increment(amount),
        });

        setState(() {
          accountBalance += amount;
          _balanceAnimation = Tween<double>(
            begin: _balanceAnimation.value,
            end: accountBalance,
          ).animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
          );
          _controller.forward(from: 0); // Restart animation
        });
      }
    } catch (e) {
      print('Error adding funds: $e');
    }
  }

  Future<void> _WithdrawFunds(double amount) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: widget.username)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        await doc.reference.update({
          'Account_Balance': FieldValue.increment(-amount),
        });

        setState(() {
          accountBalance -= amount;
          _balanceAnimation = Tween<double>(
            begin: _balanceAnimation.value,
            end: accountBalance,
          ).animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
          );
          _controller.forward(from: 0); // Restart animation
        });
      }
    } catch (e) {
      print('Error adding funds: $e');
    }
  }

  List<Map<String, dynamic>> transactionList = [];

  void addNewData(double addfundamount) async {
    await DatabaseHelper().insertTransaction(addfundamount, 'deposit');
    loadTransactions();
  }

  void withdrawData(double withdrawamount) async {
    await DatabaseHelper().insertTransaction(-withdrawamount, 'withdraw');
    loadTransactions();
  }

  void loadTransactions() async {
    final data = await DatabaseHelper().fetchTransactions();
    setState(() {
      transactionList = data; // Update the list with fetched data.
    });
  }

  bool? transcationflag;
  @override
  Widget build(BuildContext context) {
    double responsiveWidth = MediaQuery.of(context).size.width / 400;
    double responsiveHeight = MediaQuery.of(context).size.height / 800;
    if (isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(0, 0, 41, 1),
        elevation: 0,
        centerTitle: true,
        title: Text(
          "My Wallet",
          style: GoogleFonts.breeSerif(
            fontWeight: FontWeight.w700,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_sharp, color: Colors.white),
          onPressed: () {
          Navigator.pop(context);
          },
        ),
      ),
        body: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                   Color.fromRGBO(0, 0, 41, 1),
               Color.fromRGBO(53, 52, 92, 1),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(16.0 * responsiveWidth),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                       physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          AnimatedBuilder(
                            animation: _balanceAnimation,
                            builder: (context, child) {
                              return Text(
                                '₹${_balanceAnimation.value.toStringAsFixed(2)}',
                                style: GoogleFonts.breeSerif(
                                  fontSize: 40 * responsiveWidth,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              );
                            },
                          ),
                          SizedBox(height: 10 * responsiveHeight),
                          Text(
                            'Available Balance',
                            style: GoogleFonts.cairo(
                                fontSize: 18 * responsiveWidth, color: Colors.grey),
                          ),
                          SizedBox(height: 40 * responsiveHeight),
                          FancyButton(
                            text: "Add Funds",
                            icon: Icons.add,
                            gradientColors: const [
                              Color.fromARGB(255, 105, 240, 174),
                              Color.fromARGB(255, 76, 175, 80)
                            ],
                            onPressed: _showAddFundsDialog,
                          ),
                          SizedBox(height: 20 * responsiveHeight),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  // Call the dialog and pass the selected amount
                                  _showAddFundsDialog(amount: 50);
                                },
                                child: AmountContainer(
                                    amount: '+₹50', responsiveWidth: responsiveWidth),
                              ),
                              GestureDetector(
                                onTap: () {
                                  // Call the dialog and pass the selected amount
                                  _showAddFundsDialog(amount: 100);
                                },
                                child: AmountContainer(
                                    amount: '+₹100',
                                    responsiveWidth: responsiveWidth),
                              ),
                              GestureDetector(
                                onTap: () {
                                  // Call the dialog and pass the selected amount
                                  _showAddFundsDialog(amount: 200);
                                },
                                child: AmountContainer(
                                    amount: '+₹200',
                                    responsiveWidth: responsiveWidth),
                              ),
                              GestureDetector(
                                onTap: () {
                                  // Call the dialog and pass the selected amount
                                  _showAddFundsDialog(amount: 500);
                                },
                                child: AmountContainer(
                                    amount: '+₹500',
                                    responsiveWidth: responsiveWidth),
                              ),
                            ],
                          ),
                              
                          SizedBox(height: 30 * responsiveHeight),
                          FancyButton(
                            text: "Withdraw",
                            icon: Icons.remove,
                            gradientColors: const [
                              Colors.redAccent,
                              Color.fromARGB(255, 95, 23, 18)
                            ],
                            onPressed: () {
                              // Withdraw action
                              _showWithdrawFundsDialog();
                            },
                          ),
                          //transcation history
                          SizedBox(height: 50 * responsiveHeight),
                          Column(
                              crossAxisAlignment: CrossAxisAlignment
                                  .center, // Center-align the content
                              children: [
                                Text(
                                  'Transaction History',
                                  style:GoogleFonts.cairo(
                                    fontSize: 22 * responsiveWidth,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white70,
                                  ),
                                  textAlign:
                                      TextAlign.center, // Center-align the text
                                ),
                                SizedBox(
                                    height: 10 *
                                        responsiveWidth), // Add spacing below the headline
                                SizedBox(
                                  height: 300 * responsiveHeight,
                                  child: ListView.builder(
                                    //physics:const NeverScrollableScrollPhysics(),
                                    itemCount: transactionList.length,
                                    itemBuilder: (context, index) {
                                      final transaction = transactionList[index];
                                      final isDeposit =
                                          transaction['type'] == 'deposit';
                                      return Container(
                                        margin: EdgeInsets.symmetric(
                                            vertical: 8 * responsiveWidth),
                                        padding: EdgeInsets.all(12 * responsiveWidth),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                              10 * responsiveWidth),
                                        ),
                                        child: ListTile(
                                          leading: Icon(
                                            Icons.currency_rupee_outlined,
                                            color: isDeposit
                                                ? Colors.greenAccent
                                                : Colors.redAccent,
                                            size: 24 * responsiveWidth,
                                          ),
                                          title: Text(
                                            isDeposit ? 'Deposit' : 'Withdrawal',
                                            style: GoogleFonts.cairo(
                                              color: Colors.white,
                                              fontSize: 16 * responsiveWidth,
                                            ),
                                          ),
                                          subtitle: Text(
                                            'Date: ${DateFormat('MM/dd/yyyy\nHH:mm').format(DateTime.parse(transaction['date']))}',
                                            style:GoogleFonts.cairo(
                                                color: Colors.grey,
                                                fontSize: 14 * responsiveWidth),
                                          ),
                                          trailing: Text(
                                            '${transaction['amount'] > 0 ? '+' : ''}${transaction['amount']}',
                                            style: GoogleFonts.breeSerif(
                                              color: transaction['amount'] > 0
                                                  ? Colors.greenAccent
                                                  : Colors.redAccent,
                                              fontSize: 20 * responsiveWidth,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ]),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class FancyButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final List<Color> gradientColors;
  final VoidCallback onPressed;

  const FancyButton({
    required this.text,
    required this.icon,
    required this.gradientColors,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    double responsiveWidth = MediaQuery.of(context).size.width / 400;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10 * responsiveWidth),
        ),
        padding: EdgeInsets.symmetric(
          vertical: 15 * responsiveWidth,
          horizontal: 25 * responsiveWidth,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 24 * responsiveWidth),
            SizedBox(width: 10 * responsiveWidth),
            Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18 * responsiveWidth,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AmountContainer extends StatelessWidget {
  final String amount;
  final double responsiveWidth;

  const AmountContainer({required this.amount, required this.responsiveWidth});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 10 * responsiveWidth,
        horizontal: 15 * responsiveWidth,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10 * responsiveWidth),
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 105, 240, 174),
            Color.fromARGB(255, 55, 128, 57)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Text(
        amount,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16 * responsiveWidth,
        ),
      ),
    );
  }
}
