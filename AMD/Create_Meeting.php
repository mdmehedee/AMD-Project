
<?php 
  include "inc/conn.php";
  include "inc/header.php";
?>
    <title>Create_Meeting</title>
</head>
<body>
<?php include "inc/nav.php"; date_default_timezone_set("Europe/Berlin");
echo '<div class="row">';
echo '<div class="col-2">';
include "inc/second_nav.php";
echo '</div>';
?>



<div class="col">
<br> <br>

<div class="container"> <br>
    <h1 style="background:teal; padding: 10px 10px; color:white;">Add New Meeting</h1>
    <br>
    <div class="card"><br>
    <form action="fsr_if_process.php" method="post" style="margin-left:400px;">
        <div class="form-group row">
            <label class="col-sm-2 col-form-label">Location</label>
            <div class="col-sm-3">
            <input type="text" class="form-control" name="inputPlace" placeholder="Meeting Place">
            </div>
        </div>
        <br>
        <div class="form-group row">
            <label class="col-sm-2 col-form-label">Begin</label>
            <div class="col-sm-3">
            <input type="datetime-local" class="form-control" name="inputStartTime">
            </div>
        </div>
        <br>
        <div class="form-group row">
            <label class="col-sm-2 col-form-label">End</label>
            <div class="col-sm-3">
            <input type="datetime-local" class="form-control" name="inputEndTime">
            </div>
        </div>
        <br>
        <div class="form-group row">
            <div class="col-sm-10">
            <button type="submit" name="add_meeting" class="btn btn-success">Create</button>
            </div>
        </div>
    </form>
</div>
</div>
</div>

<?php include "inc/footer.php"; ?>