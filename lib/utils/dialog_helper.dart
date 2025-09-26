// Bu fonksiyon, uygulama genelinde "Emin misin?" dialogları göstermek için kullanılacak.
// title: Dialog başlığı (örn: "Listeyi Sil")
// content: Dialog içeriği (örn: "'Alışveriş' listesini silmek istediğine emin misin?")
// onConfirm: "Sil" butonuna basıldığında çalıştırılacak olan asenkron fonksiyon.
import 'package:flutter/material.dart';

Future<void> showConfirmDialog({
  required BuildContext context,
  required String title,
  required String content,
  required Future<void> Function() onConfirm,
}) async {
  final bool? didConfirm = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text("İptal"),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          // Stili kırmızı yaparak daha dikkat çekici hale getirelim
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text("Sil"),
        ),
      ],
    ),
  );

  // Kullanıcı "Sil" butonuna bastıysa (true döndüyse)
  // kendisine verilen onConfirm fonksiyonunu çalıştır.
  if (didConfirm == true) {
    await onConfirm();
  }
}
