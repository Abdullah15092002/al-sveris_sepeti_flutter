// Belirli bir grubun detaylarını, üyelerini ve listelerini gösterir.
import 'package:alisveris_sepeti/screens/list_detail_page.dart';
import 'package:alisveris_sepeti/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:alisveris_sepeti/services/list_service.dart';
import 'package:alisveris_sepeti/services/group_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:alisveris_sepeti/widgets/delete_icon_button.dart';
import 'package:alisveris_sepeti/widgets/group_members_list.dart';

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
  late final Stream<DocumentSnapshot> _groupStream;

  @override
  void initState() {
    super.initState();
    final listService = Provider.of<ListService>(context, listen: false);
    final groupService = Provider.of<GroupService>(context, listen: false);

    _groupStream = groupService.groupsRef.doc(widget.groupId).snapshots();

    _groupListsStream = listService.listsRef
        .where('groupId', isEqualTo: widget.groupId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      imagePath: 'assets/images/ten.jpeg',
      appBar: AppBar(
        title: Text(widget.groupName),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _groupStream,
        builder: (context, groupSnapshot) {
          if (groupSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!groupSnapshot.hasData || !groupSnapshot.data!.exists) {
            return const Center(child: Text("Grup bulunamadı veya silinmiş."));
          }

          final groupData = groupSnapshot.data!.data() as Map<String, dynamic>;
          final memberIds = List<String>.from(groupData['members'] ?? []);
          final ownerId = groupData['ownerId'] as String;

          return ListView(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.person_add),
                  label: const Text("Gruba Davet Et"),
                  onPressed: () => _inviteUserByCode(context),
                ),
              ),
              GroupMembersList(memberIds: memberIds, ownerId: ownerId),
              StreamBuilder<QuerySnapshot>(
                stream: _groupListsStream,
                builder: (context, listsSnapshot) {
                  if (listsSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                        child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ));
                  }
                  if (listsSnapshot.hasError) {
                    return Center(
                      child: Text(
                          "Listeler yüklenirken bir hata oluştu: ${listsSnapshot.error}"),
                    );
                  }
                  if (!listsSnapshot.hasData ||
                      listsSnapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Card(
                        color: Colors.white70,
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            "Bu grupta henüz liste yok.\nYeni bir liste oluşturmak için + butonunu kullan.",
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    );
                  }
                  return _buildListsView(listsSnapshot.data!.docs);
                },
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddGroupListDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildListsView(List<QueryDocumentSnapshot> docs) {
    final listService = Provider.of<ListService>(context, listen: false);
    final currentUser = FirebaseAuth.instance.currentUser!;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: docs.length,
      itemBuilder: (context, index) {
        final data = docs[index].data() as Map<String, dynamic>;
        final listId = docs[index].id;
        final listTitle = data['title'] ?? 'Adsız Liste';
        final listOwnerId = data['owner'] as String;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          color: Colors.white.withOpacity(0.9),
          elevation: 4,
          child: ListTile(
            title: Text(listTitle),
            subtitle: Text('Ürün sayısı: ${data['items']?.length ?? 0}'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      ListDetailPage(listId: listId, title: listTitle),
                ),
              );
            },
            trailing: currentUser.uid == listOwnerId
                ? DeleteIconButton(
                    itemType: "Liste",
                    itemName: listTitle,
                    onDelete: () async {
                      await listService.deleteList(listId);
                    },
                  )
                : null,
          ),
        );
      },
    );
  }

  // Gruba yeni bir liste eklemek için dialog penceresi gösterir.
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

  // Davet kodu ile bir kullanıcıyı gruba davet etmek için dialog gösterir.
  void _inviteUserByCode(BuildContext context) {
    final groupService = Provider.of<GroupService>(context, listen: false);
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Kullanıcı Davet Et"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: "Kullanıcı Davet Kodunu Girin",
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
                inviteCode: invitedUserCode,
                groupId: widget.groupId,
                groupName: widget.groupName,
              );

              Navigator.pop(context);

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(errorMessage ?? "Davet gönderildi!"),
                    backgroundColor:
                        errorMessage != null ? Colors.red : Colors.green,
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
