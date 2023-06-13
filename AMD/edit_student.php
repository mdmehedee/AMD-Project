<?php 
  include "inc/conn.php";
  include "inc/header.php";
?>
    <title>Edit Student</title>
</head>
<body>
<?php include "inc/nav.php"; 

echo '<div class="row">';
echo '<div class="col-2">';
include "inc/second_nav.php";
echo '</div>';
?>



<div class="col">
<br>
    <div class="container">
    
        <div class="row">
            <h3 style="background:teal; padding: 10px 10px; color:white;">Edit Student Name</h3>
            <div class="card"><br>
            <form action="student_process.php" method="post"><br>
            <?php  
                if(isset($_POST['edit_student']))
                {	
                    $student_id = $_POST['edit_student'];
                    //echo "<input type='text' name= 'owner' value = ". $student_id . ">";
                    $sql = pg_query($db, "select * from edit_student($student_id);");
                    while($row = pg_fetch_row($sql)) {
                            echo "<input type='hidden' name= 'student_id' value = ". $row[0] . ">";
                            echo "<p>Student Name: <input type='text' class='form-control' name='student_name' value=" . $row[1] . "></p>";
                            
                    }
                }
            ?>
            <input type="submit" class="btn btn-outline-success" name="update_change_name" value="Update">
            </form>
        </div>
    </div>
    </div>
<?php include "inc/footer.php"; ?>