import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:html' as html;
import 'dart:convert';
import 'package:washify/components/components.dart';
import 'package:washify/pages/bookings_page.dart';
import 'package:washify/pages/scheduling_page.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key, this.username, this.id});
  static const String route = 'welcome';

  final String? username;
  final String? id;

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  // Method to add user information to the database
  Future<void> addUserToDatabase(String username, String id) async {
    final url = Uri.parse('http://localhost:3001/adduser');
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': username,
        'id': id,
      }),
    );

    if (response.statusCode == 200) {
      // User added successfully
      print('User added to the database.');
    } else {
      // Failed to add user
      print('Failed to add user to the database.');
    }
  }

  @override
  void initState() {
    super.initState();
    // Call the method to add user information to the database when the WelcomePage is initialized
    addUserToDatabase(widget.username ?? '', widget.id ?? '');
  }

  Future<void> _logout() async {
    String authUrl = 'http://localhost:8080';
    html.window.open(authUrl, "_self");
  }

  Future<bool> _showLogoutConfirmationDialog() async {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.grey.withOpacity(0.9),
        title: Text(
          'Logout?',
          style: TextStyle(
            color: Colors.white,
            fontSize: 25,
            letterSpacing:
                1.2,
            shadows: [
              BoxShadow(
                color: Color.fromARGB(30, 0, 0, 0),
                blurRadius: 1,
                offset:
                    Offset(-2, 2), 
              ),
            ],
          ),
        ),
        content: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'You will be sent to the login page.',
              style: TextStyle(
                color: Colors.white, 
                fontSize: 20,
                letterSpacing:
                    1.2,
                shadows: [
                  BoxShadow(
                    color: Color.fromARGB(30, 0, 0, 0),
                    blurRadius: 1,
                    offset:
                        Offset(-2, 2),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 300,
              child: OverflowBar(
                alignment: MainAxisAlignment.spaceEvenly,
                overflowAlignment: OverflowBarAlignment.center,
                children: [
                  CustomButton(
                    buttonText: 'Cancel',
                    icon2: Icons.cancel,
                    width: 130,
                    height: 60,
                    fontSize: 15,
                    onPressed: () {
                      Navigator.of(context).pop(false); // Cancel logout
                    },
                  ),
                  CustomButton(
                    buttonText: 'Confirm',
                    icon: Icons.check_circle,
                    width: 130,
                    height: 60,
                    fontSize: 15,
                    onPressed: () {
                      Navigator.of(context).pop(true); // Confirm logout
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  ).then((value) => value ?? false); // Handle the future returned by showDialog
}


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Intercept back button press
        bool logoutConfirmed = await _showLogoutConfirmationDialog();
        if (logoutConfirmed) {
          _logout();
        }
        return false;
      },
      child: Scaffold(
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
            onPressed: () async {
              bool logoutConfirmed = await _showLogoutConfirmationDialog();
              if (logoutConfirmed) {
                _logout();
              }
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Welcome, ${widget.username}!', // Displaying username
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color:
                          Colors.grey,
                      fontSize:
                          50,
                      letterSpacing:
                          1.2,
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
                          offset: Offset(
                              -2, 2),
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
                    'What would you like to do today?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color:
                          Colors.grey, // Adjusted color for better visibility
                      fontSize:
                          40, // Reduced font size for improved readability
                      letterSpacing:
                          1.2, // Increased letter spacing for better legibility
                      shadows: [
                        BoxShadow(
                          color: Color.fromARGB(30, 0, 0, 0), // Shadow color
                          blurRadius: 1, // Spread radius
                          offset: Offset(
                              -2, 2), // Offset in the y direction (downwards)
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  /*
                  Text(
                    'ID: ${widget.id}', // Displaying user ID
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 50,
                    ),
                  ),
                  */
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 600,
                    child: OverflowBar(
                      alignment: MainAxisAlignment.spaceEvenly,
                      overflowAlignment: OverflowBarAlignment.center,
                      children: [
                        Hero(
                          tag: 'schedule_btn',
                          child: CustomButton(
                            buttonText: 'Schedule a Wash',
                            icon: Icons.calendar_today,
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => SchedulingPage(userId: widget.id!),
                            ));
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        Hero(
                          tag: 'scheduled_btn',
                          child: CustomButton(
                            buttonText: 'Check Schedule',
                            icon: Icons.calendar_view_month,
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => BookingsPage(userId: widget.id!),
                              ));
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Hero(
                    tag: 'logout_btn',
                    child: CustomButton(
                      buttonText: 'Logout',
                      icon: Icons.logout,
                      onPressed: () async {
                        bool logoutConfirmed =
                            await _showLogoutConfirmationDialog();
                        if (logoutConfirmed) {
                          _logout();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
