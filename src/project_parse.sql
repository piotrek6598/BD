-- Wrappers for inserting which prevents adding same information two times.

/* Procedure user_insert_or_update inserts new user or update user's informations.
   Followers_count_in setted as -1 avoid updating this field. In case of new users
   followers_count_in = 1 is equivalent to followers_count_in = 0.
   @param user_id_in[in]           - user id
   @param name_in[in]              - user's name
   @param followers_count_in[in]   - number of user's followers.
   */
CREATE OR REPLACE PROCEDURE users_insert_or_update (user_id_in in VARCHAR2, 
	name_in in VARCHAR2, followers_count_in in NUMBER)
IS
	user_in NUMBER;
BEGIN

-- checking if user exists in database
SELECT count(*)
INTO user_in
FROM users
WHERE users.user_id = user_id_in;

IF user_in = 0 THEN
	IF followers_count_in = -1 THEN
		INSERT INTO users VALUES (user_id_in, name_in, 0);
	ELSE
		INSERT INTO users VALUES (user_id_in, name_in, followers_count_in);
	END IF;
ELSIF followers_count_in > -1 THEN 
	UPDATE users SET followers_count = followers_count_in WHERE user_id = user_id_in;
END IF;

END;
/

/* Function time_insert inserts given date with next time id.
   Do nothing if date was already inserterted.
   @param data_in[in]   - date to be inserted.
   @return Id representing this date.
   */
CREATE OR REPLACE FUNCTION time_insert (data_in in VARCHAR2)
	RETURN NUMBER
IS
	time_in NUMBER;
	time_id1 NUMBER;
BEGIN

BEGIN
SELECT time_id
INTO time_id1
FROM time
WHERE time_data = data_in;
EXCEPTION
	WHEN NO_DATA_FOUND THEN time_id1 := 0;
END;

IF time_id1 = 0 THEN
	time_id1 := time_seq.nextval;
	INSERT INTO time VALUES (time_id1, data_in);
END IF;

RETURN time_id1;
END;
/

/* Procedure tweet_insert_or_update inserts new tweet or update number
   of retweets if tweet was already inserted.
   @param tweet_in[in]     - id of tweet;
   @param user_in[in]      - id of tweet's author;
   @param time_in[in]      - id of tweet's time;
   @param text_in[in]      - text of tweet;
   @param retweet_in[in]   - number of retweets.
   */
CREATE OR REPLACE PROCEDURE tweet_insert_or_update (tweet_in in VARCHAR2, 
	user_in in VARCHAR2, time_in in NUMBER, text_in in VARCHAR2, 
	retweet_in in NUMBER)
IS
	tweet_count NUMBER;
BEGIN

-- checking if tweet exists in database
SELECT count(*)
INTO tweet_count
FROM tweet
WHERE tweet_id = tweet_in;

IF tweet_count = 0 THEN
	INSERT INTO tweet VALUES (tweet_in, user_in, time_in, text_in, 	retweet_in);
ELSE 
	UPDATE tweet SET retweet_count = retweet_in WHERE tweet_in = tweet_id;
END IF;

END;
/

/* Procedure mention_insert inserts new mention
   @param user_in    - id of mentioned user;
   @param tweet_in   - id of tweet in which mention is enclosed.
   */
CREATE OR REPLACE PROCEDURE mention_insert (user_in in VARCHAR2,
	tweet_in in VARCHAR2)
IS
BEGIN
INSERT INTO mention VALUES (mention_seq.nextval, user_in, tweet_in);
END;
/

/* Function hashtag_insert insert new hashtag with next hashtag id.
   Do nothing if hashtag was already inserted.
   @param name_in[in]   - name of hashtag.
   @return id of hashtag.
   */
CREATE OR REPLACE FUNCTION hashtag_insert (name_in in VARCHAR2)
	RETURN NUMBER
IS
	id NUMBER;
BEGIN

-- checking if hashtag exists in database
BEGIN
SELECT hashtag_id
INTO id
FROM hashtag
WHERE name_in = name;
EXCEPTION
	WHEN NO_DATA_FOUND THEN id := 0;
END;

IF id = 0 THEN
	id := hashtag_seq.nextval;
	INSERT INTO hashtag VALUES (id, name_in);
