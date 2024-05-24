import 'package:flutter/material.dart';
import 'package:washify/components/components.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:html' as html;

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  static const String route = 'home';

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late bool _googleEnabled = false;
  late bool _githubEnabled = false;
  late bool _linkedinEnabled = false;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    // Start the timer when the widget is initialized
    _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      _fetchProvidersAndSetButtons();
    });
  }

  @override
  void dispose() {
    super.dispose();
    // Cancel the timer when the widget is disposed to prevent memory leaks
    _timer.cancel();
  }

  Future<void> _fetchProvidersAndSetButtons() async {
    try {
      http.Response response =
          await http.get(Uri.parse('http://127.0.0.1:5002/providers'));
      if (response.statusCode == 200) {
        Map<String, bool> providers =
            json.decode(response.body).cast<String, bool>();
        setState(() {
          _googleEnabled = providers['google'] ?? false;
          _githubEnabled = providers['github'] ?? false;
          _linkedinEnabled = providers['linkedin'] ?? false;
        });
      } else {
        throw Exception(
            'Failed to fetch providers. Status code: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Error fetching providers: $error');
    }
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
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      const Text(
                        'Welcome to Washify!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 60,
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
                        'Please click the button below to sign and authenticate yourself.',
                        textAlign: TextAlign.center,
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
                        tag: 'login_btn',
                        child: CustomButton(
                          buttonText: 'Sign in',
                          icon: Icons.login,
                          onPressed: () async {
                            // Launch the Flask backend's authentication API in another tab
                            String authUrl = 'http://localhost:8000';
                            html.window.open(authUrl, "_self");
                          },
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const SizedBox(height: 20),
                      const Text(
                        'Available Providers:',
                        style: TextStyle(
                          color:
                              Colors.grey,
                          fontSize:
                              22,
                          letterSpacing:
                              1.2,
                          shadows: [
                            BoxShadow(
                              color: Color.fromARGB(30, 0, 0, 0),
                              blurRadius: 1,
                              offset: Offset(
                                  -2, 2),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_githubEnabled)
                            const Image(
                              image: AssetImage('assets/images/icons/github.png'),
                            ),
                          if (_googleEnabled)
                            const Image(
                              image: AssetImage('assets/images/icons/google.png'),
                            ),
                          if (_linkedinEnabled)
                            const Image(
                              image:
                                  AssetImage('assets/images/icons/linkedin.png'),
                            ),
                          if (!_githubEnabled &&
                              !_googleEnabled &&
                              !_linkedinEnabled)
                            const Text(
                              'No providers available at the moment!',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 16,
                              ),
                            ),
                        ],
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
