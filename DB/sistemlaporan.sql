-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Waktu pembuatan: 13 Mar 2025 pada 15.07
-- Versi server: 10.4.32-MariaDB
-- Versi PHP: 8.3.17

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `sistemlaporan`
--

-- --------------------------------------------------------

--
-- Struktur dari tabel `hasilanalisis`
--

CREATE TABLE `hasilanalisis` (
  `Hasil_id` int(11) NOT NULL,
  `Laporan_id` int(11) DEFAULT NULL,
  `Sentimen` enum('Positif','Negatif','Netral') DEFAULT NULL,
  `Prediksi_Kategori` varchar(255) DEFAULT NULL,
  `Tanggal_Analisis` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `laporan`
--

CREATE TABLE `laporan` (
  `Laporan_id` int(11) NOT NULL,
  `User_id` int(11) DEFAULT NULL,
  `Judul` varchar(255) NOT NULL,
  `Deskripsi` text NOT NULL,
  `Lokasi` varchar(255) NOT NULL,
  `Foto_Bukti` varchar(255) DEFAULT NULL,
  `Status` enum('Dikirim','Diproses','Selesai','Ditolak') DEFAULT 'Dikirim',
  `Tanggal_Buat` timestamp NOT NULL DEFAULT current_timestamp(),
  `Tanggal_Perbarui` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `roles`
--

CREATE TABLE `roles` (
  `Role_id` int(11) NOT NULL,
  `Role_name` enum('User','Petugas','Admin') NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `roles`
--

INSERT INTO `roles` (`Role_id`, `Role_name`) VALUES
(1, 'User'),
(2, 'Petugas'),
(3, 'Admin');

-- --------------------------------------------------------

--
-- Struktur dari tabel `tanggapan`
--

CREATE TABLE `tanggapan` (
  `Tanggapan_id` int(11) NOT NULL,
  `Laporan_id` int(11) DEFAULT NULL,
  `User_id` int(11) DEFAULT NULL,
  `Isi_Tanggapan` text NOT NULL,
  `Tanggal_Tanggapan` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Trigger `tanggapan`
--
DELIMITER $$
CREATE TRIGGER `Before_Insert_Tanggapan` BEFORE INSERT ON `tanggapan` FOR EACH ROW BEGIN
    DECLARE userRole VARCHAR(20);
    SELECT Role_name INTO userRole FROM Users u
    JOIN Roles r ON u.Role_id = r.Role_id
    WHERE u.User_id = NEW.User_id;
    
    IF userRole != 'Petugas' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Hanya petugas yang bisa memberikan tanggapan!';
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Struktur dari tabel `users`
--

CREATE TABLE `users` (
  `User_id` int(11) NOT NULL,
  `Role_id` int(11) DEFAULT NULL,
  `Nama` varchar(255) NOT NULL,
  `Email` varchar(255) NOT NULL,
  `Password` varchar(255) NOT NULL,
  `Tanggal_daftar` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Indexes for dumped tables
--

--
-- Indeks untuk tabel `hasilanalisis`
--
ALTER TABLE `hasilanalisis`
  ADD PRIMARY KEY (`Hasil_id`),
  ADD KEY `Laporan_id` (`Laporan_id`);

--
-- Indeks untuk tabel `laporan`
--
ALTER TABLE `laporan`
  ADD PRIMARY KEY (`Laporan_id`),
  ADD KEY `User_id` (`User_id`);

--
-- Indeks untuk tabel `roles`
--
ALTER TABLE `roles`
  ADD PRIMARY KEY (`Role_id`),
  ADD UNIQUE KEY `Role_name` (`Role_name`);

--
-- Indeks untuk tabel `tanggapan`
--
ALTER TABLE `tanggapan`
  ADD PRIMARY KEY (`Tanggapan_id`),
  ADD KEY `Laporan_id` (`Laporan_id`),
  ADD KEY `User_id` (`User_id`);

--
-- Indeks untuk tabel `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`User_id`),
  ADD UNIQUE KEY `Email` (`Email`),
  ADD KEY `Role_id` (`Role_id`);

--
-- AUTO_INCREMENT untuk tabel yang dibuang
--

--
-- AUTO_INCREMENT untuk tabel `hasilanalisis`
--
ALTER TABLE `hasilanalisis`
  MODIFY `Hasil_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `laporan`
--
ALTER TABLE `laporan`
  MODIFY `Laporan_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `roles`
--
ALTER TABLE `roles`
  MODIFY `Role_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT untuk tabel `tanggapan`
--
ALTER TABLE `tanggapan`
  MODIFY `Tanggapan_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `users`
--
ALTER TABLE `users`
  MODIFY `User_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- Ketidakleluasaan untuk tabel pelimpahan (Dumped Tables)
--

--
-- Ketidakleluasaan untuk tabel `hasilanalisis`
--
ALTER TABLE `hasilanalisis`
  ADD CONSTRAINT `hasilanalisis_ibfk_1` FOREIGN KEY (`Laporan_id`) REFERENCES `laporan` (`Laporan_id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `laporan`
--
ALTER TABLE `laporan`
  ADD CONSTRAINT `laporan_ibfk_1` FOREIGN KEY (`User_id`) REFERENCES `users` (`User_id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `tanggapan`
--
ALTER TABLE `tanggapan`
  ADD CONSTRAINT `tanggapan_ibfk_1` FOREIGN KEY (`Laporan_id`) REFERENCES `laporan` (`Laporan_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `tanggapan_ibfk_2` FOREIGN KEY (`User_id`) REFERENCES `users` (`User_id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `users_ibfk_1` FOREIGN KEY (`Role_id`) REFERENCES `roles` (`Role_id`) ON DELETE SET NULL;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
