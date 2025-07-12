// lib/config/env.dart

class Env {
  //기본 http://10.0.2.2:8080로 연결
  //명령어로 실행 : flutter run --dart-define=BASE_URL=https://pium.store
  static const String baseUrl = String.fromEnvironment('BASE_URL', defaultValue: 'http://10.0.2.2:8080');
}