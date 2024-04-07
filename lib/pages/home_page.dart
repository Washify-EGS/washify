import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:washify/components/components.dart';
import 'package:washify/pages/welcome_page.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:html' as html;
import 'dart:io' as dio;
import 'package:jwt_decoder/jwt_decoder.dart';


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  static const String id = 'home';

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late bool _googleEnabled = false;
  late bool _githubEnabled = false;
  late bool _linkedinEnabled = false;

  @override
  void initState() {
    super.initState();
    _fetchProvidersAndSetButtons();
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
        title: Text('Washify', style: Theme.of(context).textTheme.bodyMedium,),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white,),
            onPressed: () {
              _fetchProvidersAndSetButtons();
          },
        ),
        Text("", style: Theme.of(context).textTheme.bodyMedium),
      ],
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: const Image(
                        image: AssetImage('assets/images/washify_logo.jpeg'), height: 300, width: 600,fit: BoxFit.fitWidth,
                      ),
                    ),
                    SizedBox(height: 30),
                    const Text(
                      'Welcome to Washify, please sign in to authenticate yourself.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(height: 30),
                    Hero(
                      tag: 'login_btn',
                      child: CustomButton(
                        buttonText: 'Sign in',
                        onPressed: () async {
                          // Launch the Flask backend's authentication API in another tab
                          launchUrlString('http://127.0.0.1:5000', mode: LaunchMode.inAppBrowserView);
                          Navigator.pushNamed(context, WelcomePage.id);
                        },
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const Text(
                      'Available Providers:',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_githubEnabled)
                          Image( 
                            image: AssetImage('assets/images/icons/github.png'),
                          ),
                        if (_googleEnabled)  
                          Image( 
                            image: AssetImage('assets/images/icons/google.png'),
                          ),
                        if (_linkedinEnabled)
                          Image( 
                            image: AssetImage('assets/images/icons/linkedin.png'),
                          ),
                        if (!_githubEnabled && !_googleEnabled && !_linkedinEnabled)
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
    );
  }
}