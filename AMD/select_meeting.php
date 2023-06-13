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
<div class="container">
    <h3>
    <?php 
        // if(isset($_POST['notification'])){
        //     echo "$_POST['inputNotify']"; 
        // }    
    ?>
    </h3>
    <form action="create_study_group.php" method="post">
    <h3 style="background:teal; padding: 10px 10px; color:white;">Select Meeting</h3><br>
    <table class="table table-bordered table-striped">
        <thead>
            <tr>
                <th scope="col">Id</th>
                <th scope="col">Location</th>
                <th scope="col">Begin</th>
                <th scope="col">End</th>
                <th> Action </th>
            </tr>
        </thead>
        <tbody>
        <?php 
        
        $results = pg_query($db, "select * from only_visible_meeting_list()");
        if(isset($_POST['submit']))
            {	 
                $suname=$_POST['username'];
                $spass=$_POST ['password'];
                    $sql= "select * from student_login('$suname','$spass')";
                    $result = pg_query($db, $sql);
                    while($row = pg_fetch_row($result))
                    {
                        $student_id = $row[0];
                    }
            }
        
        echo '<input type="hidden" name="inputStudent_id" value="'.$student_id.'">';
        if($student_id){
            while ($row = pg_fetch_row($results)) {
                echo "<tr>";
                echo  "<td> $row[0] </td>";
                echo  "<td> $row[1] </td>";
                echo  "<td> $row[2] </td>";
                echo  "<td> $row[3] </td>";
                echo "<td><button class='btn btn-outline-success' text-white'  type= 'submit' name= 'select_meeting' value= '$row[0]' >" . "Select"  . "</button></td>";
                echo "</tr>";
            }
        }
        else 
        {
          echo "Wrong username or password!!";
          header("Refresh:2; url= student_login.php");
        }
        ?>
        </tbody>
    </table>
    </form>   
</div>
</div>
<?php include "inc/footer.php"; ?>