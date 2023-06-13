<?php 
  include "inc/conn.php";
  include "inc/header.php";
?>
    <title>List Of Meeting</title>
</head>
<body>
<?php include "inc/nav.php"; 
echo '<div class="row">';
echo '<div class="col-2">';
include "inc/second_nav.php";
echo '</div>';
?>



<div class="col">

    <div class="container"><br><br>
    <div class="row">
    <div class="col-6">
    
    <h3 style="background:teal; padding: 10px 10px; color:white;">Meeting Lists</h3><br>
    <form action="details_meeting.php" method="post">
    <table class="table table-bordered table-striped">
        <thead>
            <tr>
                <th scope="col">Id</th>
                <th scope="col">Meeting Location</th>
                <th scope="col">Begin</th>
                <th scope="col">End</th>
                <th scope="col">Action</th>
            </tr>
        </thead>
        <tbody>
        <?php 
        $result = pg_query($db, "select * from get_meeting_overview();");
        if (!$result) {
            echo "An error occurred.\n";
            exit;
        }
        
        while ($row = pg_fetch_row($result)) {
            echo "<tr>";
                echo  "<td> $row[0] </td>";
                echo  "<td> $row[1] </td>";
                echo  "<td> $row[2] </td>";
                echo  "<td> $row[3] </td>";
                
                echo "<td><button class='btn btn-outline-primary' formaction='edit_meeting.php' type= 'submit' name= 'edit_meeting' value= '$row[0]' >" . "Edit"  . "</button></td>";
                echo "<td><button class='btn btn-outline-info' type= 'submit' name= 'details_meeting' value= '$row[0]' >" . "Overview"  . "</button></td>";
                echo "</tr>";
        }
            ?>
        </tbody>
    </table>
    
    
    
    </form>   
    </div>
     <br><br>
   
    <div class="col-6">
    <h3 style="background:teal; padding: 10px 10px; color:white;">Remove hidden meeting only</h3> <br>
    <form action="fsr_if_process.php" method="post">
    <table class="table table-bordered table-striped">
        <thead>
            <tr>
                <th scope="col">Id</th>
                <th scope="col">Meeting Location</th>
                <th scope="col">Begin</th>
                <th scope="col">End</th>
                <th scope="col">Action</th>
            </tr>
        </thead>
        <tbody>
        <?php 
        $result = pg_query($db, "select * from only_hidden_meeting_list();");
        if (!$result) {
            echo "An error occurred.\n";
            exit;
        }
        
        while ($row = pg_fetch_row($result)) {
            echo "<tr>";
                echo  "<td> $row[0] </td>";
                echo  "<td> $row[1] </td>";
                echo  "<td> $row[2] </td>";
                echo  "<td> $row[3] </td>";
                echo "<td><button class='btn btn-outline-danger' type= 'submit' name= 'delete_meeting' value= '$row[0]' >" . "Delete"  . "</button></td>";
                echo "<td><button class='btn btn-outline-success' type= 'submit' name= 'visible' value= '$row[0]' >" . "Active"  . "</button></td>";
                echo "</tr>";
        }
            ?>
        </tbody>
    </table>
    </form>   
    </div>
    </div>
    </div>
    </div>
<?php include "inc/footer.php"; ?>