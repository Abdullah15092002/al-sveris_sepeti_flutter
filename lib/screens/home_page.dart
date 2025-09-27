// Kullanıcı giriş yaptıktan sonra karşılaştığı ana yönlendirme sayfasıdır.
import 'package:alisveris_sepeti/screens/group_page.dart';
import 'package:alisveris_sepeti/screens/mylists_page.dart';
import 'package:alisveris_sepeti/screens/profil_page.dart';
import 'package:alisveris_sepeti/screens/group_invites_page.dart';
import 'package:alisveris_sepeti/services/auth_service.dart';
import 'package:alisveris_sepeti/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    final userService = Provider.of<UserService>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alışveriş Listem'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Çıkış Yap',
            onPressed: () => authService.signOut(),
          ),
          // Kullanıcının davet sayısını gösteren bildirim ikonu
          StreamBuilder<DocumentSnapshot>(
            stream: userService.getInvitesStream(user.uid),
            builder: (context, snapshot) {
              int inviteCount = 0;
              if (snapshot.hasData && snapshot.data!.exists) {
                final data = snapshot.data!.data() as Map<String, dynamic>?;
                final invites = data?['groupInvites'] ?? [];
                inviteCount = (invites as List).length;
              }

              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.mail_outline),
                    tooltip: 'Grup Davetleri',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const GroupInvitesPage(),
                        ),
                      );
                    },
                  ),
                  if (inviteCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '$inviteCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          IconButton(
            tooltip: 'Profil',
            icon: const CircleAvatar(
              radius: 16,
              child: Icon(Icons.person, size: 18),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Butonların daha belirgin olması için stil eklendi
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                icon: const Icon(Icons.list_alt),
                label: const Text("Listelerim"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MyListsPage()),
                  );
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                icon: const Icon(Icons.group),
                label: const Text("Gruplarım"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const GroupsPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
