<html>
<!--
Performs hashtag's use analysis

@author Piotr Jasinski <jasinskipiotr99@gmail.com>
-->
<body>
<?php
$hashtag = $_POST['hashtag'];
$user = $_POST['user'];
$password = $_POST['password'];

if (empty($hashtag)){
	echo "Hashtag was't entered";
	exit;
}

function form($c){
	if ($c == 1)
		return " time";
	return " times";
}

function expandGroup($c){
	if ($c == 0)
		return "Between 00:00 and 05:59 hashtag was used ";
	if ($c == 1)
		return "Between 06:00 and 11:59 hashtag was used ";
	if ($c == 2)
		return "Between 12:00 and 17:59 hashtag was used ";
	return "Between 18:00 and 23:59 hashtag was used ";
}

$conn = oci_connect($user, $password);
if (!$conn) {
	$e = oci_error();
	echo "Connection to database failed.({$e['message'
	]})\n";
	echo "File was not uploaded";
	exit;
}

$cursor = oci_new_cursor($conn);
$sql = "BEGIN hashtag_time_analysis(:name, :cursor, :total);END;";
$stmt = oci_parse($conn, $sql);

oci_bind_by_name($stmt, ":name", $hashtag);
oci_bind_by_name($stmt, ":cursor",  $cursor, -1, OCI_B_CURSOR);
oci_bind_by_name($stmt, ":total", $total);

oci_execute($stmt);
oci_execute($cursor);

echo "#<b>" . $hashtag . "</b> was used <b> ". $total ." </b> " . form($total). "<br />\n";
while (($row = oci_fetch_array($cursor, OCI_ASSOC+OCI_RETURN_NULLS)) != false) {
	echo expandGroup($row['INTERVAL']). " <b>" . $row['HASHTAGS']. "</b>" . form($row['HASHTAGS']). "<br />\n";
}

oci_free_statement($stmt);
oci_free_statement($cursor);
oci_close($conn);

?>
</body>
</html>
