import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hidaya/app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:device_preview/device_preview.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(DevicePreview(
    enabled: kDebugMode,
    builder: (context) => ProviderScope(child: const MyApp()),
  ));
}
