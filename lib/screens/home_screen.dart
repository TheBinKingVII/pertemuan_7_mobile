import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/todo.dart';
import 'add_todo_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// Ubah status login jadi false, lalu kembali ke LoginScreen
  /// dan hapus semua halaman sebelumnya dari stack navigasi.
  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('loginData', false);
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Todo List App',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        // ValueListenableBuilder "mendengarkan" box 'todos'.
        // Setiap ada add/put/delete, hanya bagian ini yang di-build ulang.
        child: ValueListenableBuilder(
          valueListenable: Hive.box<Todo>('todos').listenable(),
          builder: (context, Box<Todo> box, child) {
            if (box.isEmpty) {
              return const Center(child: Text('Belum ada to-do. Tekan + untuk menambah.'));
            }
            return ListView.builder(
              itemCount: box.length,
              itemBuilder: (context, index) {
                // READ: ambil data berdasarkan index
                final todo = box.getAt(index);
                if (todo == null) return const SizedBox.shrink();

                return Card(
                  color: Colors.white,
                  shadowColor: Colors.black,
                  elevation: 4,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                todo.title,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                todo.subtitle,
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            // UPDATE: kirim index + todo ke halaman form
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddTodoScreen(
                                      index: index,
                                      todo: todo,
                                    ),
                                  ),
                                );
                              },
                            ),
                            // DELETE: hapus berdasarkan index
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                box.deleteAt(index);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      // CREATE: buka form tanpa index/todo -> mode tambah
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTodoScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
