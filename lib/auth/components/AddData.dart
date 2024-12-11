import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreHelper {
  // Singleton pattern for easy usage across the app
  static final FirestoreHelper _instance = FirestoreHelper._internal();
  factory FirestoreHelper() => _instance;
  FirestoreHelper._internal();

  // Method to set data for the current user
  Future<void> setData(String collectionName, Map<String, dynamic> data) async {
    try {
      // Get the currently signed-in user
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        // Add the user ID to the data
        data['userId'] = currentUser.uid;

        // Use `set` with the user ID as the document ID
        await FirebaseFirestore.instance
            .collection(collectionName)
            .doc(currentUser.uid)
            .set(data, SetOptions(merge: true)); // Merge to avoid overwriting
        print("Data set successfully for user: ${currentUser.uid}");
      } else {
        print("No user is currently signed in. Unable to set data.");
      }
    } catch (e) {
      print("Error setting data: $e");
    }
  }
}
