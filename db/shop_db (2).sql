-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: May 01, 2025 at 10:48 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `shop_db`
--

-- --------------------------------------------------------

--
-- Table structure for table `products`
--

CREATE TABLE `products` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `price` decimal(10,2) NOT NULL,
  `image` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `products`
--

INSERT INTO `products` (`id`, `name`, `description`, `price`, `image`) VALUES
(1, 'รองเท้าผ้าใบชาย', 'รองเท้าผ้าใบชายสีขาว เหมาะสำหรับการใส่ในทุกโอกาส', 1200.00, 'URL'),
(2, 'รองเท้าผ้าใบหญิง', 'รองเท้าผ้าใบหญิงสีชมพู สวมใส่สบาย เหมาะสำหรับกิจกรรมกลางแจ้ง', 1300.00, 'URL'),
(3, 'รองเท้ากีฬา', 'รองเท้ากีฬาสำหรับวิ่ง มีความยืดหยุ่นสูง เหมาะสำหรับนักวิ่ง', 1500.00, 'URL'),
(4, 'รองเท้าหนังผู้ชาย', 'รองเท้าหนังผู้ชายสีน้ำตาล สำหรับใส่ในโอกาสทางการ', 2500.00, 'URL'),
(5, 'รองเท้าหนังผู้หญิง', 'รองเท้าหนังผู้หญิงสีดำ สำหรับใส่ในโอกาสทางการ', 2700.00, 'URL'),
(6, 'รองเท้าแตะชาย', 'รองเท้าแตะชายสีน้ำเงิน เหมาะสำหรับใส่ในบ้านหรือทะเล', 600.00, 'URL'),
(7, 'รองเท้าแตะหญิง', 'รองเท้าแตะหญิงสีม่วง สวมใส่สบาย เหมาะสำหรับการเดินเล่น', 650.00, 'URL');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `ID` int(11) NOT NULL,
  `name` varchar(70) NOT NULL,
  `address` varchar(120) NOT NULL,
  `phone` varchar(15) NOT NULL,
  `Username` varchar(50) NOT NULL,
  `Password` varchar(255) NOT NULL,
  `role` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `products`
--
ALTER TABLE `products`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`ID`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `products`
--
ALTER TABLE `products`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
