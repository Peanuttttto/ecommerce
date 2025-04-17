<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

include 'condb.php';

try {
    if ($_SERVER['REQUEST_METHOD'] == 'POST') {
        $data = json_decode(file_get_contents('php://input'), true);
        $first_name = $data['first_name'];
        $last_name = $data['last_name'];
        $address = $data['address'];
        $phone = $data['phone'];
        $username = $data['username'];
        $password = $data['password'];

        // ตรวจสอบว่า username ซ้ำหรือไม่
        $stmt = $conn->prepare("SELECT COUNT(*) FROM users WHERE username = :username");
        $stmt->bindParam(':username', $username);
        $stmt->execute();
        if ($stmt->fetchColumn() > 0) {
            echo json_encode(["status" => "error", "message" => "Username already exists"]);
            exit;
        }

        $hashed_password = password_hash($password, PASSWORD_DEFAULT);
        $role = 'user'; // ค่าเริ่มต้นสำหรับผู้ใช้ทั่วไป

        $stmt = $conn->prepare("INSERT INTO users (first_name, last_name, address, phone, username, password, role) 
                               VALUES (:first_name, :last_name, :address, :phone, :username, :password, :role)");
        $stmt->bindParam(':first_name', $first_name);
        $stmt->bindParam(':last_name', $last_name);
        $stmt->bindParam(':address', $address);
        $stmt->bindParam(':phone', $phone);
        $stmt->bindParam(':username', $username);
        $stmt->bindParam(':password', $hashed_password);
        $stmt->bindParam(':role', $role);

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