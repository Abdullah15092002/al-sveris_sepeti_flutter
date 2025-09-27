// Kullanıcılarla ilgili Firestore işlemlerini (belge oluşturma, güncelleme, davet yönetimi) yönetir.
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final CollectionReference usersRef = FirebaseFirestore.instance.collection(
    'users',
  );

  // Kullanıcının davetlerini anlık olarak dinlemek için bir stream döndürür.
  Stream<DocumentSnapshot<Object?>> getInvitesStream(String userId) {
    return usersRef.doc(userId).snapshots();
  }

  // Yeni kullanıcı için benzersiz bir davet kodu oluşturur.
  Future<String> _createUniqueInviteCode() async {
    String code;
    // Kodun veritabanında mevcut olmadığından emin olana kadar yeni kod üretir.
    while (true) {
      const chars =
          'ABCDEFGHIJKLMNOPQRSTUVWXYZ01234GHIJKLMNOPQRSTUVWXYZ0123456789';
      final random = Random();
      code = String.fromCharCodes(
        Iterable.generate(
          6,
          (_) => chars.codeUnitAt(random.nextInt(chars.length)),
        ),
      );

      final query = await usersRef
          .where('inviteCode', isEqualTo: code)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        break;
      }
    }
    return code;
  }

  // Yeni kullanıcı için Firestore'da bir belge oluşturur.
  Future<void> createUserDocument({
    required String uid,
    required String email,
  }) async {
    final inviteCode = await _createUniqueInviteCode();

    await usersRef.doc(uid).set({
      'email': email,
      'name': null,
      'surname': null,
      'inviteCode': inviteCode,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Firestore'dan kullanıcının mevcut verilerini yükler.
  Future<DocumentSnapshot> loadUserData(String userId) async {
    return usersRef.doc(userId).get();
  }

  // Kullanıcının profil bilgilerini (isim, soyisim vb.) günceller.
  Future<void> saveUserData(
    String userId, {
    String? name,
    String? surname,
  }) async {
    final dataToUpdate = <String, dynamic>{};
    if (name != null) dataToUpdate['name'] = name;
    if (surname != null) dataToUpdate['surname'] = surname;

    if (dataToUpdate.isNotEmpty) {
      await usersRef.doc(userId).set(dataToUpdate, SetOptions(merge: true));
    }
  }

  // Bir grup davetini kabul etme işlemini atomik olarak gerçekleştirir.
  Future<void> acceptInvite(
    String currentUserId,
    String groupId,
    Map<String, dynamic> invite,
  ) async {
    final db = FirebaseFirestore.instance;
    final userRef = usersRef.doc(currentUserId);
    final groupRef = db.collection('groups').doc(groupId);

    WriteBatch batch = db.batch();

    batch.update(userRef, {
      'groupInvites': FieldValue.arrayRemove([invite]),
    });

    batch.update(groupRef, {
      'members': FieldValue.arrayUnion([currentUserId]),
    });

    await batch.commit();
  }

  // Bir grup davetini reddeder.
  Future<void> rejectInvite(
    String currentUserId,
    Map<String, dynamic> invite,
  ) async {
    await usersRef.doc(currentUserId).update({
      'groupInvites': FieldValue.arrayRemove([invite]),
    });
  }

  // Verilen ID listesindeki tüm kullanıcıların belgelerini getirir.
  Future<List<DocumentSnapshot>> getUsersByIds(List<String> userIds) async {
    if (userIds.isEmpty) return [];

    final querySnapshot = await usersRef
        .where(FieldPath.documentId, whereIn: userIds)
        .get();
    return querySnapshot.docs;
  }
}
