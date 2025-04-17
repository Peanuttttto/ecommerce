<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

include 'condb.php';

try {
    $stmt = $conn->prepare("SELECT id, first_name, last_name, address, phone, profile_image, username FROM users");
    $stmt->execute();
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

    $base_url = 'http://localhost/ecommerce/';
    foreach ($result as &$user) {
        if (!empty($user['profile_image'])) {
            $user['profile_image'] = $base_url . $user['profile_image'];
        }
    }

    echo json_encode($result);
} catch (PDOException $e) {
    echo json_encode(["status" => "error", "message" => $e->getMessage()]);
}
?>