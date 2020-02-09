# Project for Databases 2019/20 at MIMUW University of Warsaw

# Describtion

Database enables user to collect some information about twitter users and theirs activity. All informations are collected from Twitter API .json files. <br/>
Database abilities: <br/>
-> Uploading new .json file <br/>
-> Getting user's profile analysis containing summary of posted tweets, used hashtags, mentionied users, number of followers and time activity <br/>
-> Comparing users by number of posted tweets, used hashtags, mentioned other users, times being mentioned and number of followers <br/>
-> Getting hashtag's analysis containing summary of usage detailed in time's intervals <br/>
-> Comparing hashtags by number of being used <br/>
-> Reload database<br/>

# How to run database

To run database at any server you need to:

1. Create new user with privilege to create and update tables, sequences, function and procedures. <br/>
2. Create new path with CREATE OR REPLACE DIRECTORY JSON_DIR as 'path', where 'path' is place where .json files have to be stored. It is possible to create DIRECTORY with other name, but you have to change procedure parse_json_file in project_parse.sql file by substitute in section IS in function utl_file.fopen 'JSON_DIR' for new DIRECTORY name. <br/>
3. Give user privilege to read this directory. <br/>
4. Run scripts: project_tables.sql, project_parse.sql, project_analysis.sql <br/>
5. Place .php files at server. <br/>
6. In file index.php modify $user, $password to correct user's data. <br/>
7. Run index.php <br/>