END IF;

RETURN id;
END;
/

/* Procedure tweet_hashtag_insert inserts new usage of hashtag in tweet.
   @param tweet_in[in]     - id of tweet;
   @param hashtag_in[in]   - id of hashtag.
   */
CREATE OR REPLACE PROCEDURE tweet_hashtag_insert (tweet_in in VARCHAR2, 
	hashtag_in in NUMBER)
IS
BEGIN
INSERT INTO tweet_hashtag VALUES (tweet_in, hashtag_in);
END;
/


-- Twitter JSON file's parsers.
CREATE OR REPLACE FUNCTION parse_user (
	fid in utl_file.file_type)
	RETURN VARCHAR2
IS
	line VARCHAR2(2000);
	j NUMBER := 1;
	id VARCHAR2(30);
	screen_name VARCHAR2(15);
	followers_count NUMBER;
	posbeg NUMBER;
	posend NUMBER;
	id_lock NUMBER := 0;
	name_lock NUMBER := 0;
	followers_lock NUMBER := 0;
BEGIN
LOOP
utl_file.get_line(fid, line);

IF line like '%{%' THEN
	j := j + 1;
END IF;

IF line like '%"id"%' AND id_lock = 0 THEN 
	posbeg := INSTR(line, ':') + 2;
	posend := INSTR(line, ',') - 1;
	id := SUBSTR(line, posbeg, posend - posbeg + 1);
	id_lock := 1;
END IF;

IF line like '%"screen_name"%' AND name_lock = 0 THEN
	posbeg := INSTR(line, ':') + 3;
	posend := INSTR(line, ',') - 2;
	screen_name := SUBSTR(line, posbeg, posend - posbeg + 1);
	name_lock := 1;
END IF;

IF line like '%"followers_count"%' AND followers_lock = 0 THEN
	posbeg := INSTR(line, ':') + 2;
	posend := INSTR(line, ',') - 1;
	followers_count := TO_NUMBER(SUBSTR(line, posbeg, posend - posbeg + 1));
	followers_lock := 1;
END IF;

IF line like '%}%' THEN
	j := j - 1;
END IF;

EXIT WHEN j = 0;
END LOOP;

users_insert_or_update(id, screen_name, followers_count);

RETURN id;
END;
/

CREATE OR REPLACE PROCEDURE parse_hashtags (
	fid in utl_file.file_type, tweet_in in VARCHAR2)
IS
	line VARCHAR2(2000);
	j NUMBER := 1;
	text VARCHAR2(50);
	posbeg NUMBER;
	posend NUMBER;
	id NUMBER;
BEGIN

SELECT count(*)
INTO id
FROM tweet_hashtag
WHERE tweet_id = tweet_in;

IF id > 0 THEN
	RETURN;
END IF;

LOOP
utl_file.get_line(fid, line);

IF line like '%[%' THEN
	j := j + 1;
END IF;

IF line like '%"text"%' THEN
	posbeg := INSTR(line, ':') + 3;
	posend := INSTR(line, '",') - 1;
	text := SUBSTR(line, posbeg, posend - posbeg + 1);
	id := hashtag_insert(text);
	tweet_hashtag_insert(tweet_in, id);
END IF;

IF line like '%]%' THEN
	j := j - 1;
END IF;

EXIT WHEN j = 0;
END LOOP;
END;
/

CREATE OR REPLACE PROCEDURE parse_user_mentions (
	fid in utl_file.file_type, tweet_in in VARCHAR2)
IS
	line VARCHAR2(2000);
	screen_name VARCHAR2(15);
	id VARCHAR2(50);
	j NUMBER := 1;
	posbeg NUMBER;
	posend NUMBER;
	name_lock NUMBER := 0;
BEGIN

SELECT count(*)
INTO j
FROM mention
WHERE tweet_in = tweet_id;

IF j > 0 THEN
	RETURN;
ELSE
	j := 1;
END IF;

LOOP
utl_file.get_line(fid, line);

IF line like '%[%' THEN
	j := j + 1;
END IF;

IF line like '%"screen_name"%' AND name_lock = 0 THEN
	posbeg := INSTR(line, ':') + 3;
	posend := INSTR(line, '",') - 1;
	screen_name := SUBSTR(line, posbeg, posend - posbeg + 1);
	name_lock := 1;
