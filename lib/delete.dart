import 'package:flutter/material.dart';

Future<bool> confirmDelete(BuildContext context, {String? itemTitle}) async {
  return (await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text('Xác nhận'),
          content: Text(itemTitle == null
              ? 'Bạn có chắc chắn muốn xóa?'
              : 'Bạn có chắc chắn muốn xóa "$itemTitle"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Huỷ'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Xóa'),
            ),
          ],
        ),
      )) ??
      false;
}
