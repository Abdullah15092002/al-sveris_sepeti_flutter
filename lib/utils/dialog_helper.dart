// Uygulama genelinde yeniden kullanılabilir bir onay dialog'u gösterir.
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
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text("Sil"),
        ),
      ],
    ),
  );

  if (didConfirm == true) {
    await onConfirm();
  }
}
