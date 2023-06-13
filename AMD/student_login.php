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
        <div class="row mt-5">
            <div class="col-2">
            
            </div>
            <div class="col-6 card" style="background:teal;">
            <h2 style="background:teal; padding: 10px 10px; color:white;">Student Login</h2>
            <form action = "select_meeting.php" method="post">
                <div class="form-group">
                    <label style="color:white;" for="name">Username: </label>
                    <input  class="form-control" id="username" placeholder="Enter Username" name="username"required>
                </div>
                <div class="form-group">
                    <label style="color:white;" for="password">Password:</label>
                    <input type="password" class="form-control" id="password" placeholder="Enter password" name="password" required>
                </div>
                

                <button type="submit" class=" my-3 btn btn-light " name="submit" class="btn btn-default" >Login</button>
                
            </form>
            </div>
            <div class="col-4">
            
            </div>
        </div>
    </div>
</div>
<?php include "inc/footer.php"; ?>