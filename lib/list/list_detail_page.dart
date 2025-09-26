import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:alisveris_sepeti/services/list_service.dart';
import 'package:alisveris_sepeti/widgets/delete_icon_button.dart';

// DEĞİŞİKLİK 1: StatelessWidget -> StatefulWidget
class ListDetailPage extends StatefulWidget {
  final String listId;
  final String title;

  const ListDetailPage({super.key, required this.listId, required this.title});

  @override
  State<ListDetailPage> createState() => _ListDetailPageState();
}

class _ListDetailPageState extends State<ListDetailPage> {
  // DEĞİŞİKLİK 1.1: Stream'i tutacak değişken
  late final Stream<DocumentSnapshot> _listStream;

  @override
  void initState() {
    super.initState();
    // DEĞİŞİKLİK 1.2: Stream'i SADECE BİR KEZ oluştur
    final listService = Provider.of<ListService>(context, listen: false);
    _listStream = listService.listsRef.doc(widget.listId).snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: StreamBuilder<DocumentSnapshot>(
        // DEĞİŞİKLİK 1.3: initState'te oluşturulan stream'i kullan
        stream: _listStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data?.data() == null) {
            return const Center(child: Text('Liste bulunamadı veya silinmiş.'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final items = List<Map<String, dynamic>>.from(data['items'] ?? []);

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final itemName = item['name'] as String;

              return ListTile(
                title: Text(
                  itemName,
                  style: TextStyle(
                    decoration: item['done']
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                // DEĞİŞİKLİK 2: trailing, Checkbox ve DeleteIconButton içeren bir Row oldu.
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Checkbox(
                      value: item['done'],
                      onChanged: (val) {
                        final listService = Provider.of<ListService>(
                          context,
                          listen: false,
                        );
                        final updatedItems = List<Map<String, dynamic>>.from(
                          items,
                        );
                        updatedItems[index]['done'] = val;
                        listService.updateItems(widget.listId, updatedItems);
                      },
                    ),
                    // DEĞİŞİKLİK 3: DeleteIconButton buraya eklendi.
                    DeleteIconButton(
                      itemType: "Ürün",
                      itemName: itemName,
                      onDelete: () async {
                        final listService = Provider.of<ListService>(
                          context,
                          listen: false,
                        );
                        await listService.removeItem(widget.listId, item);
                      },
                    ),
                  ],
                ),
                // DEĞİŞİKLİK 2.1: onLongPress artık gereksiz olduğu için kaldırıldı.
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddItemDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

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
