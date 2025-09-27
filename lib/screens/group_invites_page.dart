// Kullanıcının aldığı grup davetlerini listeler ve yönetir.
import 'package:alisveris_sepeti/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:alisveris_sepeti/services/user_service.dart';

class GroupInvitesPage extends StatefulWidget {
  const GroupInvitesPage({super.key});

  @override
  State<GroupInvitesPage> createState() => _GroupInvitesPageState();
}

class _GroupInvitesPageState extends State<GroupInvitesPage> {
  late final Stream<DocumentSnapshot> _invitesStream;

  // Sayfa ilk yüklendiğinde davetleri dinleyecek stream'i başlatır.
  @override
  void initState() {
    super.initState();
    final currentUser = FirebaseAuth.instance.currentUser!;
    final userService = Provider.of<UserService>(context, listen: false);
    _invitesStream = userService.getInvitesStream(currentUser.uid);
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser!;
    final userService = Provider.of<UserService>(context, listen: false);

    return AppScaffold(
      imagePath: 'assets/images/ten.jpeg',
      appBar: AppBar(
        title: const Text('Grup Davetleri'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _invitesStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data?.data() == null) {
            return const Center(
              child: Card(
                color: Colors.white70,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child:
                      Text("Yeni davetiniz yok.", textAlign: TextAlign.center),
                ),
              ),
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final invites =
              List<Map<String, dynamic>>.from(data['groupInvites'] ?? []);

          if (invites.isEmpty) {
            return const Center(
              child: Card(
                color: Colors.white70,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child:
                      Text("Hiç davetiniz yok.", textAlign: TextAlign.center),
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            itemCount: invites.length,
            itemBuilder: (context, index) {
              final invite = invites[index];
              final groupId = invite['groupId'];
              final groupName = invite['groupName'];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                color: Colors.white.withOpacity(0.9),
                elevation: 4,
                child: ListTile(
                  leading: const Icon(Icons.group_add_outlined),
                  title: Text(groupName),
                  subtitle: const Text('Sizi bu gruba davet etti.'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon:
                            const Icon(Icons.check_circle, color: Colors.green),
                        tooltip: 'Kabul Et',
                        onPressed: () async {
                          await userService.acceptInvite(
                            currentUser.uid,
                            groupId,
                            invite,
                          );
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Gruba katıldın!")),
                            );
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.red),
                        tooltip: 'Reddet',
                        onPressed: () async {
                          await userService.rejectInvite(
                              currentUser.uid, invite);
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
    );
  }
}
