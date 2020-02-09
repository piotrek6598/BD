-- Functions and procedures returning sys_refcursor and/or other parameters
-- with result of querries that are necessary to provide analysis.
CREATE OR REPLACE PROCEDURE hashtag_use_analysis ( 
	limit_in in NUMBER DEFAULT 30, rc out SYS_REFCURSOR)
IS
BEGIN

open rc FOR 
	SELECT name as hashtag, used
	FROM (
		SELECT hashtag_id as id, count(*) as used
		FROM tweet_hashtag
		GROUP BY hashtag_id
		FETCH NEXT limit_in ROWS ONLY)
	LEFT JOIN hashtag
	ON hashtag_id = id
	ORDER BY used desc;

END;
/

CREATE OR REPLACE FUNCTION getHour (time_in in VARCHAR2)
	RETURN NUMBER
IS
BEGIN
RETURN TO_NUMBER(SUBSTR(time_in, 12, 2));
END;
/

CREATE OR REPLACE FUNCTION get_tweets_in_time (name_in in VARCHAR2)
	RETURN SYS_REFCURSOR
IS
	rc SYS_REFCURSOR;
BEGIN

open rc FOR
	SELECT round(getHour(time_data)/6.0) as interval, 
		count(*) as tweets
	FROM (
		SELECT time_id
		FROM tweet
		LEFT JOIN users
		ON users.user_id = tweet.user_id
		WHERE name = name_in) A
	LEFT JOIN time
	ON A.time_id = time.time_id
	GROUP BY round(getHour(time_data)/6.0);

RETURN rc;
END;
/

CREATE OR REPLACE FUNCTION get_hashtag_in_time (name_in in VARCHAR2)
	RETURN SYS_REFCURSOR
IS
	rc SYS_REFCURSOR;
BEGIN

open rc FOR
	SELECT round(getHour(time_data)/6.0) as interval, 
		count(*) as hashtags
	FROM (
		SELECT time_id
		FROM (
			SELECT tweet_id
			FROM tweet_hashtag
			LEFT JOIN hashtag
			ON tweet_hashtag.hashtag_id = hashtag.hashtag_id
			WHERE name = name_in) A
		LEFT JOIN tweet
		ON A.tweet_id = tweet.tweet_id ) B
	LEFT JOIN time
	ON time.time_id = B.time_id
	GROUP BY round(getHour(time_data)/6.0);

RETURN rc;
END;
/

CREATE OR REPLACE PROCEDURE profile_time_analysis (name_in in VARCHAR2, 
	tweets_out out NUMBER, hashtags_out out NUMBER, rc out SYS_REFCURSOR)
IS
	test NUMBER;
BEGIN

SELECT count(*)
INTO test
FROM users
WHERE name = name_in;

IF test = 0 THEN
RETURN;
END IF;

SELECT count(*)
INTO tweets_out
FROM tweet
LEFT JOIN users
ON users.user_id = tweet.user_id
WHERE name = name_in;

SELECT count(*)
INTO hashtags_out
FROM tweet_hashtag
LEFT JOIN tweet
ON tweet.tweet_id = tweet_hashtag.tweet_id
WHERE user_id IN (
	SELECT user_id
	FROM users
	WHERE name = name_in);

open rc FOR
	SELECT round(getHour(time_data)/6.0) as interval, 
		count(*) as tweets
	FROM (
		SELECT time_id
		FROM tweet
		LEFT JOIN users
		ON users.user_id = tweet.user_id
		WHERE name = name_in) A
	LEFT JOIN time
	ON time.time_id = A.time_id
	GROUP BY round(getHour(time_data)/6.0);

END;
/

CREATE OR REPLACE PROCEDURE profile_full_analysis (name_in in VARCHAR2, 
	tweets_out out NUMBER, hashtags_out out NUMBER, mentions_out out NUMBER,
	mentioned_out out NUMBER, followers_out out NUMBER, rc out SYS_REFCURSOR)
IS
	test NUMBER;
BEGIN

SELECT count(*)
INTO test
FROM users
WHERE name = name_in;

IF test = 0 THEN
RETURN;
END IF;

profile_time_analysis(name_in, tweets_out, hashtags_out, rc);

SELECT nvl(mentions, 0) mentions, nvl(mentioned, 0) mentioned, followers_count
INTO mentions_out, mentioned_out, followers_out
FROM users
LEFT JOIN (
	SELECT count(*) mentions, tweet.user_id
	FROM tweet
	RIGHT JOIN mention
	ON tweet.tweet_id = mention.tweet_id
	GROUP BY tweet.user_id) A
ON users.user_id = A.user_id
LEFT JOIN (
	SELECT count(*) mentioned, user_id
	FROM mention
	GROUP BY user_id) B
ON users.user_id = B.user_id
WHERE users.name = name_in;
END;
/


CREATE OR REPLACE PROCEDURE compare_profile_analysis (
	priority_in in VARCHAR2 DEFAULT 'tweets',limit_in in NUMBER DEFAULT 30, rc out SYS_REFCURSOR)
IS
BEGIN

open rc FOR
	SELECT name, nvl(tweets, 0) tweets, 
		nvl(mentions, 0) mentions, 
		nvl(mentioned, 0) mentioned, 
		nvl(hashtags, 0) hashtags,
		followers_count followers
	FROM users 
	LEFT JOIN (
		SELECT user_id, count(*) tweets 
		FROM tweet 
		GROUP BY user_id) A 
	ON users.user_id = A.user_id
	LEFT JOIN (
		SELECT tweet.user_id, count(*) mentions
		FROM tweet
		RIGHT JOIN mention
		ON tweet.tweet_id = mention.tweet_id
		GROUP BY tweet.user_id) B
	ON users.user_id = B.user_id
	LEFT JOIN (
		SELECT user_id, count(*) mentioned
		FROM mention
		GROUP BY user_id) C
	ON users.user_id = C.user_id
	LEFT JOIN (
		SELECT user_id, count(*) hashtags
		FROM tweet
		RIGHT JOIN tweet_hashtag
		ON tweet.tweet_id = tweet_hashtag.tweet_id
		GROUP BY user_id) D
	ON users.user_id = D.user_id
	ORDER BY CASE priority_in
		 WHEN 'mentions' THEN mentions 
		 WHEN 'mentioned' THEN mentioned
		 WHEN 'hashtags' THEN hashtags
		 WHEN 'followers' THEN followers 
		 ELSE tweets END desc
	FETCH NEXT limit_in ROWS ONLY;
END;
/

CREATE OR REPLACE PROCEDURE hashtag_time_analysis (
	name_in in VARCHAR2, rc out SYS_REFCURSOR, total out NUMBER)
IS
BEGIN

SELECT count(*)
INTO total
FROM tweet_hashtag
LEFT JOIN hashtag
ON tweet_hashtag.hashtag_id = hashtag.hashtag_id
WHERE name = name_in;

open rc FOR
	SELECT round(getHour(time_data)/6.0) as interval, 
		count(*) as hashtags
	FROM (
		SELECT time_id
		FROM (
			SELECT tweet_id
			FROM tweet_hashtag
			LEFT JOIN hashtag
			ON tweet_hashtag.hashtag_id = hashtag.hashtag_id
			WHERE name = name_in) A
		LEFT JOIN tweet
		ON tweet.tweet_id = A.tweet_id) B
	LEFT JOIN time 
	ON time.time_id = B.time_id
	GROUP BY round(getHour(time_data)/6.0);

END;
/
