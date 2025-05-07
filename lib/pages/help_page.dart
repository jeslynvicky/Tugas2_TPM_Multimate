import 'package:flutter/material.dart';
import '../services/session_manager.dart';
import 'login_page.dart';

class HelpItem {
  final String title;
  final List<String> content;
  final IconData icon;

  HelpItem({
    required this.title,
    required this.content,
    required this.icon,
  });
}

class HelpPage extends StatelessWidget {
  final List<HelpItem> helpItems = [
    HelpItem(
      title: 'Cara Login',
      content: [
        '1. Masukkan username dan password yang telah diberikan.',
        '2. Username default adalah "admin" dan password default adalah "admin".',
        '3. Klik tombol login untuk masuk ke aplikasi.'
      ],
      icon: Icons.login,
    ),
    HelpItem(
      title: 'Melihat Anggota Kelompok',
      content: [
        '1. Pilih menu "Anggota" pada Button Bar.',
        '2. Klik tombol panah kanan dan kiri untuk melihat anggota yang lain.',
      ],
      icon: Icons.person,
    ),
    HelpItem(
      title: 'Menggunakan Stopwatch',
      content: [
        '1. Klik tombol "Mulai" untuk memulai stopwatch.',
        '2. Klik "Stop" untuk menghentikan.',
        '3. "Reset" untuk mengatur ulang stopwatch ke nol.',
        '4. "Putaran" untuk menyimpan waktu tiap sekali putaran.'
      ],
      icon: Icons.timer,
    ),
    HelpItem(
      title: 'Mengecek Jenis Bilangan',
      content: [
        '1. Masukkan bilangan yang ingin dicek pada kotak input.',
        '2. Klik tombol "Cek" untuk melihat jenis bilangan dari inputan.',
        '2. Aplikasi akan menampilkan jenis bilangan tersebut (prima, desimal, bulat, dll).'
      ],
      icon: Icons.numbers,
    ),
    HelpItem(
      title: 'Tracking LBS',
      content: [
        '1. Berikan izin lokasi pada aplikasi.',
        '2. Aplikasi akan melihat lokasi Anda saat ini pada peta.',
      ],
      icon: Icons.location_on,
    ),
    HelpItem(
      title: 'Konversi Waktu',
      content: [
        '1. Masukkan jumlah tahun pada kotak input.',
        '2. Klik "Konversi" untuk mengubahnya menjadi tahun, bulan, minggu, hari, jam, menit, dan detik.',
        '3. Hasil akan ditampilkan di bawah inputan.'
      ],
      icon: Icons.access_time,
    ),
    HelpItem(
      title: 'Rekomendasi Website',
      content: [
        '1. Pilih salah satu produk untuk menampilkan detail dari produk.',
        '2. User dapat klik icon hati dipojok kanan atas untuk manambahkan ke favourite.',
        '3. Klik pada button "Go To Store Page" untuk membuka link website.',
      ],
      icon: Icons.public,
    ),
    HelpItem(
      title: 'Logout',
      content: [
        'Klik icon logout di pojok kanan atas aplikasi dan konfirmasi untuk keluar dari akun Anda.',
      ],
      icon: Icons.logout,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Multi App',
          style: TextStyle(
            color: Colors.white, // Warna teks jadi putih
          ),
        ),
        backgroundColor: Color(0xFF6A11CB),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.logout,
              color: Colors.white, // Warna ikon jadi hitam
            ),
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFFE6E6FA)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 10),
              const Center(
                child: Text(
                  'Bantuan Penggunaan Aplikasi',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6A11CB),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: helpItems.length,
                  itemBuilder: (context, index) {
                    final item = helpItems[index];
                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ExpansionTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFF6A11CB),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(item.icon, color: Colors.white),
                        ),
                        title: Text(
                          item.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        backgroundColor: const Color(0xFFF8F3FF),
                        collapsedBackgroundColor: const Color(0xFFF8F3FF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide.none,
                        ),
                        collapsedShape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide.none,
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 8.0,
                            ),
                            child: Align(
                              alignment: Alignment
                                  .centerLeft, // pastikan teks benar-benar rata kiri
                              child: Text(
                                item.content.join("\n"),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              await SessionManager.logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
                (route) => false,
              );
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
