import 'package:flutter/material.dart';

bool isNonEmptyText(String? s) => s?.trim().isNotEmpty ?? false;

bool hasDateAndTime(DateTime? date, TimeOfDay? time) => date != null && time != null;

bool canSubmitAdd(String? text, DateTime? date, TimeOfDay? time) => isNonEmptyText(text) && hasDateAndTime(date, time);

bool canSaveEdit(String? text) => isNonEmptyText(text);

DateTime? combineDateAndTime({DateTime? date, TimeOfDay? time}) {
  if (date != null) {
    final hour = time?.hour ?? 0;
    final minute = time?.minute ?? 0;
    return DateTime(date.year, date.month, date.day, hour, minute);
  }
  if (time != null) {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, time.hour, time.minute);
  }
  return null;
}
