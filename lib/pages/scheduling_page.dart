import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:washify/components/components.dart';
import 'package:http/http.dart' as http;
import 'package:washify/pages/freeslots_page.dart';
import 'package:intl/intl.dart';

class SchedulingPage extends StatefulWidget {
  const SchedulingPage({super.key, required this.userId});
  static const String route = 'scheduling';

  final String userId;

  @override
  _SchedulingPageState createState() => _SchedulingPageState();
}

class _SchedulingPageState extends State<SchedulingPage> {
  DateTime selectedDate = DateTime.now();
  List<DateTime> freeSlots = [];
  bool isLoading = false;

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
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: _buildDatePicker(),
      ),
    );
  }

  Widget _buildDatePicker() {
    String formattedDate = DateFormat('dd-MM-yyyy').format(selectedDate);
    String buttonText = 'Selected Date: $formattedDate';

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Time to Washify your car!',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 50,
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
              const Text(
                'Pick a date for your wash by clicking on the button below:',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 22,
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
              Hero(
                tag: 'date_btn',
                child: CustomButton(
                  buttonText: buttonText,
                  onPressed: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 30)),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: ColorScheme.light(
                              primary: Colors.grey,
                              onSurface: Theme.of(context).primaryColor,
                              onPrimary: Colors.white,
                            ),
                            textButtonTheme: TextButtonThemeData(
                              style: TextButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (pickedDate != null) {
                      setState(() {
                        selectedDate = pickedDate;
                      });
                      _buildDatePicker();
                    }
                  },
                ),
              ),
              const SizedBox(height: 20),
              Hero(
                tag: 'date_confirm_btn',
                child: CustomButton(
                  buttonText: 'Confirm Date',
                  icon: Icons.check,
                  onPressed: () {
                    _showConfirmationDialog();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showConfirmationDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.grey.withOpacity(0.9),
              title: isLoading
                  ? Text(
                      "Searching... Please wait a moment.",
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
                    )
                  : Text(
                      "Search for available slots on ${DateFormat('dd-MM-yyyy').format(selectedDate)}?",
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
              content: isLoading ? LinearProgressIndicator() : null,
              actions: [
                if (!isLoading) ...[
                  OverflowBar(
                    alignment: MainAxisAlignment.spaceEvenly,
                    overflowAlignment: OverflowBarAlignment.center,
                    children: [
                      CustomButton(
                        buttonText: 'Change Date',
                        icon2: Icons.calendar_today,
                        width: 160,
                        height: 60,
                        fontSize: 15,
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                      ),
                      CustomButton(
                        buttonText: 'Continue',
                        icon: Icons.arrow_forward,
                        width: 160,
                        height: 60,
                        fontSize: 15,
                        onPressed: () async {
                          setState(() {
                            isLoading = true;
                          });
                          final response = await _fetchFreeSlots(
                            DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 8, 0, 0),
                            DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 20, 0, 0),
                          );

                          if (response == 200 && freeSlots.isNotEmpty) {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => FreeSlotsPage(
                                freeSlots: freeSlots,
                                selectedDate: selectedDate,
                                userId: widget.userId,
                              ),
                            ));
                          } else if (response == 200 && freeSlots.isEmpty) {
                            Navigator.of(context).pop(false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'No slots available for the selected date.',
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
                          } else {
                            String errorMessage = '';
                            Navigator.of(context).pop(false);
                            errorMessage = 'Something went wrong fetching the available slots. Please try again later.';
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  errorMessage,
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
                          setState(() {
                            isLoading = false;
                          });
                        },
                      ),
                    ],
                  ),
                ] else ...[
                  Center(
                    child: CustomButton(
                      buttonText: 'Go Back',
                      icon2: Icons.arrow_back,
                      width: 160,
                      height: 60,
                      fontSize: 15,
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                    ),
                  ),
                ],
              ],
            );
          },
        );
      },
    );
  }

   Future<int> _fetchFreeSlots(DateTime startDate, DateTime endDate) async {
    setState(() {
      isLoading = true;
    });

    final Map<String, String> requestData = {
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
    };

    try {
      final response = await http.post(
        Uri.parse('http://localhost:8001/v1/free'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestData),
      );

      if (response.statusCode == 200) {
        setState(() {
          final List<dynamic> decodedData = jsonDecode(response.body);
          List<DateTime> allSlots = decodedData.map((slot) => DateTime.parse(slot)).toList();

          // If the selected date is today, filter out the past slots
          if (selectedDate.day == DateTime.now().day &&
              selectedDate.month == DateTime.now().month &&
              selectedDate.year == DateTime.now().year) {
            DateTime now = DateTime.now();
            freeSlots = allSlots.where((slot) => slot.isAfter(now)).toList();
          } else {
            freeSlots = allSlots;
          }
        });
      } else {
        freeSlots = [];
      }

      setState(() {
        isLoading = false;
      });

      return response.statusCode;
    } catch (error) {
      print('Error fetching available slots: $error');
      setState(() {
        isLoading = false;
      });
      return 500; // Return an error status code in case of an exception
    }
  }
}
