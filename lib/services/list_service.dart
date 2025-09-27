// Alışveriş listeleriyle ilgili Firestore işlemlerini yönetir.
import 'package:cloud_firestore/cloud_firestore.dart';

class ListService {
  final CollectionReference listsRef = FirebaseFirestore.instance.collection(
    'lists',
  );

  // Yeni bir kişisel liste oluşturur.
  Future<void> createList(String title, String ownerId) async {
    if (title.trim().isEmpty) return;
    await listsRef.add({
      "title": title.trim(),
      "items": [],
      "owner": ownerId,
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  // Belirli bir gruba ait yeni bir liste oluşturur.
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

  // Belirli bir listeyi siler.
  Future<void> deleteList(String listId) async {
    await listsRef.doc(listId).delete();
  }

  // Bir listeye yeni bir ürün ekler.
  Future<void> addItem(String listId, String itemName) async {
    if (itemName.trim().isEmpty) return;
    final listDoc = listsRef.doc(listId);
    await listDoc.update({
      "items": FieldValue.arrayUnion([
        {"name": itemName.trim(), "done": false},
      ]),
    });
  }

  // Bir listenin tüm ürün dizisini günceller (ürün işaretleme vb. için).
  Future<void> updateItems(
    String listId,
    List<Map<String, dynamic>> items,
  ) async {
    await listsRef.doc(listId).update({"items": items});
  }

  // Bir listeden belirli bir ürünü atomik olarak siler.
  Future<void> removeItem(String listId, Map<String, dynamic> item) async {
    await listsRef.doc(listId).update({
      "items": FieldValue.arrayRemove([item]),
    });
  }
}
