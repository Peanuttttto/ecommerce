<?php
// ปิดการแสดงข้อผิดพลาด PHP เพื่อไม่ให้รบกวน JSON
ini_set('display_errors', 0);
ini_set('display_startup_errors', 0);
error_reporting(0);

$servername = "localhost";
$username = "root";
$password = "";
$dbname = "shop_db";

// สร้างการเชื่อมต่อ
try {
    $conn = new PDO("mysql:host=$servername;dbname=$dbname", $username, $password);
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    $conn->exec("SET CHARACTER SET utf8");
} catch (PDOException $e) {
    // ส่ง JSON แทน HTML
    header('Content-Type: application/json');
    echo json_encode(["status" => "error", "message" => "Connection failed: " . $e->getMessage()]);
    exit;
}
?>