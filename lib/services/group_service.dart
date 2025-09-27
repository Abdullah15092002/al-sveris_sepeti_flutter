// Gruplarla ilgili Firestore işlemlerini (oluşturma, silme, davet etme) yönetir.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GroupService {
  final CollectionReference groupsRef = FirebaseFirestore.instance.collection(
    'groups',
  );
  final CollectionReference usersRef = FirebaseFirestore.instance.collection(
    'users',
  );

  // Yeni bir grup oluşturur ve oluşturan kişiyi ilk üye olarak ekler.
  Future<void> createGroup(String name, String userId) async {
    if (name.trim().isEmpty) return;
    await groupsRef.add({
      'name': name,
      'ownerId': userId,
      'members': [userId],
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Davet kodu kullanarak bir kullanıcıyı gruba davet eder.
  Future<String?> inviteUserByCode({
    required String inviteCode,
    required String groupId,
    required String groupName,
  }) async {
    if (inviteCode.trim().isEmpty) return "Davet kodu boş olamaz.";

    final userQuery = await usersRef
        .where('inviteCode', isEqualTo: inviteCode.trim().toUpperCase())
        .limit(1)
        .get();

    if (userQuery.docs.isEmpty) {
      return "Bu davet koduna sahip bir kullanıcı bulunamadı.";
    }

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
    return null;
  }

  // Bir grubu ve o gruba ait tüm listeleri basamaklı olarak siler.
  Future<void> deleteGroup(String groupId) async {
    final db = FirebaseFirestore.instance;
    final batch = db.batch();

    final listsQuery = db
        .collection('lists')
        .where('groupId', isEqualTo: groupId);
    final listsSnapshot = await listsQuery.get();

    for (final doc in listsSnapshot.docs) {
      batch.delete(doc.reference);
    }

    final groupRef = groupsRef.doc(groupId);
    batch.delete(groupRef);

    await batch.commit();
  }
}
