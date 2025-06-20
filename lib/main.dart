import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import 'cart_provider.dart';
import 'user_provider.dart';
import 'splash.dart';
import 'push_notification_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; // Import Firebase Messaging

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  String? publishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY'];
  String? secretKey = dotenv.env['STRIPE_SECRET_KEY'];

  // Tambahkan log untuk memastikan variabel lingkungan telah dimuat
  print('Publishable Key: $publishableKey');
  print('Secret Key: $secretKey');

  if (publishableKey == null || secretKey == null) {
    throw Exception("Stripe keys are not loaded. Please check your .env file.");
  }

  // Setel kunci Stripe
  Stripe.publishableKey = publishableKey;
  Stripe.merchantIdentifier = 'merchant.flutter.stripe.test';
  Stripe.urlScheme = 'flutterstripe';
  await Stripe.instance.applySettings();

  await Firebase.initializeApp();
  
  // Inisialisasi PushNotificationService
  PushNotificationService().initialize();

  // Mendapatkan dan mencetak token FCM
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  String? token = await _firebaseMessaging.getToken();
  print('FCM Token: $token');

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CartProvider()),
        ChangeNotifierProvider(create: (context) => UserProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SplashScreen(),
      ),
    );
  }
}
