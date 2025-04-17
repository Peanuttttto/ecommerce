<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

include 'condb.php';

try {
    if ($_SERVER['REQUEST_METHOD'] == 'POST') {
        $id = $_POST['id'];
        $first_name = $_POST['first_name'];
        $last_name = $_POST['last_name'];
        $address = $_POST['address'];
        $phone = $_POST['phone'];
        $username = $_POST['username'];
        $password = $_POST['password'];

        $profile_image = '';
        if (isset($_FILES['profile_image']) && $_FILES['profile_image']['error'] == 0) {
            $upload_dir = 'uploads/';
            if (!is_dir($upload_dir)) {
                mkdir($upload_dir, 0777, true);
            }

            $allowed_types = ['image/jpeg', 'image/png', 'image/gif'];
            $file_type = $_FILES['profile_image']['type'];
            if (!in_array($file_type, $allowed_types)) {
                echo json_encode(["status" => "error", "message" => "Invalid file type. Only JPEG, PNG, and GIF are allowed"]);
                exit;
            }

            $max_size = 5 * 1024 * 1024; // 5MB
            if ($_FILES['profile_image']['size'] > $max_size) {
                echo json_encode(["status" => "error", "message" => "File size exceeds 5MB limit"]);
                exit;
            }

            $file_ext = pathinfo($_FILES['profile_image']['name'], PATHINFO_EXTENSION);
            $file_name = 'user_' . $id . '_' . time() . '.' . $file_ext;
            $upload_path = $upload_dir . $file_name;

            if (move_uploaded_file($_FILES['profile_image']['tmp_name'], $upload_path)) {
                $profile_image = $upload_path;
            } else {
                echo json_encode(["status" => "error", "message" => "Failed to upload image. Check directory permissions and file size"]);
                exit;
            }
        }

        if (!empty($password)) {
            $hashed_password = password_hash($password, PASSWORD_DEFAULT);
            $stmt = $conn->prepare("UPDATE users SET first_name = :first_name, last_name = :last_name, address = :address, phone = :phone, profile_image = :profile_image, username = :username, password = :password WHERE id = :id");
            $stmt->bindParam(':password', $hashed_password);
        } else {
            $stmt = $conn->prepare("UPDATE users SET first_name = :first_name, last_name = :last_name, address = :address, phone = :phone, profile_image = :profile_image, username = :username WHERE id = :id");
        }

        $stmt->bindParam(':id', $id);
        $stmt->bindParam(':first_name', $first_name);
        $stmt->bindParam(':last_name', $last_name);
        $stmt->bindParam(':address', $address);
        $stmt->bindParam(':phone', $phone);
        $stmt->bindParam(':profile_image', $profile_image);
        $stmt->bindParam(':username', $username);

        if ($stmt->execute()) {
            echo json_encode(["status" => "success", "message" => "User updated successfully"]);
        } else {
            echo json_encode(["status" => "error", "message" => "Failed to update user in database"]);
        }
    } else {
        echo json_encode(["status" => "error", "message" => "Invalid request method"]);
    }
} catch (PDOException $e) {
    echo json_encode(["status" => "error", "message" => $e->getMessage()]);
}
?>