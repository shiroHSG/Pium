import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:frontend_flutter/theme/app_theme.dart';
import 'package:frontend_flutter/pages/auth/login.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:frontend_flutter/pages/home/home_page.dart';
import 'package:frontend_flutter/pages/community/post_detail_page.dart';
import 'package:frontend_flutter/pages/policy_page/policy_detail_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();  // 플러터와 프레임워크 연결
  await initializeDateFormatting('ko_KR', null);  // 한국어 로케일 날짜 시간 데이터 초기화
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '피움 앱',
      theme: AppTheme.lightTheme,
      locale: const Locale('ko', 'KR'), // 앱 기본설정 한국어
      supportedLocales: const [
        Locale('ko', 'KR'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const SplashScreen(),
      routes: {
        '/home': (context) => const MyHomePage(),
        '/login': (context) => Login(),
        '/postDetail': (context) {
          final postId = ModalRoute.of(context)!.settings.arguments as int;
          return PostDetailPage(postId: postId);
        },
        '/policyDetail': (context) {
          final policyId = ModalRoute.of(context)!.settings.arguments as int;
          return PolicyDetailPage(policyId: policyId);
        },
      },
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        return Padding(
          padding: mediaQuery.viewPadding, // 시스템 UI(상단 노치, 하단 버튼 등) 피해줌
          child: child!,
        );
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDD9E5),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset('assets/logo1.png', height: 300),
            const SizedBox(height: 16),
            const SizedBox(height: 16),
            const Text(
              '부모의 마음이 피어나고, 가족이 함께 자라며,\n삶이 따뜻하게 이어지는 공간을 상상합니다.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontFamily: 'Jua',
              ),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFC85A91)),
            ),
          ],
        ),
      ),
    );
  }
}
