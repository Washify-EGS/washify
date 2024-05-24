import 'dart:html' as html;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:flutter/material.dart';
import 'package:washify/pages/home_page.dart';
import 'package:washify/pages/scheduling_page.dart';
import 'package:washify/pages/welcome_page.dart';
import 'package:washify/pages/freeslots_page.dart';
import 'package:washify/pages/washtype_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the current URL
    var url = html.window.location.href;

    return MaterialApp(
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
              seedColor: Color.fromARGB(255, 2, 72, 158)),
          textTheme: const TextTheme(
            bodyMedium: TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontFamily: 'Ubuntu',
            ),
          )),
      initialRoute: HomePage.route,
      routes: {
        WelcomePage.route: (context) => const WelcomePage(),
      },
      onGenerateRoute: (settings) {
        // Check if the current URL contains query parameters
        final uri = Uri.parse(url);
        //print(uri);
        if (uri.path == '/welcome' && uri.queryParameters.containsKey('token')) {
          // Decode the JWT token and extract the payload
          final jwtToken = uri.queryParameters['token'];
          final decodedPayload = jwtToken != null ? JwtDecoder.decode(jwtToken) : {};

          // Extract the username and ID from the decoded payload
          final username = decodedPayload['username'] as String?; // Cast to String?
          final id = decodedPayload['id'] as String?; // Cast to String?

          // Navigate to the WelcomePage with the extracted parameters
          return MaterialPageRoute(
            builder: (context) => WelcomePage(username: username ?? '', id: id ?? ''),
          );
        } else {
          // If the URL doesn't meet the criteria, navigate to the HomePage
          return MaterialPageRoute(
            builder: (context) => const HomePage(),
          );
        }
      },
    );
  }
}