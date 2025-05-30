README - SISTEM DETEKSI WARNA UNTUK PENDERITA BUTA WARNA
=========================================================

-------
Nama  : Jonathan Chandra
NIM   : D121221004
Mata Kuliah: Visi Komputer - Semester Genap 2024/2025

Judul Proyek:
-------------
SISTEM DETEKSI WARNA BERBASIS RUANG WARNA HSV UNTUK MEMBANTU PENDERITA
ACHROMATOPSIA, DEUTERANOPIA, PROTANOPIA, DAN TRITANOPIA

Deskripsi Singkat:
------------------
Proyek ini merupakan aplikasi visi komputer berbasis MATLAB yang mampu mendeteksi dan
memberi label warna secara real-time dari sebuah video. Sistem ini dirancang khusus untuk
membantu penderita buta warna, baik parsial maupun total, dengan menampilkan teks warna
yang terdeteksi langsung di atas objek dalam video.

Fitur Utama:
------------
✓ Deteksi hingga 12 warna umum (merah, hijau, biru, kuning, oranye, ungu, pink, cyan, coklat, putih, hitam)
✓ Fokus pada warna-warna yang sulit dibedakan oleh penderita buta warna
✓ Maksimal 3 warna dominan per frame untuk menghindari informasi berlebih

Cara Menjalankan:
-----------------
1. Pastikan file video bernama `colours.mp4` atau `teswarna.mp4` sudah berada dalam folder kerja MATLAB.
2. Buka MATLAB dan arahkan ke folder tempat file script berada.
3. Jalankan script utama: `colorblind.m`
4. Sistem akan membuka jendela visualisasi dan menampilkan deteksi warna secara frame-by-frame.
5. Tekan Ctrl+C untuk menghentikan proses kapan saja.

Struktur File:
--------------
- `tugasakhir.m`       → Script utama sistem deteksi warna
- `colours.mp4`        → File video input 
- `teswarna.mp4`       → File video input 
- `README.txt`         → Dokumentasi proyek

Catatan Tambahan:
-----------------
- Sistem ini tidak menyimpan hasil ke dalam file video, namun dapat dimodifikasi
  untuk merekam output menggunakan `VideoWriter` jika diperlukan.
- Gunakan video dengan pencahayaan baik agar hasil segmentasi warna optimal.
- Rentang HSV untuk masing-masing warna telah disesuaikan secara eksperimen,
  namun bisa diedit langsung di dalam script jika dibutuhkan.
