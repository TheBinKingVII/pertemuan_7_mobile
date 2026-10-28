# Modul 6 — Local Storage (To-do List dengan Shared Preferences & Hive)

Project Flutter ini adalah hasil dari **Langkah Praktikum Modul VI – Local Storage** (Praktikum Teknologi dan Pemrograman Mobile, Informatika UPN "Veteran" Yogyakarta).

Aplikasinya: **login → daftar to-do → tambah / edit / hapus to-do → logout**.

| Data | Disimpan pakai | Kenapa |
|---|---|---|
| Status sudah login atau belum (`true`/`false`) | **Shared Preferences** | Data kecil, cuma satu nilai key-value. Fungsinya mirip "session". |
| Daftar to-do (title + subtitle) | **Hive** | Data utama aplikasi, berbentuk object dan jumlahnya bisa banyak. Butuh database. |

Keduanya disimpan di **memori internal HP**, jadi tidak butuh internet, dan data **tetap ada** walaupun aplikasi ditutup atau HP dimatikan.

Akun login (hard-coded): **username `budi123`**, **password `password123`**.

---

## Daftar Isi

- [Cara menjalankan project ini](#cara-menjalankan-project-ini)
- [Struktur folder akhir](#struktur-folder-akhir)
- [Konsep dasar](#konsep-dasar)
- [Langkah Praktikum](#langkah-praktikum)
  - [Step 1 — Buat project Flutter baru](#step-1--buat-project-flutter-baru)
  - [Step 2 — Tambahkan dependency di pubspec.yaml](#step-2--tambahkan-dependency-di-pubspecyaml)
  - [Step 3 — Pub Get](#step-3--pub-get)
  - [Step 4 — Tulis main.dart](#step-4--tulis-maindart)
  - [Step 5 — Buat model Todo + generate adapter](#step-5--buat-model-todo--generate-adapter)
  - [Step 6 — Pahami pembagian tugas login & logout](#step-6--pahami-pembagian-tugas-login--logout)
  - [Step 7 — Buat login_screen.dart dan import package](#step-7--buat-login_screendart-dan-import-package)
  - [Step 8 — Buat class LoginScreen (StatefulWidget)](#step-8--buat-class-loginscreen-statefulwidget)
  - [Step 9 — Buat UI halaman login](#step-9--buat-ui-halaman-login)
  - [Step 10 — Buat fungsi _login() dan _checkLogin()](#step-10--buat-fungsi-_login-dan-_checklogin)
  - [Step 11 — Lengkapi controller, initState, dispose (kode lengkap login_screen.dart)](#step-11--lengkapi-controller-initstate-dispose-kode-lengkap-login_screendart)
  - [Step 12 — Mulai membuat home_screen.dart](#step-12--mulai-membuat-home_screendart)
  - [Step 13 — Import package di home_screen.dart](#step-13--import-package-di-home_screendart)
  - [Step 14 — Buat class HomeScreen (StatefulWidget)](#step-14--buat-class-homescreen-statefulwidget)
  - [Step 15 — Buat UI home dengan ValueListenableBuilder](#step-15--buat-ui-home-dengan-valuelistenablebuilder)
  - [Step 16 — Buat fungsi _logout() (kode lengkap home_screen.dart)](#step-16--buat-fungsi-_logout-kode-lengkap-home_screendart)
  - [Step 17 — Mulai membuat add_todo_screen.dart](#step-17--mulai-membuat-add_todo_screendart)
  - [Step 18 — Import package di add_todo_screen.dart](#step-18--import-package-di-add_todo_screendart)
  - [Step 19 — Buat class AddTodoScreen (StatefulWidget)](#step-19--buat-class-addtodoscreen-statefulwidget)
  - [Step 20 — Buat UI form tambah/edit](#step-20--buat-ui-form-tambahedit)
  - [Step 21 — Tambah variabel, initState, dispose (kode lengkap add_todo_screen.dart)](#step-21--tambah-variabel-initstate-dispose-kode-lengkap-add_todo_screendart)
- [Alur aplikasi dari awal sampai akhir](#alur-aplikasi-dari-awal-sampai-akhir)
- [Cara menguji](#cara-menguji)
- [Error yang sering muncul](#error-yang-sering-muncul)

---

## Cara menjalankan project ini

Folder ini berisi `lib/` dan `pubspec.yaml`. Folder platform (`android/`, `ios/`, `web/`, dst.) dibuat otomatis oleh Flutter:

```bash
cd modul6_local_storage
flutter create .
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

- `flutter create .` → membuat folder `android/`, `ios/`, dll. File di `lib/` **tidak** ditimpa.
- `flutter pub get` → download package.
- `dart run build_runner build ...` → generate ulang `todo.g.dart` (sebenarnya file ini sudah disertakan, jadi langkah ini opsional, tapi tetap bagus untuk latihan).
- `flutter run` → jalankan di emulator/HP.

---

## Struktur folder akhir

```
modul6_local_storage/
├── pubspec.yaml                 ← daftar package
└── lib/
    ├── main.dart                ← titik awal: init Hive, register adapter, buka box, tampilkan LoginScreen
    ├── models/
    │   ├── todo.dart            ← class Todo (bentuk data yang disimpan)
    │   └── todo.g.dart          ← TodoAdapter (hasil generate build_runner)
    └── screens/
        ├── login_screen.dart    ← login + simpan & cek status login (Shared Preferences)
        ├── home_screen.dart     ← tampil daftar to-do, hapus, logout
        └── add_todo_screen.dart ← form tambah & edit to-do
```

---

## Konsep dasar

### Shared Preferences
Mirip **session** di web. Menyimpan data dengan prinsip **key → value**, contohnya `'loginData' → true`. Di Android disimpan sebagai file XML kecil. Cepat, tapi **tidak cocok untuk data kompleks**. Biasa dipakai untuk status login, tema, bahasa, dll.

Polanya hanya dua:

```dart
final prefs = await SharedPreferences.getInstance();

// SIMPAN  → set<TipeData>('nama_key', nilai)
await prefs.setBool('loginData', true);

// AMBIL   → get<TipeData>('nama_key')
final adaLogin = prefs.getBool('loginData');
```

Tipe lain: `setString/getString`, `setInt/getInt`, `setDouble/getDouble`, `setStringList/getStringList`.

### Hive
Database **NoSQL** yang ditulis murni dengan Dart. Sangat cepat (lihat Gambar 6.1 di modul) dan bisa jalan di mobile, desktop, maupun web.

- **Box** = tempat penyimpanan, analoginya **tabel** di SQL. Harus punya nama unik (di sini `'todos'`).
- **TypeAdapter** = penerjemah object Dart (`Todo`) ↔ bytes di disk.
- **HiveObject** = class dasar agar object bisa disimpan di Hive.

CRUD di Hive tanpa SQL, cukup method:

| Operasi | Method | Dipakai di |
|---|---|---|
| Create | `box.add(value)` | `add_todo_screen.dart` (mode tambah) |
| Read | `box.getAt(index)` | `home_screen.dart` (ListView) |
| Update | `box.putAt(index, value)` | `add_todo_screen.dart` (mode edit) |
| Delete | `box.deleteAt(index)` | `home_screen.dart` (tombol hapus) |

---

## Langkah Praktikum

---

### Step 1 — Buat project Flutter baru

**Yang dikerjakan:** buat project lewat terminal (atau VS Code: `Ctrl+Shift+P` → *Flutter: New Project* → *Application*).

```bash
flutter create modul6_local_storage
cd modul6_local_storage
```

**Gunanya:** menyiapkan kerangka aplikasi: folder `lib/` (tempat semua kode Dart), `android/`, `ios/`, dan file `pubspec.yaml` (daftar package).

Setelah dibuat, **hapus isi `lib/main.dart`** bawaan Flutter (aplikasi counter), karena nanti diganti di Step 4.

---

### Step 2 — Tambahkan dependency di pubspec.yaml

**File:** `pubspec.yaml`

**Yang dikoding:** isi `pubspec.yaml` menjadi seperti ini (kode lengkap):

```yaml
name: modul6_local_storage
description: "Modul 6 - Local Storage: To-do List dengan Shared Preferences & Hive"
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: ^3.5.0

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8

  # Local storage
  shared_preferences: ^2.5.3   # simpan data kecil key-value (status login)
  hive: ^2.2.3                 # database NoSQL lokal (data utama: to-do)
  hive_flutter: ^1.1.0         # integrasi Hive dengan Flutter (initFlutter, listenable)

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0

  # Code generator untuk membuat TodoAdapter (todo.g.dart)
  hive_generator: ^2.0.1
  build_runner: ^2.4.8

flutter:
  uses-material-design: true
```

**Gunanya masing-masing package:**

| Package | Bagian | Fungsi |
|---|---|---|
| `shared_preferences` | dependencies | Menyimpan status login (`loginData`). |
| `hive` | dependencies | Mesin database-nya. Menyediakan `Box`, `HiveObject`, anotasi `@HiveType`/`@HiveField`. |
| `hive_flutter` | dependencies | Jembatan Hive ↔ Flutter: `Hive.initFlutter()` (otomatis cari folder penyimpanan di HP) dan `.listenable()` (agar UI auto-update). |
| `hive_generator` | dev_dependencies | Membaca anotasi `@HiveType` lalu membuat kode `TodoAdapter`. |
| `build_runner` | dev_dependencies | Alat yang menjalankan generator (`dart run build_runner build`). |

`dev_dependencies` artinya hanya dipakai saat development, tidak ikut masuk ke aplikasi jadi (APK).

> ⚠️ Di modul tertulis `dev dependencies:` (pakai spasi). Yang benar **`dev_dependencies:`** (pakai underscore). Kalau pakai spasi, `pub get` error.
>
> ⚠️ Perhatikan **indentasi** YAML: package harus menjorok 2 spasi di bawah `dependencies:`. YAML sensitif terhadap spasi.

---

### Step 3 — Pub Get

**Yang dikerjakan:** setelah menyimpan `pubspec.yaml`, di VS Code akan muncul tombol **Get Packages / Pub Get** di bagian atas. Klik, atau jalankan:

```bash
flutter pub get
```

**Gunanya:** mendownload semua package yang ditulis di `pubspec.yaml` ke project. Tanpa langkah ini, `import 'package:hive/hive.dart'` dan lainnya akan merah (error *Target of URI doesn't exist*).

---

### Step 4 — Tulis main.dart

**File:** `lib/main.dart`

**Yang dikoding:** hapus semua isi bawaan, ganti dengan kode lengkap berikut:

```dart
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
```

> Wajar kalau setelah step ini masih ada error merah pada `models/todo.dart`, `TodoAdapter`, `Todo`, dan `LoginScreen`. File-file itu baru dibuat di Step 5 dan Step 7–11 (di modul ditandai *"//Bisa nanti"*).

**Penjelasan per baris:**

| Kode | Gunanya |
|---|---|
| `import 'package:hive_flutter/hive_flutter.dart'` | Mengambil `Hive.initFlutter()`. File ini juga sudah meng-export isi `hive.dart`, jadi `Hive`, `Box`, dll ikut tersedia. |
| `import 'models/todo.dart'` | Mengambil class `Todo` dan `TodoAdapter`. |
| `import 'screens/login_screen.dart'` | Mengambil `LoginScreen` sebagai halaman pertama. |
| `void main() async` | `main` dibuat `async` karena di dalamnya ada `await` (menunggu Hive siap). |
| `WidgetsFlutterBinding.ensureInitialized()` | Memastikan "mesin" Flutter siap **sebelum** `runApp()`. Plugin (Hive, Shared Preferences) butuh mesin ini. Tanpa baris ini, memanggil `await` plugin sebelum `runApp` bisa membuat aplikasi crash. |
| `await Hive.initFlutter()` | Menyalakan Hive dan menentukan **folder penyimpanan** database di HP (folder dokumen aplikasi). |
| `Hive.registerAdapter(TodoAdapter())` | Memberi tahu Hive: "kalau menyimpan/membaca `Todo`, pakai adapter ini". Tanpa ini Hive tidak tahu cara menyimpan class buatan kita. |
| `await Hive.openBox<Todo>('todos')` | **Membuka** box bernama `todos` berisi object `Todo`. Box wajib dibuka sekali di awal supaya di halaman lain bisa langsung dipanggil dengan `Hive.box<Todo>('todos')` tanpa `await`. |
| `runApp(const MainApp())` | Menjalankan aplikasi. |
| `debugShowCheckedModeBanner: false` | Menghilangkan pita "DEBUG" di pojok kanan atas. |
| `home: LoginScreen()` | Halaman pertama yang muncul adalah halaman login. |

**Urutannya wajib:** `ensureInitialized` → `initFlutter` → `registerAdapter` → `openBox` → `runApp`.

---

### Step 5 — Buat model Todo + generate adapter

**File:** buat folder `lib/models/`, lalu buat file `lib/models/todo.dart`

**Yang dikoding (kode lengkap):**

```dart
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
```

**Penjelasan:**

| Kode | Gunanya |
|---|---|
| `part 'todo.g.dart';` | Menyambungkan file ini dengan file yang nanti di-generate. Awalnya merah karena file belum ada — normal. |
| `@HiveType(typeId: 0)` | Nomor identitas class `Todo` di Hive. Hive **tidak menyimpan nama class** ke disk, melainkan angka ini. Kalau nanti ada class lain (misal `Product` untuk keranjang), pakai `typeId: 1`. **Tidak boleh sama.** |
| `class Todo extends HiveObject` | Membuat `Todo` bisa disimpan di Hive, dan mendapat method bawaan seperti `.save()`, `.delete()`, `.key`. |
| `@HiveField(0)` / `@HiveField(1)` | Nomor tiap field. Yang disimpan ke disk adalah nomornya, bukan nama variabel. Jangan mengganti nomor field yang sudah dipakai, nanti data lama terbaca salah. |
| `final String title; final String subtitle;` | Dua atribut satu to-do: judul dan keterangan. |
| `Todo({required this.title, required this.subtitle});` | Constructor dengan named parameter wajib, dipakai seperti `Todo(title: 'A', subtitle: 'B')`. |

**Lalu jalankan build_runner di terminal:**

```bash
dart run build_runner build
```

Kalau ada error konflik file lama, pakai:

```bash
dart run build_runner build --delete-conflicting-outputs
```

**Gunanya:** `build_runner` membaca anotasi `@HiveType` dan `@HiveField`, lalu **membuat file `lib/models/todo.g.dart`** secara otomatis. File inilah yang berisi class `TodoAdapter`, yaitu kode untuk mengubah `Todo` menjadi bytes (saat disimpan) dan sebaliknya (saat dibaca).

Hasil generate (`lib/models/todo.g.dart`) kurang lebih seperti ini — **jangan diketik manual, cukup di-generate**:

```dart
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TodoAdapter extends TypeAdapter<Todo> {
  @override
  final int typeId = 0;

  @override
  Todo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Todo(
      title: fields[0] as String,
      subtitle: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Todo obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.subtitle);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
```

- `read(...)` → dipakai saat **membaca** dari disk: field nomor 0 jadi `title`, nomor 1 jadi `subtitle`.
- `write(...)` → dipakai saat **menyimpan**: tulis jumlah field (2), lalu nomor field + nilainya.

> Di modul disebut "HANYA mengganti nama adapternya menjadi TodoAdapter". Dengan `hive_generator` versi sekarang, namanya **sudah otomatis `TodoAdapter`**, jadi cukup dicek saja. Setelah file ini ada, error `TodoAdapter` di `main.dart` hilang.

---

### Step 6 — Pahami pembagian tugas login & logout

**Tidak ada kode di step ini**, hanya memahami rencana:

| File | Class | Tugas terkait Shared Preferences |
|---|---|---|
| `lib/screens/login_screen.dart` | `LoginScreen` | **Menyimpan** `loginData = true` saat login berhasil, dan **mengecek** nilai `loginData` setiap halaman login dibuka. |
| `lib/screens/home_screen.dart` | `HomeScreen` | **Mengubah** `loginData = false` saat logout. |

**Gunanya:** ini pola inti Shared Preferences — *ada bagian yang men-set nilai, ada bagian yang mengecek nilai*. Pola yang sama bisa dipakai untuk hal lain (tema gelap, onboarding, dll).

---

### Step 7 — Buat login_screen.dart dan import package

**File:** buat folder `lib/screens/`, lalu buat file `lib/screens/login_screen.dart`

**Yang dikoding:** tulis import di baris paling atas:

```dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home_screen.dart';
```

**Gunanya:**
- `material.dart` → widget-widget Flutter (`Scaffold`, `TextField`, `ElevatedButton`, dll).
- `shared_preferences.dart` → untuk `SharedPreferences.getInstance()`, `setBool`, `getBool`.
- `home_screen.dart` → tujuan navigasi setelah login berhasil. Akan merah sampai Step 14 dibuat (*"//Bisa nanti"*).

> Di modul import-nya `'../screens/home_screen.dart'`. Karena `login_screen.dart` dan `home_screen.dart` ada di folder yang sama, cukup `'home_screen.dart'`. Keduanya sama-sama benar.

---

### Step 8 — Buat class LoginScreen (StatefulWidget)

**File:** `lib/screens/login_screen.dart` (lanjutkan di bawah import)

**Yang dikoding:**

```dart
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
```

> Tips VS Code: ketik `stful` lalu Enter, isi nama `LoginScreen`, kerangka ini dibuat otomatis.

**Gunanya:**
- Halaman login dibuat **Stateful** karena butuh:
  - `initState()` → untuk menjalankan cek login otomatis saat halaman dibuka,
  - `dispose()` → untuk membersihkan controller,
  - menyimpan `TextEditingController` sebagai state.
- `LoginScreen` (class luar) hanya "pembungkus", sedangkan semua logika & UI ditulis di `_LoginScreenState`.
- `Placeholder()` → kotak bersilang sementara, nanti diganti di Step 9.

---

### Step 9 — Buat UI halaman login

**File:** `lib/screens/login_screen.dart`

**Yang dikoding:** ganti `_LoginScreenState` dari Step 8 menjadi seperti ini (bagian `return const Placeholder();` diganti UI login):

```dart
class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple,
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock_outline),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: _login,
                      child: const Text('Login', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

> Setelah step ini `_usernameController`, `_passwordController`, dan `_login` masih merah karena belum dibuat. Itu dibuat di Step 10 dan 11.

**Penjelasan susunan widget:**

| Widget | Gunanya |
|---|---|
| `Scaffold(backgroundColor: Colors.deepPurple)` | Kerangka halaman dengan latar ungu. |
| `Center` | Menaruh kartu login di tengah layar. |
| `Container(padding: 24)` | Memberi jarak kartu dari tepi layar. |
| `Card(shape: RoundedRectangleBorder(...))` | Kotak putih dengan sudut membulat radius 16. |
| `Column(mainAxisSize: MainAxisSize.min)` | Menyusun isi ke bawah, dan tinggi kolom **secukupnya** (tidak memenuhi layar), sehingga kartu kecil di tengah. |
| `TextField(controller: _usernameController)` | Kolom input username. `controller` dipakai untuk **membaca teks** yang diketik user. |
| `prefixIcon` | Ikon di kiri kolom input. |
| `obscureText: true` | Menyembunyikan password menjadi ●●●● (tambahan, tidak ada di modul). |
| `SizedBox(height: ...)` | Jarak antar widget. |
| `SizedBox(width: double.infinity)` | Membuat tombol selebar kartu. |
| `ElevatedButton(onPressed: _login)` | Tombol Login, saat ditekan memanggil fungsi `_login`. Perhatikan **tanpa tanda kurung** (`_login`, bukan `_login()`), karena yang dikirim adalah fungsinya, bukan hasil pemanggilannya. |

Tampilannya seperti **Gambar 6.3** di modul: kartu putih berisi Username, Password, dan tombol ungu Login di atas latar ungu.

---

### Step 10 — Buat fungsi _login() dan _checkLogin()

**File:** `lib/screens/login_screen.dart`, ditulis **di dalam class `_LoginScreenState`** (di atas method `build`).

#### 10a. Fungsi `_login()`

**Yang dikoding:**

```dart
  /// Validasi username & password, lalu simpan status login = true.
  void _login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username == 'budi123' && password == 'password123') {
      final loginData = await SharedPreferences.getInstance();
      await loginData.setBool('loginData', true);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username atau password salah')),
      );
    }
  }
```

**Penjelasan per baris:**

| Kode | Gunanya |
|---|---|
| `void _login() async` | `async` karena ada `await` untuk Shared Preferences. Underscore `_` artinya private (hanya bisa dipakai di file ini). |
| `_usernameController.text.trim()` | Ambil teks yang diketik, `trim()` membuang spasi di awal/akhir (supaya `"budi123 "` tetap dianggap benar). |
| `if (username == 'budi123' && password == 'password123')` | Validasi sederhana (akun hard-coded). |
| `await SharedPreferences.getInstance()` | Ambil "objek penyimpanan" Shared Preferences. Harus `await` karena membaca file dari HP. |
| `await loginData.setBool('loginData', true)` | **SIMPAN** status login. `'loginData'` = key, `true` = value. Inilah "ingatan" bahwa user sudah login. |
| `if (mounted)` | Cek apakah halaman masih tampil. Karena sebelumnya ada `await`, bisa saja halaman sudah ditutup; kalau dipakai, `context` jadi tidak valid dan error. |
| `Navigator.pushReplacement(...)` | Pindah ke `HomeScreen` dengan **mengganti** halaman login (bukan menumpuk). Jadi tombol back di Home tidak kembali ke halaman login. |
| `else { ...showSnackBar... }` | Tambahan: kalau salah, muncul pesan di bawah layar. |

#### 10b. Fungsi `_checkLogin()`

**Yang dikoding:**

```dart
  /// Baca nilai 'loginData' dari Shared Preferences.
  /// Kalau true -> langsung lompat ke HomeScreen (tidak perlu login lagi).
  void _checkLogin() async {
    final loginData = await SharedPreferences.getInstance();
    final adaLogin = loginData.getBool('loginData') ?? false;
    if (adaLogin && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }
```

**Penjelasan per baris:**

| Kode | Gunanya |
|---|---|
| `await SharedPreferences.getInstance()` | Ambil objek penyimpanan. |
| `loginData.getBool('loginData')` | **AMBIL** nilai key `loginData`. Hasilnya `true`, `false`, atau `null` (kalau belum pernah disimpan, misal pertama kali install). |
| `?? false` | Operator *null-coalescing*: kalau hasilnya `null`, pakai `false`. Jadi `adaLogin` pasti bertipe `bool`. |
| `if (adaLogin && mounted)` | Kalau sudah pernah login dan halaman masih tampil… |
| `Navigator.pushReplacement(... HomeScreen())` | …langsung lompat ke Home tanpa mengisi form. |

Fungsi ini nanti dipanggil di `initState()` (Step 11) sehingga **otomatis jalan setiap kali halaman login dibuka**.

---

### Step 11 — Lengkapi controller, initState, dispose (kode lengkap login_screen.dart)

**File:** `lib/screens/login_screen.dart`

**Yang ditambahkan di step ini:**

1. Dua controller di bagian atas `_LoginScreenState`:
   ```dart
   final _usernameController = TextEditingController();
   final _passwordController = TextEditingController();
   ```
   **Gunanya:** "penghubung" ke `TextField`, dipakai untuk membaca teks yang diketik.

2. `initState()`:
   ```dart
   @override
   void initState() {
     super.initState();
     _checkLogin();
   }
   ```
   **Gunanya:** `initState` dijalankan **sekali saat halaman pertama dibuat**. Di sini memanggil `_checkLogin()` sehingga setiap aplikasi dibuka, status login langsung dicek. `super.initState()` wajib dipanggil di baris pertama.

3. `dispose()`:
   ```dart
   @override
   void dispose() {
     _usernameController.dispose();
     _passwordController.dispose();
     super.dispose();
   }
   ```
   **Gunanya:** `dispose` dijalankan saat halaman dihancurkan (misal diganti `pushReplacement`). Controller dibersihkan agar tidak terjadi *memory leak*. `super.dispose()` dipanggil di baris terakhir.

**Kode lengkap `lib/screens/login_screen.dart` setelah Step 7–11 digabung:**

```dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Setiap kali halaman login dimuat, cek dulu apakah sudah pernah login
    _checkLogin();
  }

  /// Baca nilai 'loginData' dari Shared Preferences.
  /// Kalau true -> langsung lompat ke HomeScreen (tidak perlu login lagi).
  void _checkLogin() async {
    final loginData = await SharedPreferences.getInstance();
    final adaLogin = loginData.getBool('loginData') ?? false;
    if (adaLogin && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  /// Validasi username & password, lalu simpan status login = true.
  void _login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username == 'budi123' && password == 'password123') {
      final loginData = await SharedPreferences.getInstance();
      await loginData.setBool('loginData', true);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } else {
      // Tambahan kecil: beri tahu user jika login gagal
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username atau password salah')),
      );
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple,
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock_outline),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: _login,
                      child: const Text('Login', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

**Sampai sini bagian Shared Preferences sudah selesai:** ada yang menyimpan (`_login` → `setBool(true)`) dan ada yang mengecek (`_checkLogin` → `getBool`). Error yang tersisa hanya `HomeScreen` karena belum dibuat.

---

### Step 12 — Mulai membuat home_screen.dart

**File:** buat file baru `lib/screens/home_screen.dart`

**Yang dikerjakan:** cukup buat file kosongnya dulu.

**Gunanya:** halaman utama setelah login. Di halaman ini:
- semua to-do dari Hive ditampilkan (**Read**),
- to-do bisa dihapus (**Delete**),
- ada tombol menuju form tambah (**Create**) dan edit (**Update**),
- ada tombol **Logout** (Shared Preferences).

---

### Step 13 — Import package di home_screen.dart

**File:** `lib/screens/home_screen.dart`

**Yang dikoding:**

```dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/todo.dart';
import 'add_todo_screen.dart';
import 'login_screen.dart';
```

**Gunanya:**

| Import | Dipakai untuk |
|---|---|
| `material.dart` | Widget UI. |
| `hive_flutter.dart` | `Hive.box<Todo>('todos')`, `.listenable()`, tipe `Box`. |
| `shared_preferences.dart` | `setBool('loginData', false)` saat logout. |
| `../models/todo.dart` | Tipe data `Todo`. `../` artinya naik satu folder (dari `screens/` ke `lib/`) lalu masuk `models/`. |
| `add_todo_screen.dart` | Tujuan navigasi tombol tambah & edit. Masih merah sampai Step 17–19 (*"//Bisa nanti"*). |
| `login_screen.dart` | Tujuan navigasi setelah logout. |

---

### Step 14 — Buat class HomeScreen (StatefulWidget)

**File:** `lib/screens/home_screen.dart` (di bawah import)

**Yang dikoding:**

```dart
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
```

**Gunanya:** kerangka halaman Home. Dibuat Stateful karena ada fungsi `_logout()` yang memakai `mounted` dan `context` (hanya ada di `State`). Setelah step ini, error `HomeScreen` di `login_screen.dart` hilang.

---

### Step 15 — Buat UI home dengan ValueListenableBuilder

**File:** `lib/screens/home_screen.dart`

**Yang dikoding:** ganti method `build` di `_HomeScreenState` (yang tadinya `Placeholder`) dengan kode lengkap berikut:

```dart
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
              return const Center(
                child: Text('Belum ada to-do. Tekan + untuk menambah.'),
              );
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
```

> Di step ini `_logout` masih merah (dibuat di Step 16) dan `AddTodoScreen` masih merah (dibuat di Step 17–21). Kalau ingin mencoba run duluan seperti saran modul, **comment dulu** bagian `Navigator.push(... AddTodoScreen ...)`.

**Penjelasan bagian AppBar:**

| Kode | Gunanya |
|---|---|
| `AppBar(title: 'Todo List App', centerTitle: true)` | Judul di tengah atas. |
| `actions: [IconButton(Icons.logout, onPressed: _logout)]` | Tombol logout di kanan atas AppBar. |

**Penjelasan inti — `ValueListenableBuilder`:**

| Kode | Gunanya |
|---|---|
| `Hive.box<Todo>('todos')` | Mengambil box yang **sudah dibuka** di `main.dart`. Tidak perlu `await` lagi. |
| `.listenable()` | Mengubah box menjadi sesuatu yang bisa "didengarkan" perubahannya. |
| `ValueListenableBuilder(valueListenable: ..., builder: ...)` | Setiap kali isi box berubah (ada `add`, `putAt`, `deleteAt`), fungsi `builder` dijalankan ulang sehingga list **otomatis ter-update**. Ini **pengganti `setState()`**, dan lebih efisien karena hanya bagian list yang di-build ulang, bukan seluruh halaman. |
| `builder: (context, Box<Todo> box, child)` | `box` = isi box terbaru. |
| `if (box.isEmpty) ...` | Tambahan: tampil pesan kalau belum ada to-do. |

**Penjelasan bagian list:**

| Kode | Gunanya |
|---|---|
| `ListView.builder(itemCount: box.length, ...)` | Membuat list sebanyak jumlah data di box. `builder` hanya membuat item yang terlihat di layar (hemat memori). |
| `final todo = box.getAt(index);` | **READ** — ambil to-do di posisi `index`. Nilai `index` ini sangat penting karena dipakai untuk **edit** dan **hapus**. |
| `if (todo == null) return const SizedBox.shrink();` | Jaga-jaga kalau datanya `null`, tampilkan widget kosong berukuran 0. |
| `Card(elevation: 4)` | Kartu putih dengan bayangan untuk tiap to-do. |
| `Row(mainAxisAlignment: spaceBetween)` | Teks di kiri, tombol di kanan. |
| `Expanded(child: Column(...))` | Kolom teks mengambil sisa ruang, sehingga teks panjang tidak overflow (tambahan). |
| `Text(todo.title)` / `Text(todo.subtitle)` | Menampilkan judul (tebal) dan keterangan (abu-abu). |

**Penjelasan tombol:**

| Tombol | Kode | Operasi |
|---|---|---|
| ✏️ Edit (biru) | `Navigator.push(... AddTodoScreen(index: index, todo: todo))` | **Update** — membuka form sambil mengirim posisi data dan data lamanya. |
| 🗑️ Hapus (merah) | `box.deleteAt(index)` | **Delete** — langsung hapus dari database. List otomatis ter-update karena `ValueListenableBuilder`. |
| ➕ FloatingActionButton | `Navigator.push(... const AddTodoScreen())` | **Create** — membuka form **tanpa** parameter, jadi otomatis mode tambah. |

`Navigator.push` (bukan `pushReplacement`) dipakai karena setelah selesai mengisi form kita ingin **kembali** ke Home dengan `Navigator.pop`.

---

### Step 16 — Buat fungsi _logout() (kode lengkap home_screen.dart)

**File:** `lib/screens/home_screen.dart`, di dalam `_HomeScreenState` (di atas `build`).

**Yang dikoding:**

```dart
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
```

**Penjelasan per baris:**

| Kode | Gunanya |
|---|---|
| `await prefs.setBool('loginData', false)` | Ubah status login jadi `false`. Akibatnya, saat aplikasi dibuka lagi, `_checkLogin()` **tidak** melompati halaman login. |
| `if (mounted)` | Pastikan halaman masih tampil setelah `await`. |
| `Navigator.pushAndRemoveUntil(..., (route) => false)` | Pindah ke `LoginScreen` **dan hapus semua halaman sebelumnya** dari tumpukan navigasi. `(route) => false` artinya "jangan sisakan satu halaman pun". Jadi user tidak bisa menekan back untuk kembali ke Home. |

> Logout **tidak menghapus** data to-do di Hive. Setelah login lagi, to-do lama masih ada.

**Kode lengkap `lib/screens/home_screen.dart` setelah Step 12–16 digabung:**

```dart
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
              return const Center(
                child: Text('Belum ada to-do. Tekan + untuk menambah.'),
              );
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
```

> Di modul (Contoh program 6.19) ada `dispose()` yang isinya hanya `super.dispose();`. Karena tidak ada controller di halaman ini, method itu tidak berpengaruh apa-apa, jadi di project ini tidak ditulis. Boleh ditambahkan kalau ingin sama persis dengan modul.

Tampilannya seperti **Gambar 6.4** di modul: AppBar ungu "Todo List App" dengan ikon logout, daftar kartu to-do dengan ikon edit biru dan hapus merah, serta tombol + di kanan bawah.

---

### Step 17 — Mulai membuat add_todo_screen.dart

**File:** buat file baru `lib/screens/add_todo_screen.dart`

**Gunanya:** **satu halaman untuk dua fungsi** — menambah to-do baru (**Create**) dan mengedit to-do lama (**Update**). Halaman ini sengaja dibuat sederhana, yang penting CRUD-nya jalan.

---

### Step 18 — Import package di add_todo_screen.dart

**File:** `lib/screens/add_todo_screen.dart`

**Yang dikoding:**

```dart
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../models/todo.dart';
```

**Gunanya:**
- `material.dart` → widget UI.
- `hive/hive.dart` → `Hive.box<Todo>('todos')` untuk `add` dan `putAt`. Di halaman ini tidak butuh `.listenable()`, jadi cukup `hive`, tidak perlu `hive_flutter`.
- `../models/todo.dart` → untuk membuat object `Todo(...)`.

---

### Step 19 — Buat class AddTodoScreen (StatefulWidget)

**File:** `lib/screens/add_todo_screen.dart` (di bawah import)

**Yang dikoding:**

```dart
class AddTodoScreen extends StatefulWidget {
  const AddTodoScreen({super.key});

  @override
  State<AddTodoScreen> createState() => _AddTodoScreenState();
}

class _AddTodoScreenState extends State<AddTodoScreen> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
```

**Gunanya:** kerangka halaman form. Stateful karena ada dua `TextEditingController` dan variabel `_isEditMode` yang ditentukan di `initState()`.

> Setelah step ini, error `AddTodoScreen()` di FloatingActionButton Home hilang. Tapi `AddTodoScreen(index: ..., todo: ...)` di tombol edit masih merah karena constructor-nya belum punya parameter (ditambahkan di Step 21).

---

### Step 20 — Buat UI form tambah/edit

**File:** `lib/screens/add_todo_screen.dart`

**Yang dikoding:** ganti method `build` di `_AddTodoScreenState` (yang tadinya `Placeholder`) dengan:

```dart
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
```

> Setelah step ini `_isEditMode`, `titleController`, `subtitleController`, dan `widget.index` masih merah — semuanya dibuat di Step 21.

**Penjelasan:**

| Kode | Gunanya |
|---|---|
| `_isEditMode ? 'Edit Todo' : 'Add Todo'` | Operator ternary: judul AppBar berubah sesuai mode. |
| `TextField(controller: titleController)` | Input judul to-do. |
| `TextField(controller: subtitleController)` | Input keterangan to-do. |
| `final box = Hive.box<Todo>('todos');` | Ambil box yang sudah dibuka di `main.dart`. |
| `final newTodo = Todo(title: ..., subtitle: ...)` | Buat object `Todo` baru dari isi form. |
| `box.putAt(widget.index!, newTodo)` | **UPDATE** — timpa data di posisi `index` dengan data baru. `widget.index` = parameter yang dikirim dari Home. Tanda `!` artinya "saya yakin ini tidak null" (aman karena hanya dijalankan saat mode edit). |
| `box.add(newTodo)` | **CREATE** — tambahkan data baru di posisi paling akhir box. |
| `await` | Tunggu sampai data benar-benar tersimpan sebelum menutup halaman. |
| `if (context.mounted) Navigator.pop(context)` | Tutup halaman form dan kembali ke Home. Home langsung menampilkan data terbaru karena `ValueListenableBuilder` mendeteksi box berubah. |
| `_isEditMode ? 'Save' : 'Add'` | Teks tombol berubah sesuai mode. |

Tampilannya seperti **Gambar 6.5** di modul: AppBar ungu "Add Todo", dua kolom input Title dan Subtitle, dan tombol Add.

---

### Step 21 — Tambah variabel, initState, dispose (kode lengkap add_todo_screen.dart)

**File:** `lib/screens/add_todo_screen.dart`

#### 21a. Menambahkan variabel

**Di class `AddTodoScreen` (class luar)**, tambahkan dua parameter:

```dart
class AddTodoScreen extends StatefulWidget {
  final int? index; //tambahkan ini
  final Todo? todo; //tambahkan ini

  const AddTodoScreen({super.key, this.index, this.todo});

  @override
  State<AddTodoScreen> createState() => _AddTodoScreenState();
}
```

**Gunanya:**
- `index` → posisi to-do di box, dipakai untuk `putAt(index, ...)`.
- `todo` → data lama, dipakai untuk mengisi form saat edit.
- Keduanya bertipe **nullable (`?`)** dan tidak `required`, artinya **boleh tidak diisi**:
  - `AddTodoScreen()` → keduanya `null` → mode **tambah**.
  - `AddTodoScreen(index: index, todo: todo)` → keduanya terisi → mode **edit**.
- Setelah ini, error di tombol edit pada `home_screen.dart` hilang.

**Di class `_AddTodoScreenState`**, tambahkan tiga variabel di bagian atas:

```dart
  final titleController = TextEditingController();
  final subtitleController = TextEditingController();
  late bool _isEditMode;
```

**Gunanya:**
- `titleController` & `subtitleController` → membaca dan mengisi teks di kedua `TextField`.
- `late bool _isEditMode` → penanda mode. `late` artinya "nilainya diisi nanti (di `initState`), tapi pasti sebelum dipakai".

#### 21b. Menambahkan `initState()` & `dispose()`

```dart
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
```

**Penjelasan:**

| Kode | Gunanya |
|---|---|
| `_isEditMode = widget.index != null && widget.todo != null;` | Tentukan mode **sekali di awal**. Kalau `index` dan `todo` dikirim dari Home → `true` (edit), kalau tidak → `false` (tambah). `widget.` dipakai untuk mengakses parameter class luar dari dalam `State`. |
| `if (_isEditMode) { titleController.text = ...; }` | Saat mode edit, **form langsung terisi data lama** sehingga user tinggal mengubahnya. |
| `dispose()` | Membersihkan kedua controller saat halaman ditutup (mencegah memory leak). |

**Kenapa ditulis di `initState()`?** Karena halaman ini dipakai untuk dua hal (tambah & edit). `initState()` berjalan sekali di awal sebelum `build`, jadi mode sudah pasti diketahui sebelum UI digambar.

**Alternatif lebih ringkas (disebut di modul): pakai getter.** Hapus `late bool _isEditMode;` dan baris `_isEditMode = ...` di `initState`, lalu ganti dengan:

```dart
  bool get _isEditMode => widget.index != null && widget.todo != null;
```

Getter dihitung setiap kali dipanggil, jadi tidak perlu `late` dan tidak perlu diisi di `initState`.

**Kode lengkap `lib/screens/add_todo_screen.dart` setelah Step 17–21 digabung:**

```dart
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
```

**Selesai!** Sekarang semua error merah hilang dan aplikasi To-do List sudah lengkap: Shared Preferences untuk authentication, Hive untuk menyimpan data to-do dengan CRUD.

---

## Alur aplikasi dari awal sampai akhir

```
Buka aplikasi
  └─ main(): ensureInitialized → initFlutter → registerAdapter → openBox('todos') → runApp
        └─ LoginScreen.initState → _checkLogin()
              ├─ getBool('loginData') == true   → pushReplacement ke HomeScreen
              └─ false / null                    → tampil form login
                    └─ tekan Login → _login()
                          ├─ benar → setBool('loginData', true) → pushReplacement ke HomeScreen
                          └─ salah → SnackBar "Username atau password salah"

HomeScreen  (ValueListenableBuilder mendengarkan box 'todos')
  ├─ [+]       → AddTodoScreen()              → box.add(newTodo)          → pop → list auto update
  ├─ [✏️ edit] → AddTodoScreen(index, todo)   → box.putAt(index, newTodo) → pop → list auto update
  ├─ [🗑️ hapus] → box.deleteAt(index)                                      → list auto update
  └─ [logout]  → setBool('loginData', false) → pushAndRemoveUntil ke LoginScreen
```

Hubungan antar file:

```
main.dart ──home──▶ login_screen.dart ──login──▶ home_screen.dart ──+ / edit──▶ add_todo_screen.dart
    │                    ▲                            │                               │
    │                    └─────────logout─────────────┘                               │
    └── openBox('todos') ◀──── Hive.box('todos') dipakai oleh home & add_todo ────────┘
                         models/todo.dart (+ todo.g.dart) dipakai oleh semuanya
```

---

## Cara menguji

1. **Uji Shared Preferences:** login → **tutup paksa aplikasi** (swipe dari recent apps) → buka lagi. Hasil yang benar: langsung masuk Home tanpa login.
2. **Uji Hive (Create & persistensi):** tambah 2 to-do → tutup paksa → buka lagi. Hasil: kedua to-do masih ada.
3. **Uji Update:** tekan ikon edit → form sudah terisi data lama, judul "Edit Todo", tombol "Save" → ubah → Save. Hasil: kartu berubah.
4. **Uji Delete:** tekan ikon hapus. Hasil: kartu langsung hilang.
5. **Uji Logout:** tekan ikon logout → kembali ke login. Tekan tombol back HP → aplikasi keluar (tidak kembali ke Home). Buka lagi → muncul halaman login. Login lagi → to-do lama masih ada.
6. **Uji offline:** matikan internet/mode pesawat → semua fitur tetap jalan.

---

## Error yang sering muncul

| Error | Penyebab | Solusi |
|---|---|---|
| `Target of URI doesn't exist: 'package:hive/hive.dart'` | Belum `pub get` | Jalankan `flutter pub get` |
| `Undefined name 'TodoAdapter'` / `todo.g.dart` tidak ada | Belum generate | `dart run build_runner build --delete-conflicting-outputs` |
| `HiveError: Box not found. Did you forget to call Hive.openBox()?` | `Hive.box('todos')` dipanggil sebelum dibuka | Pastikan `await Hive.openBox<Todo>('todos')` ada di `main()` sebelum `runApp` |
| `HiveError: Cannot write, unknown type: Todo. Did you forget to register an adapter?` | Adapter belum didaftarkan | Tambahkan `Hive.registerAdapter(TodoAdapter())` sebelum `openBox` |
| `HiveError: There is already a TypeAdapter for typeId 0` | Dua class memakai `typeId` sama | Beri `typeId` unik per class |
| Error saat `pub get` di baris `dev dependencies` | Salah tulis | Gunakan `dev_dependencies:` |
| Konflik versi `hive_generator` / `build_runner` | Versi tidak cocok | Gunakan versi di `pubspec.yaml` ini, lalu `flutter pub get` |
| `MissingPluginException` (shared_preferences) | Package ditambah saat app sedang jalan | Stop aplikasi lalu `flutter run` ulang (jangan hot reload) |
| `Null check operator used on a null value` di halaman edit | `index`/`todo` tidak dikirim tapi dianggap mode edit | Pastikan tombol edit mengirim `AddTodoScreen(index: index, todo: todo)` |
| Data lama terbaca aneh setelah mengubah model | Nomor `@HiveField` / `typeId` diubah | Kembalikan nomornya, atau uninstall aplikasi untuk menghapus data lama |

---

Referensi project asli dari modul: https://github.com/AndiZirahitaf/modul_6_prak_mobile
