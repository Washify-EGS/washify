import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:washify/components/components.dart';
import 'package:http/http.dart' as http;
import 'package:washify/pages/bookings_page.dart';

class WashTypeSelectionPage extends StatefulWidget {
  final DateTime selectedSlot;
  final DateTime selectedDate;
  final String userId;

  static const String route = 'washselect';

  const WashTypeSelectionPage({
    super.key,
    required this.selectedSlot,
    required this.selectedDate,
    required this.userId,
  });

  @override
  _WashTypeSelectionPageState createState() => _WashTypeSelectionPageState();
}

class _WashTypeSelectionPageState extends State<WashTypeSelectionPage> {
  String? selectedWashType;

  @override
  Widget build(BuildContext context) {
    final DateFormat timeFormatter = DateFormat('HH:mm');
    final DateFormat dateFormatter = DateFormat('yMMMMd');

    void _showConfirmationDialog() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.grey.withOpacity(0.9),
            title: Text(
              "Please confirm your booking:",
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
                  "- Date: ${dateFormatter.format(widget.selectedDate)}",
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
                  "- Time: ${timeFormatter.format(widget.selectedSlot)}",
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
                  "- Type: ${selectedWashType ?? ''}",
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
              ],
            ),
            actions: [
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
                      Navigator.of(context).pop(false);
                    },
                  ),
                  CustomButton(
                    buttonText: 'Confirm',
                    icon: Icons.check,
                    width: 130,
                    height: 60,
                    fontSize: 15,
                    onPressed: () async {
                      Navigator.of(context).pop(true);
                      try {
                        // Step 1: Ensure the selectedDateTime meets the interval requirements
                        final selectedDateTime =
                            widget.selectedSlot.toIso8601String().split('.')[0];

                        // Step 2: Create a booking in the external API
                        final bookingsUrl = Uri.parse(
                            'http://localhost:8001/v1/busy?date=${selectedDateTime}');

                        final createBookingResponse = await http.post(
                          bookingsUrl,
                          headers: {
                            'Content-Type': 'application/json',
                          },
                        );

                        // Check if the request was successful
                        if (createBookingResponse.statusCode == 201) {
                          // Status code 201 for successful creation
                          // Booking created successfully
                          print('Booking created successfully!');

                          // Step 3: Get the created booking details
                          var getBookingResponse = await http
                              .get(Uri.parse('http://localhost:8001/v1/busy'));

                          // Check if the request was successful
                          if (getBookingResponse.statusCode == 200) {
                            // Booking fetched successfully
                            final List<dynamic> bookingData =
                                jsonDecode(getBookingResponse.body);

                            // Find the entry with the selected date
                            Map<String, dynamic>? bookingWithSelectedDate;
                            for (var booking in bookingData) {
                              if (booking['date'] == selectedDateTime) {
                                bookingWithSelectedDate = booking;
                                break;
                              }
                            }

                            // Check if a booking with the selected date was found
                            if (bookingWithSelectedDate != null) {
                              final bookingUuid =
                                  bookingWithSelectedDate['uuid'];
                              print(
                                  'UUID of booking with selected date: $bookingUuid');

                              // Step 4: Add the booking to your local database
                              final addBookingURL =
                                  Uri.parse('http://localhost:3001/addBooking');
                              var addBookingResponse = await http.post(
                                addBookingURL,
                                headers: {
                                  'Content-Type': 'application/json',
                                },
                                body: jsonEncode({
                                  'booking_uuid': bookingUuid,
                                  'booking_type':
                                      selectedWashType == 'Washify Regular'
                                          ? 'Regular'
                                          : 'Premium',
                                  'user_id': widget.userId,
                                  'payment_status': false,
                                }),
                              );

                              // Check if the request was successful
                              if (addBookingResponse.statusCode == 200) {
                                // Step 5: Booking added successfully, show confirmation dialog
                                print('Booking added successfully!');
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      backgroundColor:
                                          Colors.grey.withOpacity(0.9),
                                      title: Text(
                                        "Booking created!\nClick below to check your schedule:",
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
                                      actions: [
                                        Center(
                                          child: CustomButton(
                                            buttonText: 'Check Schedule',
                                            icon: Icons.calendar_view_month,
                                            width: 250,
                                            height: 60,
                                            fontSize: 20,
                                            onPressed: () {
                                              Navigator.of(context).push(MaterialPageRoute(
                                                builder: (context) => BookingsPage(userId: widget.userId),
                                              ));
                                            },
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              } else {
                                // Request failed, handle error
                                throw Exception('Failed to add booking.');
                              }
                            } else {
                              print('No booking found with the selected date.');
                            }
                          } else {
                            // Request failed, handle error
                            throw Exception('Failed to get booking.');
                          }
                        } else {
                          // Request failed, handle error
                          throw Exception('Failed to create booking.');
                        }
                      } catch (error) {
                        // Handle errors
                        print('Error: $error');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'An error has occurred. Please try again later.',
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
    }

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
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Selected Slot:\n ${timeFormatter.format(widget.selectedSlot)} on ${dateFormatter.format(widget.selectedDate)}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
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
                    child: Image(
                      image: AssetImage('assets/images/washify_logo.jpeg'),
                      height: 300,
                      width: 600,
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Please choose one of the packages below:',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.grey,
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
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 400,
                      child: ListTile(
                        leading: const Icon(
                          Icons.local_car_wash,
                          color: Color.fromARGB(225, 2, 73, 159),
                          size: 50,
                        ),
                        title: const Text(
                          'Washify Regular 10\$',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey,
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
                        trailing: Radio<String>(
                          value: 'Washify Regular',
                          groupValue: selectedWashType,
                          onChanged: (String? value) {
                            setState(() {
                              selectedWashType = value;
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 400,
                      child: ListTile(
                        leading: const Icon(
                          Icons.star,
                          color: Color.fromARGB(255, 255, 230, 0),
                          size: 50,
                        ),
                        title: const Text(
                          'Washify Premium 25\$',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey,
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
                        trailing: Radio<String>(
                          value: 'Washify Premium',
                          groupValue: selectedWashType,
                          onChanged: (String? value) {
                            setState(() {
                              selectedWashType = value;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                CustomButton(
                  buttonText: 'Continue',
                  icon: Icons.arrow_forward,
                  width: 200,
                  height: 60,
                  fontSize: 20,
                  onPressed: () {
                    if (selectedWashType != null) {
                      _showConfirmationDialog();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Please select a wash type to continue.',
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
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
