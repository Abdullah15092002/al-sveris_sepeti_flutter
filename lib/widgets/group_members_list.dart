// Bir grubun üye listesini, kullanıcı adları ve rolleriyle birlikte gösteren widget.
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:alisveris_sepeti/services/user_service.dart';

class GroupMembersList extends StatelessWidget {
  final List<String> memberIds;
  final String ownerId;

  const GroupMembersList({
    super.key,
    required this.memberIds,
    required this.ownerId,
  });

  @override
  Widget build(BuildContext context) {
    final userService = Provider.of<UserService>(context, listen: false);

    return FutureBuilder<List<DocumentSnapshot>>(
      future: userService.getUsersByIds(memberIds),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(8.0),
            child: Center(
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink(); // Hata varsa veya üye yoksa hiçbir şey gösterme
        }

        final memberDocs = snapshot.data!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                "Grup Üyeleri",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: memberDocs.length,
              itemBuilder: (context, index) {
                final userData =
                    memberDocs[index].data() as Map<String, dynamic>;
                final userId = memberDocs[index].id;

                final String name = userData['name'] ?? '';
                final String surname = userData['surname'] ?? '';
                final String fullName = (name.isNotEmpty || surname.isNotEmpty)
                    ? '$name $surname'.trim()
                    : userData['email'] ?? 'İsimsiz Kullanıcı';

                final bool isOwner = userId == ownerId;

                return ListTile(
                  leading: Icon(
                    isOwner ? Icons.verified_user : Icons.person_outline,
                    color: isOwner ? Colors.amber.shade700 : Colors.grey,
                  ),
                  title: Text(fullName),
                  subtitle: Text(isOwner ? 'Kurucu' : 'Üye'),
                );
              },
            ),
            const Divider(),
          ],
        );
      },
    );
  }
}
