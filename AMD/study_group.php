<?php 
  include "inc/conn.php";
  include "inc/header.php";
?>
    <title>Study_Group</title>
</head>
<body>
<?php include "inc/nav.php"; 
echo '<div class="row">';
echo '<div class="col-2">';
include "inc/second_nav.php";
echo '</div>';
?>



<div class="col">

<div class="container"> <br>
    <h3 style="background: teal; padding: 10px 10px; color:white;">List of Study Group</h3> <br>
    <form action="student_process.php" method="post">
        <div class="form-group row">
           
            <div class="col-sm-3">
            <?php
            if(isset($_POST['select_meeting']))
            {	 
                $student_id = $_POST['inputStudent_id'];
                echo "<input type='hidden' class='form-control' name='inputStudentId' value='$student_id' readonly>";
            }
            ?>
            </div>
        </div>
        <table class="table table-bordered table-striped">
        <thead>
            <tr>
            <th scope="col">Study Group Id</th>
            <th scope="col">Meeting Id</th>
            <th scope="col">Topic</th>
            <th scope="col">Description</th>
            <th scope="col">Student limit</th>
            <th scope="col">Created on</th>
            <th scope="col">Status</th>
            <th scope="col">Action</th>
            </tr>
        </thead>
        <tbody>
        <?php 
        $results = pg_query($db, "select * from get_all_study_groups()");
        if (!$results) {
            echo "An error occurred.\n";
            exit;
        }
        
        while ($row = pg_fetch_row($results)) {
            echo "<tr>";
                echo  "<td> $row[0] </td>";
                echo  "<td> $row[1] </td>";
                echo  "<td> $row[2] </td>";
                echo  "<td> $row[3] </td>";
                echo  "<td> $row[4] </td>";
                echo  "<td> $row[5] </td>";
                echo  "<td> $row[6] </td>";
                echo "<td><button class='btn btn-outline-success text-black' type= 'submit' name= 'Join_group' value= '$row[0]' >" . "Join"  . "</button></td>";
            echo "</tr>";
        }
            ?>
        </tbody>
    </table> 
    </form>  
</div>
</div>
<?php include "inc/footer.php"; ?>