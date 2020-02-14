<html>
<!--
User activity analysis interface.

@author Piotr Jasinski <jasinskipiotr99@gmail.com>
-->
<body>

This type of analysis provides total number of user's tweets and hashtags used. <br>Tweets are divided into four 6-hours intervals. First interval starts from 00:00 GMT.
<br> Enter user's nickname to get report. </br>

<br><form action="user_activity.php" method="post" target="_blank">
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
