import 'dart:math';

import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as encrypt;

final LocalAuthentication auth = LocalAuthentication();
final FlutterSecureStorage secureStorage = FlutterSecureStorage();

Uint8List generateCryptographicKey(int keyLength) {
  final random = Random.secure();
  final key = Uint8List(keyLength);
  for (int i = 0; i < key.length; i++) {
    key[i] = random.nextInt(256);
  }
  return key;
}

Future<Uint8List> retrieveCryptographicKey() async {
  final String? keyBase64 = await secureStorage.read(key: 'cryptographic_key');
  if (keyBase64 == null) {
    throw Exception('Cryptographic key not found.');
  }
  return Uint8List.fromList(base64.decode(keyBase64));
}


Future<String> fetchDataFromSecureStorage() async {
  // Fetch the encrypted data from secure storage (e.g., FlutterSecureStorage)
  final String? encryptedData =
      await secureStorage.read(key: 'encrypted_data_key');
  if (encryptedData == null) {
    throw Exception('Encrypted data not found.');
  }
  return encryptedData;
}

String decryptData(String encryptedData, Uint8List cryptographicKey) {
  final key = encrypt.Key(cryptographicKey);
  final iv = encrypt.IV.fromLength(16);
  final encrypter = encrypt.Encrypter(encrypt.AES(key));
  final encrypted = encrypt.Encrypted.fromBase64(encryptedData);
  final decrypted = encrypter.decrypt(encrypted, iv: iv);
  return decrypted;
}

class BiometricEncryption extends StatelessWidget {
  void writeData() async {
    try {
      // Step 1: Biometric Authentication
      bool authenticated = await auth.authenticate(
        localizedReason: 'Let OS determine authentication method',
        options: const AuthenticationOptions(
          stickyAuth: true,
        ),
      );

      if (authenticated) {
        // Step 2: Generate the Cryptographic Key
        const int keyLength = 32;
        final Uint8List cryptographicKey = generateCryptographicKey(keyLength);
        print('Generated Cryptographic Key: ${cryptographicKey.toList()}');

        // Step 3: Store the Cryptographic Key in Secure Storage
        await secureStorage.write(
            key: 'cryptographic_key', value: base64.encode(cryptographicKey));

        // Step 4: Encrypt and Store Data
        const String dataToEncrypt = 'dangerrrrrrrrr';
        final key = encrypt.Key(cryptographicKey);
        final iv = encrypt.IV.fromLength(16);
        final encrypter = encrypt.Encrypter(encrypt.AES(key));
        final encryptedData = encrypter.encrypt(dataToEncrypt, iv: iv);

        await secureStorage.write(
            key: 'encrypted_data_key', value: encryptedData.base64);

        print('Data encrypted and stored successfully!$encryptedData');
      }
    } catch (e) {
      print('Authentication failed: $e');
    }
  }

  void readData() async {
    try {
      // Step 1: Biometric Authentication
      bool authenticated = await auth.authenticate(
        localizedReason: 'Let OS determine authentication method',
        options: const AuthenticationOptions(
          stickyAuth: true,
        ),
      );

      if (authenticated) {
        // Step 2: Retrieve the Cryptographic Key
        final Uint8List retrievedKey = await retrieveCryptographicKey();

        // Step 3: Use the Cryptographic Key to Decrypt Data
        final String encryptedData = await fetchDataFromSecureStorage();
        final String decryptedData = decryptData(encryptedData, retrievedKey);
        print('Decrypted Data: $decryptedData');
      }
    } catch (e) {
      print('Authentication failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Biometric Data Encryption/Decryption'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: writeData,
                child: const Text('Encrypt and Store Data'),
              ),
              ElevatedButton(
                onPressed: readData,
                child: const Text('Decrypt Data'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
