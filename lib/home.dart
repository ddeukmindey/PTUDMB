import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'delete.dart';
import 'validation.dart';
import 'insert.dart';
import 'fix.dart';

class TodoItem {
  String title;
  bool done;
  DateTime? dueDate;
  TodoItem(this.title, {this.done = false, this.dueDate});

  Map<String, dynamic> toJson() => {
        'title': title,
        'done': done,
        'dueDate': dueDate?.toIso8601String(),
      };

  factory TodoItem.fromJson(Map<String, dynamic> json) => TodoItem(
        json['title'] as String? ?? '',
        done: json['done'] as bool? ?? false,
        dueDate: json['dueDate'] != null ? DateTime.tryParse(json['dueDate'] as String) : null,
      );
}

enum Filter { all, active, done }

enum AddMode { dialog, bottomSheet }

class TodoHomePage extends StatefulWidget {
  const TodoHomePage({super.key});

  @override
  State<TodoHomePage> createState() => _TodoHomePageState();
}

class _TodoHomePageState extends State<TodoHomePage> {
  final List<TodoItem> _items = [];

  static const String _prefsKey = 'todo_items_v1';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(_items.map((e) => e.toJson()).toList());
      await prefs.setString(_prefsKey, encoded);
    } catch (e) {
      // ignore save errors for now
    }
  }

  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final s = prefs.getString(_prefsKey);
      if (s != null && s.isNotEmpty) {
        final List<dynamic> data = jsonDecode(s);
        final loaded = data
            .map((e) => TodoItem.fromJson(e as Map<String, dynamic>))
            .toList(growable: true);
        setState(() {
          _items
            ..clear()
            ..addAll(loaded);
        });
      }
    } catch (e) {
      // ignore load errors
    }
  }

  Filter _filter = Filter.all;

  @override
  Widget build(BuildContext context) {
    final List<TodoItem> visibleItems = _items.where((it) {
      switch (_filter) {
        case Filter.active:
          return !it.done;
        case Filter.done:
          return it.done;
        case Filter.all:
          return true;
      }
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách việc cần làm'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Wrap(
                spacing: 8,
                children: [
                  _buildFilterChip('Tất cả', Filter.all),
                  _buildFilterChip('Chưa xong', Filter.active),
                  _buildFilterChip('Đã xong', Filter.done),
                ],
              ),
            ),

            Expanded(
              child: ListView.separated(
                itemCount: visibleItems.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = visibleItems[index];
                  return _buildTodoRow(item, _items.indexOf(item));
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await showTodoDialog(context, onSave: (title, date) {
            setState(() => addTodo(_items, title, date));
            _saveData();
          });
        },
        tooltip: 'Thêm',
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        child: const Icon(Icons.add),
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    final d = '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$d $hh:$mm';
  }

  Widget _buildFilterChip(String label, Filter f) {
    final selected = _filter == f;
    return ChoiceChip(
      label: Text(
        label,
        style: selected
            ? TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer)
            : null,
      ),
      selected: selected,
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      onSelected: (_) => setState(() => _filter = f),
    );
  }

  Widget _buildTodoRow(TodoItem item, int index) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      child: Row(
        children: [
          Checkbox(
            value: item.done,
            onChanged: (v) {
              setState(() => item.done = v ?? false);
              _saveData();
            },
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            fillColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return Theme.of(context).colorScheme.primary;
              }
              return Theme.of(context).colorScheme.onSurfaceVariant;
            }),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: item.done ? 0.5 : 1.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          decoration: item.done ? TextDecoration.lineThrough : null,
                          color: item.done ? Theme.of(context).colorScheme.onSurfaceVariant : null,
                        ),
                  ),
                  if (item.dueDate != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      _formatDateTime(item.dueDate!),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                  ]
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 96,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: 'Sửa',
                  onPressed: () async {
                    await showTodoDialog(
                      context,
                      initialItem: item,
                      onSave: (newText, newDate) {
                        setState(() => editTodo(item, newText, newDate));
                        _saveData();
                      },
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  tooltip: 'Xóa',
                  onPressed: () async {
                    final confirmed = await confirmDelete(context, itemTitle: item.title);
                    if (confirmed) {
                      setState(() => _items.removeAt(index));
                      _saveData();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> showTodoDialog(
  BuildContext context, {
  TodoItem? initialItem,
  required void Function(String, DateTime?) onSave,
}) async {
  final controller = TextEditingController(text: initialItem?.title ?? '');
  DateTime? selectedDate = initialItem?.dueDate;
  TimeOfDay? selectedTime = selectedDate != null ? TimeOfDay.fromDateTime(selectedDate) : null;

  await showDialog<void>(
    context: context,
    builder: (ctx) {
      return StatefulBuilder(builder: (ctx, setState) {
        final isEdit = initialItem != null;
        final isValid = isEdit ? canSaveEdit(controller.text) : canSubmitAdd(controller.text, selectedDate, selectedTime);
        
        return AlertDialog(
          title: Text(isEdit ? 'Sửa việc' : 'Thêm việc mới'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: controller,
                autofocus: true,
                decoration: const InputDecoration(hintText: 'Nhập nội dung...'),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(selectedDate == null ? 'Chưa chọn ngày' : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'),
                  TextButton(
                    onPressed: () async {
                      final d = await showDatePicker(context: ctx, initialDate: selectedDate ?? DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100));
                      if (d != null) setState(() => selectedDate = d);
                    },
                    child: const Text('Chọn ngày'),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Text(selectedTime == null ? 'Chưa chọn giờ' : '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}'),
                   TextButton(
                    onPressed: () async {
                      final t = await showTimePicker(context: ctx, initialTime: selectedTime ?? TimeOfDay.now());
                      if (t != null) setState(() => selectedTime = t);
                    },
                    child: const Text('Chọn giờ'),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Huỷ'),
            ),
            TextButton(
              onPressed: isValid
                  ? () {
                      final combined = combineDateAndTime(date: selectedDate, time: selectedTime);
                      onSave(controller.text.trim(), combined);
                      Navigator.of(ctx).pop();
                    }
                  : null,
              child: Text(isEdit ? 'Lưu' : 'Thêm'),
            ),
          ],
        );
      });
    },
  );
}
