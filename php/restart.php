<html>
<!--
Clears all data from database

@author Piotr Jasinski <jasinskipiotr99@gmail.com>
-->
<body>
<?php

$user = $_POST['user'];
$password = $_POST['password'];

$conn = oci_connect($user, $password);
if (!$conn) {
	$e = oci_error();
	echo "Connection to database failed.({$e['message'
	]})\n";
	echo "Data was not removed.";
	exit;
}

$sql = "BEGIN remove_data;END;";
$stmt = oci_parse($conn, $sql);

if (!oci_execute($stmt, OCI_DEFAULT)){
	oci_rollback($conn);
	echo "Removing data failed.";
	exit;
}

oci_commit($conn);
oci_free_statement($stmt);
oci_close($conn);
echo "Data was successfully removed.";

?>
</body>
</html>
