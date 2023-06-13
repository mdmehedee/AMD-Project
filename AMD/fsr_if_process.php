<?php
include 'inc/conn.php';
if(isset($_POST['add_meeting']))
{	 
    $place = $_POST['inputPlace'];
    $start_time = $_POST['inputStartTime'];
    $end_time = $_POST['inputEndTime'];
    $sql = "select add_meeting('$place', '$start_time', '$end_time', '0')";
    $result = pg_query($db, $sql);
    if ($result) {
        while ($row = pg_fetch_row($result)) {
            echo "$row[0]\n";
        }
        header("Location: fsr_if.php");
        exit();
    }
}
if(isset($_POST['delete_meeting']))
{	 
    $meeting_id = $_POST['delete_meeting'];
    $sql = "select remove_meeting('$meeting_id')";
    $result = pg_query($db, $sql);
    if ($result) {
        header("Location: fsr_if.php");
        exit();
    }
}
if(isset($_POST['update_change_meeting']))
{	 
    $meeting = $_POST['meeting_id'];
    echo $meeting;
    $place = $_POST['inputPlace'];
    $start = $_POST['inputStart'];
    $end = $_POST['inputEnd'];
    $status = $_POST['in_status'];
    $sql = "select update_meeting($meeting,'$place','$start','$end','$status')";
    $result = pg_query($db, $sql);
    if ($result) {
        header("Location: fsr_if.php");
        exit();
    }
}
if(isset($_POST['visible']))
{	 
    $meeting = $_POST['visible'];
    echo $meeting;
    $sql = "select update_meeting_status($meeting)";
    $result = pg_query($db, $sql);
    if ($result) {
        header("Location: fsr_if.php");
        exit();
    }
}
?>


<!-- <script type="text/javascript">
    document.getElementById('notify').submit(); // SUBMIT FORM
</script> -->