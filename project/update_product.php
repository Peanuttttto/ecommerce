<?php
include 'condb.php';

try {
    if ($_SERVER['REQUEST_METHOD'] == 'POST') {
        $data = json_decode(file_get_contents('php://input'), true);
        
        $id = $data['id'];
        $name = $data['name'];
        $description = $data['description'];
        $price = $data['price'];
        $image = $data['image'];

        $stmt = $conn->prepare("UPDATE products SET name = :name, description = :description, price = :price, image = :image WHERE id = :id");
        $stmt->bindParam(':id', $id);
        $stmt->bindParam(':name', $name);
        $stmt->bindParam(':description', $description);
        $stmt->bindParam(':price', $price);
        $stmt->bindParam(':image', $image);

        if ($stmt->execute()) {
            echo json_encode(["status" => "success", "message" => "Product updated successfully"]);
        } else {
            echo json_encode(["status" => "error", "message" => "Failed to update product"]);
        }
    }
} catch (PDOException $e) {
    echo json_encode(["status" => "error", "message" => $e->getMessage()]);
}
?>