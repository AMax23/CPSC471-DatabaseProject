<?php

// Execute the sql script to set up the database (one time).
// Use  the  mysqli_query()  function to send the database script to the MySQL connection.

$servername = 'localhost';
$username = 'root';
$password = 'root';
$database = "";
$connection;

try {

    // Create connection
    $connection = new PDO('mysql:host=' . $servername . ';dbname=' . $database, $username, $password);
    // Set error mode. Get exception when we create queries in case something goes wrong
    $connection->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    echo 'Successfully connected to the database.';

}catch(PDOException $exception) {

    echo 'install.php: Failed to connect to MySQL: ' . $exception->getMessage();

}

$sql = file_get_contents(__DIR__ . '/database.sql');

$stmt = $connection->prepare($sql);

if ($stmt->execute()) echo 'Database and tables created successfully.';
else echo 'install.php: Could not create database.';

?>