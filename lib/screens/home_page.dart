// Kullanıcı giriş yaptıktan sonra karşılaştığı ana yönlendirme ve karşılama sayfasıdır.
import 'package:alisveris_sepeti/screens/group_page.dart';
import 'package:alisveris_sepeti/screens/mylists_page.dart';
import 'package:alisveris_sepeti/screens/profil_page.dart';
import 'package:alisveris_sepeti/screens/group_invites_page.dart';
import 'package:alisveris_sepeti/services/auth_service.dart';
import 'package:alisveris_sepeti/services/user_service.dart';
import 'package:alisveris_sepeti/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  // Sayfa açıldığında kullanıcının adını Firestore'dan bir kez çeker.
  Future<void> _loadUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userService = Provider.of<UserService>(context, listen: false);
    final userDoc = await userService.loadUserData(user.uid);

    if (userDoc.exists && mounted) {
      final data = userDoc.data() as Map<String, dynamic>;
      setState(() {
        _userName = data['name'] ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    final userService = Provider.of<UserService>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);

    return AppScaffold(
      imagePath: 'assets/images/white.jpeg',
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Çıkış Yap',
            onPressed: () => authService.signOut(),
          ),
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Image.asset(
                'assets/images/logo.png',
                height: 200,
                width: 200,
              ),
              const SizedBox(height: 16),
              if (_userName.isNotEmpty)
                Text(
                  'Hoş geldin, $_userName!',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [Shadow(color: Colors.black45, blurRadius: 2)],
                  ),
                ),
              const SizedBox(height: 40),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _DashboardCard(
                    icon: Icons.list_alt_rounded,
                    label: 'Listelerim',
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const MyListsPage()));
                    },
                  ),
                  _DashboardCard(
                    icon: Icons.group_rounded,
                    label: 'Gruplarım',
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const GroupsPage()));
                    },
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

// Ana sayfadaki menü kartları için yeniden kullanılabilir widget.
class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      color: Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Theme.of(context).primaryColor),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
