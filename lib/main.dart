import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/qr_screen.dart';
import 'screens/transaction_screen.dart';
import 'screens/success_screen.dart';
import 'screens/generate_qr_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const EasyPeApp());
}

class EasyPeApp extends StatelessWidget {
  const EasyPeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'EasyPe',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      getPages: [
        GetPage(name: '/',             page: () => const SplashScreen()),
        GetPage(name: '/login',        page: () => const LoginScreen()),
        GetPage(name: '/dashboard',    page: () => const DashboardScreen()),
        GetPage(name: '/qr',           page: () => const QRScreen()),
        GetPage(name: '/generate-qr', page: () => const GenerateQRScreen()),
        GetPage(name: '/transactions', page: () => const TransactionScreen()),
        GetPage(name: '/success',      page: () => SuccessScreen(
          amount: 0, transactionId: '',
        )),
      ],
      theme: ThemeData(
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5f259f),
        ),
        useMaterial3: true,
      ),
    );
  }
}