<?php
    $host           = "host = localhost";
    $port           = "port = 5432";
    $dbname         = "dbname = postgres";
    $credentials    = "user = postgres password = 1234";

    $db = pg_connect("$host $port $dbname $credentials");
    if(!$db) {
       echo"<script>console.log('Error : unable to open database\n')</script>";
    } else {
        echo"<script> console.log('Connect sucessfully')</script>";
    }
?>