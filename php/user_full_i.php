<html>
<body>

This report provides following information:<br><br>
<b>&rarr;</b> number of tweets <br>
<b>&rarr;</b> number of hashtags used <br>
<b>&rarr;</b> number of followers <br>
<b>&rarr;</b> number of user's mentions <br>
<b>&rarr;</b> number of times user was mentioned <br>
<b>&rarr;</b> user time activity <br><br>
Enter user's nickname to get report.</br>


<br><form action="user_full.php" method="post" target="_blank">
Nickname: <input type="text" name="name"/>
<input id="user" type="hidden" name="user" value="<?php echo $_POST['user']?>"/>
<input id="password" type="hidden" name="password" value="<?php echo $_POST['password']?>"/>
<input type="submit" value="get report"/>
</form></br>

<form action="index.php" method="post">
<input type="submit" value="Back to home page"/>
</form>
 

</body>
</html>

