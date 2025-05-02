<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

include 'condb.php';

try {
    if ($_SERVER['REQUEST_METHOD'] == 'POST') {
        $data = json_decode(file_get_contents('php://input'), true);
        $name = $data['name'];
        $address = $data['address'];
        $phone = $data['phone'];
        $username = $data['Username'];
        $password = $data['Password'];


        // ตรวจสอบว่า username ซ้ำหรือไม่
        $stmt = $conn->prepare("SELECT COUNT(*) FROM users WHERE Username = :Username");
        $stmt->bindParam(':Username', $username);
        $stmt->execute();
        if ($stmt->fetchColumn() > 0) {
            echo json_encode(["status" => "error", "message" => "Username already exists"]);
            exit;
        }

        $hashed_password = password_hash($password, PASSWORD_DEFAULT);
        $role = 'user'; // ค่าเริ่มต้นสำหรับผู้ใช้ทั่วไป

        $stmt = $conn->prepare("INSERT INTO users (name, address, phone, Username, Password) 
                               VALUES (name, :address, :phone, :Username, :Password)");
        $stmt->bindParam(':name', $name);
        $stmt->bindParam(':address', $address);
        $stmt->bindParam(':phone', $phone);
        $stmt->bindParam(':Username', $username);
        $stmt->bindParam(':Password', $hashed_password);

        if ($stmt->execute()) {
            echo json_encode(["status" => "success", "message" => "Signup successful"]);
        } else {
            echo json_encode(["status" => "error", "message" => "Failed to signup"]);
        }
    } else {
        echo json_encode(["status" => "error", "message" => "Invalid request method"]);
    }
} catch (PDOException $e) {
    echo json_encode(["status" => "error", "message" => $e->getMessage()]);
}
?>