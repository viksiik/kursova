import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreHelper {
  static final FirestoreHelper _instance = FirestoreHelper._internal();
  factory FirestoreHelper() => _instance;
  FirestoreHelper._internal();

  Future<void> setData(String collectionName, Map<String, dynamic> data) async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        data['userId'] = currentUser.uid;

        await FirebaseFirestore.instance
            .collection(collectionName)
            .doc(currentUser.uid)
            .set(data, SetOptions(merge: true));
        print("Data set successfully for user: ${currentUser.uid}");
      } else {
        print("No user is currently signed in. Unable to set data.");
      }
    } catch (e) {
      print("Error setting data: $e");
    }
  }
}
