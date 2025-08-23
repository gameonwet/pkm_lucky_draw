import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final storageService = FlutterSecureStorage(
  aOptions: const AndroidOptions(encryptedSharedPreferences: true),
);
