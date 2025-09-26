import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:alisveris_sepeti/services/user_service.dart';

class GroupInvitesPage extends StatelessWidget {
  const GroupInvitesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser!;
    final userService = Provider.of<UserService>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Grup Davetleri')),
      body: StreamBuilder<DocumentSnapshot>(
        stream: userService.getInvitesStream(currentUser.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data?.data() == null) {
            return const Center(child: Text('Veri yok'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final invites = List<Map<String, dynamic>>.from(
            data['groupInvites'] ?? [],
          );

          if (invites.isEmpty) {
            return const Center(child: Text('Hiç davet yok'));
          }

          return ListView.builder(
            itemCount: invites.length,
            itemBuilder: (context, index) {
              final invite = invites[index];
              final groupId = invite['groupId'];
              final groupName = invite['groupName'];

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(groupName),
                  subtitle: const Text('Davetiye aldı'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
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
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () async {
                          await userService.rejectInvite(
                            currentUser.uid,
                            invite,
                          );
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
