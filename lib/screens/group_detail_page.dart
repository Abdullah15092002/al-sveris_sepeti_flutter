import 'package:alisveris_sepeti/list/list_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:alisveris_sepeti/services/list_service.dart';
import 'package:alisveris_sepeti/services/group_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:alisveris_sepeti/widgets/delete_icon_button.dart'; // Widget'ımızı import ediyoruz

class GroupDetailPage extends StatefulWidget {
  final String groupId;
  final String groupName;

  const GroupDetailPage({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  State<GroupDetailPage> createState() => _GroupDetailPageState();
}

class _GroupDetailPageState extends State<GroupDetailPage> {
  late final Stream<QuerySnapshot> _groupListsStream;

  @override
  void initState() {
    super.initState();
    final listService = Provider.of<ListService>(context, listen: false);
    _groupListsStream = listService.listsRef
        .where('groupId', isEqualTo: widget.groupId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final groupService = Provider.of<GroupService>(context, listen: false);
    final listService = Provider.of<ListService>(
      context,
      listen: false,
    ); // Silme işlemi için eklendi
    final currentUser =
        FirebaseAuth.instance.currentUser!; // Mevcut kullanıcıyı alıyoruz

    return Scaffold(
      appBar: AppBar(title: Text(widget.groupName)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () => _inviteUserByCode(context, groupService),
              child: const Text("Gruba Davet Et"),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _groupListsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  // ... (hata kontrolü aynı kalıyor)
                  return Center(
                    child: Text("Bir hata oluştu: ${snapshot.error}"),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('Bu grupta henüz liste yok.'),
                  );
                }

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;

                    // --- DEĞİŞİKLİK 1: Gerekli değişkenler tanımlanıyor ---
                    final listId = docs[index].id;
                    final listTitle = data['title'] ?? 'Adsız Liste';
                    final listOwnerId =
                        data['owner'] as String; // Listenin sahibinin ID'si

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        title: Text(listTitle),
                        subtitle: Text(
                          'Ürün sayısı: ${data['items']?.length ?? 0}',
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ListDetailPage(
                                listId: listId,
                                title: listTitle,
                              ),
                            ),
                          );
                        },
                        // --- DEĞİŞİKLİK 2 & 3: Koşullu silme butonu ekleniyor ---
                        trailing: currentUser.uid == listOwnerId
                            ? DeleteIconButton(
                                itemType: "Liste",
                                itemName: listTitle,
                                onDelete: () async {
                                  await listService.deleteList(listId);
                                },
                              )
                            : null, // Eğer kullanıcı listenin sahibi değilse buton görünmez
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddGroupListDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  // Bu sayfanın altındaki diğer fonksiyonlar (_showAddGroupListDialog, _inviteUserById) aynı kalıyor...
  void _showAddGroupListDialog(BuildContext context) {
    final listService = Provider.of<ListService>(context, listen: false);
    final controller = TextEditingController();
    final ownerId = FirebaseAuth.instance.currentUser!.uid;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Yeni Grup Listesi Oluştur"),
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
                listService.createListByGroup(
                  text,
                  ownerId: ownerId,
                  groupId: widget.groupId,
                );
              }
            },
            child: const Text("Oluştur"),
          ),
        ],
      ),
    );
  }

  void _inviteUserByCode(BuildContext context, GroupService groupService) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Kullanıcı Davet Et"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: "Kullanıcı Davet Linkini Girin",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("İptal"),
          ),
          ElevatedButton(
            onPressed: () async {
              final invitedUserCode = controller.text.trim();
              if (invitedUserCode.isEmpty) return;

              final errorMessage = await groupService.inviteUserByCode(
                inviteCode: controller.text,
                groupId: widget.groupId,
                groupName: widget.groupName,
              );

              Navigator.pop(context);

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(errorMessage ?? "Davet gönderildi!"),
                    backgroundColor: errorMessage != null
                        ? Colors.red
                        : Colors.green,
                  ),
                );
              }
            },
            child: const Text("Gönder"),
          ),
        ],
      ),
    );
  }
}
