import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {

  static final FirebaseFirestore _db =
      FirebaseFirestore.instance;

  // Save phone number
  static Future<void> savePhoneNumber(String phone) async {
  try {
    await _db.collection('users').add({
      'phone': phone,
      'loginTime': DateTime.now().toString(),
    });

    print('DATA SAVED SUCCESSFULLY');
  } catch (e) {
    print('FIREBASE ERROR: $e');
  }
}

  // Dummy OTP verification
  static bool verifyOTP(String enteredOTP) {
    return enteredOTP == '1234';
  }

  // Validate phone number
  static bool validatePhone(String phone) {
    return phone.length == 10 &&
        int.tryParse(phone) != null;
  }
}