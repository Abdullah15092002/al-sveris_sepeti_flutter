import 'package:flutter/material.dart';
import 'package:alisveris_sepeti/services/list_service.dart';

class ListDetailPage extends StatelessWidget {
  final String listId;
  final String title;

  const ListDetailPage({super.key, required this.listId, required this.title});

  @override
  Widget build(BuildContext context) {
    final listService = ListService();

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: StreamBuilder(
        stream: listService.listsRef.doc(listId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final items = List<Map<String, dynamic>>.from(data['items'] ?? []);

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                title: Text(
                  item['name'],
                  style: TextStyle(
                    decoration: item['done']
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                trailing: Checkbox(
                  value: item['done'],
                  onChanged: (val) {
                    items[index]['done'] = val;
                    listService.updateItems(listId, items);
                  },
                ),
                onLongPress: () {
                  items.removeAt(index);
                  listService.updateItems(listId, items);
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddItemDialog(context, listService),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddItemDialog(BuildContext context, ListService listService) {
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
                listService.addItem(listId, text);
              }
            },
            child: const Text("Ekle"),
          ),
        ],
      ),
    );
  }
}
