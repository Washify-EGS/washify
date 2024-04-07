import 'dart:async';
import 'package:flutter/material.dart';
import 'package:washify/components/components.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:jwt_decoder/jwt_decoder.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);
  static const String id = 'welcome';

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  late bool userSignedIn = false;
  late Map<String, dynamic> userInfo = {};

  @override
  void initState() {
    super.initState();
    _checkUserSignIn();
  }

  Future<void> _checkUserSignIn() async {
    while (!userSignedIn) {
      var userData = await _fetchUserInfo();
      if (userData != null) {
        setState(() {
          userSignedIn = true;
          userInfo = userData;
        });
      }
      // Add a delay before the next iteration to avoid blocking the UI thread
      await Future.delayed(Duration(seconds: 1));
    }
  }

  Future<Map<String, dynamic>?> _fetchUserInfo() async {
    try {
      var response =
          await http.get(Uri.parse('http://127.0.0.1:5000/userinfo'));

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = json.decode(response.body);
        String jwtToken = responseData['token'];
        Map<String, dynamic> decodedToken = JwtDecoder.decode(jwtToken);
        return decodedToken;
      } else {
        print('Failed to authenticate user. Status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error authenticating user: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          'Washify',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
      body: Stack(
        children: [
          userSignedIn
              ? _buildWelcomeScreen()
              : Center(
                  child: CircularProgressIndicator(),
                ),
          if (!userSignedIn)
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(10),
                color: Colors.grey.withOpacity(0.7),
                child: Text(
                  'Please go to the other tab to authenticate yourself.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }


  Widget _buildWelcomeScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Welcome, ${userInfo['name']}!', // Displaying username
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 50,
              ),
            ),
            SizedBox(height: 20),
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
                      onPressed: () {},
                    ),
                  ),
                  SizedBox(height: 20),
                  Hero(
                    tag: 'logout_btn',
                    child: CustomButton(
                      buttonText: 'Logout',
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
