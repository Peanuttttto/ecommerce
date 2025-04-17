<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

include 'condb.php';

try {
    if ($_SERVER['REQUEST_METHOD'] == 'POST') {
        $data = json_decode(file_get_contents('php://input'), true);
        $username = $data['username'] ?? '';
        $password = $data['password'] ?? '';

        if (empty($username) || empty($password)) {
            error_log("Login failed: Username or password is empty");
            echo json_encode(["status" => "error", "message" => "Username and password are required"]);
            exit;
        }

        $stmt = $conn->prepare("SELECT * FROM users WHERE username = :username");
        $stmt->bindParam(':username', $username);
        $stmt->execute();
        $user = $stmt->fetch(PDO::FETCH_ASSOC);

        if ($user) {
            error_log("User found: " . print_r($user, true));
            // ชั่วคราว: ข้ามการตรวจสอบรหัสผ่านเพื่อทดสอบ
            if ($username === 'admin' && $password === '123') {
                $role = 'admin';
                error_log("Login successful for admin with correct password, Role: $role");
            } else {
                $role = 'user';
                error_log("Login successful for admin but with wrong password, Role: $role");
            }
            echo json_encode(["status" => "success", "message" => "Login successful", "role" => $role]);
        } else {
            error_log("User not found: $username");
            echo json_encode(["status" => "error", "message" => "Invalid username or password"]);
        }
    } else {
        error_log("Invalid request method: " . $_SERVER['REQUEST_METHOD']);
        echo json_encode(["status" => "error", "message" => "Invalid request method"]);
    }
} catch (PDOException $e) {
    error_log("Database error: " . $e->getMessage());
    echo json_encode(["status" => "error", "message" => $e->getMessage()]);
}
?>