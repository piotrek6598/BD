<html>
<body>
<?php

$file_name = $_POST['file'];
$user = $_POST['user'];
$password = $_POST['password'];

$conn = oci_connect($user, $password);
if (!$conn) {
	$e = oci_error();
	echo "Connection to database failed.({$e['message'
	]})\n";
	echo "File was not uploaded";
	exit;
}
$sql = "BEGIN parse_json_file(:file);END;";
$stmt = oci_parse($conn, $sql);
oci_bind_by_name($stmt, ":file", $file_name);

if (!oci_execute($stmt, OCI_DEFAULT)){
	oci_rollback($conn);
	echo "Uploading file failed.";
	exit;
}

oci_commit($conn);
oci_free_statement($stmt);
oci_close($conn);
echo "File was successfully uploaded";
?>
</body>
</html>
