<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

include 'condb.php';

try {
    $stmt = $conn->prepare("SELECT * FROM products");
    $stmt->execute();
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

    $base_url = 'http://localhost/ecommerce/';
    foreach ($result as &$product) {
        if (!empty($product['image'])) {
            $product['image'] = $base_url . $product['image'];
        }
    }

    // ส่ง JSON list เสมอ แม้ว่าจะว่าง
    echo json_encode($result ?: []);
} catch (PDOException $e) {
    // ส่ง JSON list ว่างถ้ามีข้อผิดพลาด
    echo json_encode([]);
}
?>