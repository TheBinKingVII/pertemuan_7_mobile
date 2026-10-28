import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../models/todo.dart';

class AddTodoScreen extends StatefulWidget {
  // Jika diisi -> mode EDIT, jika null -> mode TAMBAH
  final int? index;
  final Todo? todo;

  const AddTodoScreen({super.key, this.index, this.todo});

  @override
  State<AddTodoScreen> createState() => _AddTodoScreenState();
}

class _AddTodoScreenState extends State<AddTodoScreen> {
  final titleController = TextEditingController();
  final subtitleController = TextEditingController();
  late bool _isEditMode;
  // Alternatif yang lebih ringkas (getter):
  // bool get _isEditMode => widget.index != null && widget.todo != null;

  @override
  void initState() {
    _isEditMode = widget.index != null && widget.todo != null;
    super.initState();

    // Mode edit: isi form dengan data lama
    if (_isEditMode) {
      titleController.text = widget.todo!.title;
      subtitleController.text = widget.todo!.subtitle;
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    subtitleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditMode ? 'Edit Todo' : 'Add Todo',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Title',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: subtitleController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Subtitle',
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                final box = Hive.box<Todo>('todos');
                final newTodo = Todo(
                  title: titleController.text,
                  subtitle: subtitleController.text,
                );
                if (_isEditMode) {
                  await box.putAt(widget.index!, newTodo); // UPDATE
                } else {
                  await box.add(newTodo); // CREATE
                }
                if (context.mounted) Navigator.pop(context);
              },
              child: Text(_isEditMode ? 'Save' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }
}
