// Belirli bir alışveriş listesinin içindeki ürünleri gösterir ve yönetir.
import 'package:alisveris_sepeti/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:alisveris_sepeti/services/list_service.dart';
import 'package:alisveris_sepeti/widgets/delete_icon_button.dart';

class ListDetailPage extends StatefulWidget {
  final String listId;
  final String title;

  const ListDetailPage({super.key, required this.listId, required this.title});

  @override
  State<ListDetailPage> createState() => _ListDetailPageState();
}

class _ListDetailPageState extends State<ListDetailPage> {
  late final Stream<DocumentSnapshot> _listStream;

  // Sayfa ilk yüklendiğinde liste verisini dinleyecek stream'i başlatır.
  @override
  void initState() {
    super.initState();
    final listService = Provider.of<ListService>(context, listen: false);
    _listStream = listService.listsRef.doc(widget.listId).snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      imagePath: 'assets/images/white.jpeg',
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot>(
          stream: _listStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data?.data() == null) {
              return const Center(
                  child: Text('Liste bulunamadı veya silinmiş.'));
            }

            final data = snapshot.data!.data() as Map<String, dynamic>;
            final items = List<Map<String, dynamic>>.from(data['items'] ?? []);

            if (items.isEmpty) {
              return const Center(
                child: Card(
                  color: Colors.white70,
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      "Bu listede henüz ürün yok.\nYeni bir ürün eklemek için + butonunu kullan.",
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final itemName = item['name'] as String;

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  color: Colors.white.withOpacity(0.9),
                  elevation: 4,
                  child: ListTile(
                    title: Text(
                      itemName,
                      style: TextStyle(
                        decoration:
                            item['done'] ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Checkbox(
                          value: item['done'],
                          onChanged: (val) {
                            final listService = Provider.of<ListService>(
                                context,
                                listen: false);
                            final updatedItems =
                                List<Map<String, dynamic>>.from(items);
                            updatedItems[index]['done'] = val;
                            listService.updateItems(
                                widget.listId, updatedItems);
                          },
                        ),
                        DeleteIconButton(
                          itemType: "Ürün",
                          itemName: itemName,
                          onDelete: () async {
                            final listService = Provider.of<ListService>(
                                context,
                                listen: false);
                            await listService.removeItem(widget.listId, item);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddItemDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  // Yeni ürün eklemek için bir dialog penceresi gösterir.
  void _showAddItemDialog(BuildContext context) {
    final listService = Provider.of<ListService>(context, listen: false);
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Ürün Ekle"),
        content: TextField(controller: controller),
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
                listService.addItem(widget.listId, text);
              }
            },
            child: const Text("Ekle"),
          ),
        ],
      ),
    );
  }
}
