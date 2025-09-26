import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final CollectionReference usersRef = FirebaseFirestore.instance.collection(
    'users',
  );
  Future<String> _createUniqueInviteCode() async {
    String code;
    // Kodun benzersiz olduğundan emin olmak için bir döngü kullanıyoruz.
    while (true) {
      // 6 haneli basit bir kod üretiyoruz (örn: AB12CD)
      const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
      final random = Random();
      code = String.fromCharCodes(
        Iterable.generate(
          6,
          (_) => chars.codeUnitAt(random.nextInt(chars.length)),
        ),
      );

      // Bu kodun veritabanında başka bir kullanıcı tarafından kullanılıp kullanılmadığını kontrol et
      final query = await usersRef
          .where('inviteCode', isEqualTo: code)
          .limit(1)
          .get();

      // Eğer sorgu boş dönerse, kod benzersizdir ve döngüden çıkabiliriz.
      if (query.docs.isEmpty) {
        break;
      }
    }
    return code;
  }

  // YENİ METOT: Yeni kullanıcı için Firestore'da belge oluşturur
  Future<void> createUserDocument(String uid, String email) async {
    final inviteCode = await _createUniqueInviteCode();

    await usersRef.doc(uid).set({
      'email': email,
      'name': '', // Başlangıçta boş
      'surname': '', // Başlangıçta boş
      'inviteCode': inviteCode, // BENZERSİZ DAVET KODU EKLENDİ
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<DocumentSnapshot<Object?>> getInvitesStream(String userId) {
    return usersRef.doc(userId).snapshots();
  }

  Future<DocumentSnapshot> loadUserData(String userId) async {
    return usersRef.doc(userId).get();
  }

  Future<void> saveUserData(
    String userId, {
    String? name,
    String? surname,
    String? email,
  }) async {
    await usersRef.doc(userId).set({
      'name': name,
      'surname': surname,
      'email': email,
    }, SetOptions(merge: true));
  }

  // DEĞİŞİKLİK: Davet kabul etme işlemini atomik hale getiren metod.
  Future<void> acceptInvite(
    String currentUserId,
    String groupId,
    Map<String, dynamic> invite,
  ) async {
    final db = FirebaseFirestore.instance;
    final userRef = usersRef.doc(currentUserId);
    final groupRef = db.collection('groups').doc(groupId);

    WriteBatch batch = db.batch();

    // 1. Kullanıcının davet listesinden daveti kaldır.
    batch.update(userRef, {
      'groupInvites': FieldValue.arrayRemove([invite]),
    });

    // 2. Gruba kullanıcıyı ekle.
    batch.update(groupRef, {
      'members': FieldValue.arrayUnion([currentUserId]),
    });

    // İki işlemi aynı anda Firestore'a gönder.
    await batch.commit();
  }

  Future<void> rejectInvite(
    String currentUserId,
    Map<String, dynamic> invite,
  ) async {
    await usersRef.doc(currentUserId).update({
      'groupInvites': FieldValue.arrayRemove([invite]),
    });
  }
}
