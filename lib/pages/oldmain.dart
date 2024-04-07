import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Washify',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(0, 2, 73, 159)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Washify'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage> {
  late bool _googleEnabled = false;
  late bool _githubEnabled = false;
  late bool _linkedinEnabled = false;

  Future<void> _fetchProvidersAndSetButtons() async {
    try {
      http.Response response = await http.get(Uri.parse('http://127.0.0.1:5002/providers'));
      if (response.statusCode == 200) {
        Map<String, bool> providers = json.decode(response.body).cast<String, bool>();
        setState(() {
          _googleEnabled = providers['google'] ?? false;
          _githubEnabled = providers['github'] ?? false;
          _linkedinEnabled = providers['linkedin'] ?? false;
        });
      } else {
        throw Exception('Failed to fetch providers. Status code: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Error fetching providers: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchProvidersAndSetButtons();
  }

  Future<void> _googleSignIn() async {
    const signInUrl = 'http://127.0.0.1:5000/login/google';
    try {
      launchUrl(Uri.parse(signInUrl));

    } catch (e) {
      print('Error launching URL: $e');
    }
  }

  Future<void> _githubSignIn() async {
    const signInUrl = 'http://127.0.0.1:5000/login/github';
    try {
      launchUrl(Uri.parse(signInUrl));
    } catch (e) {
      print('Error launching URL: $e');
    }
  }

  Future<void> _linkedinSignIn() async {
    const signInUrl = 'http://127.0.0.1:5000/login/linkedin';
    try {
      launchUrl(Uri.parse(signInUrl));
    } catch (e) {
      print('Error launching URL: $e');
    }
  }

  Future<void> _handleSignInSuccess(uri) async {
      try {
        var response = await http.get(Uri.parse(uri));
        print('Response Status Code: ${response.statusCode}');
        print('Response Body: ${response.body}');
        if (response.statusCode == 200) {
          Map<String, dynamic> data = json.decode(response.body);
          print(data);
          if (data['success'] == true) {
            //Navigator.push(
              //context,
              //MaterialPageRoute(builder: (context) => WelcomePage(userName: data['name'])),
            //);
          } else {
            // Handle unsuccessful login here, such as displaying an error message
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Login Failed'),
                  content: const Text('Your login was not successful. Please try again.'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('OK'),
                    ),
                  ],
                );
              },
            );
          }
        } else {
          throw Exception('Failed to load data: ${response.statusCode}');
        }
      } catch (e) {
        // Handle HTTP request errors here
        print('Error: $e');
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content: Text('An error occurred: $e'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(widget.title, style: const TextStyle(color: Colors.white),),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white,),
            onPressed: () {
              _fetchProvidersAndSetButtons();
          },
        ),
        const Text("Refresh Providers", style: TextStyle(color: Colors.white),),
      ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: const Image(
                  image: AssetImage('images/washify_logo.jpeg'), width: 600, height: 400, fit: BoxFit.fitWidth,
                ),
              ),
              const Text(
                'Welcome to Washify, please choose your method of authentication:',
                style: TextStyle(fontSize: 20,)
              ),
              ButtonBar(
                alignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.max,
                children: [
                  ElevatedButton(
                    onPressed: _googleEnabled ? () async {
                      await _googleSignIn();
                      //await _handleSignInSuccess('http://127.0.0.1:5000/login/google/success');
                    } : null,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white10), 
                    child: const Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image( image: AssetImage('images/google.png'), height: 40, width: 40,),
                        Text('Sign in with Google', style: TextStyle(color: Colors.white, fontSize: 25)),
                        Icon(Icons.arrow_right_alt_sharp, color: Colors.white, size: 45.0,)
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _githubEnabled ? () async {
                      await _githubSignIn();
                      //await _handleSignInSuccess('http://127.0.0.1:5000/login/github/success');
                    } : null,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.black), 
                    child: const Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image( image: AssetImage('images/github.png'), height: 40, width: 40,),
                        Text('Sign in with Github', style: TextStyle(color: Colors.white, fontSize: 25)),
                        Icon(Icons.arrow_right_alt_sharp, color: Colors.white, size: 45.0,)
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _linkedinEnabled ? () async {
                      await _linkedinSignIn();
                      //await _handleSignInSuccess('http://127.0.0.1:5000/login/linkedin/success');
                    } : null,
                    style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 0, 119, 181)), 
                    child: const Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image( image: AssetImage('images/linkedin.png'), height: 40, width: 40,),
                        Text('Sign in with LinkedIn', style: TextStyle(color: Colors.white, fontSize: 25)),
                        Icon(Icons.arrow_right_alt_sharp, color: Colors.white, size: 45.0,)
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
