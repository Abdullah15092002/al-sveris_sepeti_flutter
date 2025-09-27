// Kullanıcının kendisine ait olan kişisel alışveriş listelerini gösterir.
import 'package:alisveris_sepeti/screens/list_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:alisveris_sepeti/services/list_service.dart';
import 'package:alisveris_sepeti/widgets/delete_icon_button.dart';

class MyListsPage extends StatefulWidget {
  const MyListsPage({super.key});

  @override
  State<MyListsPage> createState() => _MyListsPageState();
}

class _MyListsPageState extends State<MyListsPage> {
  late final Stream<QuerySnapshot> _myListsStream;

  // Sayfa ilk yüklendiğinde kullanıcının listelerini dinleyecek stream'i başlatır.
  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser!;
    final listService = Provider.of<ListService>(context, listen: false);

    _myListsStream = listService.listsRef
        .orderBy('createdAt', descending: true)
        .where('owner', isEqualTo: user.uid)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Benim Listelerim")),
      body: StreamBuilder<QuerySnapshot>(
        stream: _myListsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Bir hata oluştu: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Henüz kişisel listen yok"));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final listId = docs[index].id;
              final listTitle = data['title'] ?? 'Adsız Liste';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(listTitle),
                  subtitle: Text("Ürün sayısı: ${data['items']?.length ?? 0}"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ListDetailPage(listId: listId, title: listTitle),
                      ),
                    );
                  },
                  trailing: DeleteIconButton(
                    itemType: "Liste",
                    itemName: listTitle,
                    onDelete: () async {
                      final listService = Provider.of<ListService>(
                        context,
                        listen: false,
                      );
                      await listService.deleteList(listId);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddListDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  // Yeni bir kişisel liste oluşturmak için dialog penceresi gösterir.
  void _showAddListDialog(BuildContext context) {
    final listService = Provider.of<ListService>(context, listen: false);
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Yeni Liste Oluştur"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Liste adı"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("İptal"),
          ),
          ElevatedButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                Navigator.pop(dialogContext);
                listService.createList(text, userId);
              }
            },
            child: const Text("Oluştur"),
          ),
        ],
      ),
    );
  }
}
