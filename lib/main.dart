import 'package:flutter/material.dart';
import 'package:washify/pages/home_page.dart';
import 'package:washify/pages/welcome_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromARGB(225, 2, 73, 159)),
          textTheme: const TextTheme(
            bodyMedium: TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontFamily: 'Ubuntu',
            ),
          )),
      initialRoute: HomePage.id,
      routes: {
        HomePage.id: (context) => const HomePage(),
        WelcomePage.id: (context) => const WelcomePage(),
      },
    );
  }
}
