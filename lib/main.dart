import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:leaf_cloud/repositories/auth_repository.dart';
import 'package:leaf_cloud/repositories/auth_repository_interface.dart';
import 'package:leaf_cloud/providers/auth_provider.dart';
import 'package:leaf_cloud/services/discovery_service.dart';
import 'package:leaf_cloud/ui/login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Start searching for the server in the background
  DiscoveryService().initDiscovery();
  
  runApp(
    MultiProvider(
      providers: [
        Provider<IAuthRepository>(
          create: (_) => AuthRepository(),
        ),
        ChangeNotifierProvider(
          create: (context) => AuthProvider(
            Provider.of<IAuthRepository>(context, listen: false),
          ),
        ),
      ],
      child: const LoginApp(),
    ),
  );
}

class LoginApp extends StatelessWidget {
  const LoginApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LeafCloud Login',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4E7A43),
          surface: const Color(0xFFD9E3D9),
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFD9E3D9),
      ),
      home: const LoginPage(),
    );
  }
}
