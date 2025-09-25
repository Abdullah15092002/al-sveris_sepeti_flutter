import 'package:alisveris_sepeti/list/list_detail_page.dart';
import 'package:alisveris_sepeti/services/list_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    final listService = ListService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alışveriş Listeleri'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: listService.listsRef
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Henüz listen yok"));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              return ListTile(
                title: Text(data['title'] ?? 'Adsız Liste'),
                subtitle: Text("Ürün sayısı: ${data['items']?.length ?? 0}"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ListDetailPage(
                        listId: docs[index].id,
                        title: data['title'] ?? 'Adsız Liste',
                      ),
                    ),
                  );
                },
                //Delete Butonu
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        title: const Text("Listeyi Sil"),
                        content: Text(
                          "‘${data['title'] ?? 'Adsız Liste'}’ listesini silmek istediğine emin misin?",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(dialogContext, false),
                            child: const Text("İptal"),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(dialogContext, true),
                            child: const Text("Sil"),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      await listService.deleteList(docs[index].id);
                    }
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddListDialog(context, listService, user.uid),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddListDialog(
    BuildContext context,
    ListService listService,
    String userId,
  ) {
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
