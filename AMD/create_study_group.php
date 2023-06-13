<?php 
  include "inc/conn.php";
  include "inc/header.php";
?>
    <title>Add Study Group</title>
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
    <h3 style="background:teal; padding: 10px 10px; color:white;">List of Study Group</h3><br>
    <div class="card"> <br>
    <form action="student_process.php" method="post">
        <div class="form-group row">
            <label class="col-sm-2 col-form-label">Student ID</label>
            <div class="col-sm-3">
            <?php
            if(isset($_POST['select_meeting']))
            {	 
                $student_id = $_POST['inputStudent_id'];
                echo "<input type='text' class='form-control' name='inputStudentId' value='$student_id' readonly>";
            }
            ?>
            </div>
        </div>
        <table class="table table-bordered table-striped">
        <thead>
            <tr>
            <th scope="col">Study Group id</th>
            <th scope="col">Topic</th>
            <th scope="col">Description</th>
            <th scope="col">student limit</th>
            <th scope="col">Location</th>
            <th scope="col">Begin</th>
            <th scope="col">End</th>
            <th scope="col">action</th>
            </tr>
        </thead>
        <tbody><br><br>
        <?php 
            if(isset($_POST['select_meeting']))
            {	 
                $meeting_id = $_POST['select_meeting'];
                //echo $meeting_id;
                $results = pg_query($db, "select * from get_all_study_groups($meeting_id)");
                
                
                while ($row = pg_fetch_row($results)) {
                    echo "<tr>";
                        echo  "<td> $row[0] </td>";
                        echo  "<td> $row[1] </td>";
                        echo  "<td> $row[2] </td>";
                        echo  "<td> $row[3] </td>";
                        echo  "<td> $row[4] </td>";
                        echo  "<td> $row[5] </td>";
                        echo  "<td> $row[6] </td>";
                        echo "<td><button class='btn btn-outline-success' type= 'submit' name= 'Join_group' value= '$row[0]' >" . "Join"  . "</button></td>";
                    echo "</tr>";
                }
            }
        
            ?>
        </tbody>
    </table> 
    </form>  
</div>
<br> <br>




<div class="container">
    <div class="row">
        
        <div class="col-6">
        <h1 style="background:teal; padding: 10px 10px; color:white;"> Group Activity</h1><br>
        
        <form action="student_process.php" method="post">
        <table class="table table-bordered table-striped">
            <thead>
                <tr>
                <th scope="col">Study Group Id</th>
                <th scope="col">Topic</th>
                <th scope="col">Description</th>
                <th scope="col">Action</th>
                </tr>
            </thead>
            <tbody>
        <?php
            if(isset($_POST['select_meeting']))
            {	 
                $student_id = $_POST['inputStudent_id'];
                echo "<input type='hidden' class='form-control' name='inputStudentId' value='$student_id' readonly>";
                $results = pg_query($db, "select * from already_joined_group($student_id)");
                $incoming_student_from_db= pg_query($db, "select group_owner($student_id)");
                $owner = 0; 
                while ($row = pg_fetch_row($incoming_student_from_db)) {
                    $owner = $row[0];
                } ?> <br> <?php 
                echo " Group Leader: $owner";
                if (!$results) {
                    echo "An error occurred.\n";
                    exit;
                } 
                ?> <br> <br><?php 
                while ($row = pg_fetch_row($results)) {
                    echo "<tr>";
                        echo  "<td> $row[0] </td>";
                        echo  "<td> $row[1] </td>";
                        echo  "<td> $row[2] </td>";
                        echo "<td><button class='btn btn-outline-danger' type= 'submit' name= 'Leave_group' value= '$row[0]' >" . "Leave"  . "</button></td>";
                        if( $student_id == $owner ){
                            echo "<input type='hidden' name= 'owner' value = ". $owner . ">";
                            echo "<td><button class='btn btn-outline-success' formaction='edit_study_group.php' type= 'submit' name= 'group_id' value= '$row[0]' >" . "Edit"  . "</button></td>";
                        }
                        
                    echo "</tr>";
                }
            }
        ?>
            </tbody>
        </table> 
        </form>
        </div>

        <div class="col-6">
        <h1 style="background:teal; padding: 10px 10px; color:white;">Create Study Group</h1>
        <br>
        <div class="card"> <br>
        <form action="student_process.php" method="post">
            <div class="form-group row">
                <label class="col-sm-4 col-form-label">Student ID</label>
                <div class="col-sm-6">
                <?php
                if(isset($_POST['select_meeting']))
                {	 
                    $student_id = $_POST['inputStudent_id'];
                    echo "<input type='text' class='form-control' name='inputStudentId' value='$student_id' readonly>";
                }
                ?>
                </div>
            </div>
            <br>
            <div class="form-group row">
                <label class="col-sm-4 col-form-label">Meeting ID</label>
                <div class="col-sm-6">
                <?php
                if(isset($_POST['select_meeting']))
                {	 
                    $meeting_id = $_POST['select_meeting'];
                    echo "<input type='text' class='form-control' name='inputMeetingId' value='$meeting_id' readonly>";
                }
                ?>
                </div>
            </div>
            <br>
            <div class="form-group row">
                <label class="col-sm-4 col-form-label">Topic</label>
                <div class="col-sm-6">
                <input type="text" class="form-control" name="inputTopic" required>
                </div>
            </div>
            <br>
            <div class="form-group row">
                <label class="col-sm-4 col-form-label">Description</label>
                <div class="col-sm-6">
                <input type="text" class="form-control" name="inputDescription" required>
                </div>
            </div>
            <br>
            <div class="form-group row">
                <label class="col-sm-4 col-form-label">Student Limit</label>
                <div class="col-sm-6">
                <input type="text" class="form-control" name="inputStudentLimit" required>
                </div>
            </div>
            <br>
            <div class="form-group row">
                <div class="col-sm-20">
                <button type="submit" name="add_study_group" class="btn btn-outline-success">Create</button>
                </div>
            </div>
        </form>
        </div>
        
    </div>
</div>
</div>
<br><br>
<?php include "inc/footer.php"; ?>

