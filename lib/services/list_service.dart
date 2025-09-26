import 'package:cloud_firestore/cloud_firestore.dart';

class ListService {
  final CollectionReference listsRef = FirebaseFirestore.instance.collection(
    'lists',
  );

  Future<void> createList(String title, String ownerId) async {
    if (title.trim().isEmpty) return;
    await listsRef.add({
      "title": title.trim(),
      "items": [],
      "owner": ownerId,
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  Future<void> createListByGroup(
    String title, {
    required String ownerId,
    String? groupId,
  }) async {
    if (title.trim().isEmpty) return;

    final data = {
      "title": title.trim(),
      "items": [],
      "owner": ownerId,
      "createdAt": FieldValue.serverTimestamp(),
    };

    if (groupId != null && groupId.isNotEmpty) {
      data['groupId'] = groupId;
    }

    await listsRef.add(data);
  }

  Future<void> deleteList(String listId) async {
    await listsRef.doc(listId).delete();
  }

  Future<void> addItem(String listId, String itemName) async {
    if (itemName.trim().isEmpty) return;
    final listDoc = listsRef.doc(listId);
    await listDoc.update({
      "items": FieldValue.arrayUnion([
        {"name": itemName.trim(), "done": false},
      ]),
    });
  }

  Future<void> updateItems(
    String listId,
    List<Map<String, dynamic>> items,
  ) async {
    await listsRef.doc(listId).update({"items": items});
  }

  // DEĞİŞİKLİK: Yeni eklenen metod - Tek bir ürünü atomik olarak siler.
  Future<void> removeItem(String listId, Map<String, dynamic> item) async {
    await listsRef.doc(listId).update({
      "items": FieldValue.arrayRemove([item]),
    });
  }
}
