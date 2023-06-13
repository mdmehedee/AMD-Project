<?php 
  include "inc/conn.php";
  include "inc/header.php";
?>
    <title>Edit Study Group</title>
</head>
<body>
<?php include "inc/nav.php"; 
echo '<div class="row">';
echo '<div class="col-2">';
include "inc/second_nav.php";
echo '</div>';
?>



<div class="col">
    <div class="container">
        <div class="row">
            <h3 style="background:teal; padding: 10px 10px; color:white;">Edit Study Group </h3>
            <form class="card" action="student_process.php" method="post">
            <?php  
                if(isset($_POST['group_id']))
                {	 
                    $group_id = $_POST['group_id'];
                    $student_id = $_POST['owner'];;
                    echo "<input type='hidden' name= 'owner' value = ". $student_id . ">";
                    $sql = pg_query($db, "select * from edit_group($group_id);");
                    while($row = pg_fetch_row($sql)) {
                            echo "<input type='hidden' name= 'group_id' value = ". $row[0] . ">";
                            echo "<p>Topic: <input type='text' name='place' value=" . $row[2] . "></p><br>";
                            echo "<p>Description: <input type='textarea' name='details' value=" . $row[3] . "></p><br>";
                            echo "<p>Set Student Limit: <input type='text' name='limit' value=" . $row[4] . "></p><br>";
                            
                    }
                }
            ?>
            <input type="submit" name="update_study_group" value="Update">
            </form>
        </div>
    </div>
    </div>
<?php include "inc/footer.php"; ?>