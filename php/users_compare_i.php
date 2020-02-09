<html>
<body>

This type of analyse compares users by one of the following aspects: <br><br>
<b>&rarr;</b> number of tweets <br>
<b>&rarr;</b> number of hashtags <br>
<b>&rarr;</b> number of mentions <br>
<b>&rarr;</b> number of time user was mentioned <br>
<b>&rarr;</b> number of followers <br><br>
To get report choose aspect, comparision type and enter limit of users you want to receive.<br> Aspect comparision provides information for each user only about aspect, full comparision provides all other details too. <br>If you remain field default limit of <b>30</b> users is used.</br>

<br><form action="users_compare.php" method="post" target="_blank">
<input type="radio" name="priority" value="tweets" checked> tweets<br>
<input type="radio" name="priority" value="hashtags"> hashtags<br>
<input type="radio" name="priority" value="mentions"> mentions<br>
<input type="radio" name="priority" value="mentioned"> mentioned<br>
<input type="radio" name="priority" value="followers"> followers<br><br>
<input type="radio" name="details" value="aspect" checked> aspect comparision<br>
<input type="radio" name="details" value="full"> full comparision<br>
Limit: <input type="text" name="limit" size=3 maxsize=3>
<input id="user" type="hidden" name="user" value="<?php echo $_POST['user']?>"/>
<input id="password" type="hidden" name="password" value="<?php echo $_POST['password']?>"/>
<input type="submit" value="get report"/>
</form></br>

<form action="index.php" method="post">
<input type="submit" value="Back to home page"/>
</form>
 

</body>
</html>

