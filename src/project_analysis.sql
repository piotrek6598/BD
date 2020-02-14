-- Functions and procedures returning sys_refcursor and/or other parameters
-- with result of querries that are necessary to provide analysis.

/* Procedure hashtag_use_analysis retrieves most frequently used hashtags.
   @param limit_in[in]   - maximal number of extracted hashtags, if not
                           specified setted to 30;
   @param rc[out]        - refcursor to table with hashtag's name and
                           number of uses ordered descending by number of uses.
   */
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

/* Function getHour retrieves hour from date.
   @param time_in[in]   - date.
   @return Retrieved hour from given date.
   */
CREATE OR REPLACE FUNCTION getHour (time_in in VARCHAR2)
	RETURN NUMBER
IS
BEGIN
RETURN TO_NUMBER(SUBSTR(time_in, 12, 2));
END;
/

/* Function get_tweets_in_time retrieves number of user's tweets divided
   into four 6-hours intervals starting from 00:00 GMT.
   @param name_in[in]   - user's nickname.
   @return Refcursor to table with interval's id and number of tweets.
   */
CREATE OR REPLACE FUNCTION get_tweets_in_time (name_in in VARCHAR2)
	RETURN SYS_REFCURSOR
IS
	rc SYS_REFCURSOR;
BEGIN

open rc FOR
	SELECT floor(getHour(time_data)/6.0) as interval, 
		count(*) as tweets
	FROM (
		SELECT time_id
		FROM tweet
		LEFT JOIN users
		ON users.user_id = tweet.user_id
		WHERE name = name_in) A
	LEFT JOIN time
	ON A.time_id = time.time_id
	GROUP BY floor(getHour(time_data)/6.0);

RETURN rc;
END;
/

/* Function get_hashtag_in_time retrieves number of uses given hashtag
   divided into four 6-hours intervals starting from 00:00 GMT.
   @param name_in[in]   - hashtag's name.
   @return Refcursor to table with interval's id and number of hashtag's uses.
   */
CREATE OR REPLACE FUNCTION get_hashtag_in_time (name_in in VARCHAR2)
	RETURN SYS_REFCURSOR
IS
	rc SYS_REFCURSOR;
BEGIN

open rc FOR
	SELECT floor(getHour(time_data)/6.0) as interval, 
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
	GROUP BY floor(getHour(time_data)/6.0);

RETURN rc;
END;
/

/* Procedure profile_time_analysis retrieves number of user's tweets divided
   into four 6-hours intervals starting from 00:00 GMT, total number of tweets
   and used hashtags. If user doesn't exist in database out parameters are empty.
   @param name_in[in]         - user's nickname;
   @param tweets_out[out]     - total number of user's tweets;
   @param hashtags_out[out]   - total number of used hashtags;
   @param rc[out]             - refcursor to table with interval's id and
                                number of tweets.
   */
CREATE OR REPLACE PROCEDURE profile_time_analysis (name_in in VARCHAR2, 
	tweets_out out NUMBER, hashtags_out out NUMBER, rc out SYS_REFCURSOR)
IS
	test NUMBER;
BEGIN

-- checking if user exist in database
SELECT count(*)
INTO test
FROM users
WHERE name = name_in;

IF test = 0 THEN
RETURN;
END IF;

-- retrieving total number of tweets
SELECT count(*)
INTO tweets_out
FROM tweet
LEFT JOIN users
ON users.user_id = tweet.user_id
WHERE name = name_in;

-- retrieving total number of used hashtags
SELECT count(*)
INTO hashtags_out
FROM tweet_hashtag
LEFT JOIN tweet
ON tweet.tweet_id = tweet_hashtag.tweet_id
WHERE user_id IN (
	SELECT user_id
	FROM users
	WHERE name = name_in);

rc := get_tweets_in_time(name_in);
END;
/

/* Procedure profile_full_analysis retrieves number of user's tweets divided
   into four 6-hours intervals starting from 00:00 GMT, total number of tweets,
   used hashtags, mentions, number of being mentioned and number of followers. 
   If user doesn't exist in database out parameters are empty.
   @param name_in[in]          - user's nickname;
   @param tweets_out[out]      - total number of user's tweets;
   @param hashtags_out[out]    - total number of used hashtags;
   @param mentions_out[out]    - total number of mentions;
   @param mentioned_out[out]   - total number of being mentioned;
   @param followers_out[out]   - total number of user's followers;
   @param rc[out]              - refcursor to table with interval's id
                                 and number of tweets.
   */
CREATE OR REPLACE PROCEDURE profile_full_analysis (name_in in VARCHAR2, 
	tweets_out out NUMBER, hashtags_out out NUMBER, mentions_out out NUMBER,
	mentioned_out out NUMBER, followers_out out NUMBER, rc out SYS_REFCURSOR)
IS
	test NUMBER;
BEGIN

-- checking if user exists in database
SELECT count(*)
INTO test
FROM users
WHERE name = name_in;

IF test = 0 THEN
RETURN;
END IF;

-- getting profile time analysis
profile_time_analysis(name_in, tweets_out, hashtags_out, rc);

-- extracting number of followers, mentions, being mentioned
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

/* Procedure compare_profile_analysis compares users by given aspect.
   Users are ordered descending by given @param priority_in. Number of extracted
   users is limited by @param limit_in.
   @param priority_in[in]   - aspect of comparision, possible are number of 
                              'tweets', used 'hashtags', 'mentions', 
                              being 'mentioned', 'followers', if not specified 
                              setted to 'tweets';
   @param limit_in[in]      - maximal number of extracted users, if not specified
                              setted to 30;
   @param rc[out]           - refcursor to table with user's nickname, total number
                              of tweets, used hashtags, mentions, mentioned,
                              followers ordered descending by @param priority_in.
   */
CREATE OR REPLACE PROCEDURE compare_profile_analysis (
	priority_in in VARCHAR2 DEFAULT 'tweets',limit_in in NUMBER DEFAULT 30, 
	rc out SYS_REFCURSOR)
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

/* Procedure hashtag_time_analysis retrieves number of hashtag's uses
   divided into four 6-hours intervals starting from 00:00 GMT.
   @param name_in[in]   - hashtag's name;
   @param rc[out]       - refcursor to table with interval's id and
                          number of hashtag's uses;
   @param total[out]    - total number of hashtag's uses.
   */
CREATE OR REPLACE PROCEDURE hashtag_time_analysis (
	name_in in VARCHAR2, rc out SYS_REFCURSOR, total out NUMBER)
IS
BEGIN

-- extracting total number of hashtag's uses
SELECT count(*)
INTO total
FROM tweet_hashtag
LEFT JOIN hashtag
ON tweet_hashtag.hashtag_id = hashtag.hashtag_id
WHERE name = name_in;

open rc FOR
	SELECT floor(getHour(time_data)/6.0) as interval, 
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
	GROUP BY floor(getHour(time_data)/6.0);

END;
/
