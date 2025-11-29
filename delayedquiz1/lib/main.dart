import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart' as my_provider;
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('🚀 Starting Firebase initialization...');

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized successfully!');

    // Test Firebase Auth
    final auth = FirebaseAuth.instance;
    print('✅ Firebase Auth accessible');

    // Test if we can access current user
    final user = auth.currentUser;
    print('✅ Current user: $user');

  } catch (e) {
    print('❌ Firebase initialization failed: $e');
    print('This usually means:');
    print('1. google-services.json is missing or in wrong location');
    print('2. Firebase dependencies are missing');
    print('3. Firebase_options.dart has wrong values');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => my_provider.AuthServiceProvider()),
        StreamProvider<User?>.value(
          value: AuthService().authStateChanges,
          initialData: null,
        ),
      ],
      child: MaterialApp(
        title: 'Firebase Auth Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: const AuthWrapper(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);

    if (user != null) {
      return const HomeScreen();
    } else {
      return const LoginScreen();
    }
  }
}