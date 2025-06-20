// lib/constants.dart

import 'package:flutter_dotenv/flutter_dotenv.dart';

final String stripePublishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY']!;
final String stripeSecretKey = dotenv.env['STRIPE_SECRET_KEY']!;
