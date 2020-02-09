<html>
<body>

This type of analyse provides report about total use of hashtag divided into four 6-hours intervals. The first inteval starts from 00:00 GMT.
<br> Enter hashtag to get report. </br>

<br><form action="hashtag_analyse.php" method="post" target="_blank">
Hashtag # <input type="text" name="hashtag"/>
<input id="user" type="hidden" name="user" value="<?php echo $_POST['user']?>"/>
<input id="password" type="hidden" name="password" value="<?php echo $_POST['password']?>"/>
<input type="submit" value="get report"/>
</form></br>

<form action="index.php" method="post">
<input type="submit" value="Back to home page"/>
</form>
 

</body>
</html>
