import 'package:alisveris_sepeti/utils/dialog_helper.dart';
import 'package:flutter/material.dart';

class DeleteIconButton extends StatelessWidget {
  /// Silinecek öğenin türü. Dialog başlığında kullanılır. Örn: "Liste", "Grup", "Ürün"
  final String itemType;

  /// Silinecek öğenin adı. Dialog içeriğinde kullanılır. Örn: "Alışveriş Listesi"
  final String itemName;

  /// Onay verildikten sonra çalıştırılacak olan asıl silme fonksiyonu
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
      icon: Icon(Icons.delete_outline, color: Colors.red),
      onPressed: () {
        // Genel dialog fonksiyonumuzu, bu widget'a özel parametrelerle çağırıyoruz.
        showConfirmDialog(
          context: context,
          title: "$itemType Sil",
          content:
              "'$itemName' isimli öğeyi kalıcı olarak silmek istediğine emin misin?",
          onConfirm:
              onDelete, // Dışarıdan verilen silme fonksiyonunu buraya bağlıyoruz.
        );
      },
    );
  }
}
