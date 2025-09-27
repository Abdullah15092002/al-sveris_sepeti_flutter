// Silme işlemleri için onay dialog'u gösteren yeniden kullanılabilir ikon butonu.
import 'package:alisveris_sepeti/utils/dialog_helper.dart';
import 'package:flutter/material.dart';

class DeleteIconButton extends StatelessWidget {
  final String itemType;
  final String itemName;
  final Future<void> Function() onDelete;

  const DeleteIconButton({
    super.key,
    required this.itemType,
    required this.itemName,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.delete_outline, color: Colors.red.withOpacity(0.7)),
      tooltip: '$itemType Sil',
      onPressed: () {
        showConfirmDialog(
          context: context,
          title: "$itemType Sil",
          content:
              "'$itemName' isimli öğeyi kalıcı olarak silmek istediğine emin misin?",
          onConfirm: onDelete,
        );
      },
    );
  }
}
