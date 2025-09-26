import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GroupService {
  final CollectionReference groupsRef = FirebaseFirestore.instance.collection(
    'groups',
  );
  final CollectionReference usersRef = FirebaseFirestore.instance.collection(
    'users',
  );

  Future<void> createGroup(String name, String userId) async {
    if (name.trim().isEmpty) return;
    await groupsRef.add({
      'name': name,
      'ownerId': userId,
      'members': [userId],
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<String?> inviteUserByCode({
    required String inviteCode,
    required String groupId,
    required String groupName,
  }) async {
    if (inviteCode.trim().isEmpty) return "Davet kodu boş olamaz.";

    // 1. Davet koduna sahip kullanıcıyı bul
    final userQuery = await usersRef
        .where(
          'inviteCode',
          isEqualTo: inviteCode.trim().toUpperCase(),
        ) // Kodları büyük harf saklıyorsak
        .limit(1)
        .get();

    if (userQuery.docs.isEmpty) {
      return "Bu davet koduna sahip bir kullanıcı bulunamadı.";
    }

    // 2. Kullanıcıyı bulduysak, onun ID'sini alıp davet gönder
    final invitedUserId = userQuery.docs.first.id;
    final currentUser = FirebaseAuth.instance.currentUser!;

    if (invitedUserId == currentUser.uid) {
      return "Kendini bir gruba davet edemezsin.";
    }

    await usersRef.doc(invitedUserId).update({
      'groupInvites': FieldValue.arrayUnion([
        {
          'groupId': groupId,
          'groupName': groupName,
          'fromUserId': currentUser.uid,
        },
      ]),
    });
    return null; // Başarılı
  }

  Future<void> deleteGroup(String groupId) async {
    final db = FirebaseFirestore.instance;
    final batch = db.batch();

    // 1. Adım: Silinecek gruba ait tüm listeleri bul
    final listsQuery = db
        .collection('lists')
        .where('groupId', isEqualTo: groupId);
    final listsSnapshot = await listsQuery.get();

    // 2. Adım: Bulunan her bir listeyi silme işlemi için batch'e ekle
    for (final doc in listsSnapshot.docs) {
      batch.delete(doc.reference);
    }

    // 3. Adım: Ana grup belgesini silme işlemi için batch'e ekle
    final groupRef = groupsRef.doc(groupId);
    batch.delete(groupRef);

    // 4. Adım: Tüm silme işlemlerini tek seferde sunucuya gönder
    await batch.commit();
  }
}