END IF;

IF line like '%"id"%' THEN
	posbeg := INSTR(line, ':') + 2;
	posend := INSTR(line, ',') - 1;
	id := SUBSTR(line, posbeg, posend - posbeg + 1);
	users_insert_or_update(id, screen_name, -1);
	mention_insert(id, tweet_in);
	name_lock := 0;
END IF;

IF line like '%]%' THEN
	j := j - 1;
END IF;

EXIT WHEN j = 0;
END LOOP;
END;
/

CREATE OR REPLACE PROCEDURE parse_tweet (
	fid in utl_file.file_type)
IS
	line VARCHAR2(2000);
	j NUMBER := 1;
	id VARCHAR2(30);
	text VARCHAR2(200);
	created_at VARCHAR2(50);
	user_id VARCHAR2(20);
	posbeg NUMBER;
	posend NUMBER;
	retweet_count NUMBER := 0;
	time_id NUMBER;
	created_lock NUMBER := 0;
	id_lock NUMBER := 0;
	text_lock NUMBER := 0;
	retweet_lock NUMBER := 0;
BEGIN
LOOP
utl_file.get_line(fid, line);

IF line like '%{%' THEN
	j := j + 1;
END IF;

IF line like '%"created_at"%' AND created_lock = 0 THEN
	posbeg := INSTR(line, ':') + 3;
	posend := INSTR(line, '",') - 1;
	created_at := SUBSTR(line, posbeg, posend - posbeg + 1);
	created_lock := 1;
END IF;

IF line like '%"id"%' AND id_lock = 0 THEN
	posbeg := INSTR(line, ':') + 2;
	posend := INSTR(line, ',') - 1;
	id := SUBSTR(line, posbeg, posend - posbeg + 1);
	id_lock := 1;
END IF;

IF line like '%"text"%' AND text_lock = 0 THEN
	posbeg := INSTR(line, ':') + 3;
	posend := INSTR(line, '",') - 1;
	text := SUBSTR(line, posbeg, posend - posbeg + 1);
	text_lock := 1;
END IF;

IF line like '%"hashtags": [' THEN
	parse_hashtags(fid, id);
END IF;

IF line like '%"user_mentions": [' THEN
	parse_user_mentions(fid, id);
END IF;

IF line like '%"user": {' THEN
	user_id := parse_user(fid);
	j := j - 1;
END IF;

IF line like '%"retweeted_status": {' THEN
	parse_tweet(fid);
	j := j - 1;
END IF;

IF line like '%"retweet_count":%' AND retweet_lock = 0 THEN
	posbeg := INSTR(line, ':') + 2;
	posend := INSTR(line, ',') - 1;
	retweet_count := TO_NUMBER(SUBSTR(line, posbeg, posend - posbeg + 1));
	retweet_lock := 1;
END IF;

IF line like '%}%' THEN
	j := j - 1;
END IF;

EXIT WHEN j = 0;
END LOOP;

time_id := time_insert(created_at);

tweet_insert_or_update(id, user_id, time_id, text, 	retweet_count); 
END;
/

CREATE OR REPLACE PROCEDURE parse_json_file(file in VARCHAR2)
IS
	fid utl_file.file_type := utl_file.fopen('JSON_DIR', file, 'R');
	line VARCHAR2(2000);
BEGIN
utl_file.get_line(fid, line);

EXECUTE IMMEDIATE 'ALTER TABLE tweet_hashtag DISABLE CONSTRAINTS tweet_hashtag_tweet_id_fk';
EXECUTE IMMEDIATE 'ALTER TABLE mention DISABLE CONSTRAINTS mention_tweet_id_fk';

LOOP
utl_file.get_line(fid, line);

IF line like '%{%' THEN
	parse_tweet(fid);
END IF;

EXIT WHEN line like '%]%';
END LOOP;

utl_file.fclose(fid);

EXECUTE IMMEDIATE 'ALTER TABLE tweet_hashtag ENABLE CONSTRAINTS tweet_hashtag_tweet_id_fk';
EXECUTE IMMEDIATE 'ALTER TABLE mention ENABLE CONSTRAINTS mention_tweet_id_fk';
END;
/
