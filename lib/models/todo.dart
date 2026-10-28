import 'package:hive/hive.dart';

// File hasil generate build_runner (berisi TodoAdapter)
part 'todo.g.dart';

// typeId = "KTP" class ini di Hive. Hive tidak menyimpan nama class,
// yang disimpan ke disk adalah angka ini. Tiap class harus unik.
@HiveType(typeId: 0)
class Todo extends HiveObject {
  // Nomor field juga disimpan ke disk; jangan diubah setelah ada data
  @HiveField(0)
  final String title;

  @HiveField(1)
  final String subtitle;

  Todo({required this.title, required this.subtitle});
}
