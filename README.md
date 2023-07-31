# Flutter Biometric Encryption 🔐

# Introduction
Flutter Biometric Encryption is a Flutter project that demonstrates how to implement biometrically authenticated data encryption and decryption in a mobile application. The project leverages biometric authentication, such as fingerprint or face unlock, to ensure that sensitive data remains secure even if the device is lost or stolen.

# Requirements and Dependencies

- local_auth: ^2.1.6
- flutter_secure_storage: ^8.0.0
- encrypt: ^5.0.1
  
For detailed setup instructions, refer to the pubspec.yaml file.

# Features

- Biometric Authentication: Use fingerprint or face unlock to authenticate the user.
- Secure Cryptographic Key Storage: Store cryptographic keys securely using FlutterSecureStorage.
- Data Encryption: Encrypt sensitive data using AES encryption.
- Data Decryption: Decrypt encrypted data with biometrically authenticated key.
  
# Getting Started

Follow these steps to get the project up and running:

Clone the repository:

```sh
git clone https://github.com/rkmonarch/flutter-biometric-encryption

cd flutter-biometric-encryption
```

Install dependencies:

```sh
flutter pub get
```

Run the app:
```
flutter run
```

## Encryption and Decryption Functions

```
import 'package:encrypt/encrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

final FlutterSecureStorage secureStorage = FlutterSecureStorage();

// Function to generate a cryptographic key
Uint8List generateCryptographicKey(int keyLength) {
  final random = Random.secure();
  final key = Uint8List(keyLength);
  for (int i = 0; i < key.length; i++) {
    key[i] = random.nextInt(256);
  }
  return key;
}

// Function to encrypt and store data
Future<void> encryptAndStoreData(String data, Uint8List cryptographicKey) async {
  final key = Key(cryptographicKey);
  final iv = IV.fromLength(16);
  final encrypter = Encrypter(AES(key));
  final encryptedData = encrypter.encrypt(data, iv: iv);

  await secureStorage.write(key: 'encrypted_data_key', value: encryptedData.base64);
}

// Function to retrieve encrypted data and decrypt it
Future<String> decryptData(Uint8List cryptographicKey) async {
  final String? encryptedData = await secureStorage.read(key: 'encrypted_data_key');
  if (encryptedData == null) {
    throw Exception('Encrypted data not found.');
  }

  final key = Key(cryptographicKey);
  final iv = IV.fromLength(16);
  final encrypter = Encrypter(AES(key));
  final encrypted = Encrypted.fromBase64(encryptedData);
  final decrypted = encrypter.decrypt(encrypted, iv: iv);

  return decrypted;
}
```

Usage
The app will display two buttons - "Encrypt and Store Data" and "Decrypt Data." Press the "Encrypt and Store Data" button to encrypt and store sample data using the encryptAndStoreData function securely. Subsequently, use the "Decrypt Data" button to biometrically authenticate and retrieve the decrypted data using the decrypt data process.

# Security - Android Keystore

For Android devices, the cryptographic key generated during biometric authentication is securely stored in the Android Keystore. The Android Keystore is a secure system-wide storage for cryptographic keys and certificates, making it extremely difficult for other applications to access the keys. This ensures the highest level of security for the cryptographic key used in data encryption and decryption.

Contributing
Contributions are welcome! Feel free to open issues and pull requests to suggest improvements, report bugs, or add new features.

License
This project is licensed under the MIT License.
