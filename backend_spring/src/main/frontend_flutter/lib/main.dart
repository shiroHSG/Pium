import 'package:flutter/material.dart';
import 'package:frontend_flutter/theme/app_theme.dart';
import 'package:frontend_flutter/pages/auth/login.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:frontend_flutter/pages/home/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ko_KR', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '피움 앱',
      theme: AppTheme.lightTheme,
      home: const Login(),
      routes: {
        '/home': (context) => const MyHomePage(),
      },
    );
  }
}