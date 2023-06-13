<?php 
  include_once "inc/conn.php";
  include "inc/header.php";
?>
    <title>List Of hidden Meeting</title>
</head>
<body>
<?php include "inc/nav.php"; ?>
    <div class="container"><br><br>
    <h3 style="background:red; padding: 10px 10px; color:white;"> Remove hidden meeting only</h3><br>
    <form action="fsr_if_process.php" method="post">
    <table class="table table-bordered table-striped">
        <thead>
            <tr>
                <th scope="col">Id</th>
                <th scope="col">Location</th>
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
                echo "<td><button class='btn btn-danger' type= 'submit' name= 'delete_meeting' value= '$row[0]' >" . "Delete"  . "</button></td>";
            echo "</tr>";
        }
            ?>
        </tbody>
    </table>
    </form>   
    </div>
<?php include "inc/footer.php"; ?>