<?php

// Required HTTP headers
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Max-Age: 3600");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

include_once '../../config/Database.php'; // Bring in database

if ($_SERVER["REQUEST_METHOD"] != "POST") {
    // Set response code - 405 Method not allowed
    http_response_code(405);
    $message = array('Message' => 'Request method ' . $_SERVER["REQUEST_METHOD"] . ' not allowed.');
    echo json_encode($message);
    exit();
}

// Instantiate DB and connect
$database = new Database();
$db = $database->connect();
$database->authenticate("med");
// Get data that is gonna be in JSON format.
$data = json_decode(file_get_contents("php://input"));

// Check if any paramters were passed and return that else return an empty string.
$billId = !empty($data->BillId) ? $data->BillId : '';
$amountPending = !empty($data->AmountPending) ? $data->AmountPending : 0;
$paymentMethod = !empty($data->PaymentMethod) ? $data->PaymentMethod : NULL;

// SQL statement to call the stored proc. Positional paramaters - act as placeholders.
$sql = 'CALL PayBill(:billId, :paymentMethod, :amountPending)';

// Prepare for execution of stored procedure
$stmt = $db->prepare($sql);

// Clean up and sanitize data: remove html characters and strip any tags
$billId = htmlspecialchars(strip_tags($billId));
$amountPending = htmlspecialchars(strip_tags($amountPending));
$paymentMethod = !is_null($paymentMethod) ? htmlspecialchars(strip_tags($paymentMethod)) : NULL;

// Bind data
$stmt->bindParam(':billId', $billId);
$stmt->bindParam(':amountPending', $amountPending);
$stmt->bindParam(':paymentMethod', $paymentMethod);

// Validate request:

// Check if the data is empty
if (empty($billId)) {

    // Set response code - 400 bad request
    http_response_code(400);

    $message = array('Message' => 'Payment unsuccesfull. Data is incomplete.');
    echo json_encode($message);

    // Check data type
}else if ( !is_numeric($billId) || !is_numeric($amountPending) || ctype_digit($paymentMethod) ) {

    // Set response code - 400 bad request
    http_response_code(400);

    $message = array('Message' => 'Payment unsuccesfull. Data type is not correct.');
    echo json_encode($message);

    // Make sure that the input length matches model
}else if (strlen($billId) > 11 || strlen($amountPending) > 11 || strlen($paymentMethod) > 30) {

    // Set response code - 400 bad request
    http_response_code(400);

    $message = array('Message' => 'Payment unsuccesfull. Data length does not match the defined model.');
    echo json_encode($message);

}else {

    // Execute stored procedure
    try {
        $stmt->execute();
        // Set response code - 201 created
        http_response_code(200);

        $message = array('Message' => "Payment Succesfull.");
        echo json_encode($message);
    }
    catch(PDOException $exception) {
        // Set response code - 400 bad request
        // Show error if something goes wrong.
        http_response_code(400);
        $message = array('Message' => "Unable to create daycare. " . $exception->getMessage());
        echo json_encode($message);
    }
}
?>