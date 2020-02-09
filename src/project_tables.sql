-- Drops and creates all necessary tables and sequences.

DROP TABLE TWEET_HASHTAG;
DROP TABLE HASHTAG;
DROP TABLE MENTION;
DROP TABLE TWEET;
DROP TABLE TIME;
DROP TABLE USERS;
DROP SEQUENCE time_seq;
DROP SEQUENCE mention_seq;
DROP SEQUENCE hashtag_seq;

CREATE TABLE USERS
	(
	user_id VARCHAR2(30) NOT NULL,
	name VARCHAR2(50) NOT NULL,
	followers_count NUMBER NOT NULL,
	CONSTRAINTS USERS_user_id_pk PRIMARY KEY (user_id),
	CONSTRAINTS USERS_followers_count_check CHECK (followers_count >= 0),
	CONSTRAINTS USERS_name_unique UNIQUE (name)
	);

CREATE TABLE TIME
	(
	time_id NUMBER NOT NULL,
	time_data VARCHAR2(50) NOT NULL,
	CONSTRAINTS TIME_time_id_pk PRIMARY KEY (time_id),
	CONSTRAINTS TIME_time_id_check CHECK (time_id > 0)
	);

CREATE TABLE TWEET
	(
	tweet_id VARCHAR2(30) NOT NULL,
	user_id VARCHAR2(30) NOT NULL,
	time_id NUMBER NOT NULL,
	text VARCHAR2(200) NOT NULL,
	retweet_count NUMBER NOT NULL,
	CONSTRAINTS TWEET_tweet_id_pk PRIMARY KEY (tweet_id),
	CONSTRAINTS TWEET_user_id_fk FOREIGN KEY (user_id) REFERENCES users(user_id),
	CONSTRAINTS TWEET_time_id_fk FOREIGN KEY (time_id) REFERENCES time(time_id),
	CONSTRAINTS TWEET_tweet_id_check CHECK (tweet_id > 0)
	);

CREATE TABLE MENTION
	(
	mention_id NUMBER NOT NULL,
	user_id VARCHAR2(30) NOT NULL,
	tweet_id VARCHAR2(30) NOT NULL,
	CONSTRAINTS MENTION_mention_id_pk PRIMARY KEY(mention_id),
	CONSTRAINTS MENTION_user_id_fk FOREIGN KEY (user_id) REFERENCES users(user_id),
	CONSTRAINTS MENTION_tweet_id_fk FOREIGN KEY (tweet_id) REFERENCES tweet(tweet_id),
	CONSTRAINTS MENTION_mention_id_check CHECK (mention_id > 0)
	);

CREATE TABLE HASHTAG
	(
	hashtag_id NUMBER NOT NULL,
	name VARCHAR2(50) NOT NULL,
	CONSTRAINTS HASHTAG_hashtag_id_pk PRIMARY KEY(hashtag_id),
	CONSTRAINTS HASHTAG_hashtag_id_check CHECK (hashtag_id > 0)
	);

CREATE TABLE TWEET_HASHTAG
	(
	tweet_id VARCHAR2(30) NOT NULL,
	hashtag_id NUMBER NOT NULL,
	CONSTRAINTS TWEET_HASHTAG_tweet_id_fk FOREIGN KEY (tweet_id) 
		REFERENCES tweet(tweet_id),
	CONSTRAINTS TWEET_HASHTAG_hashtag_id_fk FOREIGN KEY (hashtag_id) 
		REFERENCES hashtag(hashtag_id)
	);

CREATE SEQUENCE time_seq
	MINVALUE 1
	MAXVALUE 1000000000
	START WITH 1
	INCREMENT BY 1
	NOCACHE;

CREATE SEQUENCE mention_seq
	MINVALUE 1
	MAXVALUE 1000000000
	START WITH 1
	INCREMENT BY 1
	NOCACHE;

CREATE SEQUENCE hashtag_seq
	MINVALUE 1
	MAXVALUE 1000000000
	START WITH 1
	INCREMENT BY 1
	NOCACHE;

CREATE OR REPLACE PROCEDURE remove_data
IS
BEGIN
DELETE FROM tweet_hashtag;
DELETE FROM hashtag;
DELETE FROM mention;
DELETE FROM tweet;
DELETE FROM time;
DELETE FROM users;
EXECUTE IMMEDIATE 'DROP SEQUENCE time_seq';
EXECUTE IMMEDIATE 'DROP SEQUENCE mention_seq';
EXECUTE IMMEDIATE 'DROP SEQUENCE hashtag_seq';
EXECUTE IMMEDIATE 'CREATE SEQUENCE time_seq
	MINVALUE 1
	MAXVALUE 1000000000
	START WITH 1
	INCREMENT BY 1
	NOCACHE';
EXECUTE IMMEDIATE '
CREATE SEQUENCE mention_seq
	MINVALUE 1
	MAXVALUE 1000000000
	START WITH 1
	INCREMENT BY 1
	NOCACHE';
EXECUTE IMMEDIATE '
CREATE SEQUENCE hashtag_seq
	MINVALUE 1
	MAXVALUE 1000000000
	START WITH 1
	INCREMENT BY 1
	NOCACHE';
END;
/