import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:html' as html;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:washify/components/components.dart';
import 'package:washify/pages/scheduling_page.dart';

class BookingsPage extends StatefulWidget {
  const BookingsPage({super.key, required this.userId});
  final String userId;

  @override
  _BookingsPageState createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> {
  List<dynamic> bookings = [];
  bool isLoading = true;
  bool isPolling = false;
  bool paymentSuccess = false;

  @override
  void initState() {
    super.initState();
    fetchBookings();
  }

Future<void> fetchBookings() async {
  var url = Uri.parse('http://localhost:3001/bookings/${widget.userId}');
  try {
    var response = await http.get(url);
    if (response.statusCode == 200 && response.body.isNotEmpty) {
      List<dynamic> fetchedBookings = jsonDecode(response.body);
      bookings = await Future.wait(fetchedBookings.map((booking) async {
        String? date = await fetchBookingDate(booking['booking_uuid']);
        booking['date'] = date;
        return booking;
      }).toList());
      sortBookingsByDate();
      setState(() {});
      //print('Fetched bookings: $bookings');
    } else {
      setState(() {
        bookings = [];
      });
    }
  } catch (e) {
    print('Error fetching bookings: $e');
    setState(() {
      bookings = [];
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error fetching bookings')),
    );
  } finally {
    setState(() {
      isLoading = false;
    });
  }
}

Future<String?> fetchBookingDate(String uuid) async {
  var url = Uri.parse('http://localhost:8001/v1/busy/$uuid');
  try {
    var response = await http.get(url);
    if (response.statusCode == 200 && response.body.isNotEmpty) {
      var data = jsonDecode(response.body);
      return data['date'];
    }
  } catch (e) {
    print('Error fetching booking date: $e');
  }
  return null; // Return null if there is an error or no data
}

void sortBookingsByDate() {
  bookings.sort((a, b) {
    DateTime dateA = a['date'] != null ? DateTime.parse(a['date']) : DateTime.now();
    DateTime dateB = b['date'] != null ? DateTime.parse(b['date']) : DateTime.now();
    return dateA.compareTo(dateB);
  });
}

  Future<void> startPolling(String paymentUuid, String bookingUuid) async {
    const pollInterval = Duration(seconds: 5);
    print('Polling for Payment ID: $paymentUuid');
    while (!paymentSuccess) {
      await Future.delayed(pollInterval);
      try {
        var response =
            await http.get(Uri.parse('http://localhost:8002/successfulpaymentuuid'));
        if (response.statusCode == 200 && response.body.isNotEmpty) {
          var data = jsonDecode(response.body);
          if (data['payment_uuid'] == paymentUuid) {
            setState(() {
              paymentSuccess = true;
            });

            // Update payment status in the database
            await updatePaymentStatus(bookingUuid, 1);

            // Fetch the updated bookings
            await fetchBookings();

            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Payment successful!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    letterSpacing: 1.2,
                    shadows: [
                      BoxShadow(
                        color: Color.fromARGB(30, 0, 0, 0),
                        blurRadius: 1,
                        offset: Offset(-2, 2),
                      ),
                    ],
                  ),
                ),
                backgroundColor: Colors.green,
              ),
            );
            break;
          }
        }
      } catch (e) {
        print('Error polling payment status: $e');
      }
    }
  }

  Future<void> updatePaymentStatus(String bookingUuid, int status) async {
    var url = Uri.parse('http://localhost:3001/updatepayment/$bookingUuid');
    try {
      var response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'payment_status': status}),
      );
      if (response.statusCode == 200) {
        print('Payment status updated in the database');
      } else {
        print('Failed to update payment status in the database');
      }
    } catch (e) {
      print('Error updating payment status in the database: $e');
    }
  }

  String formatDateString(String dateString) {
    final DateTime dateTime = DateTime.parse(dateString);
    final DateFormat formatter = DateFormat('dd-MM-yyyy HH:mm');
    return formatter.format(dateTime);
  }

  void _showBookingDetailsDialog(
    Map<String, dynamic> booking, String dateDisplay) {
    String paymentStatus = booking['payment_status'] == 1 ? 'Paid' : 'Pending';
    String bookingUuid = booking['booking_uuid'];
    String message = paymentStatus == 'Paid'
        ? 'Booking is paid. See you there!'
        : 'Payment is still pending.';

    Color typeColor = booking['booking_type'] == 'Premium'
        ? const Color.fromARGB(255, 255, 255, 0)
        : Colors.white;
    Color paymentColor = booking['payment_status'] == 1
        ? const Color.fromARGB(255, 0, 255, 8)
        : Color.fromARGB(255, 255, 0, 0);
    Icon typeIcon = booking['booking_type'] == 'Premium'
        ? const Icon(Icons.star, color: Colors.yellow)
        : const Icon(Icons.local_car_wash, color: Colors.white);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              backgroundColor: Colors.grey.withOpacity(0.9),
              title: Text(
                'Booking Details:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  letterSpacing: 1.2,
                  shadows: [
                    BoxShadow(
                      color: Color.fromARGB(30, 0, 0, 0),
                      blurRadius: 1,
                      offset: Offset(-2, 2),
                    ),
                  ],
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '- Slot: $dateDisplay',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      letterSpacing: 1.2,
                      shadows: [
                        BoxShadow(
                          color: Color.fromARGB(30, 0, 0, 0),
                          blurRadius: 1,
                          offset: Offset(-2, 2),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        '- Type: ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          letterSpacing: 1.2,
                          shadows: [
                            BoxShadow(
                              color: Color.fromARGB(30, 0, 0, 0),
                              blurRadius: 1,
                              offset: Offset(-2, 2),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${booking['booking_type']}',
                        style: TextStyle(
                          color: typeColor,
                          fontSize: 20,
                          letterSpacing: 1.2,
                          shadows: [
                            BoxShadow(
                              color: Color.fromARGB(30, 0, 0, 0),
                              blurRadius: 1,
                              offset: Offset(-2, 2),
                            ),
                          ],
                        ),
                      ),
                      typeIcon,
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        '- Payment: ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          letterSpacing: 1.2,
                          shadows: [
                            BoxShadow(
                              color: Color.fromARGB(30, 0, 0, 0),
                              blurRadius: 1,
                              offset: Offset(-2, 2),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        paymentStatus,
                        style: TextStyle(
                          color: paymentColor,
                          fontSize: 20,
                          letterSpacing: 1.2,
                          shadows: [
                            BoxShadow(
                              color: Color.fromARGB(30, 0, 0, 0),
                              blurRadius: 1,
                              offset: Offset(-2, 2),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        paymentStatus == 'Paid' ? Icons.check : Icons.payment,
                        color: paymentColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (!isPolling)
                    Text(
                      message,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        letterSpacing: 1.2,
                        shadows: [
                          BoxShadow(
                            color: Color.fromARGB(30, 0, 0, 0),
                            blurRadius: 1,
                            offset: Offset(-2, 2),
                          ),
                        ],
                      ),
                    )
                  else if (isPolling && !paymentSuccess)
                    Column(
                      children: [
                        LinearProgressIndicator(),
                        const SizedBox(height: 10),
                        Text(
                          'Processing payment... Please check the payment tab.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            letterSpacing: 1.2,
                            shadows: [
                              BoxShadow(
                                color: Color.fromARGB(30, 0, 0, 0),
                                blurRadius: 1,
                                offset: Offset(-2, 2),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  else if (paymentSuccess)
                    Text(
                      'Payment successful!',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 18,
                        letterSpacing: 1.2,
                        shadows: [
                          BoxShadow(
                            color: Color.fromARGB(30, 0, 0, 0),
                            blurRadius: 1,
                            offset: Offset(-2, 2),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              actions: [
                if (!isPolling)
                  OverflowBar(
                    alignment: MainAxisAlignment.spaceEvenly,
                    overflowAlignment: OverflowBarAlignment.center,
                    children: [
                      CustomButton(
                        buttonText: 'Go Back',
                        icon2: Icons.arrow_back,
                        width: 130,
                        height: 60,
                        fontSize: 15,
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      if (paymentStatus == 'Pending')
                        const SizedBox(width: 20),
                      if (paymentStatus == 'Pending')
                        CustomButton(
                          buttonText: 'Pay Now',
                          icon: Icons.payment,
                          width: 130,
                          height: 60,
                          fontSize: 15,
                          onPressed: () async {
                            try {
                              final updatePriceUrl = Uri.parse(
                                  'http://localhost:8002/update_price_amount');
                              var updatePriceResponse = await http.post(
                                updatePriceUrl,
                                headers: {'Content-Type': 'application/json'},
                                body: jsonEncode({
                                  'amount': booking['booking_type'] == 'Premium'
                                      ? 25
                                      : 10,
                                  'currency': 'USD',
                                }),
                              );

                              if (updatePriceResponse.statusCode == 200) {
                                var responseBody =
                                    jsonDecode(updatePriceResponse.body);
                                String paymentUuid =
                                    responseBody['payment_uuid'];

                                // Save the payment_uuid and booking_uuid in the database
                                final addPaymentUrl = Uri.parse(
                                    'http://localhost:3001/addpayment');
                                var addPaymentResponse = await http.post(
                                  addPaymentUrl,
                                  headers: {'Content-Type': 'application/json'},
                                  body: jsonEncode({
                                    'payment_uuid': paymentUuid,
                                    'booking_uuid': bookingUuid,
                                  }),
                                );

                                if (addPaymentResponse.statusCode == 200) {
                                  setState(() {
                                    isPolling = true;
                                  });

                                  // Redirect to the payment page
                                  String paymentUrl = 'http://localhost:8002/';
                                  html.window.open(paymentUrl, "_blank");

                                  startPolling(paymentUuid, bookingUuid)
                                      .then((_) {
                                    setState(() {
                                      isPolling = false;
                                      paymentSuccess = true;
                                    });
                                  });
                                } else {
                                  throw Exception('Failed to add payment.');
                                }
                              } else {
                                throw Exception('Failed to update price.');
                              }
                            } catch (error) {
                              print('Error: $error');
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'An error occurred. Please try again.',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                    ],
                  ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          'Washify',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            shadows: [
              BoxShadow(
                color: Color.fromARGB(30, 0, 0, 0),
                blurRadius: 1,
                offset: Offset(-2, 2),
              ),
            ],
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pushNamed('/welcome');
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Check your Washify bookings!',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 40,
                    letterSpacing: 1.2,
                    shadows: [
                      BoxShadow(
                        color: Color.fromARGB(30, 0, 0, 0),
                        blurRadius: 1,
                        offset: Offset(-2, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 1,
                        offset: Offset(-2, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/images/washify_logo.jpeg',
                      height: 300,
                      width: 600,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                if (bookings.isNotEmpty) const SizedBox(height: 20),
                Text(
                  'Select a booking below to see details:',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 35,
                    letterSpacing: 1.2,
                    shadows: [
                      BoxShadow(
                        color: Color.fromARGB(30, 0, 0, 0),
                        blurRadius: 1,
                        offset: Offset(-2, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                if (isLoading)
                  Center(child: CircularProgressIndicator())
                else if (bookings.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 0.0),
                    child: Column(
                      children: [
                        Center(
                          child: Text(
                            'No Washify bookings yet 😢',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 30,
                              letterSpacing: 1.2,
                              shadows: [
                                BoxShadow(
                                  color: Color.fromARGB(30, 0, 0, 0),
                                  blurRadius: 1,
                                  offset: Offset(-2, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Hero(
                          tag: 'sched_btn',
                          child: CustomButton(
                            buttonText: 'Schedule a Wash',
                            icon: Icons.calendar_today,
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) =>
                                    SchedulingPage(userId: widget.userId),
                              ));
                            },
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 650),
                      child: Card(
                        child: Container(
                          height: 400,
                          child: ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            itemCount: bookings.length,
                            itemBuilder: (context, index) {
                              final booking = bookings[index];
                              String paymentStatus =
                                  booking['payment_status'] == 1
                                      ? 'Paid'
                                      : 'Pending';
                              Color typeColor =
                                  booking['booking_type'] == 'Premium'
                                      ? const Color.fromARGB(255, 255, 255, 0)
                                      : Colors.white;
                              Color paymentColor =
                                  booking['payment_status'] == 1
                                      ? const Color.fromARGB(255, 0, 255, 8)
                                      : Color.fromARGB(255, 255, 0, 0);
                              Icon typeIcon = booking['booking_type'] ==
                                      'Premium'
                                  ? const Icon(Icons.star, color: Colors.yellow)
                                  : const Icon(Icons.local_car_wash,
                                      color: Colors.white);

                              return FutureBuilder<String?>(
                                future:
                                    fetchBookingDate(booking['booking_uuid']),
                                builder: (context, snapshot) {
                                  String dateDisplay =
                                      snapshot.connectionState ==
                                              ConnectionState.waiting
                                          ? 'Loading date...'
                                          : snapshot.data != null
                                              ? formatDateString(snapshot.data!)
                                              : 'Date unavailable';

                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(20),
                                      onTap: () {
                                        _showBookingDetailsDialog(
                                            booking, dateDisplay);
                                      },
                                      child: Ink(
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: ListTile(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          textColor: Colors.white,
                                          leading: const Icon(
                                            Icons.calendar_today,
                                            color: Colors.white,
                                          ),
                                          title: Text(
                                            'Booking ${index + 1} 💦 $dateDisplay',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                              letterSpacing: 1.2,
                                              shadows: [
                                                BoxShadow(
                                                  color: Color.fromARGB(
                                                      30, 0, 0, 0),
                                                  blurRadius: 1,
                                                  offset: Offset(-2, 2),
                                                ),
                                              ],
                                            ),
                                          ),
                                          subtitle: Row(
                                            children: [
                                              Text(
                                                'Type: ',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20,
                                                  letterSpacing: 1.2,
                                                  shadows: [
                                                    BoxShadow(
                                                      color: Color.fromARGB(
                                                          30, 0, 0, 0),
                                                      blurRadius: 1,
                                                      offset: Offset(-2, 2),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Text(
                                                '${booking['booking_type']}',
                                                style: TextStyle(
                                                  color: typeColor,
                                                  fontSize: 20,
                                                  letterSpacing: 1.2,
                                                  shadows: [
                                                    BoxShadow(
                                                      color: Color.fromARGB(
                                                          30, 0, 0, 0),
                                                      blurRadius: 1,
                                                      offset: Offset(-2, 2),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              typeIcon,
                                              Text(
                                                ' - Payment: ',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20,
                                                  letterSpacing: 1.2,
                                                  shadows: [
                                                    BoxShadow(
                                                      color: Color.fromARGB(
                                                          30, 0, 0, 0),
                                                      blurRadius: 1,
                                                      offset: Offset(-2, 2),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Text(
                                                '$paymentStatus',
                                                style: TextStyle(
                                                  color: paymentColor,
                                                  fontSize: 20,
                                                  letterSpacing: 1.2,
                                                  shadows: [
                                                    BoxShadow(
                                                      color: Color.fromARGB(
                                                          30, 0, 0, 0),
                                                      blurRadius: 1,
                                                      offset: Offset(-2, 2),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Icon(
                                                paymentStatus == 'Paid'
                                                    ? Icons.check
                                                    : Icons.payment,
                                                color: paymentColor,
                                              ),
                                            ],
                                          ),
                                          trailing: const Icon(
                                            Icons.arrow_forward,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      splashColor: Colors.black.withAlpha(30),
                                      highlightColor:
                                          Colors.black.withAlpha(50),
                                      hoverColor: Colors.black.withAlpha(50),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
