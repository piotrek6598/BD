<html>
<?php

$user = "c##piotr1";
$password = "bdproject";

?>
<body>
<font size="6">
Welcome to twitter analyser.
</font>

<br><br>
<font size="4">
Upload new JSON data file or choose one of the following available analyse type. You can also remove all inserted previously data.
</font>
</br></br>

<form action="upload_i.php" method="post">
Upload file.
<input type="hidden" name="user" value="<?php echo $user; ?>"/>
<input type="hidden" name="password" value="<?php echo $password; ?>"/>
<input type="submit" value="upload"/>
</form>

<form action="compare_hashtags_i.php" method="post">
Compare hashtags use.
<input type="hidden" name="user" value="<?php echo $user; ?>"/>
<input type="hidden" name="password" value="<?php echo $password; ?>"/>

<input type="submit" value="compare"/>
</form>

<form action="hashtag_analyse_i.php" method="post">
Analyse use of hashtag in time intervals.
<input type="hidden" name="user" value="<?php echo $user; ?>"/>
<input type="hidden" name="password" value="<?php echo $password; ?>"/>
<input type="submit" value="analyse"/>
</form>

<form action="user_activity_i.php" method="post">
Analyse user's time activity.
<input type="hidden" name="user" value="<?php echo $user; ?>"/>
<input type="hidden" name="password" value="<?php echo $password; ?>"/>
<input type="submit" value="analyse"/>
</form>

<form action="user_full_i.php" method="post">
Get full raport about user activity.
<input type="hidden" name="user" value="<?php echo $user; ?>"/>
<input type="hidden" name="password" value="<?php echo $password; ?>"/>
<input type="submit" value="get report"/>
</form>

<form action="users_compare_i.php" method="post">
Compare twitter users.
<input type="hidden" name="user" value="<?php echo $user; ?>"/>
<input type="hidden" name="password" value="<?php echo $password; ?>"/>
<input type="submit" value="compare"/>
</form>

<form action="restart.php" method="post" target="_blank">
Remove all data.
<input type="hidden" name="user" value="<?php echo $user; ?>"/>
<input type="hidden" name="password" value="<?php echo $password; ?>"/>
<input type="submit" value="remove"/>

</body>
</html>