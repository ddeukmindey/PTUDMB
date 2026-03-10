import 'home.dart';

void addTodo(List<TodoItem> items, String title, DateTime? dueDate) {
  if (title.trim().isNotEmpty) {
    items.insert(0, TodoItem(title.trim(), dueDate: dueDate));
  }
}
