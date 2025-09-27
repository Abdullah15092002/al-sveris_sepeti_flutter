// Kullanıcının dahil olduğu grupları listeler ve yeni grup oluşturmaya olanak tanır.
import 'package:alisveris_sepeti/screens/group_detail_page.dart';
import 'package:alisveris_sepeti/widgets/app_scaffold.dart';
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

  // Sayfa ilk yüklendiğinde kullanıcının gruplarını dinleyecek stream'i başlatır.
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

    return AppScaffold(
      imagePath: 'assets/images/ten.jpeg',
      appBar: AppBar(
        title: const Text('Gruplarım'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.group_add),
              label: const Text('Grup Oluştur'),
              onPressed: () =>
                  _showCreateGroupDialog(context, groupService, user.uid),
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12)),
            ),
            const SizedBox(height: 20),
            StreamBuilder<QuerySnapshot>(
              stream: _myGroupsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                      child: Text("Bir hata oluştu: ${snapshot.error}"));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Card(
                    color: Colors.white70,
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        "Henüz bir gruba dahil değilsin.\nYeni bir grup oluştur.",
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final groupId = docs[index].id;
                    final groupName = data['name'] ?? 'Adsız Grup';
                    final ownerId = data['ownerId'] as String;

                    return Card(
                      color: Colors.white.withOpacity(0.9),
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 6),
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
                                      Provider.of<GroupService>(context,
                                          listen: false);
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
          ],
        ),
      ),
    );
  }

  // Yeni bir grup oluşturmak için dialog penceresi gösterir.
  // DÜZELTME: Fonksiyonun tam hali artık sınıfın içinde, doğru yerde.
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
