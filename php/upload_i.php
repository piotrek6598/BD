<html>
<!--
Uploading new .json file interface.

@author Piotr Jasinski <jasinskipiotr99@gmail.com>
-->
<body>
Put the file in the: <b>C:\json_dir</b> directory and enter file's full name below.
<br>
Remember that only files coming from official <b>Twitter API Search</b> can be successfully uploaded.
</br>

<br><form action="upload.php" method="post" target="_blank">
File name: <input type="text" name="file"/>
<input id="user" type="hidden" name="user" value="<?php echo $_POST['user']?>"/>
<input id="password" type="hidden" name="password" value="<?php echo $_POST['password']?>"/>
<input type="submit" value="upload"/>
</form></br>

<form action="index.php" method="post">
<input type="submit" value="Back to home page"/>
</form>

</body>
</html>
