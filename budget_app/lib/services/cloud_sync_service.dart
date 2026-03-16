import 'package:cloud_firestore/cloud_firestore.dart';

class CloudSyncService {

  final _db = FirebaseFirestore.instance;

  Future<void> saveExpenses(
    String userId,
    Map<String, dynamic> data,
  ) async {

    await _db
        .collection('users')
        .doc(userId)
        .collection('months')
        .doc(data['month'])
        .set(data, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>?> loadExpenses(
    String userId,
    String month,
  ) async {

    final doc = await _db
        .collection('users')
        .doc(userId)
        .collection('months')
        .doc(month)
        .get();

    return doc.data();
  }
}