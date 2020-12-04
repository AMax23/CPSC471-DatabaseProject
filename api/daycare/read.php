<?php

/*
// Headers
header('Access-Control-Allow-Origin: *'); //
header('Content-Type: application/json'); // Accepts json

include_once '../../config/Database.php'; // Bring in database
include_once '../../models/Daycare.php'; // Bring in Daycare model

// Instantiate DB & connect
$database = new Database();
$db = $database->connect();


// Turn to JSON & output
echo "yooo";

 */

/*
$requestMethod = $_SERVER["REQUEST_METHOD"];
include('../../config/Database.php'); // Bring in database
$database = new Database();
$db = $database->connect();
switch($requestMethod) {
    case 'POST':
        echo 'hahaha';
        break;
    default:
        header("HTTP/1.0 405 Method Not Allowed");
        echo 'matata';
        break;
}

 */

header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include_once '../../config/Database.php'; // Bring in database

// Check if any paramters were passed and return that.
$daycareName = isset($_GET['DaycareName']) ? $_GET['DaycareName'] : die(); //why tho
$daycareAddress = isset($_GET['DaycareAddress']) ? $_GET['DaycareAddress'] : die();
$limit = isset($_GET['limit']) ? $_GET['limit'] : '10';
// Instantiate DB and connect
$database = new Database();
$db = $database->connect();
$database->authenticate("high");

// SQL statement to call the stored proc
// Positional paramaters. Act as placeholders.
$sql = 'CALL SelectDaycare(:daycareName,:daycareAddress)';
$limit = htmlspecialchars(strip_tags($limit));

// Prepare for execution of stored procedure
$stmt = $db->prepare($sql);

// Bind values
$stmt->bindParam(':daycareName', $daycareName);
$stmt->bindParam(':daycareAddress', $daycareAddress);

// Execute stored procedure
$stmt->execute();


$stmt->execute();

// Set response code - 200 OK
http_response_code(200);

// Returns all rows as an object
$numOfRecords = $stmt->rowCount();

if ($numOfRecords == 0) {
    $message = array('Message' => 'No reports available.');
    echo json_encode($message);
}
else if ($numOfRecords >= $limit) {
    // Set response code - 200 ok
    
    for ($x = 0; $x < $limit; $x++) {
        // Returns all rows as an object
        $conditionRows = $stmt->fetch(PDO::FETCH_OBJ);
        
        // Turn to JSON & output
        echo json_encode($conditionRows);                
    }
}

else 
{
    // Returns all rows as an object
    $conditionRows = $stmt->fetchAll(PDO::FETCH_OBJ);
    
    // Turn to JSON & output
    echo json_encode($conditionRows);
}


$stmt->closeCursor();





//$stmt->setFetchMode(PDO::FETCH_ASSOC);


// Instantiate daycare entitiy
//$daycare = new Daycare($db);

/*
// Get Daycare records
$stmt = $daycare->read();

// Returns all rows as an object
$daycareRows = $stmt->fetchAll(PDO::FETCH_OBJ);

// Turn to JSON & output
echo json_encode($daycareRows);

*/

/*
$data = array();
while($row = $stmt->fetch(PDO::FETCH_ASSOC)){
$data[] = $row['DaycareName'];
}

echo json_encode($data);

 */

/*
// Get row count
$numOfRecords = $stmt->rowCount();


// echo json_encode($numOfRecords);

// Check if there are any records in the table
if($numOfRecords > 0) {

    $daycareArr = array();
    $daycareArr["body"] = array();
    $daycareArr["itemCount"] = $numOfRecords;

    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)){

        extract($row);

        $e = array(
            "DaycareName" => $DaycareName,
            "DaycareAddress" => $DaycareAddress,
            "TotalNumOfCaretakers" => $TotalNumOfCaretakers,
        );

        array_push($daycareArr["body"], $e);
    }
    echo json_encode($daycareArr);
}

else {

    http_response_code(404);
    echo json_encode(
        array("message" => "No record found.")
    );
}
*/

?>