<html>
<!--
Performs hashtags comparision.

@author Piotr Jasinski <jasinskipiotr99@gmail.com>
-->
<body>
<?php
$limit = $_POST['limit'];
$user = $_POST['user'];
$password = $_POST['password'];


if (empty($limit)){
	$limit = 30;
}

function form($c){
	if ($c == 1)
		return " time";
	return " times";
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
$sql = "BEGIN hashtag_use_analysis(:limit, :cursor);END;";
$stmt = oci_parse($conn, $sql);

oci_bind_by_name($stmt, ":limit", $limit);
oci_bind_by_name($stmt, ":cursor", $cursor, -1, OCI_B_CURSOR);

oci_execute($stmt);
oci_execute($cursor);
echo "<b>List of " . $limit . " most frequently used hashtags: <br><br></b>";
while (($row = oci_fetch_array($cursor, OCI_ASSOC+OCI_RETURN_NULLS)) != false) {
    echo "#<b>"; echo $row['HASHTAG'], "</b> was used " ; echo "<b>". $row['USED']. "</b>". form($row['USED'])."<br />\n";
}

oci_free_statement($stmt);
oci_free_statement($cursor);
oci_close($conn);
?>
</body>
</html>
