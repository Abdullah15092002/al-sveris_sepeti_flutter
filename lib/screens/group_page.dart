import 'package:alisveris_sepeti/screens/group_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:alisveris_sepeti/services/group_service.dart';
import 'package:alisveris_sepeti/widgets/delete_icon_button.dart';

class GroupsPage extends StatefulWidget {
  const GroupsPage({super.key});

  @override
  State<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  late final Stream<QuerySnapshot> _myGroupsStream;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser!;
    final groupService = Provider.of<GroupService>(context, listen: false);

    _myGroupsStream = groupService.groupsRef
        .where('members', arrayContains: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    final groupService = Provider.of<GroupService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Gruplar')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () =>
                  _showCreateGroupDialog(context, groupService, user.uid),
              child: const Text('Grup Oluştur'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _myGroupsStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    if (snapshot.error.toString().contains(
                      'requires an index',
                    )) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'Veritabanı bu sorgu için bir dizin (index) gerektiriyor. Lütfen Debug Console\'daki linki kullanarak Firebase\'de dizini oluşturun.',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }
                    return Center(
                      child: Text("Bir hata oluştu: ${snapshot.error}"),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text("Henüz bir gruba dahil değilsin."),
                    );
                  }

                  final docs = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;

                      // HATA BURADAYDI: Bu üç satır eksikti.
                      final groupId = docs[index].id;
                      final groupName = data['name'] ?? 'Adsız Grup';
                      final ownerId = data['ownerId'] as String;

                      return Card(
                        child: ListTile(
                          title: Text(groupName),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => GroupDetailPage(
                                  groupId: groupId,
                                  groupName: groupName,
                                ),
                              ),
                            );
                          },
                          trailing: ownerId == user.uid
                              ? DeleteIconButton(
                                  itemType: "Grup",
                                  itemName: groupName,
                                  onDelete: () async {
                                    final groupService =
                                        Provider.of<GroupService>(
                                          context,
                                          listen: false,
                                        );
                                    await groupService.deleteGroup(groupId);
                                  },
                                )
                              : null,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateGroupDialog(
    BuildContext context,
    GroupService groupService,
    String userId,
  ) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Grup Oluştur'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Grup adı"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("İptal"),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                await groupService.createGroup(name, userId);
                Navigator.pop(dialogContext);
              }
            },
            child: const Text("Oluştur"),
          ),
        ],
      ),
    );
  }
}
