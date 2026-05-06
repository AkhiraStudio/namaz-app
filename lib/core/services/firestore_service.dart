import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Service Firestore — synchronisation cross-device des données utilisateur.
/// Toutes les méthodes sont fire-and-forget : les échecs sont silencieux
/// (l'app fonctionne 100% offline via Hive).
class FirestoreService {
  final FirebaseFirestore _db;

  FirestoreService({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  DocumentReference<Map<String, dynamic>>? get _userDoc {
    final uid = _uid;
    if (uid == null) return null;
    return _db.collection('users').doc(uid);
  }

  // ── Profile ───────────────────────────────────────────────────────────────

  Future<void> saveProfile(Map<String, dynamic> data) async {
    try {
      await _userDoc?.set({'profile': data}, SetOptions(merge: true));
    } catch (_) {}
  }

  Future<Map<String, dynamic>?> getProfile() async {
    try {
      final snap = await _userDoc?.get();
      final data = snap?.data();
      return data?['profile'] as Map<String, dynamic>?;
    } catch (_) {
      return null;
    }
  }

  // ── Prayer records ────────────────────────────────────────────────────────

  Future<void> savePrayerRecord(Map<String, dynamic> record) async {
    try {
      final id = record['id'] as String?;
      if (id == null) return;
      await _userDoc?.collection('prayerRecords').doc(id).set(record);
    } catch (_) {}
  }

  Future<List<Map<String, dynamic>>> getPrayerRecords() async {
    try {
      final snap = await _userDoc?.collection('prayerRecords').get();
      return snap?.docs.map((d) => d.data()).toList() ?? [];
    } catch (_) {
      return [];
    }
  }

  // ── Sunnah records ────────────────────────────────────────────────────────

  Future<void> saveSunnahRecord(String key, bool value) async {
    try {
      await _userDoc?.collection('sunnahRecords').doc(key).set({'value': value});
    } catch (_) {}
  }

  Future<Map<String, bool>> getSunnahRecords() async {
    try {
      final snap = await _userDoc?.collection('sunnahRecords').get();
      if (snap == null) return {};
      return {
        for (final d in snap.docs)
          d.id: (d.data()['value'] as bool?) ?? false,
      };
    } catch (_) {
      return {};
    }
  }

  // ── Settings ──────────────────────────────────────────────────────────────

  Future<void> saveSettings(Map<String, dynamic> data) async {
    try {
      await _userDoc?.set({'settings': data}, SetOptions(merge: true));
    } catch (_) {}
  }

  Future<Map<String, dynamic>?> getSettings() async {
    try {
      final snap = await _userDoc?.get();
      final data = snap?.data();
      return data?['settings'] as Map<String, dynamic>?;
    } catch (_) {
      return null;
    }
  }

  // ── Bulk pull (utilisé au login pour restaurer les données) ───────────────

  Future<Map<String, dynamic>?> pullAll() async {
    try {
      final snap = await _userDoc?.get();
      return snap?.data();
    } catch (_) {
      return null;
    }
  }
}
