import 'package:ejemplo_1/views/Loot/credit_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/auth.viewmodel.dart';
import 'viewmodels/profile.viewmodel.dart';
import 'views/home/home.screen.dart';
import 'views/login/login.screen.dart';
import 'views/register/register.screen.dart';
import 'services/profile.service.dart';
import 'services/auth.service.dart';
import 'views/Loot/loot.dart';
import 'views/Loot/loot.Free.dart';
// Importa la nueva vista de conversión
import 'views/services/transaction_service.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final profileService = ProfileService();
    final authService = AuthService();
    final transactionService = TransactionService();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel(authService)),
        ChangeNotifierProvider(create: (_) => AuthViewModel(authService)),
        ChangeNotifierProvider(create: (_) => ProfileViewModel(profileService)),
        Provider(create: (_) => transactionService),
        ChangeNotifierProvider(create: (_) => CreditProvider()),
      ],
      child: MaterialApp(
        title: 'Login App',
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegistrationScreen(),
          '/home': (context) => const HomeScreen(),
          '/Loot': (context) => const Loot(),
          '/LootFree': (context) => const LootFree(),
        },
      ),
    );
  }
}
