import 'home.dart';

void editTodo(TodoItem item, String newTitle, DateTime? newDueDate) {
  if (newTitle.trim().isNotEmpty) {
    item.title = newTitle.trim();
    item.dueDate = newDueDate;
  }
}
