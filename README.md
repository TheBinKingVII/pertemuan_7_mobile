# Modul 6 — Local Storage (To-do List dengan Shared Preferences & Hive)

Project Flutter ini adalah hasil dari **Langkah Praktikum Modul VI – Local Storage** (Praktikum Teknologi dan Pemrograman Mobile, Informatika UPN "Veteran" Yogyakarta).

Aplikasinya sederhana: **login → daftar to-do → tambah / edit / hapus to-do**. Yang menarik bukan tampilannya, tapi *di mana datanya disimpan*:

| Data | Disimpan pakai | Kenapa |
|---|---|---|
| Status sudah login atau belum (`true`/`false`) | **Shared Preferences** | Data kecil, cuma satu nilai key-value. Cocok untuk "session". |
| Daftar to-do (title + subtitle) | **Hive** | Data utama aplikasi, bentuknya object & bisa banyak. Butuh database. |

Keduanya disimpan di **memori internal HP**, jadi:
- tidak butuh internet sama sekali,
- data **tetap ada** walaupun aplikasi ditutup atau HP dimatikan.

Akun login (hard-coded di kode): **username `budi123`**, **password `password123`**.

---

## Daftar Isi
1. [Cara menjalankan project](#1-cara-menjalankan-project)
2. [Struktur folder](#2-struktur-folder)
3. [Konsep dasar (biar paham dulu)](#3-konsep-dasar-biar-paham-dulu)
4. [Langkah praktikum + gunanya apa](#4-langkah-praktikum--gunanya-apa)
5. [Alur aplikasi dari awal sampai akhir](#5-alur-aplikasi-dari-awal-sampai-akhir)
6. [Error yang sering muncul](#6-error-yang-sering-muncul)

---

## 1. Cara menjalankan project

Folder ini hanya berisi `lib/` dan `pubspec.yaml` (kode inti). Folder platform (`android/`, `ios/`, `web/`, dst.) dibuat otomatis oleh Flutter:

```bash
cd modul6_local_storage
flutter create .                 # buat folder android/ios/web dll (kode lib/ TIDAK ditimpa)
flutter pub get                  # download package
dart run build_runner build --delete-conflicting-outputs   # (opsional) generate ulang todo.g.dart
flutter run
```

> `todo.g.dart` sudah disertakan, jadi `build_runner` sebenarnya opsional. Tapi tetap jalankan sekali supaya kamu tahu prosesnya — ini bagian dari praktikum.

---

## 2. Struktur folder

```
modul6_local_storage/
├── pubspec.yaml                 ← daftar package (shared_preferences, hive, dll)
└── lib/
    ├── main.dart                ← titik awal: inisialisasi Hive, buka box, tampilkan LoginScreen
    ├── models/
    │   ├── todo.dart            ← class Todo (bentuk data yang disimpan)
    │   └── todo.g.dart          ← TodoAdapter, hasil generate build_runner
    └── screens/
        ├── login_screen.dart    ← login + simpan & cek status login (Shared Preferences)
        ├── home_screen.dart     ← tampilkan daftar to-do, hapus, logout
        └── add_todo_screen.dart ← form tambah & edit to-do (satu halaman dua fungsi)
```

---

## 3. Konsep dasar (biar paham dulu)

### Shared Preferences
Mirip **session** di web. Menyimpan data dengan prinsip **key → value**, misalnya:

```
'loginData' → true
```

Di Android disimpan sebagai file XML kecil. Cepat diakses, tapi **tidak cocok untuk data kompleks** (list object, data relasional). Biasanya dipakai untuk: status login, tema gelap/terang, bahasa, onboarding sudah dilihat atau belum.

Cara pakainya cuma dua pola:
```dart
final prefs = await SharedPreferences.getInstance();
await prefs.setBool('loginData', true);      // SIMPAN: set<TipeData>('key', nilai)
final adaLogin = prefs.getBool('loginData'); // AMBIL : get<TipeData>('key')
```
Ada juga `setString`, `setInt`, `setDouble`, `setStringList` dan pasangan `get`-nya.

### Hive
Database **NoSQL** yang ditulis murni dengan Dart. Kelebihannya: sangat cepat (lihat Gambar 6.1 di modul — baca/tulis 1000 data jauh lebih cepat dari SQLite), bisa jalan di mobile, desktop, dan web.

Istilah penting:
- **Box** = tempat penyimpanan, analoginya seperti **tabel** di SQL. Harus punya nama unik (di sini `'todos'`).
- **TypeAdapter** = "penerjemah" yang mengubah object Dart (`Todo`) menjadi bytes untuk disimpan, dan sebaliknya.
- **HiveObject** = class dasar agar object bisa disimpan di Hive.

CRUD di Hive tidak pakai SQL, tapi method:

| Operasi | Method | Dipakai di |
|---|---|---|
| Create | `box.add(value)` | `add_todo_screen.dart` (mode tambah) |
| Read | `box.getAt(index)` | `home_screen.dart` (ListView) |
| Update | `box.putAt(index, value)` | `add_todo_screen.dart` (mode edit) |
| Delete | `box.deleteAt(index)` | `home_screen.dart` (tombol tong sampah) |

---

## 4. Langkah praktikum + gunanya apa

### Langkah 1 — Buat project Flutter baru
```bash
flutter create modul6_local_storage
```
**Gunanya:** menyiapkan kerangka aplikasi (folder `lib`, `android`, `ios`, `pubspec.yaml`).

---

### Langkah 2 — Tambahkan dependency di `pubspec.yaml`
```yaml
dependencies:
  shared_preferences: ^2.5.3
  hive: ^2.2.3
  hive_flutter: ^1.1.0

dev_dependencies:
  hive_generator: ^2.0.1
  build_runner: ^2.4.8
```
**Gunanya masing-masing:**
- `shared_preferences` → menyimpan status login.
- `hive` → mesin database-nya.
- `hive_flutter` → jembatan Hive ke Flutter: menyediakan `Hive.initFlutter()` (otomatis menentukan folder penyimpanan di HP) dan `.listenable()` (supaya UI bisa auto-update).
- `hive_generator` + `build_runner` → **dev_dependencies**, artinya hanya dipakai saat development, tidak ikut ke aplikasi jadi. Keduanya bertugas **membuat kode `TodoAdapter` secara otomatis** supaya kita tidak menulisnya manual.

> ⚠️ Di modul tertulis `dev dependencies:` (pakai spasi). Yang benar adalah **`dev_dependencies:`** (pakai underscore), kalau tidak `pub get` akan gagal.

---

### Langkah 3 — `Pub Get`
```bash
flutter pub get
```
**Gunanya:** mendownload semua package yang sudah ditulis di `pubspec.yaml`. Tanpa ini, `import 'package:hive/...'` akan error.

---

### Langkah 4 — Isi `main.dart`
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(TodoAdapter());
  await Hive.openBox<Todo>('todos');
  runApp(const MainApp());
}
```
Ini bagian paling penting di `main.dart`. Penjelasan per baris:

| Baris | Gunanya |
|---|---|
| `void main() async` | `main` dibuat `async` karena di dalamnya ada `await` (menunggu Hive siap). |
| `WidgetsFlutterBinding.ensureInitialized()` | Memastikan "mesin" Flutter sudah siap **sebelum** `runApp()`. Wajib kalau ada kode async/plugin sebelum `runApp`, kalau tidak aplikasi bisa crash. |
| `await Hive.initFlutter()` | Menyalakan Hive dan menentukan **folder penyimpanan** database di HP. |
| `Hive.registerAdapter(TodoAdapter())` | Memberi tahu Hive: "kalau ketemu object `Todo`, pakai adapter ini untuk menyimpan/membacanya." Tanpa ini Hive tidak tahu cara menyimpan class buatan kita. |
| `await Hive.openBox<Todo>('todos')` | **Membuka** box bernama `todos` yang isinya object `Todo`. Box harus dibuka dulu sebelum dipakai di halaman lain lewat `Hive.box<Todo>('todos')`. |
| `home: LoginScreen()` | Halaman pertama yang muncul adalah halaman login. |

Urutannya **harus** seperti ini: init → register adapter → open box → runApp.

---

### Langkah 5 — Buat model `lib/models/todo.dart`
```dart
part 'todo.g.dart';

@HiveType(typeId: 0)
class Todo extends HiveObject {
  @HiveField(0) final String title;
  @HiveField(1) final String subtitle;
  Todo({required this.title, required this.subtitle});
}
```
**Gunanya:** mendefinisikan **bentuk data** satu to-do (punya `title` dan `subtitle`).

- `@HiveType(typeId: 0)` → "nomor identitas" class `Todo` di Hive. Hive **tidak menyimpan nama class** ke disk, yang disimpan angka ini. Kalau nanti ada class lain (misal `Product`), pakai `typeId: 1`, dst. **Tidak boleh sama.**
- `@HiveField(0)`, `@HiveField(1)` → nomor tiap field. Sama seperti typeId, yang disimpan adalah nomornya. Jangan mengubah nomor field yang sudah dipakai, nanti data lama terbaca salah.
- `extends HiveObject` → membuat object bisa disimpan Hive (dan dapat method tambahan seperti `.save()`, `.delete()`).
- `part 'todo.g.dart'` → menyambungkan file ini dengan file hasil generate.

Lalu jalankan:
```bash
dart run build_runner build
```
**Gunanya:** `build_runner` membaca anotasi `@HiveType`/`@HiveField` lalu **membuat file `todo.g.dart`** berisi class `TodoAdapter` (kode untuk mengubah `Todo` ↔ bytes). Itulah adapter yang didaftarkan di `main.dart`.

> Di versi `hive_generator` terbaru nama adapter sudah otomatis `TodoAdapter`, jadi biasanya tidak perlu di-rename lagi seperti yang disebut modul.

---

### Langkah 6 — Pahami pembagian tugas login/logout
- `login_screen.dart` → **men-set** nilai Shared Preferences (saat login) dan **mengecek** nilainya (saat halaman dibuka).
- `home_screen.dart` → **men-set ulang** nilainya menjadi `false` (saat logout).

**Gunanya:** memahami pola inti Shared Preferences: *ada yang menyimpan, ada yang membaca.*

---

### Langkah 7 — Buat folder `screens` + `login_screen.dart`, import package
```dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
```
**Gunanya:** menyiapkan alat yang dipakai halaman login (widget Material, Shared Preferences, dan tujuan navigasi setelah login).

---

### Langkah 8 — Buat class `LoginScreen` (StatefulWidget)
**Gunanya:** halaman login harus **Stateful** karena butuh `initState()` (untuk cek login saat dibuka), `dispose()` (untuk membersihkan controller), dan menyimpan `TextEditingController`.

---

### Langkah 9 — Buat UI login
Isinya: `TextField` username, `TextField` password, dan tombol **Login** yang memanggil `_login`.

**Gunanya:** tempat user memasukkan data. `controller` dipakai untuk **membaca teks** yang diketik (`_usernameController.text`).

> Di project ini ditambah `obscureText: true` pada password supaya teksnya tersembunyi (●●●●).

---

### Langkah 10a — Fungsi `_login()`
```dart
if (username == 'budi123' && password == 'password123') {
  final loginData = await SharedPreferences.getInstance();
  await loginData.setBool('loginData', true);
  if (mounted) Navigator.pushReplacement(... HomeScreen());
}
```
**Gunanya:**
1. Cek username & password.
2. Kalau benar, **simpan `loginData = true`** ke Shared Preferences → inilah "ingatan" bahwa user sudah login.
3. Pindah ke `HomeScreen` dengan `pushReplacement`, artinya halaman login **diganti** (bukan ditumpuk), jadi tombol back tidak kembali ke login.
- `if (mounted)` → memastikan halaman masih ada di layar sebelum navigasi (karena ada `await` sebelumnya; kalau halaman sudah ditutup, `context` tidak valid).

> Tambahan di project ini: kalau salah, muncul SnackBar "Username atau password salah".

### Langkah 10b — Fungsi `_checkLogin()`
```dart
final adaLogin = loginData.getBool('loginData') ?? false;
if (adaLogin && mounted) Navigator.pushReplacement(... HomeScreen());
```
**Gunanya:** **membaca** `loginData`. Kalau `true` → langsung lompat ke HomeScreen tanpa login lagi. Inilah yang membuat aplikasi "ingat" user walaupun aplikasi sudah ditutup.
- `?? false` → kalau key belum pernah ada (pertama kali install), hasilnya `null`, maka dianggap `false`.

### Langkah 11 — Lengkapi `initState()`, `dispose()`, controller
- `initState()` memanggil `_checkLogin()` → **setiap kali halaman login dibuka, otomatis dicek.**
- `dispose()` memanggil `controller.dispose()` → membebaskan memori ketika halaman ditutup (mencegah *memory leak*).

Sampai sini, **bagian Shared Preferences selesai**: ada yang menyimpan (`_login`) dan ada yang mengecek (`_checkLogin`).

---

### Langkah 12–14 — Buat `home_screen.dart`, import, class `HomeScreen`
Import yang dipakai: `shared_preferences` (logout), `hive_flutter` (baca box), `todo.dart` (tipe data), `login_screen.dart` & `add_todo_screen.dart` (navigasi).

**Gunanya:** halaman utama yang menampilkan semua to-do dari Hive.

---

### Langkah 15 — UI Home dengan `ValueListenableBuilder`
```dart
ValueListenableBuilder(
  valueListenable: Hive.box<Todo>('todos').listenable(),
  builder: (context, Box<Todo> box, child) {
    return ListView.builder(
      itemCount: box.length,
      itemBuilder: (context, index) {
        final todo = box.getAt(index);
        ...
```
**Gunanya:**
- `Hive.box<Todo>('todos')` → mengambil box yang **sudah dibuka** di `main.dart` (tidak perlu `await` lagi).
- `.listenable()` → membuat box bisa "didengarkan".
- `ValueListenableBuilder` → **otomatis build ulang daftar** setiap kali isi box berubah (add / putAt / deleteAt). Jadi **tidak perlu `setState()`**, dan yang di-build ulang hanya bagian list, bukan seluruh halaman.
- `box.getAt(index)` → **Read**: ambil to-do ke-`index`. Nilai `index` ini penting karena dipakai untuk edit & hapus.

Tombol di tiap kartu:
- ✏️ **Edit** → buka `AddTodoScreen(index: index, todo: todo)` → kirim posisi & data lama.
- 🗑️ **Delete** → `box.deleteAt(index)` → hapus dari database; list otomatis ter-update.
- ➕ **FloatingActionButton** → buka `AddTodoScreen()` tanpa parameter → mode tambah.

> Tambahan di project ini: kalau box kosong tampil teks "Belum ada to-do", dan kolom teks dibungkus `Expanded` supaya teks panjang tidak overflow.

---

### Langkah 16 — Fungsi `_logout()`
```dart
await prefs.setBool('loginData', false);
Navigator.pushAndRemoveUntil(context, ... LoginScreen(), (route) => false);
```
**Gunanya:**
1. Ubah `loginData` jadi `false` → saat aplikasi dibuka lagi, `_checkLogin()` tidak akan melompati login.
2. `pushAndRemoveUntil(..., (route) => false)` → pindah ke LoginScreen **dan hapus semua halaman sebelumnya** dari stack, supaya user tidak bisa menekan back kembali ke Home.

> Catatan: logout **tidak menghapus** to-do di Hive. Login lagi, datanya masih ada.

---

### Langkah 17–19 — Buat `add_todo_screen.dart`, import, class `AddTodoScreen`
Import: `material`, `hive` (akses box), `todo.dart`.

**Gunanya:** **satu halaman untuk dua fungsi** — tambah to-do baru dan edit to-do lama.

---

### Langkah 20 — UI form tambah/edit
Dua `TextField` (Title & Subtitle) dan satu tombol. Saat tombol ditekan:
```dart
final box = Hive.box<Todo>('todos');
final newTodo = Todo(title: ..., subtitle: ...);
if (_isEditMode) {
  box.putAt(widget.index!, newTodo);   // UPDATE: timpa data di posisi index
} else {
  box.add(newTodo);                    // CREATE: tambah di posisi paling akhir
}
Navigator.pop(context);                // kembali ke Home
```
**Gunanya:** di sinilah **Create** dan **Update** terjadi. Judul AppBar dan teks tombol juga berubah (`Add Todo`/`Add` vs `Edit Todo`/`Save`) tergantung mode.

Setelah `pop`, Home langsung menampilkan data baru karena `ValueListenableBuilder` mendeteksi perubahan box.

---

### Langkah 21a — Variabel `index`, `todo`, dan `_isEditMode`
```dart
final int? index;   // posisi to-do di box
final Todo? todo;   // data lama
late bool _isEditMode;
```
**Gunanya:**
- `index` & `todo` bertipe nullable (`?`) karena **boleh tidak diisi**. Tidak diisi = mode tambah, diisi = mode edit.
- `_isEditMode` = penanda mode, dipakai untuk memilih `add` atau `putAt`, dan teks di UI.

### Langkah 21b — `initState()` & `dispose()`
```dart
_isEditMode = widget.index != null && widget.todo != null;
if (_isEditMode) {
  titleController.text = widget.todo!.title;
  subtitleController.text = widget.todo!.subtitle;
}
```
**Gunanya:**
- Menentukan mode **sekali di awal** saat halaman dibuat.
- Kalau mode edit, **isi form dengan data lama** supaya user tinggal mengubahnya.
- `dispose()` membersihkan kedua controller.

Alternatif lebih ringkas (disebut di modul) adalah getter:
```dart
bool get _isEditMode => widget.index != null && widget.todo != null;
```

---

## 5. Alur aplikasi dari awal sampai akhir

```
Buka app
  └─ main(): initFlutter → registerAdapter → openBox('todos') → LoginScreen
        └─ initState → _checkLogin()
              ├─ loginData == true  → langsung ke HomeScreen
              └─ loginData false/null → tampil form login
                    └─ _login() benar → setBool('loginData', true) → HomeScreen

HomeScreen  (ValueListenableBuilder mendengarkan box 'todos')
  ├─ [+]      → AddTodoScreen()            → box.add()      → list auto update
  ├─ [edit]   → AddTodoScreen(index, todo) → box.putAt()    → list auto update
  ├─ [hapus]  → box.deleteAt(index)                         → list auto update
  └─ [logout] → setBool('loginData', false) → LoginScreen (stack dibersihkan)
```

**Uji coba yang disarankan:**
1. Login → tambah 2 to-do → **tutup paksa aplikasi** → buka lagi. Hasil: langsung masuk Home (Shared Preferences bekerja) dan to-do masih ada (Hive bekerja).
2. Logout → buka lagi. Hasil: kembali ke halaman login, tapi setelah login to-do lama masih ada.
3. Matikan internet → semuanya tetap jalan (local storage).

---

## 6. Error yang sering muncul

| Error | Penyebab | Solusi |
|---|---|---|
| `Undefined name 'TodoAdapter'` / `todo.g.dart` tidak ada | Belum generate | `dart run build_runner build --delete-conflicting-outputs` |
| `HiveError: Box not found. Did you forget to call Hive.openBox()?` | `Hive.box('todos')` dipanggil sebelum box dibuka | Pastikan `await Hive.openBox<Todo>('todos')` ada di `main()` sebelum `runApp` |
| `HiveError: Cannot write, unknown type: Todo` | Adapter belum didaftarkan | Tambahkan `Hive.registerAdapter(TodoAdapter())` |
| `Error on line ... dev dependencies` saat pub get | Salah tulis | Gunakan `dev_dependencies:` |
| Konflik versi `hive_generator` vs `build_runner` | Versi tidak cocok | Gunakan versi di `pubspec.yaml` ini, lalu `flutter pub get` |
| `MissingPluginException` (shared_preferences) | Plugin baru ditambah saat app sedang jalan | Stop app, lalu `flutter run` ulang (bukan hot reload) |

---

Referensi project asli dari modul: https://github.com/AndiZirahitaf/modul_6_prak_mobile
