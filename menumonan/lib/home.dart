import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'models/note.dart';
import 'services/note_storage.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'options.dart';
import 'services/firebase_auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final NoteStorage _storage = NoteStorage();
  List<Note> _notes = [];
  List<Note> _filtered = [];
  String _query = '';

  // Update these to match the student's real name and ID
  static const _studentName = 'Thân Đức Minh';
  static const _studentId = '2351060467';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final notes = await _storage.loadNotes();
    setState(() {
      _notes = notes;
      _applyFilter();
    });
  }

  void _applyFilter() {
    if (_query.isEmpty) {
      _filtered = List.from(_notes);
    } else {
      _filtered = _notes.where((n) => n.title.toLowerCase().contains(_query.toLowerCase())).toList();
    }
  }

  void _onSearchChanged(String v) {
    setState(() {
      _query = v;
      _applyFilter();
    });
  }

  Future<void> _openEditor({Note? note}) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => EditScreen(note: note ?? Note.createEmpty())));
    // Refresh when returning
    await _load();
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    final r = await showDialog<bool>(context: context, builder: (c) => AlertDialog(title: const Text('Xác nhận'), content: const Text('Bạn có chắc chắn muốn xóa ghi chú này không?'), actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Hủy')), TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('OK'))]));
    return r ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final title = 'Smart Note - $_studentName - $_studentId';
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Đăng xuất',
            onPressed: () async {
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Đăng xuất'),
                  content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Hủy'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Đăng xuất'),
                    ),
                  ],
                ),
              );

              if (shouldLogout == true) {
                try {
                  await FirebaseAuthService().signOut();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đã đăng xuất')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Lỗi: $e')),
                    );
                  }
                }
              }
            },
          ),
        ],
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: TextField(
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Tìm theo tiêu đề...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey[100],
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
            ),
          ),
        ),
        Expanded(child: _buildBody()),
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEditor(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    if (_filtered.isEmpty) {
      return Center(
        child: Opacity(
          opacity: 0.6,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.note, size: 120, color: Colors.grey[400]),
            const SizedBox(height: 12),
            const Text('Bạn chưa có ghi chú nào, hãy tạo mới nhé!', style: TextStyle(color: Colors.black54)),
          ]),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: MasonryGridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        itemCount: _filtered.length,
        itemBuilder: (context, index) {
          final note = _filtered[index];
          return Dismissible(
            key: ValueKey(note.id),
            direction: DismissDirection.endToStart,
            confirmDismiss: (direction) async => await _confirmDelete(context),
            onDismissed: (direction) async {
              await _storage.deleteNote(note.id);
              await _load();
            },
            background: Container(
              decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12)),
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 16),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            child: GestureDetector(
              onTap: () => _openEditor(note: note),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(note.title.isEmpty ? '(Không có tiêu đề)' : note.title, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 8),
                    Text(note.content, style: TextStyle(color: Colors.black54), maxLines: 3, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 12),
                    if (note.imagePaths.isNotEmpty || note.filePaths.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        children: [
                          if (note.imagePaths.isNotEmpty)
                            Chip(
                              label: Text('${note.imagePaths.length} ảnh'),
                              avatar: const Icon(Icons.image, size: 16),
                              labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          if (note.filePaths.isNotEmpty)
                            Chip(
                              label: Text('${note.filePaths.length} tệp'),
                              avatar: const Icon(Icons.attach_file, size: 16),
                              labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                        ],
                      ),
                    Align(alignment: Alignment.bottomRight, child: Text(DateFormat('dd/MM/yyyy HH:mm').format(note.updatedAt), style: const TextStyle(fontSize: 12, color: Colors.black54))),
                  ]),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
