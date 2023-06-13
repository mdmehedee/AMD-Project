<?php 
  include "inc/conn.php";
  include "inc/header.php";
?>
    <title>Edit Meeting</title>
</head>
<body>
<?php include "inc/nav.php"; echo '<div class="row">';
echo '<div class="col-2">';
include "inc/second_nav.php";
echo '</div>';
?>



<div class="col">
<br>
    <div class="container">
        <div class="row">
        
            <h3 style="background:teal; padding: 10px 10px; color:white;">Update Selected Meeting </h3><br><br>
            <form action="fsr_if_process.php" method="post"><br>
            <?php  
                if(isset($_POST['edit_meeting']))
                {	
                    $meeting_id = $_POST['edit_meeting'];
                    $sql = pg_query($db, "select * from edit_meeting($meeting_id);");
                    while($row = pg_fetch_row($sql)) {
                            echo "<p>Meeting Id: <input type='text' name='meeting_id' class='form-control' value=" . $row[0] .  " readonly></p>";
                            echo "<p>Location: <input type='text' name='inputPlace' class='form-control' value=" . $row[1] . "></p>";
                            $stime = date('Y-m-d\TH:i', strtotime($row[2]));
                            $etime = date('Y-m-d\TH:i', strtotime($row[3]));
                            echo "<p>Begin: <input type='datetime-local' class='form-control' name='inputStart' value=" . $stime ."></p>";
                            echo "<p>End: <input type='datetime-local' class='form-control' name='inputEnd' value=" . $etime . "></p>";
                            echo "Status: <input type='radio' name='in_status' value='t' checked = 'true'>Visible ";
                            echo "<input type='radio' name='in_status' value='f'>Hide</p>";
                           
                    }
                }
            ?>
            <input type="submit" class="button btn-secondary" name="update_change_meeting" value="Update">
            </form>
        </div>
    </div>
    </div>
<?php include "inc/footer.php"; ?>