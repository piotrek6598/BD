<html>
<body>
<?php
$limit = $_POST['limit'];
$priority = $_POST['priority'];
$details = $_POST['details'];
$user = $_POST['user'];
$password = $_POST['password'];

if (empty($limit)){
	$limit = 30;
}

if (empty($priority)) {
	$priority = "tweets";
}

function form($c){
	if ($c == 1)
		return "";
	return "s";
}

$conn = oci_connect($user, $password);
if (!$conn) {
	$e = oci_error();
	echo "Connection to databse failed.({$e['message']})\n";
	exit;
}

$cursor = oci_new_cursor($conn);
$sql = "BEGIN compare_profile_analysis(:priority, :limit, :cursor);END;";
$stmt = oci_parse($conn, $sql);

oci_bind_by_name($stmt, ":priority", $priority);
oci_bind_by_name($stmt, ":limit", $limit);
oci_bind_by_name($stmt, ":cursor", $cursor, -1, OCI_B_CURSOR);

oci_execute($stmt);
oci_execute($cursor);

echo "<b> List of " . $limit . " users ordered by number of ";
if ($priority == "mentioned"){
	echo " being mentioned";
} else {
	echo $priority;
}
echo "<br><br></b>";

while (($row = oci_fetch_array($cursor, OCI_ASSOC+OCI_RETURN_NULLS)) != false) {
	if ($details == "full") {
	echo "User <b>" . $row['NAME'] . "</b> posted <b>" . $row['TWEETS'] . "</b> tweet" .
	form($row['TWEETS']) . " with <b>" . $row['HASHTAGS'] . "</b> hashtag" . form($row['HASHTAGS']) .
	", mentioned other users <b>" . $row['MENTIONS'] . "</b> time" . form($row['MENTIONS']) . 
	", was mentioned <b>" . $row['MENTIONED'] . "</b> time" . form($row['MENTIONED']) . " and has <b>". $row['FOLLOWERS']. "</b> follower". 
form($row['FOLLOWERS']) .".<br />\n";
	} else {
		echo "User <b>" . $row['NAME'] . "</b> ";
		switch ($priority){
			case "tweets":
				echo "posted <b>" . $row['TWEETS']. "</b> 				tweet" . form($row['TWEETS']);
				break;
			case "hashtags":
				echo "used <b>" . $row['HASHTAGS']. "</b> 				hashtag" . form ($row['HASHTAGS']);
				break;
			case "mentions":
				echo "mentioned other users <b>" . 					$row['MENTIONS'] . "</b> time" . 					form($row['MENTIONS']);
				break;
			case "mentioned":
				echo "was mentioned <b>" . 
				$row['MENTIONED'] . "</b> time" . 					form($row['MENTIONED']);
				break;
			case "followers":
				echo "has <b>" . $row['FOLLOWERS']. "</b> 				follower" . form($row['FOLLOWERS']);
				break;
		}
		echo "<br/ >\n";
	}
}

oci_free_statement($stmt);
oci_free_statement($cursor);
oci_close($conn);

?>
</body>
</html>