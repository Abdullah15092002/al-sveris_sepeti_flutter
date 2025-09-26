import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:alisveris_sepeti/services/user_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _user = FirebaseAuth.instance.currentUser!;

  bool _loading = true;
  String _errorMessage = '';
  // YENİ: Davet kodunu tutacak state değişkeni
  String _inviteCode = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userService = Provider.of<UserService>(context, listen: false);
    try {
      final doc = await userService.loadUserData(_user.uid);
      if (mounted) {
        final data = doc.data() as Map<String, dynamic>?;
        _nameController.text = data?['name'] ?? '';
        _surnameController.text = data?['surname'] ?? '';
        // DEĞİŞİKLİK: Davet kodunu da data'dan alıyoruz
        setState(() {
          _inviteCode = data?['inviteCode'] ?? 'Kod bulunamadı';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Kullanıcı verisi yüklenemedi: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _saveChanges() async {
    final userService = Provider.of<UserService>(context, listen: false);
    try {
      await userService.saveUserData(
        _user.uid,
        name: _nameController.text.trim(),
        surname: _surnameController.text.trim(),
        email: _user.email,
      );

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Bilgiler güncellendi')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Hata: $e')));
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      // DEĞİŞİKLİK: Arayüzü ListView ile sarmalıyoruz (daha esnek bir yapı)
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // DEĞİŞİKLİK: Bilgileri Card widget'ları içinde grupluyoruz
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    child: Icon(Icons.person, size: 40),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    // İsim ve soyisim boşsa e-postayı göster
                    (_nameController.text.isEmpty &&
                            _surnameController.text.isEmpty)
                        ? _user.email!
                        : '${_nameController.text} ${_surnameController.text}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  if (_nameController.text.isNotEmpty ||
                      _surnameController.text.isNotEmpty)
                    Text(_user.email!),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Bilgileri Düzenle",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'İsim',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _surnameController,
                    decoration: const InputDecoration(
                      labelText: 'Soyisim',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // DEĞİŞİKLİK: UID yerine davet kodunu gösteren yeni Card
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              leading: const Icon(Icons.share),
              title: Text(
                _inviteCode,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: const Text(
                "Arkadaşlarını davet etmek için bu kodu paylaş",
              ),
              trailing: IconButton(
                icon: const Icon(Icons.copy, size: 20),
                onPressed: () {
                  // DEĞİŞİKLİK: Artık davet kodunu kopyalıyoruz
                  Clipboard.setData(ClipboardData(text: _inviteCode));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Davet kodu kopyalandı!')),
                  );
                },
              ),
            ),
          ),
          if (_errorMessage.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(_errorMessage, style: const TextStyle(color: Colors.red)),
          ],
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _saveChanges,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Değişiklikleri Kaydet'),
          ),
        ],
      ),
    );
  }
}
