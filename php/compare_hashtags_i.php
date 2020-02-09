<html>
<body>

This type of analyse compares hashtags by number of uses.
<br> Enter the limit of most frequently used hashtags you want to receive. If you remain the field free, the default limit of <b>30</b> hashtags is used. </br>

<br><form action="compare_hashtags.php" method="post" target="_blank">
Limit: <input type="text" name="limit" size=3 maxsize=3/>
<input id="user" type="hidden" name="user" value="<?php echo $_POST['user']?>"/>
<input id="password" type="hidden" name="password" value="<?php echo $_POST['password']?>"/>
<input type="submit" value="get report"/>
</form></br>

<form action="index.php" method="post">
<input type="submit" value="Back to home page"/>
</form>
 

</body>
</html>