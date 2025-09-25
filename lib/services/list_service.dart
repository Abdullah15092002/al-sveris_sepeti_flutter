import 'package:cloud_firestore/cloud_firestore.dart';

class ListService {
  final CollectionReference listsRef = FirebaseFirestore.instance.collection(
    'lists',
  );

  // Liste oluştur
  Future<void> createList(String title, String ownerId) async {
    if (title.trim().isEmpty) return;
    await listsRef.add({
      "title": title.trim(),
      "items": [],
      "owner": ownerId,
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  // Listeyi sil
  Future<void> deleteList(String listId) async {
    await listsRef.doc(listId).delete();
  }

  // Listeye ürün ekle
  Future<void> addItem(String listId, String itemName) async {
    if (itemName.trim().isEmpty) return;
    final listDoc = listsRef.doc(listId);
    await listDoc.update({
      "items": FieldValue.arrayUnion([
        {"name": itemName.trim(), "done": false},
      ]),
    });
  }

  // Liste ürününü güncelle (checkbox veya isim değişikliği)
  Future<void> updateItems(
    String listId,
    List<Map<String, dynamic>> items,
  ) async {
    await listsRef.doc(listId).update({"items": items});
  }
}
