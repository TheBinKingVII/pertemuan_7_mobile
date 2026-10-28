import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'models/todo.dart';
import 'screens/login_screen.dart';

void main() async {
  // Wajib dipanggil sebelum ada operasi async (await) di main()
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Hive + tentukan lokasi penyimpanan di device
  await Hive.initFlutter();

  // Daftarkan adapter agar Hive bisa menyimpan object Todo
  Hive.registerAdapter(TodoAdapter());

  // Buka box (≈ tabel) bernama 'todos' yang berisi object Todo
  await Hive.openBox<Todo>('todos');

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}
